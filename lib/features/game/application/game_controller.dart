import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/constants/game_config.dart';
import '../domain/entities/game_loss_reason.dart';
import '../domain/entities/game_session.dart';
import '../domain/entities/game_status.dart';
import '../domain/entities/item_kind.dart';
import '../domain/entities/shelf_hint_move.dart';
import '../domain/entities/tile_model.dart';
import '../domain/services/board_generation_request.dart';
import '../domain/services/board_generator.dart';
import '../domain/services/level_objective_engine.dart';

class GameController extends ChangeNotifier {
  GameController({
    GameConfig? config,
    BoardGenerator? boardGenerator,
    LevelObjectiveEngine? objectiveEngine,
    DateTime Function()? now,
  }) : _config = config ?? const GameConfig(),
       _boardGenerator = boardGenerator ?? const BoardGenerator(),
       _objectiveEngine = objectiveEngine ?? const LevelObjectiveEngine(),
       _now = now ?? DateTime.now;

  final GameConfig _config;
  final BoardGenerator _boardGenerator;
  final LevelObjectiveEngine _objectiveEngine;
  final DateTime Function() _now;

  GameSession _session = GameSession.initial();
  final List<GameSession> _history = <GameSession>[];
  DateTime? _activePlayStartedAt;

  GameSession get session => _session;

  bool get canUndo => _history.isNotEmpty && !_session.isGameOver;

  bool get canShuffle =>
      _session.status == GameStatus.playing &&
      _session.shuffleCharges > 0 &&
      _session.remainingTiles > 1;

  int get shelfCapacity => _config.shelfCapacity;

  int get currentRemainingSeconds {
    final limit = _session.levelTimeLimitSeconds;
    if (limit <= 0) {
      return 0;
    }

    final remaining = limit - _effectiveElapsedPlaySeconds();
    return max(0, remaining);
  }

  ShelfHintMove? findHintMove() {
    if (_session.status != GameStatus.playing || currentRemainingSeconds <= 0) {
      return null;
    }

    ShelfHintMove? bestMove;
    var bestScore = -1;

    for (var fromShelf = 0; fromShelf < _session.shelves.length; fromShelf++) {
      if (_session.closedShelves.length > fromShelf &&
          _session.closedShelves[fromShelf]) {
        continue;
      }

      final source = _session.shelves[fromShelf];
      if (source.isEmpty) {
        continue;
      }

      for (var fromSlot = 0; fromSlot < source.length; fromSlot++) {
        final movingKind = source[fromSlot];
        for (var toShelf = 0; toShelf < _session.shelves.length; toShelf++) {
          if (!_isValidMove(
            shelves: _session.shelves,
            closedShelves: _session.closedShelves,
            fromShelf: fromShelf,
            fromSlot: fromSlot,
            toShelf: toShelf,
          )) {
            continue;
          }

          final target = _session.shelves[toShelf];
          var score = target.isEmpty ? 5 : 30 + (target.length * 15);
          if (_wouldAutoCloseAfterInsert(shelf: target, item: movingKind)) {
            score += 1000;
          }
          if (source.length == 1) {
            score += 20;
          }

          if (score > bestScore) {
            bestScore = score;
            bestMove = ShelfHintMove(
              fromShelf: fromShelf,
              fromSlot: fromSlot,
              toShelf: toShelf,
            );
          }
        }
      }
    }

    return bestMove;
  }

  void heartbeat() {
    _syncTimerIfNeeded();
  }

  bool addTimeSeconds(int seconds) {
    if (seconds <= 0 ||
        _session.status != GameStatus.playing ||
        currentRemainingSeconds <= 0) {
      return false;
    }

    _session = _session.copyWith(
      levelTimeLimitSeconds: _session.levelTimeLimitSeconds + seconds,
      elapsedPlaySeconds: _effectiveElapsedPlaySeconds(),
    );
    _activePlayStartedAt = _now();
    notifyListeners();
    return true;
  }

