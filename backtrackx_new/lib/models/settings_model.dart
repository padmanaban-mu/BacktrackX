/// User preferences persisted locally.
class SettingsModel {
  final double animationSpeed; // 0.5x to 3.0x
  final bool soundEnabled;
  final bool darkMode;
  final bool showHints;

  const SettingsModel({
    this.animationSpeed = 1.0,
    this.soundEnabled = true,
    this.darkMode = false,
    this.showHints = true,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      animationSpeed: (json['animationSpeed'] as num?)?.toDouble() ?? 1.0,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? false,
      showHints: json['showHints'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animationSpeed': animationSpeed,
      'soundEnabled': soundEnabled,
      'darkMode': darkMode,
      'showHints': showHints,
    };
  }

  SettingsModel copyWith({
    double? animationSpeed,
    bool? soundEnabled,
    bool? darkMode,
    bool? showHints,
  }) {
    return SettingsModel(
      animationSpeed: animationSpeed ?? this.animationSpeed,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkMode: darkMode ?? this.darkMode,
      showHints: showHints ?? this.showHints,
    );
  }
}
