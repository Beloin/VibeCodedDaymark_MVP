import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for retrieving all habits
class GetHabits {
  final HabitRepository repository;

  const GetHabits(this.repository);

  FutureResult<List<Habit>, ErrorCode> call() {
    return repository.getHabits();
  }
}