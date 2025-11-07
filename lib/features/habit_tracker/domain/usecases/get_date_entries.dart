import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/habit_repository.dart';

/// Use case for getting habit entries for a specific date
class GetDateEntries {
  final HabitRepository repository;

  const GetDateEntries(this.repository);

  FutureResult<List<HabitEntry>, ErrorCode> call(DateTime date) {
    return repository.getDateEntries(date);
  }
}