enum TelemetryEventType {
  appOpen,
  runRestored,
  levelStart,
  tileTap,
  tripleClear,
  comboAchieved,
  shuffleUsed,
  undoUsed,
  boosterPurchase,
  missionClaim,
  pause,
  resume,
  runExit,
  levelComplete,
  levelFailed,
}

class TelemetryEvent {
  const TelemetryEvent({
    required this.type,
    required this.timestamp,
    required this.properties,
  });

  final TelemetryEventType type;
  final DateTime timestamp;
  final Map<String, Object?> properties;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'properties': properties,
    };
  }

  factory TelemetryEvent.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'] as String?;
    final parsedType = TelemetryEventType.values.firstWhere(
      (item) => item.name == typeRaw,
      orElse: () => TelemetryEventType.appOpen,
    );

    final timestamp = DateTime.tryParse(json['timestamp'] as String? ?? '');

    return TelemetryEvent(
      type: parsedType,
      timestamp: timestamp ?? DateTime.now(),
      properties: _readProperties(json['properties']),
    );
  }

  static Map<String, Object?> _readProperties(Object? raw) {
    if (raw is! Map) {
      return <String, Object?>{};
    }

    final map = <String, Object?>{};
    for (final entry in raw.entries) {
      map[entry.key.toString()] = entry.value;
    }
    return map;
  }
}
