import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../audio/application/game_audio_service.dart';
import '../../audio/domain/entities/sound_cue.dart';
import '../../meta/application/progress_controller.dart';
import '../../telemetry/application/telemetry_service.dart';
import '../../telemetry/domain/entities/telemetry_event.dart';
import '../data/run_session_repository.dart';
import '../domain/entities/game_session.dart';
import '../domain/entities/game_status.dart';
import 'game_controller.dart';

class GameHubController extends ChangeNotifier {
  GameHubController({
    required this.gameController,
    required this.progressController,
    RunSessionRepository? runSessionRepository,
    GameAudioService? audioService,
    TelemetryService? telemetryService,
    this.extraShuffleCost = 140,
  }) : _runSessionRepository =
           runSessionRepository ?? const NoopRunSessionRepository(),
       _audioService = audioService ?? const NoopGameAudioService(),
       _telemetryService = telemetryService ?? const NoopTelemetryService() {
    gameController.addListener(_handleGameStateChanged);
    progressController.addListener(_handleProgressChanged);
  }

  final GameController gameController;
  final ProgressController progressController;
  final RunSessionRepository _runSessionRepository;
  final GameAudioService _audioService;
  final TelemetryService _telemetryService;
  final int extraShuffleCost;

  GameSession _lastSession = GameSession.initial();
  bool _hasRestorableRun = false;
  bool _suppressGameListener = false;

  bool get isReady => progressController.isReady;

  int get coins => progressController.profile.coins;

  bool get hasRestorableRun => _hasRestorableRun;

  bool get canBuyExtraShuffle =>
      gameController.session.status == GameStatus.playing &&
      progressController.profile.coins >= extraShuffleCost;

  Future<void> initialize() async {
    await _audioService.initialize();
    await _telemetryService.initialize();
    await progressController.initialize();
    _audioService.setEnabled(progressController.settings.soundEnabled);
    await _restoreRunIfAvailable();

    unawaited(
      _telemetryService.track(
        TelemetryEventType.appOpen,
        properties: <String, Object?>{'hasRestorableRun': _hasRestorableRun},
      ),
    );

    _lastSession = gameController.session;
    notifyListeners();
  }

  void startLevel({required int level, int? seed}) {
    progressController.recordLevelStarted(level);
    gameController.startLevel(level: level, seed: seed);
    unawaited(_audioService.play(SoundCue.levelStart));
    unawaited(
      _telemetryService.track(
        TelemetryEventType.levelStart,
        properties: <String, Object?>{'level': level, 'seeded': seed != null},
      ),
    );
  }

  void nextLevel() {
    gameController.nextLevel();
    progressController.recordLevelStarted(gameController.session.level);
    unawaited(_audioService.play(SoundCue.levelStart));
    unawaited(
      _telemetryService.track(
        TelemetryEventType.levelStart,
        properties: <String, Object?>{
          'level': gameController.session.level,
          'seeded': false,
          'source': 'nextLevel',
        },
      ),
    );
  }

  void restart() {
    progressController.recordLevelStarted(gameController.session.level);
    gameController.restart();
    unawaited(_audioService.play(SoundCue.levelStart));
    unawaited(
      _telemetryService.track(
        TelemetryEventType.levelStart,
        properties: <String, Object?>{
          'level': gameController.session.level,
          'seeded': true,
          'source': 'restart',
        },
      ),
    );
  }

  void pause() {
    gameController.pause();
    unawaited(_audioService.play(SoundCue.pause));
    unawaited(_telemetryService.track(TelemetryEventType.pause));
  }

  void resume() {
    gameController.resume();
    unawaited(_audioService.play(SoundCue.resume));
    unawaited(_telemetryService.track(TelemetryEventType.resume));
  }

  void goIdle() {
    gameController.goIdle();
    _hasRestorableRun = false;
    unawaited(_runSessionRepository.clear());
    unawaited(
      _telemetryService.track(
        TelemetryEventType.runExit,
        properties: const <String, Object?>{'mode': 'idle'},
      ),
    );
  }

