import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for marking a habit as completed for today
class MarkHabitToday {
  final HabitRepository repository;

  const MarkHabitToday(this.repository);

  FutureResult<bool, ErrorCode> call(String habitId, bool isCompleted) {
    return repository.markHabitForToday(habitId, isCompleted);
  }
}