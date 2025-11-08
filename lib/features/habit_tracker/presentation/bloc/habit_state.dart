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
  final Map<String, List<HabitEntry>> historicalEntries;
  final DateTime selectedDate;
  final bool isMarkingCompletion;
  final bool isDeleting;
  final bool isCreating;
  final bool isRefreshing;
  final String? loadingHabitId;

  const HabitLoaded({
    required this.habits,
    this.selectedDateEntries = const [],
    this.historicalEntries = const {},
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
    Map<String, List<HabitEntry>>? historicalEntries,
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
      historicalEntries: historicalEntries ?? this.historicalEntries,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    if (other is! HabitLoaded) return false;
    
    final isEqual = 
        const ListEquality().equals(habits, other.habits) &&
        const ListEquality().equals(selectedDateEntries, other.selectedDateEntries) &&
        const MapEquality(values: ListEquality()).equals(historicalEntries, other.historicalEntries) &&
        selectedDate == other.selectedDate &&
        isMarkingCompletion == other.isMarkingCompletion &&
        isDeleting == other.isDeleting &&
        isCreating == other.isCreating &&
        isRefreshing == other.isRefreshing &&
        loadingHabitId == other.loadingHabitId;
    
    // Log equality comparison for debugging
    if (!isEqual) {
      AppLogger.i('HabitLoaded equality check failed - states are different', tag: 'HabitState');
      AppLogger.i('  habits: ${habits.length} vs ${other.habits.length}', tag: 'HabitState');
      AppLogger.i('  selectedDateEntries: ${selectedDateEntries.length} vs ${other.selectedDateEntries.length}', tag: 'HabitState');
      AppLogger.i('  historicalEntries: ${historicalEntries.length} vs ${other.historicalEntries.length}', tag: 'HabitState');
      AppLogger.i('  selectedDate: $selectedDate vs ${other.selectedDate}', tag: 'HabitState');
      AppLogger.i('  loading flags: $isMarkingCompletion/$isDeleting/$isCreating/$isRefreshing vs ${other.isMarkingCompletion}/${other.isDeleting}/${other.isCreating}/${other.isRefreshing}', tag: 'HabitState');
      AppLogger.i('  loadingHabitId: $loadingHabitId vs ${other.loadingHabitId}', tag: 'HabitState');
    }
    
    return isEqual;
  }

  @override
  int get hashCode {
    return Object.hash(
      const ListEquality().hash(habits),
      const ListEquality().hash(selectedDateEntries),
      const MapEquality(values: ListEquality()).hash(historicalEntries),
      selectedDate,
      isMarkingCompletion,
      isDeleting,
      isCreating,
      isRefreshing,
      loadingHabitId,
    );
  }
}

/// Error state
class HabitError extends HabitState {
  final String message;

  const HabitError({required this.message});

  @override
  String toString() => 'HabitError(message: $message)';
}

/// Initialization error state for database failures
class HabitInitializationError extends HabitState {
  final String message;

  const HabitInitializationError({required this.message});

  @override
  String toString() => 'HabitInitializationError(message: $message)';
}