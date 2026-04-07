import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/application/game_controller.dart';
import 'package:shelf_short/features/game/application/game_hub_controller.dart';
import 'package:shelf_short/features/meta/application/progress_controller.dart';
import 'package:shelf_short/features/meta/data/progress_repository.dart';
import 'package:shelf_short/features/meta/domain/entities/progress_snapshot.dart';

import 'package:shelf_short/main.dart';

void main() {
  testWidgets('Home screen renders key actions', (WidgetTester tester) async {
    final hub = GameHubController(
      gameController: GameController(),
      progressController: ProgressController(
        repository: _InMemoryRepository(),
      ),
    );
    await hub.initialize();

    await tester.pumpWidget(ShelfRushApp(hub: hub));

    expect(find.text('Shelf Rush'), findsOneWidget);
    expect(find.text('Start New Run'), findsOneWidget);
    expect(find.textContaining('Jump To L'), findsOneWidget);
  });
}

class _InMemoryRepository implements ProgressRepository {
  ProgressSnapshot _snapshot = ProgressSnapshot.initial();

  @override
  Future<ProgressSnapshot> load() async => _snapshot;

  @override
  Future<void> save(ProgressSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}
