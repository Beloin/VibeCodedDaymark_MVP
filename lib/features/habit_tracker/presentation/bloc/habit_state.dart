part of 'habit_bloc.dart';

/// Base class for habit states
sealed class HabitState {
  const HabitState();
  
  /// Check if any operation is currently loading
  bool get isLoading => false;
}

/// Initial state
class HabitInitial extends HabitState {
  const HabitInitial();
}

/// Loading state
class HabitLoading extends HabitState {
  final bool isMarkingCompletion;
  final bool isDeleting;
  final bool isCreating;
  final bool isRefreshing;

  const HabitLoading({
    this.isMarkingCompletion = false,
    this.isDeleting = false,
    this.isCreating = false,
    this.isRefreshing = false,
  });

  @override
  bool get isLoading => true;

  HabitLoading copyWith({
    bool? isMarkingCompletion,
    bool? isDeleting,
    bool? isCreating,
    bool? isRefreshing,
  }) {
    return HabitLoading(
      isMarkingCompletion: isMarkingCompletion ?? this.isMarkingCompletion,
      isDeleting: isDeleting ?? this.isDeleting,
      isCreating: isCreating ?? this.isCreating,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Loaded state with habits and entries for selected date
class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final List<HabitEntry> selectedDateEntries;
  final DateTime selectedDate;
  final bool isMarkingCompletion;
  final bool isDeleting;
  final bool isCreating;
  final bool isRefreshing;
  final String? loadingHabitId;

  const HabitLoaded({
    required this.habits,
    this.selectedDateEntries = const [],
    required this.selectedDate,
    this.isMarkingCompletion = false,
    this.isDeleting = false,
    this.isCreating = false,
    this.isRefreshing = false,
    this.loadingHabitId,
  });

  @override
  bool get isLoading => isMarkingCompletion || isDeleting || isCreating || isRefreshing;

  HabitLoaded copyWith({
    List<Habit>? habits,
    List<HabitEntry>? selectedDateEntries,
    DateTime? selectedDate,
    bool? isMarkingCompletion,
    bool? isDeleting,
    bool? isCreating,
    bool? isRefreshing,
    String? loadingHabitId,
  }) {
    return HabitLoaded(
      habits: habits ?? this.habits,
      selectedDateEntries: selectedDateEntries ?? this.selectedDateEntries,
      selectedDate: selectedDate ?? this.selectedDate,
      isMarkingCompletion: isMarkingCompletion ?? this.isMarkingCompletion,
      isDeleting: isDeleting ?? this.isDeleting,
      isCreating: isCreating ?? this.isCreating,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      loadingHabitId: loadingHabitId ?? this.loadingHabitId,
    );
  }

  @override
  String toString() => 'HabitLoaded(habits: ${habits.length}, selectedDateEntries: ${selectedDateEntries.length}, selectedDate: $selectedDate, isLoading: $isLoading, loadingHabitId: $loadingHabitId)';
}

/// Error state
class HabitError extends HabitState {
  final String message;

  const HabitError({required this.message});

  @override
  String toString() => 'HabitError(message: $message)';
}