  void exitToHome() {
    final status = gameController.session.status;
    if (status == GameStatus.playing) {
      gameController.pause();
      unawaited(_audioService.play(SoundCue.pause));
      unawaited(
        _telemetryService.track(
          TelemetryEventType.runExit,
          properties: const <String, Object?>{'mode': 'pauseThenExit'},
        ),
      );
      return;
    }

    if (status == GameStatus.paused) {
      _hasRestorableRun = true;
      _persistRun(gameController.session);
      unawaited(
        _telemetryService.track(
          TelemetryEventType.runExit,
          properties: const <String, Object?>{'mode': 'pausedExit'},
        ),
      );
      notifyListeners();
      return;
    }

    goIdle();
  }

  bool resumeActiveRun() {
    if (!_hasRestorableRun) {
      return false;
    }

    if (gameController.session.status == GameStatus.paused) {
      gameController.resume();
      unawaited(_audioService.play(SoundCue.resume));
    }

    unawaited(_telemetryService.track(TelemetryEventType.runRestored));

    return gameController.session.status == GameStatus.playing;
  }

  void tapTile(String tileId) {
    final beforeMoves = gameController.session.moves;
    gameController.tapTile(tileId);

    if (gameController.session.moves > beforeMoves) {
      unawaited(_audioService.play(SoundCue.tileTap));
      unawaited(
        _telemetryService.track(
          TelemetryEventType.tileTap,
          properties: <String, Object?>{
            'level': gameController.session.level,
            'moves': gameController.session.moves,
          },
        ),
      );
    }
  }

  void moveShelfItem({
    required int fromShelf,
    required int fromSlot,
    required int toShelf,
  }) {
    final beforeMoves = gameController.session.moves;
    final moved = gameController.moveItem(
      fromShelf: fromShelf,
      fromSlot: fromSlot,
      toShelf: toShelf,
    );

    if (!moved || gameController.session.moves <= beforeMoves) {
      return;
    }

    unawaited(_audioService.play(SoundCue.tileTap));
    unawaited(
      _telemetryService.track(
        TelemetryEventType.tileTap,
        properties: <String, Object?>{
          'level': gameController.session.level,
          'moves': gameController.session.moves,
          'fromShelf': fromShelf,
          'fromSlot': fromSlot,
          'toShelf': toShelf,
          'mode': 'dragDrop',
        },
      ),
    );
  }

  void undo() {
    gameController.undo();
    unawaited(_audioService.play(SoundCue.undo));
    unawaited(_telemetryService.track(TelemetryEventType.undoUsed));
  }

  void shuffleRemaining() {
    final before = gameController.session.shufflesUsedInRun;
    gameController.shuffleRemaining();
    if (gameController.session.shufflesUsedInRun > before) {
      unawaited(_audioService.play(SoundCue.shuffle));
      unawaited(
        _telemetryService.track(
          TelemetryEventType.shuffleUsed,
          properties: <String, Object?>{
            'level': gameController.session.level,
            'remainingCharges': gameController.session.shuffleCharges,
          },
        ),
      );
    }
  }

  bool buyExtraShuffle() {
    if (!canBuyExtraShuffle) {
      unawaited(
        _telemetryService.track(
          TelemetryEventType.boosterPurchase,
          properties: <String, Object?>{
            'success': false,
            'cost': extraShuffleCost,
          },
        ),
      );
      return false;
    }

    final spent = progressController.spendCoins(extraShuffleCost);
    if (!spent) {
      unawaited(
        _telemetryService.track(
          TelemetryEventType.boosterPurchase,
          properties: <String, Object?>{
            'success': false,
            'cost': extraShuffleCost,
          },
        ),
      );
      return false;
    }

    gameController.grantShuffleCharge(1);
    unawaited(_audioService.play(SoundCue.boosterPurchase));
    unawaited(
      _telemetryService.track(
        TelemetryEventType.boosterPurchase,
        properties: <String, Object?>{
          'success': true,
          'cost': extraShuffleCost,
        },
      ),
    );
    return true;
  }

  int claimMissionReward(String missionId) {
    final reward = progressController.claimMissionReward(missionId);
    if (reward > 0) {
      unawaited(_audioService.play(SoundCue.missionClaim));
      unawaited(
        _telemetryService.track(
          TelemetryEventType.missionClaim,
          properties: <String, Object?>{
            'missionId': missionId,
            'reward': reward,
          },
        ),
      );
    }
    return reward;
  }

