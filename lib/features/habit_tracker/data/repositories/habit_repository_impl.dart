import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';
import 'package:daymark/services/habit_service.dart';

/// Implementation of HabitRepository using the service abstraction
class HabitRepositoryImpl implements HabitRepository {
  final HabitService service;

  const HabitRepositoryImpl(this.service);

  @override
  FutureResult<List<Habit>, ErrorCode> getHabits() {
    return service.getHabits();
  }

  @override
  FutureResult<Habit, ErrorCode> getHabit(String id) {
    return service.getHabit(id);
  }

  @override
  FutureResult<Habit, ErrorCode> createHabit(Habit habit) {
    return service.createHabit(habit);
  }

  @override
  FutureResult<Habit, ErrorCode> updateHabit(Habit habit) {
    return service.updateHabit(habit);
  }

  @override
  FutureResult<bool, ErrorCode> deleteHabit(String id) {
    return service.deleteHabit(id);
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getHabitEntries(
    String habitId, 
    DateTime startDate, 
    DateTime endDate,
  ) {
    return service.getHabitEntries(habitId, startDate, endDate);
  }

  @override
  FutureResult<HabitEntry, ErrorCode> getHabitEntry(String habitId, DateTime date) {
    return service.getHabitEntry(habitId, date);
  }

  @override
  FutureResult<HabitEntry, ErrorCode> createHabitEntry(HabitEntry entry) {
    return service.createHabitEntry(entry);
  }

  @override
  FutureResult<HabitEntry, ErrorCode> updateHabitEntry(HabitEntry entry) {
    return service.updateHabitEntry(entry);
  }

  @override
  FutureResult<bool, ErrorCode> deleteHabitEntry(String id) {
    return service.deleteHabitEntry(id);
  }

  @override
  FutureResult<List<HabitEntry>, ErrorCode> getTodayEntries() {
    return service.getTodayEntries();
  }

  @override
  FutureResult<bool, ErrorCode> markHabitForToday(String habitId, bool isCompleted) {
    return service.markHabitForToday(habitId, isCompleted);
  }
}