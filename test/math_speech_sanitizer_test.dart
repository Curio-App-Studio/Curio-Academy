import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/core/audio/math_speech_sanitizer.dart';

void main() {
  group('MathSpeechSanitizer - Equations and Subtraction Tests', () {
    test('Converts standard subtraction "-" to "minus" and never says "dash"', () {
      final result = MathSpeechSanitizer.sanitize('15 - 7 = 8');
      expect(result, contains('minus'));
      expect(result, isNot(contains('dash')));
      expect(result, equals('15 minus 7 equals 8'));
    });

    test('Converts Unicode en-dash "–" and em-dash "—" in equations to "minus"', () {
      final result1 = MathSpeechSanitizer.sanitize('25 – 10 = 15');
      expect(result1, contains('minus'));
      expect(result1, isNot(contains('–')));

      final result2 = MathSpeechSanitizer.sanitize('100 — 40 = 60');
      expect(result2, contains('minus'));
      expect(result2, isNot(contains('—')));
    });

    test('Converts compact subtraction like "15-7" to "minus"', () {
      final result = MathSpeechSanitizer.sanitize('15-7');
      expect(result, equals('15 minus 7'));
    });

    test('Preserves hyphenated English words like "step-by-step" and "two-digit"', () {
      final result = MathSpeechSanitizer.sanitize('Follow the step-by-step process for two-digit numbers: 45 - 20 = ?');
      expect(result, contains('step-by-step'));
      expect(result, contains('two-digit'));
      expect(result, contains('45 minus 20 equals what?'));
      expect(result, isNot(contains('step minus by')));
    });

    test('Handles negative numbers properly', () {
      final result = MathSpeechSanitizer.sanitize('Calculate: -5 + 12 = ?');
      expect(result, contains('negative 5 plus 12 equals what?'));
    });
  });

  group('MathSpeechSanitizer - Division and Fractions Tests', () {
    test('Converts standard slash "/" division to "divided by" and never says "slash"', () {
      final result = MathSpeechSanitizer.sanitize('12 / 3 = 4');
      expect(result, contains('divided by'));
      expect(result, isNot(contains('slash')));
      expect(result, equals('12 divided by 3 equals 4'));
    });

    test('Converts division symbol "÷" to "divided by"', () {
      final result = MathSpeechSanitizer.sanitize('24 ÷ 6 = 4');
      expect(result, equals('24 divided by 6 equals 4'));
    });

    test('Converts common fractions to natural words (1/2, 3/4, 2/3)', () {
      expect(MathSpeechSanitizer.sanitize('Find 1/2 of 10'), contains('one half of 10'));
      expect(MathSpeechSanitizer.sanitize('What is 3/4?'), contains('three quarters?'));
      expect(MathSpeechSanitizer.sanitize('Color 2/3 of the circle'), contains('two thirds of the circle'));
      expect(MathSpeechSanitizer.sanitize('1/4 + 1/4 = 1/2'), equals('one quarter plus one quarter equals one half'));
    });

    test('Converts mixed numbers e.g. "2 1/2" to "2 and one half"', () {
      final result = MathSpeechSanitizer.sanitize('She has 2 1/2 apples.');
      expect(result, contains('2 and one half apples.'));
    });

    test('Converts speed units like km/h and m/s to "per hour" / "per second"', () {
      final result1 = MathSpeechSanitizer.sanitize('The speed is 60 km/h');
      expect(result1, contains('60 kilometers per hour'));

      final result2 = MathSpeechSanitizer.sanitize('Velocity is 10 m/s');
      expect(result2, contains('10 meters per second'));
    });
  });

  group('MathSpeechSanitizer - Multiplication, Blanks, Powers, & Symbols', () {
    test('Converts multiplication "*" and "×" without stripping to empty', () {
      final result1 = MathSpeechSanitizer.sanitize('5 * 4 = 20');
      expect(result1, equals('5 multiplied by 4 equals 20'));

      final result2 = MathSpeechSanitizer.sanitize('7 × 8 = 56');
      expect(result2, equals('7 multiplied by 8 equals 56'));
    });

    test('Converts fill-in-the-blank "___" to "blank" instead of "underscore"', () {
      final result = MathSpeechSanitizer.sanitize('8 + ___ = 12');
      expect(result, contains('8 plus blank equals 12'));
      expect(result, isNot(contains('underscore')));
    });

    test('Converts "= ?" to "equals what?"', () {
      final result = MathSpeechSanitizer.sanitize('9 - 4 = ?');
      expect(result, equals('9 minus 4 equals what?'));
    });

    test('Converts exponents and roots (², ³, √)', () {
      expect(MathSpeechSanitizer.sanitize('5² = 25'), equals('5 squared equals 25'));
      expect(MathSpeechSanitizer.sanitize('2³ = 8'), equals('2 cubed equals 8'));
      expect(MathSpeechSanitizer.sanitize('√16 = 4'), equals('square root of 16 equals 4'));
    });

    test('Converts relations (<, >, ≤, ≥, ≠)', () {
      expect(MathSpeechSanitizer.sanitize('5 < 10'), equals('5 is less than 10'));
      expect(MathSpeechSanitizer.sanitize('12 > 4'), equals('12 is greater than 4'));
      expect(MathSpeechSanitizer.sanitize('x ≠ y'), equals('x does not equal y'));
      expect(MathSpeechSanitizer.sanitize('a ≤ b'), equals('a is less than or equal to b'));
    });

    test('Converts range like "Class 1-5" to "Class 1 to 5"', () {
      expect(MathSpeechSanitizer.sanitize('Syllabus for Class 1-5'), equals('Syllabus for Class 1 to 5'));
      expect(MathSpeechSanitizer.sanitize('Read pages 10-15'), equals('Read pages 10 to 15'));
    });

    test('Strips emojis cleanly', () {
      final result = MathSpeechSanitizer.sanitize('Solve: 🍎 3 + 2 = 5 ⭐');
      expect(result, equals('Solve: 3 plus 2 equals 5'));
    });
  });

  group('MathSpeechSanitizer - Hindi Curriculum Support', () {
    test('Speaks Hindi math prompts in Hindi phonetics', () {
      final result = MathSpeechSanitizer.sanitize('हल करें: 15 - 7 = ?', isHindi: true);
      expect(result, contains('माइनस'));
      expect(result, contains('बराबर क्या?'));
      expect(result, isNot(contains('dash')));

      final resultDiv = MathSpeechSanitizer.sanitize('12 / 3 = 4', isHindi: true);
      expect(resultDiv, contains('बटा'));
      expect(resultDiv, contains('बराबर'));
      expect(resultDiv, isNot(contains('slash')));
    });

    test('Auto-detects Devanagari text as Hindi', () {
      final result = MathSpeechSanitizer.sanitize('जोड़ें: 5 + 3 = ?');
      expect(result, contains('प्लस'));
      expect(result, contains('बराबर क्या?'));
    });
  });
}
