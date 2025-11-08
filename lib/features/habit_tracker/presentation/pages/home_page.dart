import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/config_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/config_event.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/config_state.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/habit_card.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/habit_tile_view.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/calendar_view.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/empty_state_widget.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/error_state_widget.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/add_habit_modal.dart';
import 'package:daymark/app/shared/layout/responsive_layout.dart';
import 'package:daymark/app/shared/utils/logger.dart';
import 'package:daymark/app/shared/widgets/loading_overlay.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Main home page with habit cards and calendar view
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, bool> _expandedCards = {};
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  ViewType _currentView = ViewType.calendar;
  
  // State tracking to prevent infinite loading loops
  bool _isLoadingHistoricalData = false;
  DateTime? _lastHistoricalDataLoad;
  final Duration _historicalDataDebounce = const Duration(seconds: 2);
  
  // Track which habits have historical data loaded to prevent duplicate loads
  final Set<String> _habitsWithHistoricalData = {};
  
  // Track completion-triggered reload cycles to prevent recursive calls
  bool _isCompletionReloadCycle = false;

  @override
  void initState() {
    super.initState();
    // Load initial data - habits and configuration
    AppLogger.i('Initializing home page - loading habits and config', tag: 'HomePage');
    _loadInitialData();
  }

  void _loadInitialData() {
    // Add a small delay to ensure the widget is fully built
    Future.delayed(const Duration(milliseconds: 100), () {
      context.read<HabitBloc>().add(const LoadHabits());
      context.read<ConfigBloc>().add(const LoadConfig());
      
      // If starting in tile view, load historical data
      if (_currentView == ViewType.tile && !_isLoadingHistoricalData) {
        _loadHistoricalData();
      }
    });
  }

  void _toggleCardExpansion(String habitId) {
    setState(() {
      _expandedCards[habitId] = !(_expandedCards[habitId] ?? false);
    });
  }

  void _markHabitCompleted(String habitId, bool isCompleted) {
    // Enhanced haptic feedback for better tactile experience
    if (isCompleted) {
      HapticFeedback.mediumImpact(); // More pronounced feedback for completion
    } else {
      HapticFeedback.lightImpact(); // Lighter feedback for uncompletion
    }
    
    AppLogger.i(
      'Marking habit completion: habitId=$habitId, isCompleted=$isCompleted, date=$_selectedDate', 
      tag: 'HomePage',
    );
    
    context.read<HabitBloc>().add(MarkHabitCompleted(
      habitId: habitId,
      isCompleted: isCompleted,
      date: _selectedDate,
    ));
  }

  void _deleteHabit(String habitId) {
    // Provide haptic feedback for deletion
    HapticFeedback.heavyImpact();
    
    AppLogger.i(
      'Deleting habit: habitId=$habitId', 
      tag: 'HomePage',
    );
    
    // Store the habit name for undo functionality
    final habitName = _getHabitNameById(habitId);
    
    context.read<HabitBloc>().add(DeleteHabit(
      habitId: habitId,
    ));
    
    // Show snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Habit "$habitName" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Note: Undo functionality would require storing the deleted habit
            // and restoring it. This is a placeholder for future enhancement.
            AppLogger.i('Undo deletion requested for habit: $habitId', tag: 'HomePage');
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _getHabitNameById(String habitId) {
    final state = context.read<HabitBloc>().state;
    if (state is HabitLoaded) {
      final habit = state.habits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => Habit(
          id: habitId,
          name: 'Unknown Habit',
          description: '',
          createdAt: DateTime.now(),
        ),
      );
      return habit.name;
    }
    return 'Unknown Habit';
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

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    AppLogger.i('Selected date: $date', tag: 'HomePage');
    context.read<HabitBloc>().add(LoadDateEntries(date: date));
  }

  void _goToPreviousDay() {
    final newDate = _selectedDate.subtract(const Duration(days: 1));
    setState(() {
      _selectedDate = newDate;
    });
    context.read<HabitBloc>().add(LoadDateEntries(date: newDate));
  }

  void _goToNextDay() {
    final newDate = _selectedDate.add(const Duration(days: 1));
    setState(() {
      _selectedDate = newDate;
    });
    context.read<HabitBloc>().add(LoadDateEntries(date: newDate));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    
    if (difference.inDays == -1) return 'Yesterday';
    if (difference.inDays == 1) return 'Tomorrow';
    if (difference.inDays < -1) return '${difference.inDays.abs()} days ago';
    if (difference.inDays > 1) return 'In ${difference.inDays} days';
    return '';
  }

  Future<void> _refreshData() async {
    AppLogger.i('Refreshing data via pull-to-refresh', tag: 'HomePage');
    
    // Trigger reload of habits - today's entries will be loaded automatically
    context.read<HabitBloc>().add(const LoadHabits());
    
    // If in tile view, reset historical data tracking and load fresh data
    if (_currentView == ViewType.tile && !_isLoadingHistoricalData) {
      _habitsWithHistoricalData.clear();
      _loadHistoricalData();
    }
    
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showAddHabitModal() {
    AppLogger.i('Showing add habit modal', tag: 'HomePage');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHabitModal(),
    );
  }

  void _switchView(ViewType viewType) {
    setState(() {
      _currentView = viewType;
    });
    // Save the preference
    context.read<ConfigBloc>().add(UpdateViewType(viewType));
    
    // If switching to tile view, reset historical data tracking and load fresh data
    if (viewType == ViewType.tile && !_isLoadingHistoricalData) {
      _habitsWithHistoricalData.clear();
      _loadHistoricalData();
    }
  }

  void _loadHistoricalData() {
    // Prevent duplicate loading within debounce period
    final now = DateTime.now();
    if (_isLoadingHistoricalData || 
        (_lastHistoricalDataLoad != null && 
         now.difference(_lastHistoricalDataLoad!) < _historicalDataDebounce)) {
      AppLogger.i('Skipping duplicate historical data load - _isLoadingHistoricalData=$_isLoadingHistoricalData, lastLoad=$_lastHistoricalDataLoad', tag: 'HomePage');
      return;
    }
    
    AppLogger.i('Starting historical data load - setting _isLoadingHistoricalData=true', tag: 'HomePage');
    _isLoadingHistoricalData = true;
    _lastHistoricalDataLoad = now;
    
    final endDate = now;
    
    // Get the config to determine how many weeks to display
    final configState = context.read<ConfigBloc>().state;
    final weeksToDisplay = configState is ConfigLoaded ? configState.config.weeksToDisplay : 2;
    final daysToLoad = weeksToDisplay * 7;
    
    final startDate = now.subtract(Duration(days: daysToLoad));
    
    AppLogger.i('Loading historical data from $startDate to $endDate (${daysToLoad} days)', tag: 'HomePage');
    
    // Load historical entries for tile view
    AppLogger.i('Dispatching LoadHistoricalEntries event to HabitBloc', tag: 'HomePage');
    context.read<HabitBloc>().add(LoadHistoricalEntries(
      startDate: startDate,
      endDate: endDate,
    ));
  }

  void _switchToNextView() {
    final currentIndex = ViewType.values.indexOf(_currentView);
    final nextIndex = (currentIndex + 1) % ViewType.values.length;
    _switchView(ViewType.values[nextIndex]);
  }

  void _switchToPreviousView() {
    final currentIndex = ViewType.values.indexOf(_currentView);
    final previousIndex = (currentIndex - 1 + ViewType.values.length) % ViewType.values.length;
    _switchView(ViewType.values[previousIndex]);
  }

  Widget _buildViewSwitcher() {
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
      selected: {_currentView},
      onSelectionChanged: (Set<ViewType> newSelection) {
        _switchView(newSelection.first);
      },
    );
  }

  Widget _buildTileView(
    List<Habit> habits,
    List<HabitEntry> selectedDateEntries,
    AppConfig? config,
    int daysToShow,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          AppLogger.i('TileView BlocBuilder triggered - state type: ${state.runtimeType}', tag: 'HomePage');
          
          // Use the current state as the single source of truth
          if (state is HabitLoaded) {
            final currentState = state;
            final currentHabits = currentState.habits;
            final currentSelectedDateEntries = currentState.selectedDateEntries;
            final historicalEntries = currentState.historicalEntries;
            
            AppLogger.i('TileView building with ${currentHabits.length} habits, ${currentSelectedDateEntries.length} selected date entries, ${historicalEntries.length} habits with historical data', tag: 'HomePage');
            
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: currentHabits.length,
              itemBuilder: (context, index) {
                final habit = currentHabits[index];
                final todayEntry = currentSelectedDateEntries.firstWhere(
                  (entry) => entry.habitId == habit.id,
                  orElse: () => HabitEntry(
                    id: '${habit.id}_${_selectedDate.toIso8601String()}',
                    habitId: habit.id,
                    date: _selectedDate,
                    isCompleted: false,
                  ),
                );
                
                // Get historical entries for this specific habit
                final habitHistoricalEntries = historicalEntries[habit.id] ?? [];
                
                // Check if this habit is currently being marked as completed
                final isLoading = currentState.isMarkingCompletion && 
                                 currentState.loadingHabitId == habit.id;
                
                AppLogger.i('Building tile for habit "${habit.name}" - historical entries: ${habitHistoricalEntries.length}, today completed: ${todayEntry.isCompleted}, isLoading: $isLoading', tag: 'HomePage');
                
                return HabitTileView(
                  habit: habit,
                  todayEntry: todayEntry,
                  historyEntries: habitHistoricalEntries,
                  onToggleCompletion: () => _markHabitCompleted(
                    habit.id,
                    !todayEntry.isCompleted,
                  ),
                  onDelete: () => _deleteHabit(habit.id),
                  isLoading: isLoading,
                  daysToShow: daysToShow * 7, // Convert weeks to days
                  config: config,
                );
              },
            );
          } else {
            // Show loading state if not in HabitLoaded state
            AppLogger.i('TileView showing loading state - current state: ${state.runtimeType}', tag: 'HomePage');
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCalendarView(
    List<Habit> habits,
    List<HabitEntry> selectedDateEntries,
    AppConfig? config,
  ) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        // Use the current state as the single source of truth
        if (state is HabitLoaded) {
          final currentState = state;
          final currentHabits = currentState.habits;
          final currentSelectedDateEntries = currentState.selectedDateEntries;
          
          // Create completion data for calendar from current state
          final completionData = <DateTime, int>{};
          for (final entry in currentSelectedDateEntries) {
            if (entry.isCompleted) {
              final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
              completionData[date] = (completionData[date] ?? 0) + 1;
            }
          }

          return ResponsiveWidget(
            mobile: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Calendar view
                    CalendarView(
                      currentMonth: _currentMonth,
                      completionData: completionData,
                      onPreviousMonth: _previousMonth,
                      onNextMonth: _nextMonth,
                      onDaySelected: _onDaySelected,
                      selectedDate: _selectedDate,
                    ),
                    
                    // Selected date's habits section
                    Padding(
                      padding: ResponsiveLayout.getPadding(context),
                      child: Row(
                        children: [
                          // Navigation buttons
                          IconButton(
                            onPressed: _goToPreviousDay,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous day',
                          ),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _isToday(_selectedDate) 
                                    ? "Today's Habits" 
                                    : DateFormat('MMMM d, yyyy').format(_selectedDate),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (!_isToday(_selectedDate))
                                  Text(
                                    _getRelativeDateText(_selectedDate),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          IconButton(
                            onPressed: _goToNextDay,
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
                          _goToNextDay();
                        } else if (velocity != null && velocity > 100) {
                          // Swipe right - previous day
                          _goToPreviousDay();
                        }
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentHabits.length,
                        itemBuilder: (context, index) {
                          final habit = currentHabits[index];
                          final selectedDateEntry = currentSelectedDateEntries.firstWhere(
                            (entry) => entry.habitId == habit.id,
                            orElse: () => HabitEntry(
                              id: '${habit.id}_${_selectedDate.toIso8601String()}',
                              habitId: habit.id,
                              date: _selectedDate,
                              isCompleted: false,
                            ),
                          );
                          
                          // Check if this habit is currently being marked as completed
                          final isLoading = currentState.isMarkingCompletion && 
                                           currentState.loadingHabitId == habit.id;
                          
                          return HabitCard(
                            habit: habit,
                            todayEntry: selectedDateEntry,
                            isExpanded: _expandedCards[habit.id] ?? false,
                            onToggleCompletion: () => _markHabitCompleted(
                              habit.id,
                              !selectedDateEntry.isCompleted,
                            ),
                            onToggleExpand: () => _toggleCardExpansion(habit.id),
                            onDelete: () => _deleteHabit(habit.id),
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
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: ResponsiveLayout.getPadding(context),
                  child: Column(
                    children: [
                      // Calendar view
                      CalendarView(
                        currentMonth: _currentMonth,
                        completionData: completionData,
                        onPreviousMonth: _previousMonth,
                        onNextMonth: _nextMonth,
                        onDaySelected: _onDaySelected,
                        selectedDate: _selectedDate,
                      ),
                      
                      // Today's habits section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              _isToday(_selectedDate) 
                                ? "Today's Habits" 
                                : DateFormat('MMMM d, yyyy').format(_selectedDate),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${currentSelectedDateEntries.where((e) => e.isCompleted).length}/${currentHabits.length}',
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
                            _goToNextDay();
                          } else if (velocity != null && velocity > 100) {
                            // Swipe right - previous day
                            _goToPreviousDay();
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
                          itemCount: currentHabits.length,
                          itemBuilder: (context, index) {
                            final habit = currentHabits[index];
                            final selectedDateEntry = currentSelectedDateEntries.firstWhere(
                              (entry) => entry.habitId == habit.id,
                              orElse: () => HabitEntry(
                                id: '${habit.id}_${_selectedDate.toIso8601String()}',
                                habitId: habit.id,
                                date: _selectedDate,
                                isCompleted: false,
                              ),
                            );
                            
                            // Check if this habit is currently being marked as completed
                            final isLoading = currentState.isMarkingCompletion && 
                                             currentState.loadingHabitId == habit.id;
                            
                            return HabitCard(
                              habit: habit,
                              todayEntry: selectedDateEntry,
                              isExpanded: _expandedCards[habit.id] ?? false,
                              onToggleCompletion: () => _markHabitCompleted(
                                habit.id,
                                !selectedDateEntry.isCompleted,
                              ),
                              onToggleExpand: () => _toggleCardExpansion(habit.id),
                              onDelete: () => _deleteHabit(habit.id),
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
        } else {
          // Show loading state if not in HabitLoaded state
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
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
                   setState(() {
                     _currentView = state.config.preferredView;
                   });
                   
                   // If switching to tile view, reset historical data tracking and load fresh data
                   if (state.config.preferredView == ViewType.tile && !_isLoadingHistoricalData) {
                     _habitsWithHistoricalData.clear();
                     _loadHistoricalData();
                   }
                 }
               },
             ),
              BlocListener<HabitBloc, HabitState>(
                listener: (context, state) {
                  if (state is HabitLoaded && _currentView == ViewType.tile) {
                    // Reset loading flag when historical data is loaded
                    if (_isLoadingHistoricalData) {
                      AppLogger.i('Historical data loading completed - resetting loading flag', tag: 'HomePage');
                      _isLoadingHistoricalData = false;
                      
                      // Update tracking of which habits have historical data
                      for (final habit in state.habits) {
                        if (state.historicalEntries.containsKey(habit.id) && 
                            state.historicalEntries[habit.id]!.isNotEmpty) {
                          _habitsWithHistoricalData.add(habit.id);
                        }
                      }
                      AppLogger.i('Updated historical data tracking: ${_habitsWithHistoricalData.length} habits have data', tag: 'HomePage');
                    }
                    
                    // Check if we need to load historical data for any habits
                    final habitsNeedingData = state.habits.where((habit) => 
                      !_habitsWithHistoricalData.contains(habit.id)
                    ).toList();
                    
                    // Only load historical data if we have habits that need it
                    // and we're not already loading it
                    if (habitsNeedingData.isNotEmpty && !_isLoadingHistoricalData) {
                      AppLogger.i('Found ${habitsNeedingData.length} habits needing historical data: ${habitsNeedingData.map((h) => h.name).toList()}', tag: 'HomePage');
                      _loadHistoricalData();
                    }
                   }
                   
                   // When habit completion is finished, reload historical data
                   // regardless of current view to ensure Tile view stays up-to-date
                   // Only reload if we're not in a completion reload cycle and not already loading data
                   if (state is HabitLoaded && 
                       !state.isMarkingCompletion && 
                       !_isLoadingHistoricalData &&
                       !_isCompletionReloadCycle) {
                     
                     AppLogger.i('Habit completion finished - triggering historical data reload for tile view sync', tag: 'HomePage');
                     
                     // Set flag to prevent recursive calls
                     _isCompletionReloadCycle = true;
                     
                     // Only reload if we have historical data that needs updating
                     // Use a small delay to ensure the state is stable
                     Future.delayed(const Duration(milliseconds: 100), () {
                       AppLogger.i('Delayed historical data reload starting for completion-triggered sync', tag: 'HomePage');
                       _loadHistoricalData();
                       
                       // Reset the completion reload cycle flag after a delay
                       Future.delayed(const Duration(milliseconds: 500), () {
                         _isCompletionReloadCycle = false;
                         AppLogger.i('Completion reload cycle reset - ready for next completion event', tag: 'HomePage');
                       });
                     });
                   }
                 },
              ),
         ],
        child: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            // Only show loading overlay for initial loading and refreshing
            // Individual habit operations (marking completion, deleting) should not trigger full overlay
            final shouldShowLoadingOverlay = state.isLoading && 
                !(state is HabitLoaded && 
                  (state.isMarkingCompletion || 
                   state.isDeleting || 
                   state.isCreating));
            
            Widget content;
            
            if (state is HabitLoading && !state.isRefreshing) {
              content = const Center(child: CircularProgressIndicator());
            } else if (state is HabitError) {
              AppLogger.e(
                'HabitBloc error state encountered', 
                tag: 'HomePage', 
                error: state.message,
                stackTrace: StackTrace.current,
              );
              content = DataLoadingErrorState(
                onRetry: () {
                  AppLogger.i('Retrying data load after error', tag: 'HomePage');
                  context.read<HabitBloc>().add(const LoadHabits());
                },
              );
            } else if (state is HabitLoaded) {
              final habits = state.habits;
              final selectedDateEntries = state.selectedDateEntries;
              
              // Check for empty habits
              if (habits.isEmpty) {
                content = RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: NoHabitsEmptyState(
                        onCreateHabit: () {
                          AppLogger.i('Create habit action triggered from empty state', tag: 'HomePage');
                          _showAddHabitModal();
                        },
                      ),
                    ),
                  ),
                );
              } else {
                // Build content based on current view type
                content = BlocBuilder<ConfigBloc, ConfigState>(
                  builder: (context, configState) {
                    final config = configState is ConfigLoaded ? configState.config : null;
                    final daysToShow = config?.weeksToDisplay ?? 2;
                    
                    if (_currentView == ViewType.tile) {
                      return _buildTileView(habits, selectedDateEntries, config, daysToShow);
                    } else {
                      return _buildCalendarView(habits, selectedDateEntries, config);
                    }
                  },
                );
              }
            } else {
              content = const Center(child: CircularProgressIndicator());
            }
            
             return GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity;
                  if (velocity != null && velocity < -100) {
                    // Swipe left - go to next view
                    _switchToNextView();
                  } else if (velocity != null && velocity > 100) {
                    // Swipe right - go to previous view
                    _switchToPreviousView();
                  }
                },
                child: LoadingOverlay(
                  isLoading: shouldShowLoadingOverlay,
                  child: content,
                ),
              );
          },
        ),
      ),
    );
  }
}