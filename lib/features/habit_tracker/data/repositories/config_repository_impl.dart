import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/config_repository.dart';
import 'package:daymark/services/config_service.dart';

/// Implementation of ConfigRepository using the service abstraction
class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigService service;

  const ConfigRepositoryImpl(this.service);

  @override
  FutureResult<AppConfig, ErrorCode> getConfig() {
    return service.getConfig();
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateConfig(AppConfig config) {
    return service.updateConfig(config);
  }

  @override
  FutureResult<AppConfig, ErrorCode> updatePreferredView(ViewType viewType) {
    return service.updatePreferredView(viewType);
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateWeeksToDisplay(int weeks) {
    return service.updateWeeksToDisplay(weeks);
  }

  @override
  FutureResult<AppConfig, ErrorCode> updateHabitColor(String habitId, String color) {
    return service.updateHabitColor(habitId, color);
  }

  @override
  FutureResult<AppConfig, ErrorCode> removeHabitColor(String habitId) {
    return service.removeHabitColor(habitId);
  }

  @override
  FutureResult<AppConfig, ErrorCode> resetToDefaults() {
    return service.resetToDefaults();
  }
}