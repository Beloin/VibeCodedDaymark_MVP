import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/habit_card.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/calendar_view.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/empty_state_widget.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/error_state_widget.dart';
import 'package:daymark/app/shared/layout/responsive_layout.dart';
import 'package:daymark/app/shared/utils/logger.dart';

/// Main home page with habit cards and calendar view
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, bool> _expandedCards = {};
  DateTime _currentMonth = DateTime.now();

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
    // Add haptic feedback for better tactile experience
    if (isCompleted) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    
    AppLogger.i(
      'Marking habit completion: habitId=$habitId, isCompleted=$isCompleted', 
      tag: 'HomePage',
    );
    
    context.read<HabitBloc>().add(MarkHabitCompleted(
      habitId: habitId,
      isCompleted: isCompleted,
    ));
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

  Future<void> _refreshData() async {
    AppLogger.i('Refreshing data via pull-to-refresh', tag: 'HomePage');
    
    // Trigger reload of habits - today's entries will be loaded automatically
    context.read<HabitBloc>().add(const LoadHabits());
    
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daymark'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          if (state is HabitLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is HabitError) {
            AppLogger.e(
              'HabitBloc error state encountered', 
              tag: 'HomePage', 
              error: state.message,
              stackTrace: StackTrace.current,
            );
            return DataLoadingErrorState(
              onRetry: () {
                AppLogger.i('Retrying data load after error', tag: 'HomePage');
                context.read<HabitBloc>().add(const LoadHabits());
              },
            );
          }
          
          if (state is HabitLoaded) {
            final habits = state.habits;
            final todayEntries = state.todayEntries;
            
            // Create completion data for calendar
            final completionData = <DateTime, int>{};
            for (final entry in todayEntries) {
              if (entry.isCompleted) {
                final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
                completionData[date] = (completionData[date] ?? 0) + 1;
              }
            }
            
            // Check for empty habits
            if (habits.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: NoHabitsEmptyState(
                      onCreateHabit: () {
                        AppLogger.i('Create habit action triggered from empty state', tag: 'HomePage');
                        // TODO: Implement create habit functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Create habit functionality coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
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
                      ),
                      
                      // Today's habits section
                      Padding(
                        padding: ResponsiveLayout.getPadding(context),
                        child: Row(
                          children: [
                            Text(
                              "Today's Habits",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${todayEntries.where((e) => e.isCompleted).length}/${habits.length}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Habit cards
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          final todayEntry = todayEntries.firstWhere(
                            (entry) => entry.habitId == habit.id,
                            orElse: () => HabitEntry(
                              id: '${habit.id}_${DateTime.now().toIso8601String()}',
                              habitId: habit.id,
                              date: DateTime.now(),
                              isCompleted: false,
                            ),
                          );
                          
                          return HabitCard(
                            habit: habit,
                            todayEntry: todayEntry,
                            isExpanded: _expandedCards[habit.id] ?? false,
                            onToggleCompletion: () => _markHabitCompleted(
                              habit.id,
                              !todayEntry.isCompleted,
                            ),
                            onToggleExpand: () => _toggleCardExpansion(habit.id),
                          );
                        },
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
                        ),
                        
                        // Today's habits section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Text(
                                "Today's Habits",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${todayEntries.where((e) => e.isCompleted).length}/${habits.length}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Habit cards in grid for tablet
                        GridView.builder(
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
                            final todayEntry = todayEntries.firstWhere(
                              (entry) => entry.habitId == habit.id,
                              orElse: () => HabitEntry(
                                id: '${habit.id}_${DateTime.now().toIso8601String()}',
                                habitId: habit.id,
                                date: DateTime.now(),
                                isCompleted: false,
                              ),
                            );
                            
                            return HabitCard(
                              habit: habit,
                              todayEntry: todayEntry,
                              isExpanded: _expandedCards[habit.id] ?? false,
                              onToggleCompletion: () => _markHabitCompleted(
                                habit.id,
                                !todayEntry.isCompleted,
                              ),
                              onToggleExpand: () => _toggleCardExpansion(habit.id),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
