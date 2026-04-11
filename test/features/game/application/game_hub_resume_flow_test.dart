import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/application/game_controller.dart';
import 'package:shelf_short/features/game/application/game_hub_controller.dart';
import 'package:shelf_short/features/game/data/run_session_repository.dart';
import 'package:shelf_short/features/game/domain/entities/game_session.dart';
import 'package:shelf_short/features/game/domain/entities/game_status.dart';
import 'package:shelf_short/features/game/domain/entities/item_kind.dart';
import 'package:shelf_short/features/game/domain/entities/tile_model.dart';
import 'package:shelf_short/features/meta/application/progress_controller.dart';
import 'package:shelf_short/features/meta/data/progress_repository.dart';
import 'package:shelf_short/features/meta/domain/entities/progress_snapshot.dart';

void main() {
  group('GameHubController resume flow', () {
    test('restores paused run from repository', () async {
      final runRepo = _MemoryRunRepo(
        initial: GameSession(
          level: 3,
          seed: 77,
          score: 240,
          moves: 5,
          triplesClearedInRun: 2,
          shufflesUsedInRun: 1,
          comboStreak: 1,
          bestComboInRun: 3,
          objectiveTargetScore: 300,
          objectiveTargetCombo: 3,
          starsEarned: 1,
          shuffleCharges: 1,
          status: GameStatus.paused,
          levelTimeLimitSeconds: 180,
          elapsedPlaySeconds: 64,
          boardTiles: const [
            TileModel(id: 'a', kind: ItemKind.milk),
            TileModel(id: 'b', kind: ItemKind.milk),
            TileModel(id: 'c', kind: ItemKind.milk),
          ],
          tray: const [ItemKind.bread],
        ),
      );

      final hub = GameHubController(
        gameController: GameController(),
        progressController: ProgressController(repository: _ProgressRepo()),
        runSessionRepository: runRepo,
      );

      await hub.initialize();

      expect(hub.hasRestorableRun, isTrue);
      expect(hub.gameController.session.level, 3);
      expect(hub.gameController.session.status, GameStatus.paused);
      expect(hub.gameController.currentRemainingSeconds, 116);

      final resumed = hub.resumeActiveRun();
      expect(resumed, isTrue);
      expect(hub.gameController.session.status, GameStatus.playing);
    });

    test('exitToHome pauses and keeps run persistent', () async {
      final runRepo = _MemoryRunRepo();
      final hub = GameHubController(
        gameController: GameController(),
        progressController: ProgressController(repository: _ProgressRepo()),
        runSessionRepository: runRepo,
      );

      await hub.initialize();
      hub.startLevel(level: 1, seed: 123);
      await Future<void>.delayed(Duration.zero);

      hub.exitToHome();
      await Future<void>.delayed(Duration.zero);

      expect(hub.gameController.session.status, GameStatus.paused);
      expect(hub.hasRestorableRun, isTrue);
      expect(runRepo.lastSaved, isNotNull);
    });
  });
}

class _ProgressRepo implements ProgressRepository {
  ProgressSnapshot _snapshot = ProgressSnapshot.initial();

  @override
  Future<ProgressSnapshot> load() async => _snapshot;

  @override
  Future<void> save(ProgressSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}

class _MemoryRunRepo implements RunSessionRepository {
  _MemoryRunRepo({GameSession? initial}) : _stored = initial;

  GameSession? _stored;

  GameSession? get lastSaved => _stored;

  @override
  Future<void> clear() async {
    _stored = null;
  }

  @override
  Future<GameSession?> load() async => _stored;

  @override
  Future<void> save(GameSession session) async {
    _stored = session;
  }
}
