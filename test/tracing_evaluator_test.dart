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

    test('Stroke drawn over letter returns isCompleted: true with accuracy and stars', () async {
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
      expect(result.accuracy, greaterThan(0.50));
      expect(result.coverage, greaterThan(0.10));
    });
  });
}