  void startLevel({required int level, int? seed}) {
    final safeLevel = max(1, level);
    final generatedSeed = seed ?? _now().microsecondsSinceEpoch;

    final tileCount = _config.tileCountForLevel(safeLevel);
    final variety = _config.varietyForLevel(safeLevel, ItemKind.values.length);

    final boardTiles = _boardGenerator.generate(
      BoardGenerationRequest(
        seed: generatedSeed,
        tileCount: tileCount,
        variety: variety,
      ),
    );

    final objectives = _objectiveEngine.buildForLevel(
      level: safeLevel,
      tileCount: tileCount,
      baseScorePerTriple: _config.baseScorePerTriple,
    );

    final shelves = _buildShelves(boardTiles, generatedSeed);
    final closedShelves = List<bool>.filled(shelves.length, false);

    _history.clear();

    _session = GameSession(
      level: safeLevel,
      seed: generatedSeed,
      score: 0,
      moves: 0,
      triplesClearedInRun: 0,
      shufflesUsedInRun: 0,
      comboStreak: 0,
      bestComboInRun: 0,
      objectiveTargetScore: objectives.targetScore,
      objectiveTargetCombo: objectives.targetCombo,
      starsEarned: 0,
      shuffleCharges: _config.baseShuffleCharges,
      status: GameStatus.playing,
      levelTimeLimitSeconds: _config.levelTimeLimitFor(
        level: safeLevel,
        tileCount: tileCount,
      ),
      elapsedPlaySeconds: 0,
      lossReason: null,
      boardTiles: boardTiles,
      tray: const <ItemKind>[],
      shelves: shelves,
      closedShelves: closedShelves,
    );
    _activePlayStartedAt = _now();

    if (!_hasAnyValidMoves(shelves, closedShelves)) {
      _session = _session.copyWith(
        status: GameStatus.lost,
        lossReason: GameLossReason.noMoves,
      );
      _activePlayStartedAt = null;
    }

    notifyListeners();
  }

  void restoreSession(GameSession session) {
    if (session.status == GameStatus.idle || session.boardTiles.isEmpty) {
      return;
    }

    _history.clear();
    _session = session;
    _activePlayStartedAt = session.status == GameStatus.playing ? _now() : null;
    notifyListeners();
  }

  void tapTile(String tileId) {
    // Legacy no-op entry point. Drag-and-drop shelf moves are now primary.
    if (!_preparePlayingAction() || _session.shelves.isEmpty) {
      return;
    }

    for (var from = 0; from < _session.shelves.length; from++) {
      final source = _session.shelves[from];
      for (var fromSlot = 0; fromSlot < source.length; fromSlot++) {
        for (var to = 0; to < _session.shelves.length; to++) {
          if (moveItem(fromShelf: from, fromSlot: fromSlot, toShelf: to)) {
            return;
          }
        }
      }
    }
  }

  bool moveItem({
    required int fromShelf,
    required int fromSlot,
    required int toShelf,
  }) {
    if (!_preparePlayingAction()) {
      return false;
    }

    final shelves = _session.shelves;
    final closedShelves = _session.closedShelves;

    if (!_isValidMove(
      shelves: shelves,
      closedShelves: closedShelves,
      fromShelf: fromShelf,
      fromSlot: fromSlot,
      toShelf: toShelf,
    )) {
      return false;
    }

    final source = shelves[fromShelf];
    final movingKind = source[fromSlot];
    _pushHistory();

    final nextShelves = shelves
        .map((shelf) => List<ItemKind>.from(shelf))
        .toList(growable: false);
    final nextClosedShelves = List<bool>.from(closedShelves);

    nextShelves[fromShelf].removeAt(fromSlot);
    nextShelves[toShelf].add(movingKind);

    var clearedGroups = 0;
    var scoreGain = 0;

    for (var i = 0; i < nextShelves.length; i++) {
      if (nextClosedShelves[i]) {
        continue;
      }

      final shelf = nextShelves[i];
      if (shelf.length < _config.matchGroupMin) {
        continue;
      }
      if (shelf.length > _config.matchGroupMax) {
        continue;
      }

      final kind = shelf.first;
      final allSame = shelf.every((item) => item == kind);
      if (!allSame) {
        continue;
      }

      final groupSize = shelf.length;
      clearedGroups += 1;
      scoreGain +=
          _config.baseScorePerTriple +
          ((groupSize - _config.matchGroupMin) * _config.comboBonusPerTriple);
      shelf.clear();
      nextClosedShelves[i] = true;
    }

    final nextComboStreak = clearedGroups > 0
        ? _session.comboStreak + clearedGroups
        : 0;
    final streakBonus =
        max(0, nextComboStreak - 1) * _config.comboStreakBonusPerStep;
    final nextScore = _session.score + scoreGain + streakBonus;
    final nextBestCombo = max(_session.bestComboInRun, nextComboStreak);
    final elapsedSeconds = _effectiveElapsedPlaySeconds();

    final nextStatus = _resolveStatus(
      shelves: nextShelves,
      closedShelves: nextClosedShelves,
    );

    final nextStars = _objectiveEngine.evaluateStars(
      status: nextStatus,
      score: nextScore,
      bestCombo: nextBestCombo,
      targetScore: _session.objectiveTargetScore,
      targetCombo: _session.objectiveTargetCombo,
    );

    _session = _session.copyWith(
      shelves: nextShelves,
      closedShelves: nextClosedShelves,
      moves: _session.moves + 1,
      score: nextScore,
      triplesClearedInRun: _session.triplesClearedInRun + clearedGroups,
      comboStreak: nextComboStreak,
      bestComboInRun: nextBestCombo,
      starsEarned: nextStars,
      status: nextStatus,
      elapsedPlaySeconds: elapsedSeconds,
      lossReason: nextStatus == GameStatus.lost ? GameLossReason.noMoves : null,
      tray: const <ItemKind>[],
    );

    _activePlayStartedAt = nextStatus == GameStatus.playing ? _now() : null;
    notifyListeners();
    return true;
  }

