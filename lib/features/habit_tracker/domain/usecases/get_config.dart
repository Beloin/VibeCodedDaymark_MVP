import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/config_repository.dart';

/// Use case for retrieving app configuration
class GetConfig {
  final ConfigRepository repository;

  const GetConfig(this.repository);

  FutureResult<AppConfig, ErrorCode> call() {
    return repository.getConfig();
  }
}