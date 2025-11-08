import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/habit_bloc.dart';
import '../bloc/config_bloc.dart';
import '../bloc/config_event.dart';
import '../bloc/config_state.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_tile_view.dart';
import '../widgets/calendar_view.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/add_habit_modal.dart';
import '../viewmodels/habit_calendar_viewmodel.dart';
import '../viewmodels/habit_view_data.dart';
import '../../../../app/shared/layout/responsive_layout.dart';
import '../../../../app/shared/utils/logger.dart';
import '../../../../app/shared/widgets/loading_overlay.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/app_config.dart';

/// Refactored HomePage using unified MVVM architecture
class HomePageRefactoredFixed extends StatefulWidget {
  const HomePageRefactoredFixed({super.key});

  @override
  State<HomePageRefactoredFixed> createState() => _HomePageRefactoredFixedState();
}

class _HomePageRefactoredFixedState extends State<HomePageRefactoredFixed> {
  final Map<String, bool> _expandedCards = {};
  DateTime _currentMonth = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Add a small delay to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(const LoadHabits());
      context.read<ConfigBloc>().add(const LoadConfig());
    });
  }

  void _toggleCardExpansion(String habitId) {
    setState(() {
      _expandedCards[habitId] = !(_expandedCards[habitId] ?? false);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _showAddHabitModal() {
    AppLogger.i('Showing add habit modal', tag: 'HomePageRefactoredFixed');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHabitModal(),
    );
  }

  Widget _buildViewSwitcher() {
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, configState) {
        final viewModel = HabitCalendarViewModel(context);
        final currentViewType = configState is ConfigLoaded 
            ? configState.config.preferredView 
            : ViewType.calendar;
            
        return SegmentedButton<ViewType>(
          segments: const [
            ButtonSegment<ViewType>(
              value: ViewType.calendar,
              label: Text('Calendar'),
              icon: Icon(Icons.calendar_today),
            ),
            ButtonSegment<ViewType>(
              value: ViewType.tile,
              label: Text('Tiles'),
              icon: Icon(Icons.grid_view),
            ),
          ],
          selected: {currentViewType},
          onSelectionChanged: (Set<ViewType> newSelection) {
            final newViewType = newSelection.first;
            viewModel.switchView(newViewType);
            
            // If switching to tile view, load historical data
            if (newViewType == ViewType.tile) {
              viewModel.loadHistoricalData();
            }
          },
        );
      },
    );
  }

  Widget _buildTileView(HabitCalendarViewModel viewModel, HabitViewData viewData) {
    return RefreshIndicator(
      onRefresh: () async {
        viewModel.refreshData();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: viewData.habitTileData.length,
        itemBuilder: (context, index) {
          final tileData = viewData.habitTileData[index];
          final habitState = context.read<HabitBloc>().state;
          final isLoading = habitState is HabitLoaded && 
                           habitState.isMarkingCompletion && 
                           habitState.loadingHabitId == tileData.habit.id;
          
          return HabitTileView(
            habit: tileData.habit,
            todayEntry: tileData.todayEntry,
            historyEntries: tileData.historyEntries,
            onToggleCompletion: () => viewModel.markHabitCompleted(
              tileData.habit.id,
              !tileData.todayEntry.isCompleted,
            ),
            onDelete: () => viewModel.deleteHabit(tileData.habit.id),
            isLoading: isLoading,
            daysToShow: tileData.daysToShow,
            config: viewData.config,
          );
        },
      ),
    );
  }

  Widget _buildCalendarView(HabitCalendarViewModel viewModel, HabitViewData viewData) {
    return ResponsiveWidget(
      mobile: RefreshIndicator(
        onRefresh: () async {
          viewModel.refreshData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Calendar view
              CalendarView(
                currentMonth: _currentMonth,
                completionData: viewData.completionData,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
                onDaySelected: viewModel.selectDate,
                selectedDate: viewData.selectedDate,
              ),
              
              // Selected date's habits section
              Padding(
                padding: ResponsiveLayout.getPadding(context),
                child: Row(
                  children: [
                    // Navigation buttons
                    IconButton(
                      onPressed: viewModel.goToPreviousDay,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous day',
                    ),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            viewModel.isToday(viewData.selectedDate) 
                              ? "Today's Habits" 
                              : DateFormat('MMMM d, yyyy').format(viewData.selectedDate),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!viewModel.isToday(viewData.selectedDate))
                            Text(
                              viewModel.getRelativeDateText(viewData.selectedDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    IconButton(
                      onPressed: viewModel.goToNextDay,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next day',
                    ),
                  ],
                ),
              ),
              
              // Habit cards with swipe navigation
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity;
                  if (velocity != null && velocity < -100) {
                    // Swipe left - next day
                    viewModel.goToNextDay();
                  } else if (velocity != null && velocity > 100) {
                    // Swipe right - previous day
                    viewModel.goToPreviousDay();
                  }
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewData.habits.length,
                  itemBuilder: (context, index) {
                    final habit = viewData.habits[index];
                    final selectedDateEntry = viewData.selectedDateEntries.firstWhere(
                      (entry) => entry.habitId == habit.id,
                      orElse: () => HabitEntry(
                        id: '${habit.id}_${viewData.selectedDate.toIso8601String()}',
                        habitId: habit.id,
                        date: viewData.selectedDate,
                        isCompleted: false,
                      ),
                    );
                    
                    final habitState = context.read<HabitBloc>().state;
                    final isLoading = habitState is HabitLoaded && 
                                     habitState.isMarkingCompletion && 
                                     habitState.loadingHabitId == habit.id;
                    
                    return HabitCard(
                      habit: habit,
                      todayEntry: selectedDateEntry,
                      isExpanded: _expandedCards[habit.id] ?? false,
                      onToggleCompletion: () => viewModel.markHabitCompleted(
                        habit.id,
                        !selectedDateEntry.isCompleted,
                      ),
                      onToggleExpand: () => _toggleCardExpansion(habit.id),
                      onDelete: () => viewModel.deleteHabit(habit.id),
                      isLoading: isLoading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Tablet layout
      tablet: RefreshIndicator(
        onRefresh: () async {
          viewModel.refreshData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: ResponsiveLayout.getPadding(context),
            child: Column(
              children: [
                // Calendar view
                CalendarView(
                  currentMonth: _currentMonth,
                  completionData: viewData.completionData,
                  onPreviousMonth: _previousMonth,
                  onNextMonth: _nextMonth,
                  onDaySelected: viewModel.selectDate,
                  selectedDate: viewData.selectedDate,
                ),
                
                // Today's habits section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        viewModel.isToday(viewData.selectedDate) 
                          ? "Today's Habits" 
                          : DateFormat('MMMM d, yyyy').format(viewData.selectedDate),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${viewData.completedCount}/${viewData.habits.length}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Habit cards in grid for tablet with swipe navigation
                GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity;
                    if (velocity != null && velocity < -100) {
                      // Swipe left - next day
                      viewModel.goToNextDay();
                    } else if (velocity != null && velocity > 100) {
                      // Swipe right - previous day
                      viewModel.goToPreviousDay();
                    }
                  },
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: viewData.habits.length,
                    itemBuilder: (context, index) {
                      final habit = viewData.habits[index];
                      final selectedDateEntry = viewData.selectedDateEntries.firstWhere(
                        (entry) => entry.habitId == habit.id,
                        orElse: () => HabitEntry(
                          id: '${habit.id}_${viewData.selectedDate.toIso8601String()}',
                          habitId: habit.id,
                          date: viewData.selectedDate,
                          isCompleted: false,
                        ),
                      );
                      
                      final habitState = context.read<HabitBloc>().state;
                      final isLoading = habitState is HabitLoaded && 
                                       habitState.isMarkingCompletion && 
                                       habitState.loadingHabitId == habit.id;
                      
                      return HabitCard(
                        habit: habit,
                        todayEntry: selectedDateEntry,
                        isExpanded: _expandedCards[habit.id] ?? false,
                        onToggleCompletion: () => viewModel.markHabitCompleted(
                          habit.id,
                          !selectedDateEntry.isCompleted,
                        ),
                        onToggleExpand: () => _toggleCardExpansion(habit.id),
                        onDelete: () => viewModel.deleteHabit(habit.id),
                        isLoading: isLoading,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _switchToNextView(HabitCalendarViewModel viewModel) {
    final currentViewType = viewModel.currentViewType;
    final currentIndex = ViewType.values.indexOf(currentViewType);
    final nextIndex = (currentIndex + 1) % ViewType.values.length;
    final nextViewType = ViewType.values[nextIndex];
    
    viewModel.switchView(nextViewType);
    
    // If switching to tile view, load historical data
    if (nextViewType == ViewType.tile) {
      viewModel.loadHistoricalData();
    }
  }

  void _switchToPreviousView(HabitCalendarViewModel viewModel) {
    final currentViewType = viewModel.currentViewType;
    final currentIndex = ViewType.values.indexOf(currentViewType);
    final previousIndex = (currentIndex - 1 + ViewType.values.length) % ViewType.values.length;
    final previousViewType = ViewType.values[previousIndex];
    
    viewModel.switchView(previousViewType);
    
    // If switching to tile view, load historical data
    if (previousViewType == ViewType.tile) {
      viewModel.loadHistoricalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Daymark logo
            SvgPicture.asset(
              'assets/images/daymark_logo_lineart.svg',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('Daymark'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          _buildViewSwitcher(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitModal,
        child: const Icon(Icons.add),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ConfigBloc, ConfigState>(
            listener: (context, state) {
              if (state is ConfigLoaded) {
                final viewModel = HabitCalendarViewModel(context);
                
                // If switching to tile view, load historical data
                if (state.config.preferredView == ViewType.tile) {
                  viewModel.loadHistoricalData();
                }
              }
            },
          ),
        ],
        child: BlocBuilder<ConfigBloc, ConfigState>(
          builder: (context, configState) {
            return BlocBuilder<HabitBloc, HabitState>(
              builder: (context, habitState) {
            final viewModel = HabitCalendarViewModel(context);
            
            // Only show loading overlay for initial loading and refreshing
            final shouldShowLoadingOverlay = habitState.isLoading && 
                !(habitState is HabitLoaded && 
                  (habitState.isMarkingCompletion || 
                   habitState.isDeleting || 
                   habitState.isCreating));
            
            Widget content;
            
            if (habitState is HabitLoading && !habitState.isRefreshing) {
              content = const Center(child: CircularProgressIndicator());
            } else if (viewModel.hasError) {
              AppLogger.e(
                'HabitBloc error state encountered', 
                tag: 'HomePageRefactoredFixed', 
                error: viewModel.errorMessage,
                stackTrace: StackTrace.current,
              );
              content = DataLoadingErrorState(
                onRetry: () {
                  AppLogger.i('Retrying data load after error', tag: 'HomePageRefactoredFixed');
                  context.read<HabitBloc>().add(const LoadHabits());
                },
              );
            } else if (viewModel.hasNoHabits) {
              content = RefreshIndicator(
                onRefresh: () async {
                  viewModel.refreshData();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: NoHabitsEmptyState(
                      onCreateHabit: () {
                        AppLogger.i('Create habit action triggered from empty state', tag: 'HomePageRefactoredFixed');
                        _showAddHabitModal();
                      },
                    ),
                  ),
                ),
              );
            } else if (viewModel.viewData != null) {
              final viewData = viewModel.viewData!;
              
              if (viewModel.currentViewType == ViewType.tile) {
                content = _buildTileView(viewModel, viewData);
              } else {
                content = _buildCalendarView(viewModel, viewData);
              }
            } else {
              content = const Center(child: CircularProgressIndicator());
            }
            
            return GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity;
                if (velocity != null && velocity < -100) {
                  // Swipe left - go to next view
                  _switchToNextView(viewModel);
                } else if (velocity != null && velocity > 100) {
                  // Swipe right - go to previous view
                  _switchToPreviousView(viewModel);
                }
              },
              child: LoadingOverlay(
                isLoading: shouldShowLoadingOverlay,
                child: content,
              ),
            );
          },
            );
          },
        ),
      ),
    );
  }
}
