import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/config_repository.dart';

/// Use case for updating weeks to display in tile view
class UpdateWeeksToDisplay {
  final ConfigRepository repository;

  const UpdateWeeksToDisplay(this.repository);

  FutureResult<AppConfig, ErrorCode> call(int weeks) {
    return repository.updateWeeksToDisplay(weeks);
  }
}