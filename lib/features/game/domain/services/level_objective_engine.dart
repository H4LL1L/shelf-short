import 'dart:math';

import '../entities/game_status.dart';

class LevelObjectives {
  const LevelObjectives({
    required this.targetScore,
    required this.targetCombo,
  });

  final int targetScore;
  final int targetCombo;
}

class LevelObjectiveEngine {
  const LevelObjectiveEngine();

  LevelObjectives buildForLevel({
    required int level,
    required int tileCount,
    required int baseScorePerTriple,
  }) {
    final triplesInLevel = max(1, tileCount ~/ 3);
    final targetScore = (triplesInLevel * baseScorePerTriple) + (level * 45);
    final targetCombo = min(6, 2 + ((level - 1) ~/ 3));

    return LevelObjectives(
      targetScore: targetScore,
      targetCombo: targetCombo,
    );
  }

  int evaluateStars({
    required GameStatus status,
    required int score,
    required int bestCombo,
    required int targetScore,
    required int targetCombo,
  }) {
    if (status != GameStatus.won) {
      return 0;
    }

    var stars = 1;
    if (score >= targetScore) {
      stars += 1;
    }
    if (bestCombo >= targetCombo) {
      stars += 1;
    }
    return stars;
  }
}
