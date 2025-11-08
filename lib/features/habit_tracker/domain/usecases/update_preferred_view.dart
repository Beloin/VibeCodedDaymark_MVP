import 'package:daymark/app/shared/errors/result.dart';
import 'package:daymark/app/shared/errors/error_code.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';
import 'package:daymark/features/habit_tracker/domain/repositories/config_repository.dart';

/// Use case for updating preferred view type
class UpdatePreferredView {
  final ConfigRepository repository;

  const UpdatePreferredView(this.repository);

  FutureResult<AppConfig, ErrorCode> call(ViewType viewType) {
    return repository.updatePreferredView(viewType);
  }
}