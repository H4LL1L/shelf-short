import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HudPanel extends StatelessWidget {
  const HudPanel({
    super.key,
    required this.level,
    required this.score,
    required this.moves,
    required this.coins,
    required this.combo,
    required this.remainingSeconds,
    required this.isPlaying,
    required this.onPauseToggle,
    required this.onRestart,
  });

  final int level;
  final int score;
  final int moves;
  final int coins;
  final int combo;
  final int remainingSeconds;
  final bool isPlaying;
  final VoidCallback onPauseToggle;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _StatChip(label: 'LEVEL', value: '$level'),
                _StatChip(label: 'SCORE', value: '$score'),
                _StatChip(label: 'MOVES', value: '$moves'),
                _StatChip(
                  label: 'TIME',
                  value: _formatTime(remainingSeconds),
                  highlightColor: remainingSeconds <= 30
                      ? AppColors.danger
                      : AppColors.textMain,
                ),
                _StatChip(label: 'COINS', value: '$coins'),
                _StatChip(label: 'COMBO', value: '$combo'),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onPauseToggle,
            icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
            tooltip: isPlaying ? 'Pause' : 'Resume',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.panelStrong,
              foregroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.panelStrong,
              foregroundColor: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Shelf Rush',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.highlightColor,
  });

  final String label;
  final String value;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: highlightColor ?? AppColors.textMain,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

String _formatTime(int remainingSeconds) {
  final total = remainingSeconds < 0 ? 0 : remainingSeconds;
  final minutes = total ~/ 60;
  final seconds = total % 60;
  final paddedSeconds = seconds.toString().padLeft(2, '0');
  return '$minutes:$paddedSeconds';
}
