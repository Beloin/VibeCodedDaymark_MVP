import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/habit_bloc.dart';
import '../bloc/config_bloc.dart';
import '../bloc/config_event.dart';
import '../bloc/config_state.dart';
import 'habit_view_data.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/app_config.dart';
import '../../../../app/shared/utils/logger.dart';

/// Unified ViewModel that provides data for both calendar and tile views
class HabitCalendarViewModel {
  final BuildContext context;
  
  HabitCalendarViewModel(this.context);

  /// Gets the current view data
  HabitViewData? get viewData {
    final habitState = context.read<HabitBloc>().state;
    final configState = context.read<ConfigBloc>().state;
    
    if (habitState is HabitLoaded && configState is ConfigLoaded) {
      return HabitViewData.fromHabitState(habitState, configState.config);
    }
    
    return null;
  }

  /// Gets the current view type
  ViewType get currentViewType {
    final configState = context.read<ConfigBloc>().state;
    if (configState is ConfigLoaded) {
      return configState.config.preferredView;
    }
    return ViewType.calendar;
  }

  /// Checks if data is loading
  bool get isLoading {
    final habitState = context.read<HabitBloc>().state;
    return habitState.isLoading;
  }

  /// Checks if there's an error
  bool get hasError {
    final habitState = context.read<HabitBloc>().state;
    return habitState is HabitError || habitState is HabitInitializationError;
  }

  /// Gets the error message if any
  String? get errorMessage {
    final habitState = context.read<HabitBloc>().state;
    if (habitState is HabitError) {
      return habitState.message;
    } else if (habitState is HabitInitializationError) {
      return habitState.message;
    }
    return null;
  }

  /// Checks if there are no habits
  bool get hasNoHabits {
    final habitState = context.read<HabitBloc>().state;
    if (habitState is HabitLoaded) {
      return habitState.habits.isEmpty;
    }
    return false;
  }

  /// Marks a habit as completed or not completed
  void markHabitCompleted(String habitId, bool isCompleted) {
    final habitState = context.read<HabitBloc>().state;
    if (habitState is HabitLoaded) {
      context.read<HabitBloc>().add(MarkHabitCompleted(
        habitId: habitId,
        isCompleted: isCompleted,
        date: habitState.selectedDate,
      ));
    }
  }

  /// Deletes a habit
  void deleteHabit(String habitId) {
    context.read<HabitBloc>().add(DeleteHabit(habitId: habitId));
  }

  /// Switches the view type
  void switchView(ViewType viewType) {
    AppLogger.i('Switching view to: $viewType', tag: 'HabitCalendarViewModel');
    context.read<ConfigBloc>().add(UpdateViewType(viewType));
  }

  /// Loads historical data for tile view
  void loadHistoricalData() {
    final now = DateTime.now();
    final configState = context.read<ConfigBloc>().state;
    final weeksToDisplay = configState is ConfigLoaded ? configState.config.weeksToDisplay : 2;
    final daysToLoad = weeksToDisplay * 7;
    final startDate = now.subtract(Duration(days: daysToLoad));
    
    context.read<HabitBloc>().add(LoadHistoricalEntries(
      startDate: startDate,
      endDate: now,
    ));
  }

  /// Refreshes all data
  void refreshData() {
    context.read<HabitBloc>().add(const LoadHabits());
    
    // If in tile view, also reload historical data
    if (currentViewType == ViewType.tile) {
      loadHistoricalData();
    }
  }

  /// Selects a date
  void selectDate(DateTime date) {
    context.read<HabitBloc>().add(LoadDateEntries(date: date));
  }

  /// Navigates to the previous day
  void goToPreviousDay() {
    final habitState = context.read<HabitBloc>().state;
    if (habitState is HabitLoaded) {
      final newDate = habitState.selectedDate.subtract(const Duration(days: 1));
      selectDate(newDate);
    }
  }

  /// Navigates to the next day
  void goToNextDay() {
    final habitState = context.read<HabitBloc>().state;
    if (habitState is HabitLoaded) {
      final newDate = habitState.selectedDate.add(const Duration(days: 1));
      selectDate(newDate);
    }
  }

  /// Checks if a date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Gets relative date text (Yesterday, Tomorrow, etc.)
  String getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    
    if (difference.inDays == -1) return 'Yesterday';
    if (difference.inDays == 1) return 'Tomorrow';
    if (difference.inDays < -1) return '${difference.inDays.abs()} days ago';
    if (difference.inDays > 1) return 'In ${difference.inDays} days';
    return '';
  }

  /// Gets the habit name by ID
  String getHabitNameById(String habitId) {
    final habitState = context.read<HabitBloc>().state;
    if (habitState is HabitLoaded) {
      final habit = habitState.habits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => Habit(
          id: habitId,
          name: 'Unknown Habit',
          description: '',
          createdAt: DateTime.now(),
        ),
      );
      return habit.name;
    }
    return 'Unknown Habit';
  }
}