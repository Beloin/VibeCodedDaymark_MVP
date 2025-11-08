import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';

/// Repository interface for configuration operations
abstract class ConfigRepository {
  // Configuration operations
  FutureResult<AppConfig, ErrorCode> getConfig();
  FutureResult<AppConfig, ErrorCode> updateConfig(AppConfig config);
  
  // Individual preference operations
  FutureResult<AppConfig, ErrorCode> updatePreferredView(ViewType viewType);
  FutureResult<AppConfig, ErrorCode> updateWeeksToDisplay(int weeks);
  FutureResult<AppConfig, ErrorCode> updateHabitColor(String habitId, String color);
  FutureResult<AppConfig, ErrorCode> removeHabitColor(String habitId);
  
  // Reset operations
  FutureResult<AppConfig, ErrorCode> resetToDefaults();
}