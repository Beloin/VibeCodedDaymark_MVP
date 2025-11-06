import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/presentation/bloc/habit_bloc.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/habit_card.dart';
import 'package:daymark/features/habit_tracker/presentation/widgets/calendar_view.dart';

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
    // Load initial data
    context.read<HabitBloc>().add(const LoadHabits());
    context.read<HabitBloc>().add(const LoadTodayEntries());
  }

  void _toggleCardExpansion(String habitId) {
    setState(() {
      _expandedCards[habitId] = !(_expandedCards[habitId] ?? false);
    });
  }

  void _markHabitCompleted(String habitId, bool isCompleted) {
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HabitBloc>().add(const LoadHabits());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
            
            return SingleChildScrollView(
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
                    padding: const EdgeInsets.all(16),
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
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}