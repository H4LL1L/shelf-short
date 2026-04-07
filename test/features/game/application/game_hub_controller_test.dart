import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/application/game_controller.dart';
import 'package:shelf_short/features/game/application/game_hub_controller.dart';
import 'package:shelf_short/features/meta/application/progress_controller.dart';
import 'package:shelf_short/features/meta/data/progress_repository.dart';
import 'package:shelf_short/features/meta/domain/entities/progress_snapshot.dart';

void main() {
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
