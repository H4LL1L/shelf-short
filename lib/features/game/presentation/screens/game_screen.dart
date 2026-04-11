import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/game_config.dart';
import '../../../../core/theme/app_colors.dart';
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
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                          const SizedBox(height: 10),
                          _ObjectiveStrip(
                            score: session.score,
                            targetScore: session.objectiveTargetScore,
                            bestCombo: session.bestComboInRun,
                            targetCombo: session.objectiveTargetCombo,
                            stars: session.starsEarned,
                          ),
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 10),
                          _MetaStrip(
                            playerLevel: profile.playerLevel,
                            xp: profile.xp,
                            streak: profile.dailyStreak,
                          ),
                          const SizedBox(height: 10),
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

class _MetaStrip extends StatelessWidget {
  const _MetaStrip({
    required this.playerLevel,
    required this.xp,
    required this.streak,
  });

  final int playerLevel;
  final int xp;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('Player Lv $playerLevel'),
          const SizedBox(width: 12),
          const Icon(
            Icons.flash_on_rounded,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 6),
          Text('XP $xp'),
          const Spacer(),
          const Icon(
            Icons.local_fire_department,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text('Streak $streak'),
        ],
      ),
    );
  }
}

class _ObjectiveStrip extends StatelessWidget {
  const _ObjectiveStrip({
    required this.score,
    required this.targetScore,
    required this.bestCombo,
    required this.targetCombo,
    required this.stars,
  });

  final int score;
  final int targetScore;
  final int bestCombo;
  final int targetCombo;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final scoreRatio = targetScore <= 0
        ? 0.0
        : (score / targetScore).clamp(0.0, 1.0);
    final comboRatio = targetCombo <= 0
        ? 0.0
        : (bestCombo / targetCombo).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: AppColors.secondary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('Score $score/$targetScore'),
              const Spacer(),
              const Icon(
                Icons.bolt_rounded,
                color: AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('Combo $bestCombo/$targetCombo'),
              const SizedBox(width: 8),
              for (var i = 0; i < 3; i++)
                Icon(
                  i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: i < stars ? AppColors.warning : AppColors.textMuted,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: scoreRatio,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: AppColors.panelStrong,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: comboRatio,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: AppColors.panelStrong,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
