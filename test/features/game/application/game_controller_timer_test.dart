import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/core/constants/game_config.dart';
import 'package:shelf_short/features/game/application/game_controller.dart';
import 'package:shelf_short/features/game/domain/entities/game_loss_reason.dart';
import 'package:shelf_short/features/game/domain/entities/game_status.dart';

void main() {
  group('GameController timer pacing', () {
    test('counts down while playing and stays frozen while paused', () {
      final clock = _FakeClock(DateTime(2026, 1, 1, 12));
      final controller = GameController(
        config: const GameConfig(
          baseTiles: 12,
          tilesPerLevel: 0,
          maxTiles: 12,
          baseLevelTimeSeconds: 12,
          secondsPerTriple: 0,
          secondsPerLevelStep: 0,
          maxLevelTimeSeconds: 12,
        ),
        now: clock.now,
      );

      controller.startLevel(level: 1, seed: 11);
      expect(controller.currentRemainingSeconds, 12);

      clock.advance(const Duration(seconds: 5));
      expect(controller.currentRemainingSeconds, 7);

      controller.pause();
      expect(controller.session.status, GameStatus.paused);
      expect(controller.currentRemainingSeconds, 7);

      clock.advance(const Duration(seconds: 3));
      expect(controller.currentRemainingSeconds, 7);

      controller.resume();
      expect(controller.session.status, GameStatus.playing);
      expect(controller.currentRemainingSeconds, 7);
    });

    test('loses with timeExpired reason after timer runs out', () {
      final clock = _FakeClock(DateTime(2026, 1, 1, 12));
      final controller = GameController(
        config: const GameConfig(
          baseTiles: 12,
          tilesPerLevel: 0,
          maxTiles: 12,
          baseLevelTimeSeconds: 9,
          secondsPerTriple: 0,
          secondsPerLevelStep: 0,
          maxLevelTimeSeconds: 9,
        ),
        now: clock.now,
      );

      controller.startLevel(level: 1, seed: 22);
      clock.advance(const Duration(seconds: 9));

      controller.heartbeat();

      expect(controller.session.status, GameStatus.lost);
      expect(controller.session.lossReason, GameLossReason.timeExpired);
      expect(controller.currentRemainingSeconds, 0);
    });
  });
}

class _FakeClock {
  _FakeClock(this._value);

  DateTime _value;

  DateTime now() => _value;

  void advance(Duration duration) {
    _value = _value.add(duration);
  }
}
