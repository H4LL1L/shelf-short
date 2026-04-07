class PlayerProfile {
  const PlayerProfile({
    required this.coins,
    required this.highestUnlockedLevel,
    this.lastPlayedLevel = 1,
    required this.bestScore,
    required this.totalWins,
    required this.totalLosses,
    required this.totalGames,
    required this.totalTriplesCleared,
    required this.totalShufflesUsed,
    required this.totalCoinsEarned,
    required this.playerLevel,
    required this.xp,
    required this.dailyStreak,
    required this.lastPlayedDay,
    required this.levelStars,
  });

  factory PlayerProfile.initial() {
    return const PlayerProfile(
      coins: 250,
      highestUnlockedLevel: 1,
      lastPlayedLevel: 1,
      bestScore: 0,
      totalWins: 0,
      totalLosses: 0,
      totalGames: 0,
      totalTriplesCleared: 0,
      totalShufflesUsed: 0,
      totalCoinsEarned: 0,
      playerLevel: 1,
      xp: 0,
      dailyStreak: 1,
      lastPlayedDay: null,
      levelStars: {},
    );
  }

  final int coins;
  final int highestUnlockedLevel;
  final int lastPlayedLevel;
  final int bestScore;
  final int totalWins;
  final int totalLosses;
  final int totalGames;
  final int totalTriplesCleared;
  final int totalShufflesUsed;
  final int totalCoinsEarned;
  final int playerLevel;
  final int xp;
  final int dailyStreak;
  final String? lastPlayedDay;
  final Map<String, int> levelStars;

  int get totalStars {
    return levelStars.values.fold<int>(0, (sum, value) => sum + value);
  }

  int starsForLevel(int level) {
    return levelStars['$level'] ?? 0;
  }

  PlayerProfile copyWith({
    int? coins,
    int? highestUnlockedLevel,
    int? lastPlayedLevel,
    int? bestScore,
    int? totalWins,
    int? totalLosses,
    int? totalGames,
    int? totalTriplesCleared,
    int? totalShufflesUsed,
    int? totalCoinsEarned,
    int? playerLevel,
    int? xp,
    int? dailyStreak,
    String? lastPlayedDay,
    Map<String, int>? levelStars,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      lastPlayedLevel: lastPlayedLevel ?? this.lastPlayedLevel,
      bestScore: bestScore ?? this.bestScore,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalGames: totalGames ?? this.totalGames,
      totalTriplesCleared: totalTriplesCleared ?? this.totalTriplesCleared,
      totalShufflesUsed: totalShufflesUsed ?? this.totalShufflesUsed,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      playerLevel: playerLevel ?? this.playerLevel,
      xp: xp ?? this.xp,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastPlayedDay: lastPlayedDay ?? this.lastPlayedDay,
      levelStars: levelStars ?? this.levelStars,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'highestUnlockedLevel': highestUnlockedLevel,
      'lastPlayedLevel': lastPlayedLevel,
      'bestScore': bestScore,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'totalGames': totalGames,
      'totalTriplesCleared': totalTriplesCleared,
      'totalShufflesUsed': totalShufflesUsed,
      'totalCoinsEarned': totalCoinsEarned,
      'playerLevel': playerLevel,
      'xp': xp,
      'dailyStreak': dailyStreak,
      'lastPlayedDay': lastPlayedDay,
      'levelStars': levelStars,
    };
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final parsedLastPlayedLevel = _asInt(json['lastPlayedLevel'], fallback: 1);

    return PlayerProfile(
      coins: _asInt(json['coins'], fallback: 250),
      highestUnlockedLevel: _asInt(json['highestUnlockedLevel'], fallback: 1),
      lastPlayedLevel:
          parsedLastPlayedLevel < 1 ? 1 : parsedLastPlayedLevel,
      bestScore: _asInt(json['bestScore']),
      totalWins: _asInt(json['totalWins']),
      totalLosses: _asInt(json['totalLosses']),
      totalGames: _asInt(json['totalGames']),
      totalTriplesCleared: _asInt(json['totalTriplesCleared']),
      totalShufflesUsed: _asInt(json['totalShufflesUsed']),
      totalCoinsEarned: _asInt(json['totalCoinsEarned']),
      playerLevel: _asInt(json['playerLevel'], fallback: 1),
      xp: _asInt(json['xp']),
      dailyStreak: _asInt(json['dailyStreak'], fallback: 1),
      lastPlayedDay: json['lastPlayedDay'] as String?,
      levelStars: _readStars(json['levelStars']),
    );
  }

  static Map<String, int> _readStars(Object? value) {
    if (value is! Map) {
      return <String, int>{};
    }

    final result = <String, int>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      result[key] = _asInt(entry.value);
    }
    return result;
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
