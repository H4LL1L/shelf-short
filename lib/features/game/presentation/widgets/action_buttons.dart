import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.canUndo,
    required this.canShuffle,
    required this.shuffleCharges,
    required this.canUseHint,
    required this.hintCost,
    required this.canBuyExtraTime,
    required this.extraTimeCost,
    required this.extraTimeSeconds,
    required this.canBuyExtraShuffle,
    required this.extraShuffleCost,
    required this.onUndo,
    required this.onShuffle,
    required this.onUseHint,
    required this.onBuyExtraTime,
    required this.onBuyExtraShuffle,
  });

  final bool canUndo;
  final bool canShuffle;
  final int shuffleCharges;
  final bool canUseHint;
  final int hintCost;
  final bool canBuyExtraTime;
  final int extraTimeCost;
  final int extraTimeSeconds;
  final bool canBuyExtraShuffle;
  final int extraShuffleCost;
  final VoidCallback onUndo;
  final VoidCallback onShuffle;
  final VoidCallback onUseHint;
  final VoidCallback onBuyExtraTime;
  final VoidCallback onBuyExtraShuffle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _MiniActionButton(
            label: 'Undo',
            icon: Icons.undo_rounded,
            color: AppColors.accent,
            onPressed: canUndo ? onUndo : null,
            isOutlined: true,
          ),
          const SizedBox(width: 6),
          _MiniActionButton(
            label: 'Shuffle $shuffleCharges',
            icon: Icons.shuffle_rounded,
            color: AppColors.secondary,
            onPressed: canShuffle ? onShuffle : null,
          ),
          const SizedBox(width: 6),
          _MiniActionButton(
            label: 'Hint $hintCost',
            icon: Icons.lightbulb_rounded,
            color: AppColors.accent,
            onPressed: canUseHint ? onUseHint : null,
          ),
          const SizedBox(width: 6),
          _MiniActionButton(
            label: '+${extraTimeSeconds}s',
            icon: Icons.timer_rounded,
            color: AppColors.warning,
            onPressed: canBuyExtraTime ? onBuyExtraTime : null,
          ),
          const SizedBox(width: 6),
          _MiniActionButton(
            label: '+1 Shuffle',
            icon: Icons.bolt_rounded,
            color: AppColors.primary,
            onPressed: canBuyExtraShuffle ? onBuyExtraShuffle : null,
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isOutlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(label),
      ],
    );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.3),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          visualDensity: VisualDensity.compact,
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child,
    );
  }
}
