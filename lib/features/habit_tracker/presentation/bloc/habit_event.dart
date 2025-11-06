part of 'habit_bloc.dart';

/// Base class for habit events
sealed class HabitEvent {
  const HabitEvent();
}

/// Event to load all habits
class LoadHabits extends HabitEvent {
  const LoadHabits();
}

/// Event to load today's habit entries
class LoadTodayEntries extends HabitEvent {
  const LoadTodayEntries();
}

/// Event to mark a habit as completed for today
class MarkHabitCompleted extends HabitEvent {
  final String habitId;
  final bool isCompleted;

  const MarkHabitCompleted({
    required this.habitId,
    required this.isCompleted,
  });
}