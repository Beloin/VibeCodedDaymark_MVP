/// App configuration entity for user preferences
class AppConfig {
  final String id;
  final ViewType preferredView;
  final int weeksToDisplay;
  final Map<String, String> habitColors; // habitId -> color hex
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppConfig({
    required this.id,
    required this.preferredView,
    required this.weeksToDisplay,
    required this.habitColors,
    required this.createdAt,
    this.updatedAt,
  });

  /// Default configuration
  static AppConfig get defaultConfig => AppConfig(
        id: 'default',
        preferredView: ViewType.calendar,
        weeksToDisplay: 2,
        habitColors: {},
        createdAt: DateTime.now(),
      );

  AppConfig copyWith({
    String? id,
    ViewType? preferredView,
    int? weeksToDisplay,
    Map<String, String>? habitColors,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppConfig(
      id: id ?? this.id,
      preferredView: preferredView ?? this.preferredView,
      weeksToDisplay: weeksToDisplay ?? this.weeksToDisplay,
      habitColors: habitColors ?? this.habitColors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppConfig(id: $id, preferredView: $preferredView, weeksToDisplay: $weeksToDisplay, habitColors: $habitColors)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Available view types for the app
enum ViewType {
  calendar,
  tile,
}

/// Extension for ViewType serialization
extension ViewTypeExtension on ViewType {
  String get name => toString().split('.').last;
  
  static ViewType fromString(String value) {
    return ViewType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ViewType.calendar,
    );
  }
}