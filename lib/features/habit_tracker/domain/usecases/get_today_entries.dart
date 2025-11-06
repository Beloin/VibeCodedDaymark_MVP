import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for retrieving today's habit entries
class GetTodayEntries {
  final HabitRepository repository;

  const GetTodayEntries(this.repository);

  FutureResult<List<HabitEntry>, ErrorCode> call() {
    return repository.getTodayEntries();
  }
}