import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for getting habit entries for a specific habit within a date range
class GetHabitEntries {
  final HabitRepository repository;

  const GetHabitEntries(this.repository);

  FutureResult<List<HabitEntry>, ErrorCode> call(String habitId, DateTime startDate, DateTime endDate) {
    return repository.getHabitEntries(habitId, startDate, endDate);
  }
}