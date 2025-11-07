import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for deleting a habit
class DeleteHabitUseCase {
  final HabitRepository repository;

  const DeleteHabitUseCase(this.repository);

  FutureResult<bool, ErrorCode> call(String habitId) {
    return repository.deleteHabit(habitId);
  }
}