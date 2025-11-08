import 'package:equatable/equatable.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';

/// Base class for configuration states
abstract class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object?> get props => [];
}

/// Initial configuration state
class ConfigInitial extends ConfigState {
  const ConfigInitial();
}

/// Configuration loading state
class ConfigLoading extends ConfigState {
  const ConfigLoading();
}

/// Configuration loaded state
class ConfigLoaded extends ConfigState {
  final AppConfig config;
  final bool isUpdating;

  const ConfigLoaded({
    required this.config,
    this.isUpdating = false,
  });

  ConfigLoaded copyWith({
    AppConfig? config,
    bool? isUpdating,
  }) {
    return ConfigLoaded(
      config: config ?? this.config,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [config, isUpdating];
}

/// Configuration error state
class ConfigError extends ConfigState {
  final String message;

  const ConfigError({required this.message});

  @override
  List<Object?> get props => [message];
}