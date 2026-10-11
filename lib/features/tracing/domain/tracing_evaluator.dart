import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Result of evaluating a child's finger tracing on a character
class TracingEvaluationResult {
  final bool isCompleted;
  final double coverage; // Percentage of letter path covered (0.0 - 1.0)
  final double accuracy; // Combined score factoring precision (0.0 - 1.0)
  final int stars; // 0 to 3 stars
  final String feedbackEn;
  final String feedbackHi;

  const TracingEvaluationResult({
    required this.isCompleted,
    required this.coverage,
    required this.accuracy,
    required this.stars,
    required this.feedbackEn,
    required this.feedbackHi,
  });
}

class _CachedTarget {
  final String character;
  final Size size;
  final List<int> targetData;
  final int targetPixels;

  _CachedTarget({
    required this.character,
    required this.size,
    required this.targetData,
    required this.targetPixels,
  });
}

/// Evaluator that verifies whether the child accurately traced the target letter,
/// supporting real-time tracking accuracy and auto-check while finger tracing.
class TracingEvaluator {
  static const int _sampleResolution = 80;
  static _CachedTarget? _cache;

  /// Clears mask cache when character or screen size changes
  static void clearCache() {
    _cache = null;
  }

  static Future<_CachedTarget> _getTargetMask(String character, Size effectiveSize, double fontSize) async {
    final cached = _cache;
    if (cached != null && cached.character == character && cached.size == effectiveSize) {
      return cached;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
          color: const Color(0xFF000000),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      (effectiveSize.width - textPainter.width) / 2,
      (effectiveSize.height - textPainter.height) / 2,
    );

    final scaleX = _sampleResolution / effectiveSize.width;
    final scaleY = _sampleResolution / effectiveSize.height;

    final targetRecorder = ui.PictureRecorder();
    final targetCanvas = Canvas(targetRecorder);
    targetCanvas.scale(scaleX, scaleY);
    textPainter.paint(targetCanvas, textOffset);
    final targetPic = targetRecorder.endRecording();
    final targetImg = await targetPic.toImage(_sampleResolution, _sampleResolution);
    final targetBytes = await targetImg.toByteData(format: ui.ImageByteFormat.rawRgba);

    int targetPixels = 0;
    final List<int> data = List.filled(_sampleResolution * _sampleResolution, 0);

    if (targetBytes != null) {
      final uint32 = targetBytes.buffer.asUint32List();
      for (int i = 0; i < uint32.length; i++) {
        final alpha = (uint32[i] >> 24) & 0xFF;
        if (alpha > 25) {
          data[i] = 1;
          targetPixels++;
        }
      }
    }

    final newCache = _CachedTarget(
      character: character,
      size: effectiveSize,
      targetData: data,
      targetPixels: targetPixels,
    );
    _cache = newCache;
    return newCache;
  }

