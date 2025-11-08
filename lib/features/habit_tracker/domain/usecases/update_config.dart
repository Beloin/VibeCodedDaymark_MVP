import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/config_repository.dart';

/// Use case for updating app configuration
class UpdateConfig {
  final ConfigRepository repository;

  const UpdateConfig(this.repository);

  FutureResult<AppConfig, ErrorCode> call(AppConfig config) {
    return repository.updateConfig(config);
  }
}