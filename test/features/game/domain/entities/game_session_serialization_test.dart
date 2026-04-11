import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/domain/entities/game_loss_reason.dart';
import 'package:shelf_short/features/game/domain/entities/game_session.dart';
import 'package:shelf_short/features/game/domain/entities/game_status.dart';
import 'package:shelf_short/features/game/domain/entities/item_kind.dart';
import 'package:shelf_short/features/game/domain/entities/tile_model.dart';

void main() {
  test('GameSession toJson/fromJson roundtrip', () {
    final session = GameSession(
      level: 2,
      seed: 420,
      score: 300,
      moves: 8,
      triplesClearedInRun: 4,
      shufflesUsedInRun: 1,
      comboStreak: 2,
      bestComboInRun: 5,
      objectiveTargetScore: 500,
      objectiveTargetCombo: 4,
      starsEarned: 2,
      shuffleCharges: 2,
      status: GameStatus.playing,
      levelTimeLimitSeconds: 180,
      elapsedPlaySeconds: 47,
      lossReason: GameLossReason.noMoves,
      boardTiles: const [
        TileModel(id: 't1', kind: ItemKind.apple),
        TileModel(id: 't2', kind: ItemKind.bread, isCollected: true),
      ],
      tray: const [ItemKind.apple, ItemKind.apple],
    );

    final encoded = session.toJson();
    final restored = GameSession.fromJson(encoded);

    expect(restored.level, session.level);
    expect(restored.seed, session.seed);
    expect(restored.score, session.score);
    expect(restored.moves, session.moves);
    expect(restored.triplesClearedInRun, session.triplesClearedInRun);
    expect(restored.shufflesUsedInRun, session.shufflesUsedInRun);
    expect(restored.comboStreak, session.comboStreak);
    expect(restored.bestComboInRun, session.bestComboInRun);
    expect(restored.objectiveTargetScore, session.objectiveTargetScore);
    expect(restored.objectiveTargetCombo, session.objectiveTargetCombo);
    expect(restored.starsEarned, session.starsEarned);
    expect(restored.shuffleCharges, session.shuffleCharges);
    expect(restored.status, session.status);
    expect(restored.levelTimeLimitSeconds, session.levelTimeLimitSeconds);
    expect(restored.elapsedPlaySeconds, session.elapsedPlaySeconds);
    expect(restored.lossReason, session.lossReason);
    expect(restored.boardTiles, hasLength(2));
    expect(restored.boardTiles[1].isCollected, isTrue);
    expect(restored.tray, session.tray);
  });
}
