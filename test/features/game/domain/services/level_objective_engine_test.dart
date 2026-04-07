import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/domain/entities/game_status.dart';
import 'package:shelf_short/features/game/domain/services/level_objective_engine.dart';

void main() {
  const engine = LevelObjectiveEngine();

  group('LevelObjectiveEngine', () {
    test('builds scaled score/combo targets', () {
      final low = engine.buildForLevel(
        level: 1,
        tileCount: 36,
        baseScorePerTriple: 60,
      );
      final high = engine.buildForLevel(
        level: 8,
        tileCount: 72,
        baseScorePerTriple: 60,
      );

      expect(high.targetScore, greaterThan(low.targetScore));
      expect(high.targetCombo, greaterThanOrEqualTo(low.targetCombo));
    });

    test('awards stars only on win and objective completion', () {
      final stars = engine.evaluateStars(
        status: GameStatus.won,
        score: 700,
        bestCombo: 4,
        targetScore: 600,
        targetCombo: 3,
      );

      final failed = engine.evaluateStars(
        status: GameStatus.lost,
        score: 900,
        bestCombo: 8,
        targetScore: 600,
        targetCombo: 3,
      );

      expect(stars, 3);
      expect(failed, 0);
    });
  });
}
