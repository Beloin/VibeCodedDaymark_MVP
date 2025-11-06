part of 'habit_bloc.dart';

/// Base class for habit states
sealed class HabitState {
  const HabitState();
}

/// Initial state
class HabitInitial extends HabitState {
  const HabitInitial();
}

/// Loading state
class HabitLoading extends HabitState {
  const HabitLoading();
}

/// Loaded state with habits and today's entries
class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final List<HabitEntry> todayEntries;

  const HabitLoaded({
    required this.habits,
    this.todayEntries = const [],
  });

  HabitLoaded copyWith({
    List<Habit>? habits,
    List<HabitEntry>? todayEntries,
  }) {
    return HabitLoaded(
      habits: habits ?? this.habits,
      todayEntries: todayEntries ?? this.todayEntries,
    );
  }

  @override
  String toString() => 'HabitLoaded(habits: ${habits.length}, todayEntries: ${todayEntries.length})';
}

/// Error state
class HabitError extends HabitState {
  final String message;

  const HabitError({required this.message});

  @override
  String toString() => 'HabitError(message: $message)';
}