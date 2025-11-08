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

/// Event to mark a habit as completed for a specific date
class MarkHabitCompleted extends HabitEvent {
  final String habitId;
  final bool isCompleted;
  final DateTime date;

  const MarkHabitCompleted({
    required this.habitId,
    required this.isCompleted,
    required this.date,
  });
}

/// Event to create a new habit
class CreateHabit extends HabitEvent {
  final Habit habit;

  const CreateHabit({
    required this.habit,
  });
}

/// Event to load habit entries for a specific date
class LoadDateEntries extends HabitEvent {
  final DateTime date;

  const LoadDateEntries({
    required this.date,
  });
}

/// Event to delete a habit
class DeleteHabit extends HabitEvent {
  final String habitId;

  const DeleteHabit({
    required this.habitId,
  });
}

/// Event to load historical habit entries for tile view
class LoadHistoricalEntries extends HabitEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadHistoricalEntries({
    required this.startDate,
    required this.endDate,
  });
}