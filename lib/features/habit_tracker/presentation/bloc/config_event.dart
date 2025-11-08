import 'package:equatable/equatable.dart';
import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';

/// Base class for configuration events
abstract class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the current configuration
class LoadConfig extends ConfigEvent {
  const LoadConfig();
}

/// Event to update the preferred view type
class UpdateViewType extends ConfigEvent {
  final ViewType viewType;

  const UpdateViewType(this.viewType);

  @override
  List<Object?> get props => [viewType];
}

/// Event to update the number of weeks to display
class UpdateWeeksDisplay extends ConfigEvent {
  final int weeks;

  const UpdateWeeksDisplay(this.weeks);

  @override
  List<Object?> get props => [weeks];
}

/// Event to update a habit's color
class UpdateHabitColorEvent extends ConfigEvent {
  final String habitId;
  final String color;

  const UpdateHabitColorEvent(this.habitId, this.color);

  @override
  List<Object?> get props => [habitId, color];
}

/// Event to reset configuration to defaults
class ResetConfigEvent extends ConfigEvent {
  const ResetConfigEvent();
}