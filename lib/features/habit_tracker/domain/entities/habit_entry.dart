/// Habit entry entity representing a single day's completion status
class HabitEntry {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final DateTime? completedAt;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.completedAt,
  });

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'HabitEntry(id: $id, habitId: $habitId, date: $date, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}