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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _StatChip(label: 'L', value: '$level'),
                _StatChip(
                  label: 'T',
                  value: _formatTime(remainingSeconds),
                  highlightColor: remainingSeconds <= 30
                      ? AppColors.danger
                      : AppColors.textMain,
                ),
                _StatChip(label: 'S', value: '$score'),
                _StatChip(label: 'M', value: '$moves'),
                _StatChip(label: 'C', value: '$coins'),
                _StatChip(label: 'X', value: '$combo'),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            onPressed: onPauseToggle,
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            tooltip: isPlaying ? 'Pause' : 'Resume',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.panelStrong,
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.panelStrong,
              foregroundColor: AppColors.secondary,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: highlightColor ?? AppColors.textMain,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
