enum AchievementMetric {
  wins,
  triples,
  coinsEarned,
  highestLevel,
}

class AchievementBadge {
  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.goal,
    required this.rewardCoins,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int goal;
  final int rewardCoins;
  final bool isUnlocked;

  AchievementBadge copyWith({
    String? id,
    String? title,
    String? description,
    AchievementMetric? metric,
    int? goal,
    int? rewardCoins,
    bool? isUnlocked,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      metric: metric ?? this.metric,
      goal: goal ?? this.goal,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'metric': metric.name,
      'goal': goal,
      'rewardCoins': rewardCoins,
      'isUnlocked': isUnlocked,
    };
  }

  factory AchievementBadge.fromJson(Map<String, dynamic> json) {
    return AchievementBadge(
      id: json['id'] as String? ?? 'unknown_achievement',
      title: json['title'] as String? ?? 'Achievement',
      description: json['description'] as String? ?? '',
      metric: _parseMetric(json['metric'] as String?),
      goal: _asInt(json['goal'], fallback: 1),
      rewardCoins: _asInt(json['rewardCoins'], fallback: 100),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  static AchievementMetric _parseMetric(String? raw) {
    return AchievementMetric.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => AchievementMetric.wins,
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
