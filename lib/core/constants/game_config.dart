import 'dart:math';

class GameConfig {
  const GameConfig({
    this.trayCapacity = 7,
    this.shelfCapacity = 4,
    this.minShelves = 40,
    this.extraEmptyShelves = 16,
    this.matchGroupMin = 3,
    this.matchGroupMax = 4,
    this.baseTiles = 84,
    this.tilesPerLevel = 6,
    this.maxTiles = 132,
    this.baseVariety = 10,
    this.maxVariety = 12,
    this.baseShuffleCharges = 1,
    this.baseScorePerTriple = 60,
    this.comboBonusPerTriple = 20,
    this.comboStreakBonusPerStep = 15,
    this.baseLevelTimeSeconds = 80,
    this.secondsPerTriple = 3,
    this.secondsPerLevelStep = 3,
    this.maxLevelTimeSeconds = 240,
  });

  final int trayCapacity;
  final int shelfCapacity;
  final int minShelves;
  final int extraEmptyShelves;
  final int matchGroupMin;
  final int matchGroupMax;
  final int baseTiles;
  final int tilesPerLevel;
  final int maxTiles;
  final int baseVariety;
  final int maxVariety;
  final int baseShuffleCharges;
  final int baseScorePerTriple;
  final int comboBonusPerTriple;
  final int comboStreakBonusPerStep;
  final int baseLevelTimeSeconds;
  final int secondsPerTriple;
  final int secondsPerLevelStep;
  final int maxLevelTimeSeconds;

  int tileCountForLevel(int level) {
    final scaled = baseTiles + ((level - 1) * tilesPerLevel);
    final capped = min(maxTiles, scaled);
    final divisibleByThree = capped - (capped % 3);
    return max(3, divisibleByThree);
  }

  int varietyForLevel(int level, int availableKinds) {
    final scaled = baseVariety + ((level - 1) ~/ 2);
    final cappedByConfig = min(maxVariety, scaled);
    return min(max(3, cappedByConfig), availableKinds);
  }

  int shelfCountForTiles(int tileCount) {
    final requiredShelves = (tileCount / shelfCapacity).ceil();
    return max(minShelves, requiredShelves + extraEmptyShelves);
  }

  int levelTimeLimitFor({
    required int level,
    required int tileCount,
  }) {
    final triples = max(1, tileCount ~/ 3);
    final scaled =
        baseLevelTimeSeconds +
        (triples * secondsPerTriple) +
        ((max(1, level) - 1) * secondsPerLevelStep);
    return min(maxLevelTimeSeconds, scaled);
  }
}
