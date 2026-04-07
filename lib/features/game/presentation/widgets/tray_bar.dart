import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/item_kind.dart';
import '../model/item_visuals.dart';
import 'shelf_product.dart';

class TrayBar extends StatefulWidget {
  const TrayBar({
    super.key,
    required this.tray,
    required this.capacity,
    this.closeAmount = 0,
    this.closeTint = AppColors.panelStrong,
    this.reducedMotion = false,
  });

  final List<ItemKind> tray;
  final int capacity;
  final double closeAmount;
  final Color closeTint;
  final bool reducedMotion;

  @override
  State<TrayBar> createState() => _TrayBarState();
}

class _TrayBarState extends State<TrayBar> {
  Set<int> _pulseIndices = <int>{};
  bool _triplePulse = false;
  int _pulseEpoch = 0;
  Timer? _pulseTimer;

  @override
  void didUpdateWidget(covariant TrayBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (listEquals(oldWidget.tray, widget.tray)) {
      return;
    }

    final oldLength = oldWidget.tray.length;
    final newLength = widget.tray.length;

    if (newLength > oldLength) {
      final focus = newLength - 1;
      final indices = <int>{focus};
      if (focus - 1 >= 0) {
        indices.add(focus - 1);
      }
      if (focus + 1 < widget.capacity) {
        indices.add(focus + 1);
      }
      _triggerPulse(indices, triple: false);
      return;
    }

    if (newLength < oldLength) {
      _triggerPulse(
        Set<int>.from(List<int>.generate(widget.capacity, (i) => i)),
        triple: true,
      );
      return;
    }

    _triggerPulse(
      Set<int>.from(List<int>.generate(newLength, (i) => i)),
      triple: false,
    );
  }

  void _triggerPulse(Set<int> indices, {required bool triple}) {
    _pulseTimer?.cancel();
    setState(() {
      _pulseEpoch += 1;
      _pulseIndices = indices;
      _triplePulse = triple;
    });

    _pulseTimer = Timer(
      widget.reducedMotion
          ? const Duration(milliseconds: 120)
          : const Duration(milliseconds: 240),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          _pulseIndices = <int>{};
          _triplePulse = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeCloseAmount = widget.closeAmount < 0
        ? 0.0
        : widget.closeAmount > 1
        ? 1.0
        : widget.closeAmount;
    final nearOverflow = widget.tray.length >= widget.capacity - 1;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.panelStrong),
      ),
      child: Stack(
        children: [
          Row(
            children: List<Widget>.generate(widget.capacity, (index) {
              final hasItem = index < widget.tray.length;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _TraySlot(
                    slotIndex: index,
                    kind: hasItem ? widget.tray[index] : null,
                    pulseEpoch: _pulseEpoch,
                    isHighlighted: _pulseIndices.contains(index),
                    isTriplePulse: _triplePulse,
                    nearOverflow: nearOverflow,
                    reducedMotion: widget.reducedMotion,
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: _ShelfDoorOverlay(
              closeAmount: safeCloseAmount,
              tint: widget.closeTint,
              reducedMotion: widget.reducedMotion,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraySlot extends StatelessWidget {
  const _TraySlot({
    required this.slotIndex,
    required this.kind,
    required this.pulseEpoch,
    required this.isHighlighted,
    required this.isTriplePulse,
    required this.nearOverflow,
    required this.reducedMotion,
  });

  final int slotIndex;
  final ItemKind? kind;
  final int pulseEpoch;
  final bool isHighlighted;
  final bool isTriplePulse;
  final bool nearOverflow;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final visual = kind == null ? null : ItemVisuals.of(kind!);

    final baseBorderColor = kind == null
        ? AppColors.panelStrong
        : nearOverflow
        ? AppColors.warning.withValues(alpha: 0.8)
        : visual!.baseColor.withValues(alpha: 0.8);
    final glowColor = isTriplePulse
        ? AppColors.success.withValues(alpha: 0.28)
        : nearOverflow
        ? AppColors.warning.withValues(alpha: 0.2)
        : visual?.baseColor.withValues(alpha: 0.2) ?? Colors.transparent;

    final body = AnimatedContainer(
      duration: reducedMotion
          ? const Duration(milliseconds: 90)
          : const Duration(milliseconds: 220),
      height: 52,
      decoration: BoxDecoration(
        color: kind == null
            ? AppColors.panelStrong.withValues(alpha: 0.6)
            : isTriplePulse
            ? AppColors.success.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: baseBorderColor,
          width: kind == null ? 1 : 1.35,
        ),
        boxShadow: kind != null
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: isHighlighted ? 12 : 6,
                  spreadRadius: isHighlighted ? 1.5 : 0.4,
                ),
              ]
            : null,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: reducedMotion
              ? const Duration(milliseconds: 90)
              : const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            if (reducedMotion) {
              return FadeTransition(opacity: animation, child: child);
            }

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
            );
          },
          child: kind == null
              ? Icon(
                  Icons.add_rounded,
                  key: ValueKey<String>('empty-$slotIndex-$pulseEpoch'),
                  size: 18,
                  color: AppColors.textMuted,
                )
              : Stack(
                  key: ValueKey<String>(
                    'filled-${kind!.name}-$slotIndex-$pulseEpoch',
                  ),
                  clipBehavior: Clip.none,
                  children: [
                    ShelfProduct(kind: kind!, maxHeight: 30),
                    if (isHighlighted)
                      const Positioned(
                        top: -5,
                        right: -7,
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );

    if (reducedMotion || kind == null) {
      return body;
    }

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      scale: isHighlighted ? 1.08 : 1,
      child: body,
    );
  }
}

class _ShelfDoorOverlay extends StatelessWidget {
  const _ShelfDoorOverlay({
    required this.closeAmount,
    required this.tint,
    required this.reducedMotion,
  });

  final double closeAmount;
  final Color tint;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: closeAmount),
      duration: reducedMotion
          ? const Duration(milliseconds: 110)
          : const Duration(milliseconds: 340),
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        if (value <= 0.001) {
          return const SizedBox.shrink();
        }

        final topBottomHeight = 15 + (12 * value);
        final latchOpacity = value <= 0.55 ? 0.0 : (value - 0.55) / 0.45;

        return IgnorePointer(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, -topBottomHeight * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _DoorPanel(
                      height: topBottomHeight,
                      tint: tint,
                      isTop: true,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, topBottomHeight * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _DoorPanel(
                      height: topBottomHeight,
                      tint: tint,
                      isTop: false,
                    ),
                  ),
                ),
              ),
              if (latchOpacity > 0)
                Center(
                  child: Opacity(
                    opacity: latchOpacity,
                    child: Container(
                      width: 24,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DoorPanel extends StatelessWidget {
  const _DoorPanel({
    required this.height,
    required this.tint,
    required this.isTop,
  });

  final double height;
  final Color tint;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(8) : Radius.zero,
          bottom: isTop ? Radius.zero : const Radius.circular(8),
        ),
        gradient: LinearGradient(
          begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [tint.withValues(alpha: 0.92), tint.withValues(alpha: 0.55)],
        ),
      ),
    );
  }
}
