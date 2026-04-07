import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_short/features/game/domain/entities/item_kind.dart';
import 'package:shelf_short/features/game/domain/services/board_generation_request.dart';
import 'package:shelf_short/features/game/domain/services/board_generator.dart';

void main() {
  group('BoardGenerator', () {
    const generator = BoardGenerator();

    test('creates tile count and valid triples', () {
      final board = generator.generate(
        const BoardGenerationRequest(seed: 11, tileCount: 36, variety: 6),
      );

      expect(board, hasLength(36));

      final counts = <ItemKind, int>{};
      for (final tile in board) {
        counts[tile.kind] = (counts[tile.kind] ?? 0) + 1;
      }

      for (final count in counts.values) {
        expect(count % 3, 0);
      }
    });

    test('shuffle remaining keeps kind multiset and collected tiles', () {
      final board = generator.generate(
        const BoardGenerationRequest(seed: 99, tileCount: 24, variety: 4),
      );

      final marked = board.asMap().entries.map((entry) {
        if (entry.key < 3) {
          return entry.value.copyWith(isCollected: true);
        }
        return entry.value;
      }).toList();

      final beforeCounts = _countKinds(marked
          .where((tile) => !tile.isCollected)
          .map((tile) => tile.kind)
          .toList());

      final shuffled = generator.shuffleRemaining(boardTiles: marked, seed: 1234);

      final afterCounts = _countKinds(shuffled
          .where((tile) => !tile.isCollected)
          .map((tile) => tile.kind)
          .toList());

      expect(afterCounts, beforeCounts);
      expect(shuffled.take(3).every((tile) => tile.isCollected), isTrue);
    });
  });
}

Map<ItemKind, int> _countKinds(List<ItemKind> kinds) {
  final counts = <ItemKind, int>{};
  for (final kind in kinds) {
    counts[kind] = (counts[kind] ?? 0) + 1;
  }
  return counts;
}
