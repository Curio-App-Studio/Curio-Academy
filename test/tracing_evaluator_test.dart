import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/features/tracing/domain/tracing_evaluator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TracingEvaluator Accuracy & Check Tests', () {
    const canvasSize = Size(360, 400);

    test('Empty strokes return isCompleted: false', () async {
      final result = await TracingEvaluator.evaluate(
        character: 'A',
        strokes: [],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isFalse);
      expect(result.stars, equals(0));
    });

    test('Single dot in corner returns isCompleted: false with incomplete feedback', () async {
      final result = await TracingEvaluator.evaluate(
        character: 'A',
        strokes: [
          [const Offset(10, 10)]
        ],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isFalse);
      expect(result.stars, equals(0));
      expect(result.feedbackEn, contains('Trace'));
    });

    test('Stroke drawn over letter 1 returns isCompleted: true with accuracy and stars', () async {
      // Simulate tracing a centered '1'
      final List<Offset> verticalStroke = [];
      for (double y = 120; y <= 280; y += 10) {
        verticalStroke.add(Offset(180, y));
      }

      final result = await TracingEvaluator.evaluate(
        character: '1',
        strokes: [verticalStroke],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isTrue);
      expect(result.stars, greaterThanOrEqualTo(1));
      expect(result.accuracy, greaterThan(0.40));
      expect(result.coverage, greaterThan(0.10));
    });

    test('Letter C with full curved arc is completed', () async {
      final List<Offset> arc = [
        const Offset(240, 130),
        const Offset(200, 115),
        const Offset(160, 120),
        const Offset(130, 140),
        const Offset(115, 170),
        const Offset(110, 200),
        const Offset(115, 230),
        const Offset(130, 260),
        const Offset(160, 280),
        const Offset(200, 285),
        const Offset(240, 270),
      ];

      final result = await TracingEvaluator.evaluate(
        character: 'C',
        strokes: [arc],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isTrue);
      expect(result.stars, greaterThanOrEqualTo(1));
    });

    test('Letter B with only a single vertical stroke MUST NOT be completed', () async {
      final List<Offset> singleSpine = [];
      for (double y = 120; y <= 280; y += 10) {
        singleSpine.add(Offset(125, y));
      }

      final result = await TracingEvaluator.evaluate(
        character: 'B',
        strokes: [singleSpine],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isFalse);
      expect(result.stars, equals(0));
      expect(result.feedbackEn, contains('Trace all lines and curves'));
    });

    test('Letter D with only a single vertical stroke MUST NOT be completed', () async {
      final List<Offset> singleSpine = [];
      for (double y = 120; y <= 280; y += 10) {
        singleSpine.add(Offset(125, y));
      }

      final result = await TracingEvaluator.evaluate(
        character: 'D',
        strokes: [singleSpine],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isFalse);
      expect(result.stars, equals(0));
      expect(result.feedbackEn, contains('Trace all lines and curves'));
    });

    test('Letter C with only a single vertical chord MUST NOT be completed', () async {
      final List<Offset> singleChord = [];
      for (double y = 130; y <= 270; y += 10) {
        singleChord.add(Offset(150, y));
      }

      final result = await TracingEvaluator.evaluate(
        character: 'C',
        strokes: [singleChord],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isFalse);
      expect(result.stars, equals(0));
      expect(result.feedbackEn, contains('Trace all lines and curves'));
    });

    test('Letter B with full strokes (spine + top curve + bottom curve) is completed', () async {
      // 1. Spine
      final List<Offset> spine = [];
      for (double y = 120; y <= 280; y += 10) {
        spine.add(Offset(125, y));
      }

      // 2. Top curve
      final List<Offset> topLoop = [
        const Offset(125, 120),
        const Offset(180, 120),
        const Offset(220, 140),
        const Offset(220, 175),
        const Offset(180, 195),
        const Offset(125, 195),
      ];

      // 3. Bottom curve
      final List<Offset> bottomLoop = [
        const Offset(125, 195),
        const Offset(190, 195),
        const Offset(230, 220),
        const Offset(230, 255),
        const Offset(190, 280),
        const Offset(125, 280),
      ];

      final result = await TracingEvaluator.evaluate(
        character: 'B',
        strokes: [spine, topLoop, bottomLoop],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isTrue);
      expect(result.stars, greaterThanOrEqualTo(2));
      expect(result.accuracy, greaterThan(0.60));
    });

    test('Letter D with full strokes (spine + right curved arc) is completed', () async {
      // 1. Spine
      final List<Offset> spine = [];
      for (double y = 120; y <= 280; y += 10) {
        spine.add(Offset(125, y));
      }

      // 2. Right curved arc
      final List<Offset> arc = [
        const Offset(125, 120),
        const Offset(180, 120),
        const Offset(235, 150),
        const Offset(245, 200),
        const Offset(235, 250),
        const Offset(180, 280),
        const Offset(125, 280),
      ];

      final result = await TracingEvaluator.evaluate(
        character: 'D',
        strokes: [spine, arc],
        canvasSize: canvasSize,
      );

      expect(result.isCompleted, isTrue);
      expect(result.stars, greaterThanOrEqualTo(2));
      expect(result.accuracy, greaterThan(0.60));
    });
  });
}
