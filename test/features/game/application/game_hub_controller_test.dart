import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/application/game_controller.dart';
import 'package:shelf_short/features/game/application/game_hub_controller.dart';
import 'package:shelf_short/features/game/domain/entities/game_session.dart';
import 'package:shelf_short/features/game/domain/entities/game_status.dart';
import 'package:shelf_short/features/game/domain/entities/item_kind.dart';
import 'package:shelf_short/features/game/domain/entities/shelf_hint_move.dart';
import 'package:shelf_short/features/game/domain/entities/tile_model.dart';
import 'package:shelf_short/features/meta/application/progress_controller.dart';
import 'package:shelf_short/features/meta/data/progress_repository.dart';
import 'package:shelf_short/features/meta/domain/entities/progress_snapshot.dart';

void main() {
  group('GameHubController boosters', () {
    test('buyExtraShuffle spends coins and grants charge', () async {
      final hub = GameHubController(
        gameController: GameController(),
        progressController: ProgressController(repository: _MemoryRepo()),
        extraShuffleCost: 100,
      );

      await hub.initialize();
      hub.startLevel(level: 1, seed: 123);

      final beforeCharges = hub.gameController.session.shuffleCharges;
      final beforeCoins = hub.progressController.profile.coins;

      final purchased = hub.buyExtraShuffle();

      expect(purchased, isTrue);
      expect(hub.gameController.session.shuffleCharges, beforeCharges + 1);
      expect(hub.progressController.profile.coins, beforeCoins - 100);
    });

    test('useHint spends coins and returns a recommended move', () async {
      final hub = GameHubController(
        gameController: GameController(),
        progressController: ProgressController(repository: _MemoryRepo()),
        hintCost: 80,
      );

      await hub.initialize();
      hub.gameController.restoreSession(
        GameSession(
          level: 3,
          seed: 99,
          score: 0,
          moves: 0,
          triplesClearedInRun: 0,
          shufflesUsedInRun: 0,
          comboStreak: 0,
          bestComboInRun: 0,
          objectiveTargetScore: 100,
          objectiveTargetCombo: 2,
          starsEarned: 0,
          shuffleCharges: 1,
          status: GameStatus.playing,
          levelTimeLimitSeconds: 120,
          elapsedPlaySeconds: 10,
          boardTiles: const [
            TileModel(id: 'a', kind: ItemKind.milk),
            TileModel(id: 'b', kind: ItemKind.milk),
            TileModel(id: 'c', kind: ItemKind.milk),
          ],
          tray: const [],
          shelves: const [
            [ItemKind.milk, ItemKind.milk],
            [ItemKind.milk],
            [],
          ],
          closedShelves: const [false, false, false],
        ),
      );

      final beforeCoins = hub.progressController.profile.coins;
      final move = hub.useHint();

      expect(move, const ShelfHintMove(fromShelf: 1, fromSlot: 0, toShelf: 0));
      expect(hub.progressController.profile.coins, beforeCoins - 80);
    });

    test('buyExtraTime spends coins and extends level timer', () async {
      final hub = GameHubController(
        gameController: GameController(),
        progressController: ProgressController(repository: _MemoryRepo()),
        extraTimeCost: 70,
        extraTimeSeconds: 20,
      );

      await hub.initialize();
      hub.startLevel(level: 1, seed: 321);

      final beforeCoins = hub.progressController.profile.coins;
      final beforeLimit = hub.gameController.session.levelTimeLimitSeconds;

      final purchased = hub.buyExtraTime();

      expect(purchased, isTrue);
      expect(
        hub.gameController.session.levelTimeLimitSeconds,
        beforeLimit + 20,
      );
      expect(hub.progressController.profile.coins, beforeCoins - 70);
    });
  });
}

class _MemoryRepo implements ProgressRepository {
  ProgressSnapshot _snapshot = ProgressSnapshot.initial();

  @override
  Future<ProgressSnapshot> load() async => _snapshot;

  @override
  Future<void> save(ProgressSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}
