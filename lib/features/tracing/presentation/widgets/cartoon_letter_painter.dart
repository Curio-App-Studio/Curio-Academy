import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/tracing_stroke_data.dart';

/// Painter for the chunky double-bordered cartoon letter track,
/// progressive color fills, circular pearl guide dots, and directional start chevrons.
class CartoonLetterPainter extends CustomPainter {
  final String character;
  final Rect letterBounds;
  final double fontSize;
  final List<TracingStrokeGuide> allStrokes;
  final int activeStrokeIndex;
  final int activeDotIndex;
  final List<List<Offset>> completedStrokes;
  final List<Color> strokeColors;
  final List<Offset> liveCurrentStroke;
  final Color currentCrayonColor;
  final double handBounceOffset;

  CartoonLetterPainter({
    required this.character,
    required this.letterBounds,
    required this.fontSize,
    required this.allStrokes,
    required this.activeStrokeIndex,
    required this.activeDotIndex,
    required this.completedStrokes,
    required this.strokeColors,
    required this.liveCurrentStroke,
    required this.currentCrayonColor,
    required this.handBounceOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (letterBounds.isEmpty) return;

    final centerOffset = Offset(
      letterBounds.left,
      letterBounds.top,
    );

    // 1. LAYER A: OUTER BLACK CONTOUR
    final outerStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF0F172A);

    _paintTextWithStyle(
      canvas,
      centerOffset,
      character,
      fontSize,
      foreground: outerStrokePaint,
    );

    // 2. LAYER B: INNER CRISP WHITE BORDER
    final innerWhiteStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    _paintTextWithStyle(
      canvas,
      centerOffset,
      character,
      fontSize,
      foreground: innerWhiteStrokePaint,
    );

    // 3. LAYER C: TEAL LETTER TRACK WITH PROGRESSIVE COLORED FILL
    // We isolate the track fill in a layer so strokes are clipped with BlendMode.srcATop.
    // This guarantees the strokes ONLY color the teal channel, without ever touching or modifying the white or black borders!
    final trackBounds = letterBounds.inflate(20);
    canvas.saveLayer(trackBounds, Paint());

    // Paint the deep ocean teal base fill
    final trackFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0A686B);

    _paintTextWithStyle(
      canvas,
      centerOffset,
      character,
      fontSize,
      foreground: trackFillPaint,
    );

    // If there are completed or active dragging strokes, paint them with srcATop!
    if (completedStrokes.isNotEmpty || liveCurrentStroke.isNotEmpty) {
      final strokePaint = Paint()
        ..blendMode = BlendMode.srcATop
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 52.0; // Broad enough to fully fill the letter channel

      for (int i = 0; i < completedStrokes.length; i++) {
        final s = completedStrokes[i];
        if (s.isEmpty) continue;
        final color = i < strokeColors.length ? strokeColors[i] : const Color(0xFFDC2626);
        strokePaint.color = color;

        if (s.length == 1) {
          canvas.drawCircle(s.first, 26.0, strokePaint..style = PaintingStyle.fill);
          strokePaint.style = PaintingStyle.stroke;
        } else {
          final path = Path()..moveTo(s.first.dx, s.first.dy);
          for (int p = 1; p < s.length; p++) {
            path.lineTo(s[p].dx, s[p].dy);
          }
          canvas.drawPath(path, strokePaint);
        }
      }

      // Draw current live dragging stroke
      if (liveCurrentStroke.isNotEmpty) {
        strokePaint.color = currentCrayonColor;
        if (liveCurrentStroke.length == 1) {
          canvas.drawCircle(liveCurrentStroke.first, 26.0, strokePaint..style = PaintingStyle.fill);
          strokePaint.style = PaintingStyle.stroke;
        } else {
          final path = Path()..moveTo(liveCurrentStroke.first.dx, liveCurrentStroke.first.dy);
          for (int p = 1; p < liveCurrentStroke.length; p++) {
            path.lineTo(liveCurrentStroke[p].dx, liveCurrentStroke[p].dy);
          }
          canvas.drawPath(path, strokePaint);
        }
      }
    }

    canvas.restore();

