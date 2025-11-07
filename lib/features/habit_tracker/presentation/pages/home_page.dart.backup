import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/habit_card.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/calendar_view.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/empty_state_widget.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/error_state_widget.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/add_habit_modal.dart';
import 'package:daymark/app/shared/layout/responsive_layout.dart';
import 'package:daymark/app/shared/utils/logger.dart';
import 'package:daymark/app/shared/widgets/loading_overlay.dart';

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

  @override
  void initState() {
    super.initState();
    // Load initial data - only habits, today's entries will be loaded automatically
    AppLogger.i('Initializing home page - loading habits', tag: 'HomePage');
    context.read<HabitBloc>().add(const LoadHabits());
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

  String? _getLoadingText(HabitState state) {
    if (state is HabitLoading) {
      if (state.isMarkingCompletion) return 'Updating habit...';
      if (state.isDeleting) return 'Deleting habit...';
      if (state.isCreating) return 'Creating habit...';
      if (state.isRefreshing) return 'Refreshing...';
    } else if (state is HabitLoaded) {
      if (state.isMarkingCompletion) return 'Updating habit...';
      if (state.isDeleting) return 'Deleting habit...';
      if (state.isCreating) return 'Creating habit...';
      if (state.isRefreshing) return 'Refreshing...';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daymark'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitModal,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          final isLoading = state.isLoading;
          
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
            
            // Create completion data for calendar
            final completionData = <DateTime, int>{};
            for (final entry in selectedDateEntries) {
              if (entry.isCompleted) {
                final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
                completionData[date] = (completionData[date] ?? 0) + 1;
              }
            }
            
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
              content = ResponsiveWidget(
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
                            itemCount: habits.length,
                            itemBuilder: (context, index) {
                              final habit = habits[index];
                              final selectedDateEntry = selectedDateEntries.firstWhere(
                                (entry) => entry.habitId == habit.id,
                                orElse: () => HabitEntry(
                                  id: '${habit.id}_${_selectedDate.toIso8601String()}',
                                  habitId: habit.id,
                                  date: _selectedDate,
                                  isCompleted: false,
                                ),
                              );
                              
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
                                 isLoading: state is HabitLoaded && 
                                            (state as HabitLoaded).isMarkingCompletion && 
                                            (state as HabitLoaded).loadingHabitId == habit.id,
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
                                  '${selectedDateEntries.where((e) => e.isCompleted).length}/${habits.length}',
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
                              itemCount: habits.length,
                              itemBuilder: (context, index) {
                               final habit = habits[index];
                               final selectedDateEntry = selectedDateEntries.firstWhere(
                                 (entry) => entry.habitId == habit.id,
                                 orElse: () => HabitEntry(
                                   id: '${habit.id}_${_selectedDate.toIso8601String()}',
                                   habitId: habit.id,
                                   date: _selectedDate,
                                   isCompleted: false,
                                 ),
                               );
                               
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
                                   isLoading: state is HabitLoaded && 
                                              (state as HabitLoaded).isMarkingCompletion && 
                                              (state as HabitLoaded).loadingHabitId == habit.id,
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
          } else {
            content = const Center(child: CircularProgressIndicator());
          }
          
           return LoadingOverlay(
             isLoading: isLoading && !(state is HabitLoaded && (state as HabitLoaded).isMarkingCompletion),
             loadingText: _getLoadingText(state),
             child: content,
           );
        },
      ),
    );
  }
}
