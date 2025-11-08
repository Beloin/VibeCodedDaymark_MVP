import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/services/habit_service.dart';
import 'package:daymark/services/config_service.dart';

/// Mock service for testing on platforms where SQLite is not available
class MockService implements HabitService, ConfigService {
  final List<Habit> _habits = [];
  final List<HabitEntry> _habitEntries = [];
  AppConfig _config = AppConfig.defaultConfig;

  @override
  Future<void> initialize() async {
    // Mock initialization - always succeeds
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  FutureResult<List<Habit>, ErrorCode> getHabits() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return Success(_habits);
  }

  @override
  FutureResult<Habit, ErrorCode> createHabit(Habit habit) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _habits.add(habit);
    return Success(habit);
  }

  @override
  FutureResult<bool, ErrorCode> deleteHabit(String habitId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _habits.removeWhere((habit) => habit.id == habitId);
    _habitEntries.removeWhere((entry) => entry.habitId == habitId);
    return const Success(true);
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getHabitEntries(
    String habitId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final entries = _habitEntries.where((entry) => 
      entry.habitId == habitId &&
      entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      entry.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
    return Success(entries);
  }

  @override
  FutureResult<HabitEntry, ErrorCode> markHabitCompleted(
    String habitId, 
    DateTime date, 
    bool isCompleted,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Remove existing entry for this date
    _habitEntries.removeWhere((entry) => 
      entry.habitId == habitId && 
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    );
    
    // Create new entry
    final entry = HabitEntry(
      id: '${habitId}_${date.toIso8601String()}',
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
    );
    
    _habitEntries.add(entry);
    return Success(entry);
  }

  @override
  FutureResult<AppConfig, ErrorCode> getConfig() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return Success(_config);
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateConfig(AppConfig config) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _config = config;
    return Success(_config);
  }

  @override
  FutureResult<AppConfig, ErrorCode> updatePreferredView(ViewType viewType) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _config = _config.copyWith(preferredView: viewType);
    return Success(_config);
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateWeeksToDisplay(int weeks) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _config = _config.copyWith(weeksToDisplay: weeks);
    return Success(_config);
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateHabitColor(String habitId, String color) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final updatedColors = Map<String, String>.from(_config.habitColors);
    updatedColors[habitId] = color;
    _config = _config.copyWith(habitColors: updatedColors);
    return Success(_config);
  }

  @override
  FutureResult<AppConfig, ErrorCode> resetConfig() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _config = AppConfig.defaultConfig;
    return Success(_config);
  }

  // Additional required methods
  @override
  FutureResult<AppConfig, ErrorCode> removeHabitColor(String habitId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final updatedColors = Map<String, String>.from(_config.habitColors);
    updatedColors.remove(habitId);
    _config = _config.copyWith(habitColors: updatedColors);
    return Success(_config);
  }

  @override
  FutureResult<AppConfig, ErrorCode> resetToDefaults() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _config = AppConfig.defaultConfig;
    return Success(_config);
  }

  @override
  FutureResult<HabitEntry, ErrorCode> createHabitEntry(HabitEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _habitEntries.add(entry);
    return Success(entry);
  }

  @override
  FutureResult<bool, ErrorCode> deleteHabitEntry(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _habitEntries.removeWhere((entry) => entry.id == id);
    return const Success(true);
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getDateEntries(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final entries = _habitEntries.where((entry) => 
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    ).toList();
    return Success(entries);
  }

  @override
  FutureResult<Habit, ErrorCode> getHabit(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final habit = _habits.firstWhere(
      (habit) => habit.id == id,
      orElse: () => throw Exception('Habit not found'),
    );
    return Success(habit);
  }

  @override
  FutureResult<HabitEntry, ErrorCode> getHabitEntry(String habitId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final entry = _habitEntries.firstWhere(
      (entry) => entry.habitId == habitId && 
                 entry.date.year == date.year &&
                 entry.date.month == date.month &&
                 entry.date.day == date.day,
      orElse: () => HabitEntry(
        id: '${habitId}_${date.toIso8601String()}',
        habitId: habitId,
        date: date,
        isCompleted: false,
      ),
    );
    return Success(entry);
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getTodayEntries() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final today = DateTime.now();
    final entries = _habitEntries.where((entry) => 
      entry.date.year == today.year &&
      entry.date.month == today.month &&
      entry.date.day == today.day
    ).toList();
    return Success(entries);
  }

  @override
  FutureResult<bool, ErrorCode> markHabitForDate(String habitId, bool isCompleted, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Remove existing entry for this date
    _habitEntries.removeWhere((entry) => 
      entry.habitId == habitId && 
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    );
    
    // Create new entry
    final entry = HabitEntry(
      id: '${habitId}_${date.toIso8601String()}',
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
    );
    
    _habitEntries.add(entry);
    return const Success(true);
  }

  @override
  FutureResult<bool, ErrorCode> markHabitForToday(String habitId, bool isCompleted) async {
    return markHabitForDate(habitId, isCompleted, DateTime.now());
  }

  @override
  FutureResult<Habit, ErrorCode> updateHabit(Habit habit) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
    return Success(habit);
  }

  @override
  FutureResult<HabitEntry, ErrorCode> updateHabitEntry(HabitEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _habitEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _habitEntries[index] = entry;
    }
    return Success(entry);
  }

  /// Seed with sample data for testing
  Future<void> seedSampleData() async {
    // Add sample habits
    final sampleHabits = [
      Habit(
        id: '1',
        name: 'Morning Meditation',
        description: 'Start the day with 10 minutes of meditation',
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
        name: 'Read',
        description: 'Read for at least 20 minutes',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
    
    _habits.addAll(sampleHabits);
    
    // Add some completed entries for the past week
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      for (final habit in sampleHabits) {
        if (i % 2 == 0) { // Complete every other day
          await markHabitCompleted(habit.id, date, true);
        }
      }
    }
  }
}