import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for creating a new habit
class CreateHabitUseCase {
  final HabitRepository repository;

  const CreateHabitUseCase(this.repository);

  FutureResult<Habit, ErrorCode> call(Habit habit) {
    return repository.createHabit(habit);
  }
}