  int claimAllMissionRewards() {
    final totalReward = progressController.claimAllMissionRewards();
    if (totalReward > 0) {
      unawaited(_audioService.play(SoundCue.missionClaim));
      unawaited(
        _telemetryService.track(
          TelemetryEventType.missionClaim,
          properties: <String, Object?>{
            'missionId': 'all',
            'reward': totalReward,
            'bulk': true,
          },
        ),
      );
    }
    return totalReward;
  }

  void toggleSound() => progressController.toggleSound();

  void toggleHaptic() => progressController.toggleHaptic();

  void toggleReducedMotion() => progressController.toggleReducedMotion();

  void _handleProgressChanged() {
    _audioService.setEnabled(progressController.settings.soundEnabled);
    notifyListeners();
  }

  void _handleGameStateChanged() {
    if (_suppressGameListener) {
      return;
    }

    final current = gameController.session;

    final triplesDelta =
        current.triplesClearedInRun - _lastSession.triplesClearedInRun;
    if (triplesDelta > 0) {
      progressController.recordTriplesCleared(triplesDelta);
      unawaited(_audioService.play(SoundCue.match));
      unawaited(
        _telemetryService.track(
          TelemetryEventType.tripleClear,
          properties: <String, Object?>{
            'count': triplesDelta,
            'level': current.level,
          },
        ),
      );

      if (current.comboStreak >= 2) {
        unawaited(_audioService.play(SoundCue.combo));
        unawaited(
          _telemetryService.track(
            TelemetryEventType.comboAchieved,
            properties: <String, Object?>{
              'combo': current.comboStreak,
              'level': current.level,
            },
          ),
        );
      }
    }

    final shuffleDelta =
        current.shufflesUsedInRun - _lastSession.shufflesUsedInRun;
    if (shuffleDelta > 0) {
      progressController.recordShuffleUsed(shuffleDelta);
    }

    final becameTerminal =
        _lastSession.status != current.status &&
        (current.status == GameStatus.won || current.status == GameStatus.lost);

    if (becameTerminal) {
      progressController.recordMatchFinished(
        won: current.status == GameStatus.won,
        level: current.level,
        score: current.score,
        starsEarned: current.starsEarned,
      );

      final isWin = current.status == GameStatus.won;
      unawaited(_audioService.play(isWin ? SoundCue.win : SoundCue.lose));
      unawaited(
        _telemetryService.track(
          isWin
              ? TelemetryEventType.levelComplete
              : TelemetryEventType.levelFailed,
          properties: <String, Object?>{
            'level': current.level,
            'score': current.score,
            'stars': current.starsEarned,
            'triples': current.triplesClearedInRun,
            'bestCombo': current.bestComboInRun,
          },
        ),
      );
    }

    if (current.status == GameStatus.playing ||
        current.status == GameStatus.paused) {
      _hasRestorableRun = true;
      _persistRun(current);
    } else {
      _hasRestorableRun = false;
      unawaited(_runSessionRepository.clear());
    }

    _lastSession = current;
    notifyListeners();
  }

  Future<void> _restoreRunIfAvailable() async {
    final loaded = await _runSessionRepository.load();
    if (loaded == null) {
      _hasRestorableRun = false;
      return;
    }

    final canRestore =
        loaded.status != GameStatus.idle &&
        !loaded.isGameOver &&
        loaded.boardTiles.isNotEmpty;

    if (!canRestore) {
      _hasRestorableRun = false;
      await _runSessionRepository.clear();
      return;
    }

    _suppressGameListener = true;
    gameController.restoreSession(loaded);
    _suppressGameListener = false;
    progressController.recordLevelStarted(loaded.level);
    _hasRestorableRun = true;

    unawaited(
      _telemetryService.track(
        TelemetryEventType.runRestored,
        properties: <String, Object?>{
          'level': loaded.level,
          'moves': loaded.moves,
        },
      ),
    );
  }

  void _persistRun(GameSession session) {
    unawaited(_runSessionRepository.save(session));
  }

  @override
  void dispose() {
    gameController.removeListener(_handleGameStateChanged);
    progressController.removeListener(_handleProgressChanged);
    super.dispose();
  }
}
