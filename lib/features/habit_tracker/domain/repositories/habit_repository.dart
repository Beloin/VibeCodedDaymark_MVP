import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';

/// Repository interface for habit operations
abstract class HabitRepository {
  // Habit operations
  FutureResult<List<Habit>, ErrorCode> getHabits();
  FutureResult<Habit, ErrorCode> getHabit(String id);
  FutureResult<Habit, ErrorCode> createHabit(Habit habit);
  FutureResult<Habit, ErrorCode> updateHabit(Habit habit);
  FutureResult<bool, ErrorCode> deleteHabit(String id);

  // Habit entry operations
  FutureResult<List<HabitEntry>, ErrorCode> getHabitEntries(String habitId, DateTime startDate, DateTime endDate);
  FutureResult<HabitEntry, ErrorCode> getHabitEntry(String habitId, DateTime date);
  FutureResult<HabitEntry, ErrorCode> createHabitEntry(HabitEntry entry);
  FutureResult<HabitEntry, ErrorCode> updateHabitEntry(HabitEntry entry);
  FutureResult<bool, ErrorCode> deleteHabitEntry(String id);

  // Batch operations
  FutureResult<List<HabitEntry>, ErrorCode> getTodayEntries();
  FutureResult<List<HabitEntry>, ErrorCode> getDateEntries(DateTime date);
  FutureResult<bool, ErrorCode> markHabitForToday(String habitId, bool isCompleted);
  FutureResult<bool, ErrorCode> markHabitForDate(String habitId, bool isCompleted, DateTime date);
}