import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Scenic cartoon background painter featuring:
/// - Sunny sky gradient
/// - Vibrant arching rainbow
/// - Puffy green tree canopies at the top
/// - Rolling golden flower meadow at the bottom
class CartoonBackgroundPainter extends CustomPainter {
  const CartoonBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Sky Gradient Background
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF38BDF8), // Vibrant cyan sky
          Color(0xFF7DD3FC),
          Color(0xFFBAE6FD),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 2. Arching Rainbow across the center sky
    final rainbowCenter = Offset(size.width * 0.5, size.height * 0.65);
    final baseRadius = size.width * 0.55;
    const double rainbowBandWidth = 7.0;

    final rainbowColors = [
      const Color(0xFFFF5252).withValues(alpha: 0.65), // Red
      const Color(0xFFFF9800).withValues(alpha: 0.65), // Orange
      const Color(0xFFFFEB3B).withValues(alpha: 0.65), // Yellow
      const Color(0xFF4CAF50).withValues(alpha: 0.65), // Green
      const Color(0xFF2196F3).withValues(alpha: 0.65), // Blue
      const Color(0xFF9C27B0).withValues(alpha: 0.65), // Purple
    ];

    for (int i = 0; i < rainbowColors.length; i++) {
      final bandPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rainbowBandWidth
        ..color = rainbowColors[i];
      final r = baseRadius - (i * rainbowBandWidth);
      if (r > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: rainbowCenter, radius: r),
          math.pi,
          math.pi,
          false,
          bandPaint,
        );
      }
    }

    // 3. Rolling Golden Meadow Hill at the bottom
    final meadowPath = Path();
    final meadowTopY = size.height * 0.82;
    meadowPath.moveTo(0, meadowTopY);
    meadowPath.quadraticBezierTo(
      size.width * 0.25,
      meadowTopY - 20,
      size.width * 0.5,
      meadowTopY - 8,
    );
    meadowPath.quadraticBezierTo(
      size.width * 0.75,
      meadowTopY + 5,
      size.width,
      meadowTopY - 14,
    );
    meadowPath.lineTo(size.width, size.height);
    meadowPath.lineTo(0, size.height);
    meadowPath.close();

    final meadowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFDE047), // Sunny vibrant yellow
          Color(0xFFFACC15),
          Color(0xFFEAB308),
        ],
      ).createShader(rect);
    canvas.drawPath(meadowPath, meadowPaint);

    // Meadow Grass Tufts
    final grassPaint = Paint()
      ..color = const Color(0xFF65A30D)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final tuftXs = [size.width * 0.08, size.width * 0.22, size.width * 0.78, size.width * 0.92];
    for (final x in tuftXs) {
      canvas.drawLine(Offset(x, meadowTopY - 2), Offset(x - 5, meadowTopY - 14), grassPaint);
      canvas.drawLine(Offset(x, meadowTopY - 2), Offset(x, meadowTopY - 18), grassPaint);
      canvas.drawLine(Offset(x, meadowTopY - 2), Offset(x + 5, meadowTopY - 12), grassPaint);
    }

    // 4. Lush Cartoon Tree Canopies at the top corners
    _drawTreeCanopy(canvas, Offset(0, 0), isLeft: true);
    _drawTreeCanopy(canvas, Offset(size.width, 0), isLeft: false);
  }

  void _drawTreeCanopy(Canvas canvas, Offset origin, {required bool isLeft}) {
    final darkGreen = const Color(0xFF15803D);
    final midGreen = const Color(0xFF22C55E);
    final lightGreen = const Color(0xFF4ADE80);

    final sign = isLeft ? 1.0 : -1.0;

    void drawPuff(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = color,
      );
      // Highlight rim
      canvas.drawCircle(
        center - Offset(radius * 0.2, radius * 0.2),
        radius * 0.65,
        Paint()..color = lightGreen.withValues(alpha: 0.35),
      );
    }

    // Outer dark puffs
    drawPuff(origin + Offset(sign * 35, 30), 48, darkGreen);
    drawPuff(origin + Offset(sign * 80, 25), 42, darkGreen);
    drawPuff(origin + Offset(sign * 25, 75), 40, darkGreen);

    // Foreground mid puffs
    drawPuff(origin + Offset(sign * 45, 45), 44, midGreen);
    drawPuff(origin + Offset(sign * 95, 35), 36, midGreen);
    drawPuff(origin + Offset(sign * 35, 90), 34, midGreen);
    drawPuff(origin + Offset(sign * 125, 15), 30, midGreen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
