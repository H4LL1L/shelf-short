import '../entities/item_kind.dart';

class MatchResolution {
  const MatchResolution({
    required this.nextTray,
    required this.clearedTriples,
    required this.scoreGain,
  });

  final List<ItemKind> nextTray;
  final int clearedTriples;
  final int scoreGain;
}

class MatchResolver {
  const MatchResolver();

  MatchResolution resolveAfterAdding({
    required List<ItemKind> currentTray,
    required ItemKind addedKind,
    required int baseScorePerTriple,
    required int comboBonusPerTriple,
  }) {
    final tray = List<ItemKind>.from(currentTray)..add(addedKind);
    var clearedTriples = 0;

    while (true) {
      final removable = _firstRemovableKind(tray);
      if (removable == null) {
        break;
      }

      var removed = 0;
      tray.removeWhere((kind) {
        if (kind == removable && removed < 3) {
          removed += 1;
          return true;
        }
        return false;
      });
      clearedTriples += 1;
    }

    final scoreGain = _calculateScoreGain(
      baseScorePerTriple: baseScorePerTriple,
      comboBonusPerTriple: comboBonusPerTriple,
      clearedTriples: clearedTriples,
    );

    return MatchResolution(
      nextTray: tray,
      clearedTriples: clearedTriples,
      scoreGain: scoreGain,
    );
  }

  ItemKind? _firstRemovableKind(List<ItemKind> tray) {
    final counts = <ItemKind, int>{};
    for (final kind in tray) {
      counts[kind] = (counts[kind] ?? 0) + 1;
    }

    for (final entry in counts.entries) {
      if (entry.value >= 3) {
        return entry.key;
      }
    }
    return null;
  }

  int _calculateScoreGain({
    required int baseScorePerTriple,
    required int comboBonusPerTriple,
    required int clearedTriples,
  }) {
    if (clearedTriples == 0) {
      return 0;
    }

    final base = baseScorePerTriple * clearedTriples;
    final combo = (clearedTriples - 1) * comboBonusPerTriple;
    return base + combo;
  }
}
