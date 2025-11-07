import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for marking a habit as completed for a specific date
class MarkHabitForDate {
  final HabitRepository repository;

  const MarkHabitForDate(this.repository);

  FutureResult<bool, ErrorCode> call(String habitId, bool isCompleted, DateTime date) {
    return repository.markHabitForDate(habitId, isCompleted, date);
  }
}