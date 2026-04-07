import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/domain/entities/item_kind.dart';
import 'package:shelf_short/features/game/domain/services/match_resolver.dart';

void main() {
  group('MatchResolver', () {
    const resolver = MatchResolver();

    test('clears one triple and grants base score', () {
      final result = resolver.resolveAfterAdding(
        currentTray: const [ItemKind.milk, ItemKind.milk],
        addedKind: ItemKind.milk,
        baseScorePerTriple: 60,
        comboBonusPerTriple: 20,
      );

      expect(result.nextTray, isEmpty);
      expect(result.clearedTriples, 1);
      expect(result.scoreGain, 60);
    });

    test('clears chained triples and grants combo bonus', () {
      final result = resolver.resolveAfterAdding(
        currentTray: const [
          ItemKind.milk,
          ItemKind.milk,
          ItemKind.bread,
          ItemKind.bread,
          ItemKind.bread,
        ],
        addedKind: ItemKind.milk,
        baseScorePerTriple: 60,
        comboBonusPerTriple: 20,
      );

      expect(result.nextTray, isEmpty);
      expect(result.clearedTriples, 2);
      expect(result.scoreGain, 140);
    });

    test('does not clear when tray has no triple', () {
      final result = resolver.resolveAfterAdding(
        currentTray: const [ItemKind.milk, ItemKind.bread],
        addedKind: ItemKind.fish,
        baseScorePerTriple: 60,
        comboBonusPerTriple: 20,
      );

      expect(result.nextTray, const [ItemKind.milk, ItemKind.bread, ItemKind.fish]);
      expect(result.clearedTriples, 0);
      expect(result.scoreGain, 0);
    });
  });
}
