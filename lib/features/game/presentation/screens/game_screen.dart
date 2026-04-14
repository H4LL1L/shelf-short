import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/game_config.dart';
import '../../application/game_hub_controller.dart';
import '../../domain/entities/game_status.dart';
import '../../domain/entities/shelf_hint_move.dart';
import '../widgets/action_buttons.dart';
import '../widgets/board_grid.dart';
import '../widgets/decorative_background.dart';
import '../widgets/hud_panel.dart';
import '../widgets/status_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.hub});

  final GameHubController hub;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  Timer? _countdownTicker;
  Timer? _hintTicker;
  ShelfHintMove? _activeHint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countdownTicker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onCountdownTick(),
    );
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    _hintTicker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (widget.hub.gameController.session.status == GameStatus.playing) {
        widget.hub.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const config = GameConfig();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        widget.hub.exitToHome();
      },
      child: AnimatedBuilder(
        animation: widget.hub,
        builder: (context, _) {
          final session = widget.hub.gameController.session;
          final profile = widget.hub.progressController.profile;

          return Scaffold(
            body: DecorativeBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          HudPanel(
                            level: session.level,
                            score: session.score,
                            moves: session.moves,
                            coins: profile.coins,
                            combo: session.comboStreak,
                            remainingSeconds:
                                widget.hub.gameController.currentRemainingSeconds,
                            isPlaying: session.status == GameStatus.playing,
                            onPauseToggle: _onPauseToggle,
                            onRestart: _onRestart,
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFD19B66),
                                    Color(0xFFB16D37),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF8A572B),
                                  width: 1.1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 14,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: BoardGrid(
                                shelves: session.shelves,
                                closedShelves: session.closedShelves,
                                shelfCapacity: config.shelfCapacity,
                                isInputEnabled:
                                    session.status == GameStatus.playing,
                                hintMove: _activeHint,
                                onMoveItem: _onMoveItem,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ActionButtons(
                            canUndo: widget.hub.gameController.canUndo,
                            canShuffle: widget.hub.gameController.canShuffle,
                            shuffleCharges: session.shuffleCharges,
                            canUseHint: widget.hub.canUseHint,
                            hintCost: widget.hub.hintCost,
                            canBuyExtraTime: widget.hub.canBuyExtraTime,
                            extraTimeCost: widget.hub.extraTimeCost,
                            extraTimeSeconds: widget.hub.extraTimeSeconds,
                            canBuyExtraShuffle: widget.hub.canBuyExtraShuffle,
                            extraShuffleCost: widget.hub.extraShuffleCost,
                            onUndo: _onUndo,
                            onShuffle: _onShuffle,
                            onUseHint: _onUseHint,
                            onBuyExtraTime: _onBuyExtraTime,
                            onBuyExtraShuffle: _onBuyExtraShuffle,
                          ),
                        ],
                      ),
                      StatusOverlay(
                        status: session.status,
                        lossReason: session.lossReason,
                        score: session.score,
                        level: session.level,
                        starsEarned: session.starsEarned,
                        triples: session.triplesClearedInRun,
                        bestCombo: session.bestComboInRun,
                        targetScore: session.objectiveTargetScore,
                        targetCombo: session.objectiveTargetCombo,
                        onResume: _onResume,
                        onRestart: _onRestart,
                        onNextLevel: _onNextLevel,
                        onHome: () {
                          widget.hub.exitToHome();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onMoveItem(int fromShelf, int fromSlot, int toShelf) {
    _lightHaptic();
    _clearHint();
    widget.hub.moveShelfItem(
      fromShelf: fromShelf,
      fromSlot: fromSlot,
      toShelf: toShelf,
    );
  }

  void _onUndo() {
    _lightHaptic();
    _clearHint();
    widget.hub.undo();
  }

  void _onShuffle() {
    _lightHaptic();
    _clearHint();
    widget.hub.shuffleRemaining();
  }

  void _onUseHint() {
    _lightHaptic();
    final move = widget.hub.useHint();
    if (move == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hint unavailable. Check coins or remaining moves.'),
        ),
      );
      return;
    }

    _showHint(move);
  }

  void _onBuyExtraTime() {
    _lightHaptic();
    final success = widget.hub.buyExtraTime();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '+${widget.hub.extraTimeSeconds}s added to the timer.'
              : 'Not enough coins to buy extra time.',
        ),
      ),
    );
  }

  void _onBuyExtraShuffle() {
    _lightHaptic();
    final success = widget.hub.buyExtraShuffle();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Extra shuffle purchased.'
              : 'Not enough coins for booster.',
        ),
      ),
    );
  }

  void _onPauseToggle() {
    _lightHaptic();
    _clearHint();
    final status = widget.hub.gameController.session.status;
    if (status == GameStatus.playing) {
      widget.hub.pause();
    } else if (status == GameStatus.paused) {
      widget.hub.resume();
    }
  }

  void _onResume() {
    _lightHaptic();
    _clearHint();
    widget.hub.resume();
  }

  void _onRestart() {
    _lightHaptic();
    _clearHint();
    widget.hub.restart();
  }

  void _onNextLevel() {
    _lightHaptic();
    _clearHint();
    widget.hub.nextLevel();
  }

  void _onCountdownTick() {
    if (!mounted) {
      return;
    }

    if (widget.hub.gameController.session.status != GameStatus.playing) {
      return;
    }

    widget.hub.gameController.heartbeat();
    setState(() {});
  }

  void _showHint(ShelfHintMove move) {
    _hintTicker?.cancel();
    setState(() {
      _activeHint = move;
    });
    _hintTicker = Timer(const Duration(seconds: 3), _clearHint);
  }

  void _clearHint() {
    _hintTicker?.cancel();
    _hintTicker = null;
    if (_activeHint == null || !mounted) {
      return;
    }
    setState(() {
      _activeHint = null;
    });
  }

  void _lightHaptic() {
    if (!widget.hub.progressController.settings.hapticEnabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }
}

