/// Habit entity representing a daily habit to track
class Habit {
  final String id;
  final String name;
  final String description;
  final String color; // Hex color code for the habit
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const Habit({
    required this.id,
    required this.name,
    required this.description,
    this.color = '#2196F3', // Default blue color
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}