import 'dart:math';

import '../entities/item_kind.dart';
import '../entities/tile_model.dart';
import 'board_generation_request.dart';

class BoardGenerator {
  const BoardGenerator();

  List<TileModel> generate(BoardGenerationRequest request) {
    if (request.tileCount < 3 || request.tileCount % 3 != 0) {
      throw ArgumentError('tileCount must be a positive multiple of 3.');
    }

    final random = Random(request.seed);
    final selectedKinds = _selectKinds(request.variety, random);
    final tripleGroupCount = request.tileCount ~/ 3;

    final bag = <ItemKind>[];
    for (var i = 0; i < tripleGroupCount; i++) {
      final kind = selectedKinds[i % selectedKinds.length];
      bag
        ..add(kind)
        ..add(kind)
        ..add(kind);
    }

    bag.shuffle(random);

    return List<TileModel>.generate(
      request.tileCount,
      (index) => TileModel(
        id: 'tile_${request.seed}_$index',
        kind: bag[index],
      ),
    );
  }

  List<TileModel> shuffleRemaining({
    required List<TileModel> boardTiles,
    required int seed,
  }) {
    final random = Random(seed);

    final remainingIndices = <int>[];
    final remainingKinds = <ItemKind>[];

    for (var i = 0; i < boardTiles.length; i++) {
      final tile = boardTiles[i];
      if (!tile.isCollected) {
        remainingIndices.add(i);
        remainingKinds.add(tile.kind);
      }
    }

    if (remainingKinds.length < 2) {
      return List<TileModel>.from(boardTiles);
    }

    remainingKinds.shuffle(random);

    final next = List<TileModel>.from(boardTiles);
    for (var i = 0; i < remainingIndices.length; i++) {
      final index = remainingIndices[i];
      next[index] = next[index].copyWith(kind: remainingKinds[i]);
    }

    return next;
  }

  List<ItemKind> _selectKinds(int variety, Random random) {
    final pool = List<ItemKind>.from(ItemKind.values)..shuffle(random);
    final safeVariety = variety.clamp(1, ItemKind.values.length);
    return pool.take(safeVariety).toList(growable: false);
  }
}