    // --- STEP 3: DRAW ACTIVE STROKE GUIDE DOTS & CHEVRON ---
    if (activeStrokeIndex < allStrokes.length) {
      final activeStroke = allStrokes[activeStrokeIndex];
      final screenPoints = activeStroke.toScreenCoordinates(letterBounds);

      if (screenPoints.isNotEmpty) {
        // Draw Pearl Dots & Start Chevron Indicator along active stroke
        for (int i = 0; i < screenPoints.length; i++) {
          final pt = screenPoints[i];
          final isCollected = i < activeDotIndex;
          final isCurrent = i == activeDotIndex;

          if (isCollected) {
            // Already collected dot - faint golden glow
            canvas.drawCircle(
              pt,
              7.0,
              Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.85),
            );
          } else if (i == 0) {
            // Start Indicator at the beginning of the stroke (Circle with white chevron inside)
            // Outer white ring
            canvas.drawCircle(
              pt,
              13.5,
              Paint()
                ..color = Colors.white
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.2,
            );
            // Draw Chevron inside the start ring
            _drawStartChevron(
              canvas,
              pt,
              screenPoints.length > 1 ? screenPoints[1] : pt + const Offset(0, 10),
            );

            // If start dot is active, beacon glow ring
            if (isCurrent) {
              final pulseRadius = 17.0 + (handBounceOffset.abs() * 3.5);
              canvas.drawCircle(
                pt,
                pulseRadius,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.5
                  ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.9),
              );
            }
          } else {
            // Regular pearl dot - solid white with subtle drop shadow
            canvas.drawCircle(
              pt + const Offset(0, 1.5),
              11.0,
              Paint()..color = Colors.black.withValues(alpha: 0.35),
            );
            canvas.drawCircle(
              pt,
              10.5,
              Paint()..color = Colors.white,
            );
            canvas.drawCircle(
              pt - const Offset(2.0, 2.0),
              3.5,
              Paint()..color = const Color(0xFFF8FAFC),
            );

            // If this is the active dot, draw inviting golden beacon ring
            if (isCurrent) {
              final pulseRadius = 15.0 + (handBounceOffset.abs() * 3.5);
              canvas.drawCircle(
                pt,
                pulseRadius,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.5
                  ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.9),
              );
            }
          }
        }

        // Draw Animated Cartoon Hand Pointer at active dot
        if (activeDotIndex < screenPoints.length) {
          final targetPoint = screenPoints[activeDotIndex];
          _drawCartoonHandPointer(canvas, targetPoint, handBounceOffset);
        }
      }
    }
  }

  void _paintTextWithStyle(
    Canvas canvas,
    Offset offset,
    String char,
    double fSize, {
    required Paint foreground,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          fontSize: fSize,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
          foreground: foreground,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawStartChevron(Canvas canvas, Offset p0, Offset p1) {
    final angle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);

    canvas.save();
    canvas.translate(p0.dx, p0.dy);
    canvas.rotate(angle);

    // White chevron mark pointing in travel direction
    final chevronPath = Path();
    chevronPath.moveTo(-5, -6);
    chevronPath.lineTo(3.5, 0);
    chevronPath.lineTo(-5, 6);

    final chevronPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(chevronPath, chevronPaint);
    canvas.restore();
  }

  void _drawCartoonHandPointer(Canvas canvas, Offset target, double bounce) {
    // Offset the hand slightly to point directly at the dot
    final handPos = target + Offset(14 + (bounce * 4), 16 + (bounce * 6));

    canvas.save();
    canvas.translate(handPos.dx, handPos.dy);

    // 1. Red Sleeve Cuff
    final cuffPaint = Paint()..color = const Color(0xFFEF4444);
    final cuffRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 20, 24, 14),
      const Radius.circular(6),
    );
    canvas.drawRRect(cuffRRect, cuffPaint);

    // 2. Yellow/Peach Glove Hand
    final handPaint = Paint()..color = const Color(0xFFFFB74D);
    final handBorderPaint = Paint()
      ..color = const Color(0xFF9A3412)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Palm
    canvas.drawCircle(const Offset(12, 14), 13, handPaint);
    canvas.drawCircle(const Offset(12, 14), 13, handBorderPaint);

    // Pointing Index Finger pointing up-left towards target dot
    final fingerPath = Path();
    fingerPath.moveTo(6, 6);
    fingerPath.lineTo(-12, -12); // Tip pointing directly at the dot
    fingerPath.arcToPoint(const Offset(-7, -17), radius: const Radius.circular(4));
    fingerPath.lineTo(12, 2);
    fingerPath.close();

    canvas.drawPath(fingerPath, handPaint);
    canvas.drawPath(fingerPath, handBorderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CartoonLetterPainter oldDelegate) {
    return oldDelegate.activeStrokeIndex != activeStrokeIndex ||
        oldDelegate.activeDotIndex != activeDotIndex ||
        oldDelegate.liveCurrentStroke.length != liveCurrentStroke.length ||
        oldDelegate.completedStrokes.length != completedStrokes.length ||
        oldDelegate.handBounceOffset != handBounceOffset ||
        oldDelegate.character != character ||
        oldDelegate.currentCrayonColor != currentCrayonColor;
  }
}
