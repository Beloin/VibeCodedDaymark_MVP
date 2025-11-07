import 'package:daymark/features/habit_tracker/domain/entities/habit_entry.dart';

/// Data model for HabitEntry entity
class HabitEntryModel extends HabitEntry {
  const HabitEntryModel({
    required super.id,
    required super.habitId,
    required super.date,
    super.isCompleted,
    super.completedAt,
  });

  factory HabitEntryModel.fromJson(Map<String, dynamic> json) {
    return HabitEntryModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: (json['isCompleted'] as int) == 1,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory HabitEntryModel.fromEntity(HabitEntry entry) {
    return HabitEntryModel(
      id: entry.id,
      habitId: entry.habitId,
      date: entry.date,
      isCompleted: entry.isCompleted,
      completedAt: entry.completedAt,
    );
  }

  HabitEntry toEntity() {
    return HabitEntry(
      id: id,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  @override
  HabitEntryModel copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return HabitEntryModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}