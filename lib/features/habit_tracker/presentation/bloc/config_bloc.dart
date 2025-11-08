import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daymark/features/habit_tracker/domain/usecases/get_config.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/update_preferred_view.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/update_weeks_to_display.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/update_habit_color.dart';
import 'package:daymark/features/habit_tracker/domain/usecases/reset_config.dart';
import 'package:daymark/app/shared/utils/logger.dart';
import 'config_event.dart';
import 'config_state.dart';

/// BLoC for managing app configuration state
class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final GetConfig getConfig;
  final UpdatePreferredView updatePreferredView;
  final UpdateWeeksToDisplay updateWeeksToDisplay;
  final UpdateHabitColor updateHabitColor;
  final ResetConfig resetConfig;

  ConfigBloc({
    required this.getConfig,
    required this.updatePreferredView,
    required this.updateWeeksToDisplay,
    required this.updateHabitColor,
    required this.resetConfig,
  }) : super(ConfigInitial()) {
    on<LoadConfig>(_onLoadConfig);
    on<UpdateViewType>(_onUpdateViewType);
    on<UpdateWeeksDisplay>(_onUpdateWeeksDisplay);
    on<UpdateHabitColorEvent>(_onUpdateHabitColor);
    on<ResetConfigEvent>(_onResetConfig);
  }

  Future<void> _onLoadConfig(LoadConfig event, Emitter<ConfigState> emit) async {
    AppLogger.i('Loading app configuration', tag: 'ConfigBloc');
    
    emit(ConfigLoading());
    
    final result = await getConfig();
    result.when(
      success: (config) {
        AppLogger.i('Successfully loaded config: $config', tag: 'ConfigBloc');
        emit(ConfigLoaded(config: config));
      },
      failure: (error) {
        AppLogger.e(
          'Failed to load config', 
          tag: 'ConfigBloc', 
          error: error.toString(),
          stackTrace: StackTrace.current,
        );
        emit(ConfigError(message: error.toString()));
      },
    );
  }

  Future<void> _onUpdateViewType(UpdateViewType event, Emitter<ConfigState> emit) async {
    if (state is ConfigLoaded) {
      AppLogger.i('Updating preferred view to: ${event.viewType}', tag: 'ConfigBloc');
      
      final currentState = state as ConfigLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await updatePreferredView(event.viewType);
      result.when(
        success: (config) {
          AppLogger.i('Successfully updated view type', tag: 'ConfigBloc');
          emit(ConfigLoaded(config: config));
        },
        failure: (error) {
          AppLogger.e(
            'Failed to update view type', 
            tag: 'ConfigBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          emit(ConfigError(message: error.toString()));
        },
      );
    }
  }

  Future<void> _onUpdateWeeksDisplay(UpdateWeeksDisplay event, Emitter<ConfigState> emit) async {
    if (state is ConfigLoaded) {
      AppLogger.i('Updating weeks to display to: ${event.weeks}', tag: 'ConfigBloc');
      
      final currentState = state as ConfigLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await updateWeeksToDisplay(event.weeks);
      result.when(
        success: (config) {
          AppLogger.i('Successfully updated weeks to display', tag: 'ConfigBloc');
          emit(ConfigLoaded(config: config));
        },
        failure: (error) {
          AppLogger.e(
            'Failed to update weeks to display', 
            tag: 'ConfigBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          emit(ConfigError(message: error.toString()));
        },
      );
    }
  }

  Future<void> _onUpdateHabitColor(UpdateHabitColorEvent event, Emitter<ConfigState> emit) async {
    if (state is ConfigLoaded) {
      AppLogger.i('Updating habit color: ${event.habitId} -> ${event.color}', tag: 'ConfigBloc');
      
      final currentState = state as ConfigLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await updateHabitColor(event.habitId, event.color);
      result.when(
        success: (config) {
          AppLogger.i('Successfully updated habit color', tag: 'ConfigBloc');
          emit(ConfigLoaded(config: config));
        },
        failure: (error) {
          AppLogger.e(
            'Failed to update habit color', 
            tag: 'ConfigBloc', 
            error: error.toString(),
            stackTrace: StackTrace.current,
          );
          emit(ConfigError(message: error.toString()));
        },
      );
    }
  }

  Future<void> _onResetConfig(ResetConfigEvent event, Emitter<ConfigState> emit) async {
    AppLogger.i('Resetting configuration to defaults', tag: 'ConfigBloc');
    
    emit(ConfigLoading());
    
    final result = await resetConfig();
    result.when(
      success: (config) {
        AppLogger.i('Successfully reset config to defaults', tag: 'ConfigBloc');
        emit(ConfigLoaded(config: config));
      },
      failure: (error) {
        AppLogger.e(
          'Failed to reset config', 
          tag: 'ConfigBloc', 
          error: error.toString(),
          stackTrace: StackTrace.current,
        );
        emit(ConfigError(message: error.toString()));
      },
    );
  }
}