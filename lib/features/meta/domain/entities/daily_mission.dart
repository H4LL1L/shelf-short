enum MissionType {
  winLevels,
  clearTriples,
  useShuffle,
  earnCoins,
}

class DailyMission {
  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.progress,
    required this.rewardCoins,
    required this.type,
    required this.isClaimed,
  });

  final String id;
  final String title;
  final String description;
  final int goal;
  final int progress;
  final int rewardCoins;
  final MissionType type;
  final bool isClaimed;

  bool get isCompleted => progress >= goal;

  DailyMission copyWith({
    String? id,
    String? title,
    String? description,
    int? goal,
    int? progress,
    int? rewardCoins,
    MissionType? type,
    bool? isClaimed,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goal: goal ?? this.goal,
      progress: progress ?? this.progress,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      type: type ?? this.type,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goal': goal,
      'progress': progress,
      'rewardCoins': rewardCoins,
      'type': type.name,
      'isClaimed': isClaimed,
    };
  }

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      id: json['id'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Mission',
      description: json['description'] as String? ?? '',
      goal: _asInt(json['goal'], fallback: 1),
      progress: _asInt(json['progress']),
      rewardCoins: _asInt(json['rewardCoins'], fallback: 40),
      type: _parseType(json['type'] as String?),
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }

  static MissionType _parseType(String? raw) {
    return MissionType.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => MissionType.clearTriples,
    );
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }
}
