import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/meta/application/progress_controller.dart';
import 'package:shelf_short/features/meta/data/progress_repository.dart';
import 'package:shelf_short/features/meta/domain/entities/progress_snapshot.dart';

void main() {
  group('ProgressController', () {
    test('records win rewards and mission progression', () async {
      final controller = ProgressController(
        repository: _MemoryRepo(),
        now: () => DateTime(2026, 4, 7),
      );

      await controller.initialize();
      final initialCoins = controller.profile.coins;

      controller.recordMatchFinished(
        won: true,
        level: 1,
        score: 420,
        starsEarned: 3,
      );

      expect(controller.profile.totalWins, 1);
      expect(controller.profile.totalGames, 1);
      expect(controller.profile.coins, greaterThan(initialCoins));
      expect(controller.profile.starsForLevel(1), 3);
      expect(controller.dailyMissions, isNotEmpty);
    });

    test('claims completed mission reward', () async {
      final controller = ProgressController(
        repository: _MemoryRepo(),
        now: () => DateTime(2026, 4, 7),
      );
      await controller.initialize();

      controller.recordTriplesCleared(400);
      final mission = controller.dailyMissions.firstWhere((item) =>
          item.isCompleted &&
          !item.isClaimed);

      final beforeCoins = controller.profile.coins;
      final reward = controller.claimMissionReward(mission.id);

      expect(reward, greaterThan(0));
      expect(controller.profile.coins, beforeCoins + reward);
    });

    test('claims all completed missions in one call', () async {
      final controller = ProgressController(
        repository: _MemoryRepo(),
        now: () => DateTime(2026, 4, 7),
      );
      await controller.initialize();

      controller.recordTriplesCleared(1000);
      controller.recordMatchFinished(
        won: true,
        level: 2,
        score: 1200,
        starsEarned: 3,
      );

      final before = controller.profile.coins;
      final totalReward = controller.claimAllMissionRewards();

      expect(totalReward, greaterThan(0));
      expect(controller.profile.coins, before + totalReward);
      expect(
        controller.dailyMissions.every((mission) => mission.isClaimed || !mission.isCompleted),
        isTrue,
      );
    });

    test('tracks last played level from start and finish flows', () async {
      final controller = ProgressController(
        repository: _MemoryRepo(),
        now: () => DateTime(2026, 4, 7),
      );
      await controller.initialize();

      expect(controller.profile.lastPlayedLevel, 1);

      controller.recordLevelStarted(4);
      expect(controller.profile.lastPlayedLevel, 4);

      controller.recordMatchFinished(
        won: false,
        level: 6,
        score: 120,
        starsEarned: 0,
      );
      expect(controller.profile.lastPlayedLevel, 6);
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
