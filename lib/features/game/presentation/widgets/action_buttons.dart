import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.canUndo,
    required this.canShuffle,
    required this.shuffleCharges,
    required this.canBuyExtraShuffle,
    required this.extraShuffleCost,
    required this.onUndo,
    required this.onShuffle,
    required this.onBuyExtraShuffle,
  });

  final bool canUndo;
  final bool canShuffle;
  final int shuffleCharges;
  final bool canBuyExtraShuffle;
  final int extraShuffleCost;
  final VoidCallback onUndo;
  final VoidCallback onShuffle;
  final VoidCallback onBuyExtraShuffle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canUndo ? onUndo : null,
                icon: const Icon(Icons.undo_rounded),
                label: const Text('Undo'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accent, width: 1.4),
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canShuffle ? onShuffle : null,
                icon: const Icon(Icons.shuffle_rounded),
                label: Text('Shuffle ($shuffleCharges)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  disabledBackgroundColor:
                      AppColors.secondary.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canBuyExtraShuffle ? onBuyExtraShuffle : null,
            icon: const Icon(Icons.bolt_rounded),
            label: Text('Buy +1 Shuffle ($extraShuffleCost)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
