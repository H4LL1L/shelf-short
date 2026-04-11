import 'game_loss_reason.dart';
import 'game_status.dart';
import 'item_kind.dart';
import 'tile_model.dart';

class GameSession {
  GameSession({
    required this.level,
    required this.seed,
    required this.score,
    required this.moves,
    required this.triplesClearedInRun,
    required this.shufflesUsedInRun,
    required this.comboStreak,
    required this.bestComboInRun,
    required this.objectiveTargetScore,
    required this.objectiveTargetCombo,
    required this.starsEarned,
    required this.shuffleCharges,
    required this.status,
    required List<TileModel> boardTiles,
    required List<ItemKind> tray,
    this.levelTimeLimitSeconds = 0,
    this.elapsedPlaySeconds = 0,
    this.lossReason,
    List<List<ItemKind>> shelves = const <List<ItemKind>>[],
    List<bool> closedShelves = const <bool>[],
  })  : boardTiles = List.unmodifiable(boardTiles),
        tray = List.unmodifiable(tray),
        shelves = List.unmodifiable(
          shelves
              .map((shelf) => List<ItemKind>.unmodifiable(shelf))
              .toList(growable: false),
        ),
        closedShelves = List<bool>.unmodifiable(closedShelves);

  factory GameSession.initial() {
    return GameSession(
      level: 1,
      seed: 0,
      score: 0,
      moves: 0,
      triplesClearedInRun: 0,
      shufflesUsedInRun: 0,
      comboStreak: 0,
      bestComboInRun: 0,
      objectiveTargetScore: 0,
      objectiveTargetCombo: 0,
      starsEarned: 0,
      shuffleCharges: 0,
      status: GameStatus.idle,
      boardTiles: <TileModel>[],
      tray: <ItemKind>[],
      shelves: const <List<ItemKind>>[],
      closedShelves: const <bool>[],
    );
  }

  final int level;
  final int seed;
  final int score;
  final int moves;
  final int triplesClearedInRun;
  final int shufflesUsedInRun;
  final int comboStreak;
  final int bestComboInRun;
  final int objectiveTargetScore;
  final int objectiveTargetCombo;
  final int starsEarned;
  final int shuffleCharges;
  final GameStatus status;
  final int levelTimeLimitSeconds;
  final int elapsedPlaySeconds;
  final GameLossReason? lossReason;
  final List<TileModel> boardTiles;
  final List<ItemKind> tray;
  final List<List<ItemKind>> shelves;
  final List<bool> closedShelves;

  int get remainingTiles {
    if (shelves.isNotEmpty) {
      return shelves.fold<int>(0, (sum, shelf) => sum + shelf.length);
    }
    return boardTiles.where((tile) => !tile.isCollected).length;
  }

  bool get isGameOver => status == GameStatus.won || status == GameStatus.lost;

