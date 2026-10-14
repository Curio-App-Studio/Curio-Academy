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

    // --- STEP 1: PREPARE TEXT PAINTER FOR LETTER GLYPH ---
    final textSpan = TextSpan(
      text: character,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        fontFamily: 'Roboto',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

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

    // 3. LAYER C: DEEP TEAL LETTER TRACK FILL
    final trackFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0A686B); // Deep ocean teal from reference

    _paintTextWithStyle(
      canvas,
      centerOffset,
      character,
      fontSize,
      foreground: trackFillPaint,
    );

    // --- STEP 2: CLIPPED PROGRESSIVE COLORED STROKE FILLS ---
    // We use saveLayer + BlendMode.srcIn to ensure all drawn strokes stay strictly inside the letter track
    final boundsWithMargin = letterBounds.inflate(40);
    canvas.saveLayer(boundsWithMargin, Paint());

    // Destination: Solid text mask
    _paintTextWithStyle(
      canvas,
      centerOffset,
      character,
      fontSize,
      foreground: Paint()..color = Colors.white,
    );

    // Source (BlendMode.srcIn): Completed strokes & active stroke
    final strokePaint = Paint()
      ..blendMode = BlendMode.srcIn
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48.0; // Broad enough to fully fill the letter channel

    // Draw completed strokes
    for (int i = 0; i < completedStrokes.length; i++) {
      final s = completedStrokes[i];
      if (s.isEmpty) continue;
      final color = i < strokeColors.length ? strokeColors[i] : const Color(0xFFDC2626);
      strokePaint.color = color;

      if (s.length == 1) {
        canvas.drawCircle(s.first, 24.0, strokePaint..style = PaintingStyle.fill);
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
        canvas.drawCircle(liveCurrentStroke.first, 24.0, strokePaint..style = PaintingStyle.fill);
        strokePaint.style = PaintingStyle.stroke;
      } else {
        final path = Path()..moveTo(liveCurrentStroke.first.dx, liveCurrentStroke.first.dy);
        for (int p = 1; p < liveCurrentStroke.length; p++) {
          path.lineTo(liveCurrentStroke[p].dx, liveCurrentStroke[p].dy);
        }
        canvas.drawPath(path, strokePaint);
      }
    }

    canvas.restore();

    // Re-apply inner white border lightly so the stroke edges remain super crisp
    final borderTouchUp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    _paintTextWithStyle(
      canvas,
      centerOffset,
      character,
      fontSize,
      foreground: borderTouchUp,
    );

    // --- STEP 3: DRAW ACTIVE STROKE GUIDE DOTS & CHEVRON ---
    if (activeStrokeIndex < allStrokes.length) {
      final activeStroke = allStrokes[activeStrokeIndex];
      final screenPoints = activeStroke.toScreenCoordinates(letterBounds);

      if (screenPoints.isNotEmpty) {
        // Draw Start Directional Chevron at the first dot
        _drawStartChevron(canvas, screenPoints);

        // Draw Pearl Dots along the active stroke
        for (int i = 0; i < screenPoints.length; i++) {
          final pt = screenPoints[i];
          final isCollected = i < activeDotIndex;
          final isCurrent = i == activeDotIndex;

          if (isCollected) {
            // Already collected dot - faint golden glow
            canvas.drawCircle(
              pt,
              6.5,
              Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.8),
            );
          } else {
            // Uncollected pearl dot - solid white with subtle 3D highlight
            // Drop shadow
            canvas.drawCircle(
              pt + const Offset(0, 1.5),
              11.0,
              Paint()..color = Colors.black.withValues(alpha: 0.35),
            );
            // Outer white pearl
            canvas.drawCircle(
              pt,
              10.5,
              Paint()..color = Colors.white,
            );
            // Soft center highlight
            canvas.drawCircle(
              pt - const Offset(2.0, 2.0),
              3.5,
              Paint()..color = const Color(0xFFF1F5F9),
            );

            // If this is the active dot, draw an inviting golden beacon ring
            if (isCurrent) {
              final pulseRadius = 14.0 + (handBounceOffset.abs() * 3.5);
              canvas.drawCircle(
                pt,
                pulseRadius,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.5
                  ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.85),
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

  void _drawStartChevron(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;
    final p0 = points[0];
    final p1 = points[1];

    final angle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);

    canvas.save();
    canvas.translate(p0.dx, p0.dy);
    canvas.rotate(angle);

    // White chevron mark pointing in travel direction
    final chevronPath = Path();
    chevronPath.moveTo(-6, -8);
    chevronPath.lineTo(4, 0);
    chevronPath.lineTo(-6, 8);

    final chevronPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
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
