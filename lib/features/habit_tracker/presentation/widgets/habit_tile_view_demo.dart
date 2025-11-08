import 'package:flutter/material.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'habit_tile_view.dart';

/// Demo page showing how to use the HabitTileView component
class HabitTileViewDemo extends StatelessWidget {
  const HabitTileViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    final sampleHabits = [
      Habit(
        id: '1',
        name: 'Morning Meditation',
        description: 'Start the day with 10 minutes of mindfulness',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Habit(
        id: '2',
        name: 'Exercise',
        description: '30 minutes of physical activity',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Habit(
        id: '3',
        name: 'Read Book',
        description: 'Read at least 20 pages',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    // Sample history entries (last 14 days)
    final sampleHistory = <HabitEntry>[];
    final today = DateTime.now();
    
    // Generate some completed entries for demonstration
    for (int i = 0; i < 14; i++) {
      final date = today.subtract(Duration(days: i));
      
      // Habit 1: Completed most days
      if (i % 2 == 0) {
        sampleHistory.add(HabitEntry(
          id: '1_${date.toIso8601String()}',
          habitId: '1',
          date: date,
          isCompleted: true,
          completedAt: date,
        ));
      }
      
      // Habit 2: Completed every day
      sampleHistory.add(HabitEntry(
        id: '2_${date.toIso8601String()}',
        habitId: '2',
        date: date,
        isCompleted: true,
        completedAt: date,
      ));
      
      // Habit 3: Completed rarely
      if (i % 4 == 0) {
        sampleHistory.add(HabitEntry(
          id: '3_${date.toIso8601String()}',
          habitId: '3',
          date: date,
          isCompleted: true,
          completedAt: date,
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tile View Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: sampleHabits.length,
        itemBuilder: (context, index) {
          final habit = sampleHabits[index];
          final habitHistory = sampleHistory
              .where((entry) => entry.habitId == habit.id)
              .toList();
          
          // Find today's entry
          final todayEntry = habitHistory.firstWhere(
            (entry) => _isSameDay(entry.date, today),
            orElse: () => HabitEntry(
              id: '${habit.id}_${today.toIso8601String()}',
              habitId: habit.id,
              date: today,
              isCompleted: false,
            ),
          );

          return HabitTileView(
            habit: habit,
            todayEntry: todayEntry,
            historyEntries: habitHistory,
            onToggleCompletion: () {
              // In a real app, this would call your bloc to update the completion status
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${habit.name} ${todayEntry.isCompleted ? 'marked incomplete' : 'marked complete'}' +
                    ' (Demo - no actual data change)',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            daysToShow: 14,
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}