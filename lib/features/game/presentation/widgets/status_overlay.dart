import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/game_loss_reason.dart';
import '../../domain/entities/game_status.dart';

class StatusOverlay extends StatelessWidget {
  const StatusOverlay({
    super.key,
    required this.status,
    required this.lossReason,
    required this.score,
    required this.level,
    required this.starsEarned,
    required this.triples,
    required this.bestCombo,
    required this.targetScore,
    required this.targetCombo,
    required this.onResume,
    required this.onRestart,
    required this.onNextLevel,
    required this.onHome,
  });

  final GameStatus status;
  final GameLossReason? lossReason;
  final int score;
  final int level;
  final int starsEarned;
  final int triples;
  final int bestCombo;
  final int targetScore;
  final int targetCombo;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onNextLevel;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    if (status == GameStatus.playing || status == GameStatus.idle) {
      return const SizedBox.shrink();
    }

    final data = _OverlayData.from(
      status: status,
      lossReason: lossReason,
      score: score,
      level: level,
    );

    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xAA000000),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.panelStrong, width: 1.3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: data.titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                _StarRow(stars: starsEarned),
                const SizedBox(height: 10),
                _RunSummaryRow(
                  score: score,
                  triples: triples,
                  bestCombo: bestCombo,
                  targetScore: targetScore,
                  targetCombo: targetCombo,
                ),
                const SizedBox(height: 18),
                if (status == GameStatus.paused)
                  ElevatedButton(
                    onPressed: onResume,
                    child: const Text('Resume'),
                  ),
                if (status == GameStatus.won)
                  ElevatedButton(
                    onPressed: onNextLevel,
                    child: const Text('Next Level'),
                  ),
                if (status == GameStatus.lost)
                  ElevatedButton(
                    onPressed: onRestart,
                    child: const Text('Try Again'),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRestart,
                        child: const Text('Restart'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onHome,
                        child: const Text('Home'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RunSummaryRow extends StatelessWidget {
  const _RunSummaryRow({
    required this.score,
    required this.triples,
    required this.bestCombo,
    required this.targetScore,
    required this.targetCombo,
  });

  final int score;
  final int triples;
  final int bestCombo;
  final int targetScore;
  final int targetCombo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Metric(
            label: 'Score',
            value: '$score/$targetScore',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _Metric(label: 'Triples', value: '$triples')),
        const SizedBox(width: 8),
        Expanded(
          child: _Metric(
            label: 'Best Combo',
            value: '$bestCombo/$targetCombo',
          ),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (index) {
        final filled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? AppColors.warning : AppColors.textMuted,
            size: 24,
          ),
        );
      }),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.panelStrong.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _OverlayData {
  const _OverlayData({
    required this.title,
    required this.message,
    required this.titleColor,
  });

  final String title;
  final String message;
  final Color titleColor;

  factory _OverlayData.from({
    required GameStatus status,
    required GameLossReason? lossReason,
    required int score,
    required int level,
  }) {
    switch (status) {
      case GameStatus.paused:
        return const _OverlayData(
          title: 'Paused',
          message: 'Take a breath. Your shelf will wait for you.',
          titleColor: AppColors.warning,
        );
      case GameStatus.won:
        return _OverlayData(
          title: 'Level Complete',
          message: 'Great flow! Score: $score. Prepare for level ${level + 1}.',
          titleColor: AppColors.success,
        );
      case GameStatus.lost:
        if (lossReason == GameLossReason.timeExpired) {
          return const _OverlayData(
            title: 'Time Up',
            message:
                'The timer ran out before the shelves were cleared. Restart and route faster.',
            titleColor: AppColors.danger,
          );
        }
        return const _OverlayData(
          title: 'No Moves Left',
          message: 'No valid shelf transfer remains. Try a different ordering.',
          titleColor: AppColors.danger,
        );
      case GameStatus.idle:
      case GameStatus.playing:
        return const _OverlayData(
          title: '',
          message: '',
          titleColor: AppColors.textMain,
        );
    }
  }
}
