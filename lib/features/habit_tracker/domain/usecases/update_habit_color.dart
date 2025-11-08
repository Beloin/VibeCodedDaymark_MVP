import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/config_repository.dart';

/// Use case for updating habit color
class UpdateHabitColor {
  final ConfigRepository repository;

  const UpdateHabitColor(this.repository);

  FutureResult<AppConfig, ErrorCode> call(String habitId, String color) {
    return repository.updateHabitColor(habitId, color);
  }
}