  /// Evaluates strokes against target character on the given canvas size.
  static Future<TracingEvaluationResult> evaluate({
    required String character,
    required List<List<Offset>> strokes,
    required Size canvasSize,
    double fontSize = 220,
  }) async {
    // 1. Basic length & point count validation
    double totalLength = 0;
    int totalPoints = 0;
    for (final stroke in strokes) {
      totalPoints += stroke.length;
      for (int i = 0; i < stroke.length - 1; i++) {
        totalLength += (stroke[i + 1] - stroke[i]).distance;
      }
    }

    if (strokes.isEmpty || totalPoints < 3 || totalLength < 50) {
      return const TracingEvaluationResult(
        isCompleted: false,
        coverage: 0.0,
        accuracy: 0.0,
        stars: 0,
        feedbackEn: 'Trace the letter with your finger first! ✍️',
        feedbackHi: 'अपनी उंगली से अक्षर पर ट्रेस करें! ✍️',
      );
    }

    final effectiveSize = Size(
      canvasSize.width > 50 ? canvasSize.width : 300,
      canvasSize.height > 50 ? canvasSize.height : 300,
    );

    final target = await _getTargetMask(character, effectiveSize, fontSize);

    // 2. Render user strokes to sample bitmap
    final scaleX = _sampleResolution / effectiveSize.width;
    final scaleY = _sampleResolution / effectiveSize.height;

    final strokeRecorder = ui.PictureRecorder();
    final strokeCanvas = Canvas(strokeRecorder);
    strokeCanvas.scale(scaleX, scaleY);

    final strokePaint = Paint()
      ..strokeWidth = 32.0 // Kid-friendly tolerance band
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF000000);

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        strokeCanvas.drawCircle(stroke.first, 16.0, strokePaint..style = PaintingStyle.fill);
        strokePaint.style = PaintingStyle.stroke;
      } else if (stroke.length > 1) {
        final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        strokeCanvas.drawPath(path, strokePaint);
      }
    }
    final strokePic = strokeRecorder.endRecording();
    final strokeImg = await strokePic.toImage(_sampleResolution, _sampleResolution);
    final strokeBytes = await strokeImg.toByteData(format: ui.ImageByteFormat.rawRgba);

    // 3. Fast pixel-by-pixel intersection analysis
    int strokePixels = 0;
    int overlapPixels = 0;

    if (strokeBytes != null) {
      final strokeData = strokeBytes.buffer.asUint32List();
      final len = strokeData.length;
      final targetData = target.targetData;

      for (int i = 0; i < len; i++) {
        final isStroke = ((strokeData[i] >> 24) & 0xFF) > 25;
        if (isStroke) {
          strokePixels++;
          if (targetData[i] == 1) {
            overlapPixels++;
          }
        }
      }
    }

    // Coverage: percentage of the glyph covered by stroke line
    final double coverage = target.targetPixels > 0 ? (overlapPixels / target.targetPixels).clamp(0.0, 1.0) : 0.0;

    // Precision: how much of the child's drawing landed on the target letter
    final double precision = strokePixels > 0 ? (overlapPixels / strokePixels).clamp(0.0, 1.0) : 0.0;

    // Combined Accuracy (0.0 to 1.0)
    final double accuracy = ((precision * 0.6) + ((coverage / 0.22).clamp(0.0, 1.0) * 0.4)).clamp(0.0, 1.0);

    // 4. Evaluation Decisions
    // Incomplete
    if (totalLength < 80 || overlapPixels < 100) {
      return TracingEvaluationResult(
        isCompleted: false,
        coverage: coverage,
        accuracy: accuracy,
        stars: 0,
        feedbackEn: 'Almost there! Trace more of the letter lines. ✏️',
        feedbackHi: 'अक्षर पर और आगे उंगली चलाएं! पूरा अक्षर ट्रेस करें। ✏️',
      );
    }

    // Off track
    if (precision < 0.35) {
      return TracingEvaluationResult(
        isCompleted: false,
        coverage: coverage,
        accuracy: accuracy,
        stars: 0,
        feedbackEn: 'Try staying closer to the dotted letter guidelines! ✍️',
        feedbackHi: 'डॉटेड लाइनों के ऊपर उंगली चलाएं! ✍️',
      );
    }

    // Success! Calculate stars
    int stars = 1;
    if (precision >= 0.65 && overlapPixels >= 200) {
      stars = 3;
    } else if (precision >= 0.45 && overlapPixels >= 130) {
      stars = 2;
    }

    final String cheerEn = stars == 3
        ? 'Superb handwriting! Perfect trace! 🌟🌟🌟'
        : (stars == 2 ? 'Great job! Beautiful letter! 🌟🌟' : 'Good effort! Nice try! 🌟');

    final String cheerHi = stars == 3
        ? 'अद्भुत सुलेख! बहुत सुंदर लिखा! 🌟🌟🌟'
        : (stars == 2 ? 'शाबाश! बहुत अच्छा प्रयास! 🌟🌟' : 'अच्छा प्रयास! अभ्यास जारी रखें! 🌟');

    return TracingEvaluationResult(
      isCompleted: true,
      coverage: coverage,
      accuracy: accuracy,
      stars: stars,
      feedbackEn: cheerEn,
      feedbackHi: cheerHi,
    );
  }
}
