class AppSettings {
  const AppSettings({
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.reducedMotion,
  });

  factory AppSettings.initial() {
    return const AppSettings(
      soundEnabled: true,
      hapticEnabled: true,
      reducedMotion: false,
    );
  }

  final bool soundEnabled;
  final bool hapticEnabled;
  final bool reducedMotion;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? reducedMotion,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'hapticEnabled': hapticEnabled,
      'reducedMotion': reducedMotion,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticEnabled: json['hapticEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }
}
