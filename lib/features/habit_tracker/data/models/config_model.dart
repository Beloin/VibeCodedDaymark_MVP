import 'package:daymark/features/habit_tracker/domain/entities/app_config.dart';

/// Data model for app configuration persistence
class ConfigModel {
  final String id;
  final String preferredView;
  final int weeksToDisplay;
  final String habitColorsJson;
  final String createdAt;
  final String? updatedAt;

  const ConfigModel({
    required this.id,
    required this.preferredView,
    required this.weeksToDisplay,
    required this.habitColorsJson,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert entity to model
  factory ConfigModel.fromEntity(AppConfig entity) {
    return ConfigModel(
      id: entity.id,
      preferredView: entity.preferredView.name,
      weeksToDisplay: entity.weeksToDisplay,
      habitColorsJson: _mapToJson(entity.habitColors),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Convert model to entity
  AppConfig toEntity() {
    return AppConfig(
      id: id,
      preferredView: ViewTypeExtension.fromString(preferredView),
      weeksToDisplay: weeksToDisplay,
      habitColors: _jsonToMap(habitColorsJson),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preferredView': preferredView,
      'weeksToDisplay': weeksToDisplay,
      'habitColorsJson': habitColorsJson,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create from JSON
  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      id: json['id'] as String,
      preferredView: json['preferredView'] as String,
      weeksToDisplay: json['weeksToDisplay'] as int,
      habitColorsJson: json['habitColorsJson'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Copy with updated fields
  ConfigModel copyWith({
    String? id,
    String? preferredView,
    int? weeksToDisplay,
    String? habitColorsJson,
    String? createdAt,
    String? updatedAt,
  }) {
    return ConfigModel(
      id: id ?? this.id,
      preferredView: preferredView ?? this.preferredView,
      weeksToDisplay: weeksToDisplay ?? this.weeksToDisplay,
      habitColorsJson: habitColorsJson ?? this.habitColorsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert map to JSON string
  static String _mapToJson(Map<String, String> map) {
    return map.entries.map((entry) => '${entry.key}:${entry.value}').join(',');
  }

  /// Convert JSON string to map
  static Map<String, String> _jsonToMap(String json) {
    if (json.isEmpty) return {};
    final entries = json.split(',');
    final map = <String, String>{};
    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}