  void undo() {
    if (!canUndo) {
      return;
    }

    _session = _history.removeLast();
    _activePlayStartedAt = _session.status == GameStatus.playing ? _now() : null;
    notifyListeners();
  }

  void shuffleRemaining() {
    if (!_preparePlayingAction() || !canShuffle) {
      return;
    }

    _pushHistory();
    final nextShelves = _session.shelves
        .map((shelf) => List<ItemKind>.from(shelf))
        .toList(growable: false);
    final openIndices = <int>[];
    final counts = <int>[];
    final items = <ItemKind>[];

    for (var i = 0; i < nextShelves.length; i++) {
      if (_session.closedShelves.length > i && _session.closedShelves[i]) {
        continue;
      }
      final shelf = nextShelves[i];
      if (shelf.isEmpty) {
        continue;
      }
      openIndices.add(i);
      counts.add(shelf.length);
      items.addAll(shelf);
      shelf.clear();
    }

    items.shuffle(
      Random(_session.seed + _session.moves + _session.shuffleCharges),
    );

    var cursor = 0;
    for (var i = 0; i < openIndices.length; i++) {
      final count = counts[i];
      final shelfIndex = openIndices[i];
      nextShelves[shelfIndex].addAll(items.sublist(cursor, cursor + count));
      cursor += count;
    }

    final nextStatus = _resolveStatus(
      shelves: nextShelves,
      closedShelves: _session.closedShelves,
    );

    _session = _session.copyWith(
      shelves: nextShelves,
      shuffleCharges: _session.shuffleCharges - 1,
      moves: _session.moves + 1,
      shufflesUsedInRun: _session.shufflesUsedInRun + 1,
      status: nextStatus,
      elapsedPlaySeconds: _effectiveElapsedPlaySeconds(),
      lossReason: nextStatus == GameStatus.lost ? GameLossReason.noMoves : null,
    );
    _activePlayStartedAt = nextStatus == GameStatus.playing ? _now() : null;
    notifyListeners();
  }

  void grantShuffleCharge(int count) {
    if (count <= 0 || !_preparePlayingAction()) {
      return;
    }

    _session = _session.copyWith(
      shuffleCharges: _session.shuffleCharges + count,
      elapsedPlaySeconds: _effectiveElapsedPlaySeconds(),
    );
    _activePlayStartedAt = _now();
    notifyListeners();
  }

  void restart() {
    if (_session.status == GameStatus.idle) {
      return;
    }
    startLevel(level: _session.level, seed: _session.seed);
  }

  void nextLevel() {
    startLevel(level: _session.level + 1);
  }

  void pause() {
    if (_session.status != GameStatus.playing) {
      return;
    }
    if (_syncTimerIfNeeded()) {
      return;
    }

    _session = _session.copyWith(
      status: GameStatus.paused,
      elapsedPlaySeconds: _effectiveElapsedPlaySeconds(),
    );
    _activePlayStartedAt = null;
    notifyListeners();
  }

  void resume() {
    if (_session.status != GameStatus.paused) {
      return;
    }

    if (_session.levelTimeLimitSeconds > 0 &&
        _session.elapsedPlaySeconds >= _session.levelTimeLimitSeconds) {
      _session = _session.copyWith(
        status: GameStatus.lost,
        lossReason: GameLossReason.timeExpired,
      );
      notifyListeners();
      return;
    }

    _activePlayStartedAt = _now();
    _session = _session.copyWith(status: GameStatus.playing, lossReason: null);
    notifyListeners();
  }

  void goIdle() {
    _history.clear();
    _activePlayStartedAt = null;
    _session = GameSession.initial();
    notifyListeners();
  }

  void _pushHistory() {
    _history.add(
      _session.copyWith(elapsedPlaySeconds: _effectiveElapsedPlaySeconds()),
    );
    if (_history.length > 20) {
      _history.removeAt(0);
    }
  }

  bool _preparePlayingAction() {
    if (_session.status != GameStatus.playing) {
      return false;
    }

    return !_syncTimerIfNeeded();
  }

