import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgTop, AppColors.bgBottom],
        ),
      ),
      child: CustomPaint(painter: const _StoreWallPainter(), child: child),
    );
  }
}

class _StoreWallPainter extends CustomPainter {
  const _StoreWallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topBeam = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE2B67F), Color(0xFFC88D51)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 96));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 92), topBeam);

    final linePaint = Paint()
      ..color = const Color(0x118A5A27)
      ..strokeWidth = 1;

    for (double y = 116; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