  GameSession copyWith({
    int? level,
    int? seed,
    int? score,
    int? moves,
    int? triplesClearedInRun,
    int? shufflesUsedInRun,
    int? comboStreak,
    int? bestComboInRun,
    int? objectiveTargetScore,
    int? objectiveTargetCombo,
    int? starsEarned,
    int? shuffleCharges,
    GameStatus? status,
    int? levelTimeLimitSeconds,
    int? elapsedPlaySeconds,
    Object? lossReason = _copyLossReasonSentinel,
    List<TileModel>? boardTiles,
    List<ItemKind>? tray,
    List<List<ItemKind>>? shelves,
    List<bool>? closedShelves,
  }) {
    return GameSession(
      level: level ?? this.level,
      seed: seed ?? this.seed,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      triplesClearedInRun: triplesClearedInRun ?? this.triplesClearedInRun,
      shufflesUsedInRun: shufflesUsedInRun ?? this.shufflesUsedInRun,
      comboStreak: comboStreak ?? this.comboStreak,
      bestComboInRun: bestComboInRun ?? this.bestComboInRun,
      objectiveTargetScore: objectiveTargetScore ?? this.objectiveTargetScore,
      objectiveTargetCombo: objectiveTargetCombo ?? this.objectiveTargetCombo,
      starsEarned: starsEarned ?? this.starsEarned,
      shuffleCharges: shuffleCharges ?? this.shuffleCharges,
      status: status ?? this.status,
      levelTimeLimitSeconds: levelTimeLimitSeconds ?? this.levelTimeLimitSeconds,
      elapsedPlaySeconds: elapsedPlaySeconds ?? this.elapsedPlaySeconds,
      lossReason: identical(lossReason, _copyLossReasonSentinel)
          ? this.lossReason
          : lossReason as GameLossReason?,
      boardTiles: boardTiles ?? this.boardTiles,
      tray: tray ?? this.tray,
      shelves: shelves ?? this.shelves,
      closedShelves: closedShelves ?? this.closedShelves,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'seed': seed,
      'score': score,
      'moves': moves,
      'triplesClearedInRun': triplesClearedInRun,
      'shufflesUsedInRun': shufflesUsedInRun,
      'comboStreak': comboStreak,
      'bestComboInRun': bestComboInRun,
      'objectiveTargetScore': objectiveTargetScore,
      'objectiveTargetCombo': objectiveTargetCombo,
      'starsEarned': starsEarned,
      'shuffleCharges': shuffleCharges,
      'status': status.name,
      'levelTimeLimitSeconds': levelTimeLimitSeconds,
      'elapsedPlaySeconds': elapsedPlaySeconds,
      'lossReason': lossReason?.name,
      'boardTiles': boardTiles.map((tile) => tile.toJson()).toList(),
      'tray': tray.map((kind) => kind.name).toList(),
      'shelves': shelves
          .map((shelf) => shelf.map((kind) => kind.name).toList())
          .toList(),
      'closedShelves': closedShelves,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    final boardRaw = json['boardTiles'] as List<dynamic>? ?? const [];
    final trayRaw = json['tray'] as List<dynamic>? ?? const [];
    final shelvesRaw = json['shelves'] as List<dynamic>? ?? const [];
    final closedShelvesRaw = json['closedShelves'] as List<dynamic>? ?? const [];

    return GameSession(
      level: _asInt(json['level'], fallback: 1),
      seed: _asInt(json['seed']),
      score: _asInt(json['score']),
      moves: _asInt(json['moves']),
      triplesClearedInRun: _asInt(json['triplesClearedInRun']),
      shufflesUsedInRun: _asInt(json['shufflesUsedInRun']),
      comboStreak: _asInt(json['comboStreak']),
      bestComboInRun: _asInt(json['bestComboInRun']),
      objectiveTargetScore: _asInt(json['objectiveTargetScore']),
      objectiveTargetCombo: _asInt(json['objectiveTargetCombo']),
      starsEarned: _asInt(json['starsEarned']),
      shuffleCharges: _asInt(json['shuffleCharges']),
      status: GameStatusX.parse(json['status'] as String?),
      levelTimeLimitSeconds: _asInt(json['levelTimeLimitSeconds']),
      elapsedPlaySeconds: _asInt(json['elapsedPlaySeconds']),
      lossReason: GameLossReasonX.parse(json['lossReason'] as String?),
      boardTiles: boardRaw
          .map((item) => TileModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      tray: trayRaw.map((item) => _parseKind(item as String?)).toList(),
      shelves: shelvesRaw.map((shelfRaw) {
        final list = shelfRaw as List<dynamic>;
        return list.map((item) => _parseKind(item as String?)).toList();
      }).toList(),
      closedShelves: closedShelvesRaw
          .map((value) => value as bool? ?? false)
          .toList(),
    );
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static ItemKind _parseKind(String? raw) {
    return ItemKind.values.firstWhere(
      (kind) => kind.name == raw,
      orElse: () => ItemKind.milk,
    );
  }
}

const Object _copyLossReasonSentinel = Object();
