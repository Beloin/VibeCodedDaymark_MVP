import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/services/habit_service.dart';

/// Utility class to seed the database with sample data
class SampleData {
  static final List<Habit> sampleHabits = [
    Habit(
      id: '1',
      name: 'Morning Meditation',
      description: '10 minutes of mindfulness meditation',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Habit(
      id: '2',
      name: 'Exercise',
      description: '30 minutes of physical activity',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    Habit(
      id: '3',
      name: 'Read Book',
      description: 'Read at least 20 pages',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Habit(
      id: '4',
      name: 'Drink Water',
      description: 'Drink 8 glasses of water',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Habit(
      id: '5',
      name: 'Journal',
      description: 'Write in journal for 5 minutes',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  /// Seed the database with sample habits
  static Future<void> seedDatabase(HabitService service) async {
    for (final habit in sampleHabits) {
      await service.createHabit(habit);
    }
  }
}