  bool _syncTimerIfNeeded() {
    if (_session.status != GameStatus.playing ||
        _session.levelTimeLimitSeconds <= 0) {
      return false;
    }

    final elapsedSeconds = _effectiveElapsedPlaySeconds();
    if (elapsedSeconds < _session.levelTimeLimitSeconds) {
      return false;
    }

    _session = _session.copyWith(
      status: GameStatus.lost,
      elapsedPlaySeconds: _session.levelTimeLimitSeconds,
      lossReason: GameLossReason.timeExpired,
    );
    _activePlayStartedAt = null;
    notifyListeners();
    return true;
  }

  int _effectiveElapsedPlaySeconds() {
    final baseElapsed = _session.elapsedPlaySeconds;
    if (_session.status != GameStatus.playing || _activePlayStartedAt == null) {
      return baseElapsed;
    }

    final activeSeconds = _now().difference(_activePlayStartedAt!).inSeconds;
    return baseElapsed + max(0, activeSeconds);
  }

  GameStatus _resolveStatus({
    required List<List<ItemKind>> shelves,
    required List<bool> closedShelves,
  }) {
    final remainingItems = shelves.fold<int>(
      0,
      (sum, shelf) => sum + shelf.length,
    );

    if (remainingItems == 0) {
      return GameStatus.won;
    }

    if (!_hasAnyValidMoves(shelves, closedShelves)) {
      return GameStatus.lost;
    }

    return GameStatus.playing;
  }

  bool _hasAnyValidMoves(
    List<List<ItemKind>> shelves,
    List<bool> closedShelves,
  ) {
    for (var from = 0; from < shelves.length; from++) {
      if (closedShelves.length > from && closedShelves[from]) {
        continue;
      }
      final source = shelves[from];
      if (source.isEmpty) {
        continue;
      }

      for (var sourceIndex = 0; sourceIndex < source.length; sourceIndex++) {
        for (var to = 0; to < shelves.length; to++) {
          if (_isValidMove(
            shelves: shelves,
            closedShelves: closedShelves,
            fromShelf: from,
            fromSlot: sourceIndex,
            toShelf: to,
          )) {
            return true;
          }
        }
      }
    }

    return false;
  }

  List<List<ItemKind>> _buildShelves(List<TileModel> boardTiles, int seed) {
    final rng = Random(seed + 17);
    final items = boardTiles.map((tile) => tile.kind).toList(growable: true)
      ..shuffle(rng);

    final shelfCount = _config.shelfCountForTiles(items.length);
    final shelves = List<List<ItemKind>>.generate(
      shelfCount,
      (_) => <ItemKind>[],
    );

    for (final item in items) {
      final safeIndices = <int>[];
      final fallbackIndices = <int>[];

      for (var i = 0; i < shelves.length; i++) {
        final shelf = shelves[i];
        if (shelf.length >= _config.shelfCapacity) {
          continue;
        }

        fallbackIndices.add(i);

        final wouldClose = _wouldAutoCloseAfterInsert(shelf: shelf, item: item);
        if (!wouldClose) {
          safeIndices.add(i);
        }
      }

      final choices = safeIndices.isNotEmpty ? safeIndices : fallbackIndices;
      final selected = choices[rng.nextInt(choices.length)];
      shelves[selected].add(item);
    }

    return shelves;
  }

  bool _wouldAutoCloseAfterInsert({
    required List<ItemKind> shelf,
    required ItemKind item,
  }) {
    final nextSize = shelf.length + 1;
    if (nextSize < _config.matchGroupMin || nextSize > _config.matchGroupMax) {
      return false;
    }

    if (shelf.isEmpty) {
      return false;
    }

    return shelf.every((kind) => kind == item);
  }

  bool _isValidMove({
    required List<List<ItemKind>> shelves,
    required List<bool> closedShelves,
    required int fromShelf,
    required int fromSlot,
    required int toShelf,
  }) {
    if (fromShelf < 0 || toShelf < 0) {
      return false;
    }
    if (fromShelf >= shelves.length || toShelf >= shelves.length) {
      return false;
    }
    if (fromShelf == toShelf) {
      return false;
    }
    if ((closedShelves.length > fromShelf && closedShelves[fromShelf]) ||
        (closedShelves.length > toShelf && closedShelves[toShelf])) {
      return false;
    }

    final source = shelves[fromShelf];
    final target = shelves[toShelf];
    if (fromSlot < 0 || fromSlot >= source.length) {
      return false;
    }
    if (source.isEmpty || target.length >= _config.shelfCapacity) {
      return false;
    }

    final movingKind = source[fromSlot];
    return target.isEmpty || target.last == movingKind;
  }
}
