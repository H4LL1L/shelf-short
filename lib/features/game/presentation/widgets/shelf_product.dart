import 'package:flutter/material.dart';

import '../../domain/entities/item_kind.dart';
import '../model/item_visuals.dart';

class ShelfProduct extends StatelessWidget {
  const ShelfProduct({
    super.key,
    required this.kind,
    this.maxHeight = 62,
    this.maxWidth,
    this.isLifted = false,
  });

  final ItemKind kind;
  final double maxHeight;
  final double? maxWidth;
  final bool isLifted;

  @override
  Widget build(BuildContext context) {
    final visual = ItemVisuals.of(kind);
    final desiredWidth = maxHeight * visual.widthFactor;
    final width = maxWidth == null
        ? desiredWidth
        : desiredWidth.clamp(4.0, maxWidth!);
    final height = maxHeight * visual.heightFactor;

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: isLifted ? 1.06 : 1,
      child: SizedBox(
        width: width,
        height: maxHeight,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: -1,
                  child: Container(
                    width: width * 0.62,
                    height: 7,
                    decoration: BoxDecoration(
                      color: visual.shadowColor.withValues(
                        alpha: isLifted ? 0.30 : 0.18,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _ProductPainter(visual: visual)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductPainter extends CustomPainter {
  const _ProductPainter({required this.visual});

  final ItemVisual visual;

  @override
  void paint(Canvas canvas, Size size) {
    switch (visual.shape) {
      case ProductShape.carton:
        _paintCarton(canvas, size);
      case ProductShape.bottleSlim:
        _paintSlimBottle(canvas, size);
      case ProductShape.bottleRound:
        _paintRoundBottle(canvas, size);
      case ProductShape.can:
        _paintCan(canvas, size);
      case ProductShape.tube:
        _paintTube(canvas, size);
      case ProductShape.chipBag:
        _paintBag(canvas, size);
      case ProductShape.coffeeCup:
        _paintCoffee(canvas, size);
      case ProductShape.dispenser:
        _paintDispenser(canvas, size);
      case ProductShape.box:
        _paintBox(canvas, size);
      case ProductShape.jar:
        _paintPearJar(canvas, size);
      case ProductShape.ball:
        _paintBall(canvas, size);
      case ProductShape.trophy:
        _paintTrophy(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _ProductPainter oldDelegate) {
    return oldDelegate.visual != visual;
  }

  Paint _bodyShader(Size size, {double lighten = 0.1}) {
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _shift(visual.baseColor, lighten),
          _shift(visual.baseColor, -0.06),
        ],
      ).createShader(Offset.zero & size);
  }

  void _paintCarton(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.18,
        size.width * 0.68,
        size.height * 0.74,
      ),
      Radius.circular(size.width * 0.1),
    );
    final top = Path()
      ..moveTo(size.width * 0.16, size.height * 0.2)
      ..lineTo(size.width * 0.48, size.height * 0.05)
      ..lineTo(size.width * 0.84, size.height * 0.2)
      ..close();
    canvas.drawPath(top, Paint()..color = _shift(visual.baseColor, 0.16));
    canvas.drawRRect(body, _bodyShader(size));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.24,
        size.width * 0.46,
        size.height * 0.18,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.48,
        size.width * 0.46,
        size.height * 0.18,
      ),
    );
    _shine(canvas, size);
  }

  void _paintSlimBottle(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.38,
        size.height * 0.04,
        size.width * 0.24,
        size.height * 0.1,
      ),
      Paint()..color = visual.capColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.36,
          size.height * 0.12,
          size.width * 0.28,
          size.height * 0.16,
        ),
        Radius.circular(size.width * 0.08),
      ),
      Paint()..color = _shift(visual.baseColor, 0.06),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.20,
          size.height * 0.24,
          size.width * 0.60,
          size.height * 0.66,
        ),
        Radius.circular(size.width * 0.24),
      ),
      _bodyShader(size),
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.42,
        size.width * 0.44,
        size.height * 0.22,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.31,
        size.height * 0.48,
        size.width * 0.38,
        size.height * 0.12,
      ),
    );
    _shine(canvas, size);
  }

  void _paintRoundBottle(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.04,
        size.width * 0.32,
        size.height * 0.08,
      ),
      Paint()..color = visual.capColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.34,
          size.height * 0.10,
          size.width * 0.32,
          size.height * 0.16,
        ),
        Radius.circular(size.width * 0.12),
      ),
      Paint()..color = _shift(visual.baseColor, 0.08),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.14,
          size.height * 0.22,
          size.width * 0.72,
          size.height * 0.66,
        ),
        Radius.circular(size.width * 0.30),
      ),
      _bodyShader(size),
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.24,
        size.height * 0.38,
        size.width * 0.52,
        size.height * 0.24,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.29,
        size.height * 0.47,
        size.width * 0.42,
        size.height * 0.11,
      ),
    );
    _shine(canvas, size);
  }

  void _paintCan(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.12,
          size.width * 0.64,
          size.height * 0.72,
        ),
        Radius.circular(size.width * 0.18),
      ),
      _bodyShader(size),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.16,
        size.width * 0.64,
        size.height * 0.08,
      ),
      Paint()..color = _shift(visual.capColor, 0.12),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.38,
        size.width * 0.56,
        size.height * 0.16,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.40,
        size.width * 0.44,
        size.height * 0.12,
      ),
    );
    _shine(canvas, size);
  }

  void _paintTube(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.26, size.height * 0.08)
      ..lineTo(size.width * 0.74, size.height * 0.08)
      ..lineTo(size.width * 0.66, size.height * 0.90)
      ..lineTo(size.width * 0.34, size.height * 0.90)
      ..close();
    canvas.drawPath(path, _bodyShader(size));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.74,
        size.width * 0.40,
        size.height * 0.10,
      ),
      Paint()..color = visual.capColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.28,
        size.width * 0.40,
        size.height * 0.20,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.31,
        size.width * 0.32,
        size.height * 0.10,
      ),
    );
    _shine(canvas, size);
  }

  void _paintBag(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.16)
      ..lineTo(size.width * 0.30, size.height * 0.04)
      ..lineTo(size.width * 0.70, size.height * 0.04)
      ..lineTo(size.width * 0.82, size.height * 0.16)
      ..lineTo(size.width * 0.74, size.height * 0.94)
      ..lineTo(size.width * 0.26, size.height * 0.94)
      ..close();
    canvas.drawPath(path, _bodyShader(size));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.20,
        size.width * 0.48,
        size.height * 0.18,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.48,
        size.width * 0.44,
        size.height * 0.14,
      ),
    );
    _shine(canvas, size);
  }

  void _paintCoffee(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.18,
          size.width * 0.64,
          size.height * 0.12,
        ),
        Radius.circular(size.width * 0.18),
      ),
      Paint()..color = visual.capColor,
    );
    final body = Path()
      ..moveTo(size.width * 0.24, size.height * 0.30)
      ..lineTo(size.width * 0.76, size.height * 0.30)
      ..lineTo(size.width * 0.66, size.height * 0.88)
      ..lineTo(size.width * 0.34, size.height * 0.88)
      ..close();
    canvas.drawPath(body, _bodyShader(size));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.37,
        size.height * 0.08,
        size.width * 0.08,
        size.height * 0.14,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.48,
        size.width * 0.40,
        size.height * 0.12,
      ),
    );
    _shine(canvas, size);
  }

  void _paintDispenser(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.06,
        size.width * 0.24,
        size.height * 0.05,
      ),
      Paint()..color = visual.capColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.06,
        size.width * 0.16,
        size.height * 0.03,
      ),
      Paint()..color = visual.capColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.12,
          size.width * 0.18,
          size.height * 0.14,
        ),
        Radius.circular(size.width * 0.06),
      ),
      Paint()..color = _shift(visual.baseColor, 0.08),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.24,
          size.width * 0.64,
          size.height * 0.66,
        ),
        Radius.circular(size.width * 0.18),
      ),
      _bodyShader(size),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.42,
        size.width * 0.48,
        size.height * 0.16,
      ),
      Paint()..color = visual.accentColor,
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.45,
        size.width * 0.40,
        size.height * 0.10,
      ),
    );
    _shine(canvas, size);
  }

  void _paintBox(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.16,
          size.height * 0.18,
          size.width * 0.68,
          size.height * 0.70,
        ),
        Radius.circular(size.width * 0.10),
      ),
      _bodyShader(size),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.22,
        size.width * 0.56,
        size.height * 0.22,
      ),
      Paint()..color = visual.accentColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.62,
        size.height * 0.52,
        size.width * 0.08,
        size.height * 0.18,
      ),
      Paint()..color = _shift(visual.capColor, -0.04),
    );
    _label(
      canvas,
      size,
      Rect.fromLTWH(
        size.width * 0.31,
        size.height * 0.28,
        size.width * 0.18,
        size.height * 0.10,
      ),
    );
    _shine(canvas, size);
  }

  void _paintPearJar(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(size.width * 0.48, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.18,
        size.width * 0.20,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.92,
        size.width * 0.52,
        size.height * 0.92,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.92,
        size.width * 0.82,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.18,
        size.width * 0.52,
        size.height * 0.08,
      )
      ..close();
    canvas.drawPath(body, _bodyShader(size));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.46,
        size.height * 0.02,
        size.width * 0.10,
        size.height * 0.10,
      ),
      Paint()..color = visual.capColor,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.34,
        size.width * 0.42,
        size.height * 0.34,
      ),
      Paint()..color = visual.accentColor,
    );
    _shine(canvas, size);
  }

  void _paintBall(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      size.width * 0.14,
      size.height * 0.22,
      size.width * 0.72,
      size.height * 0.72,
    );
    canvas.drawOval(rect, _bodyShader(size));
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.27,
        size.height * 0.34,
        size.width * 0.18,
        size.height * 0.18,
      ),
      Paint()..color = visual.accentColor,
    );
    canvas.drawArc(
      rect,
      0.7,
      1.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08
        ..color = _shift(visual.capColor, 0.04),
    );
    _shine(canvas, size);
  }

  void _paintTrophy(Canvas canvas, Size size) {
    final cup = Path()
      ..moveTo(size.width * 0.28, size.height * 0.16)
      ..lineTo(size.width * 0.72, size.height * 0.16)
      ..lineTo(size.width * 0.62, size.height * 0.44)
      ..lineTo(size.width * 0.38, size.height * 0.44)
      ..close();
    canvas.drawPath(cup, _bodyShader(size));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.44,
        size.height * 0.44,
        size.width * 0.12,
        size.height * 0.18,
      ),
      Paint()..color = visual.capColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.30,
          size.height * 0.62,
          size.width * 0.40,
          size.height * 0.12,
        ),
        Radius.circular(size.width * 0.08),
      ),
      Paint()..color = _shift(visual.capColor, -0.04),
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.18,
        size.width * 0.20,
        size.height * 0.22,
      ),
      1.3,
      2.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08
        ..color = visual.capColor,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.68,
        size.height * 0.18,
        size.width * 0.20,
        size.height * 0.22,
      ),
      -0.2,
      2.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08
        ..color = visual.capColor,
    );
    _shine(canvas, size);
  }

  void _label(Canvas canvas, Size size, Rect rect) {
    if (visual.badgeText.isEmpty || rect.width < 8 || rect.height < 6) return;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height * 0.22),
    );
    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white.withValues(alpha: 0.82),
    );

    final painter = TextPainter(
      text: TextSpan(
        text: visual.badgeText,
        style: TextStyle(
          color: _shift(visual.capColor, -0.08),
          fontWeight: FontWeight.w800,
          fontSize: rect.height * 0.40,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout(maxWidth: rect.width);
    painter.paint(
      canvas,
      Offset(rect.left, rect.top + (rect.height - painter.height) / 2),
    );
  }

  void _shine(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.28,
          size.height * 0.16,
          size.width * 0.08,
          size.height * 0.56,
        ),
        Radius.circular(size.width * 0.04),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
  }

  Color _shift(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
