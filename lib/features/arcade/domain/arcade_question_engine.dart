import 'dart:math';
import '../../../data/models/grade_tier.dart';
import '../../../data/models/student_profile.dart';

/// Represents a single rapid-fire mental math question in the Arcade & Duel
class ArcadeQuestion {
  final String expression; // e.g. "7 × 8"
  final String displayPrompt; // e.g. "7 × 8 = ?"
  final int correctAnswer;
  final List<int> options; // Exactly 4 options, shuffled

  const ArcadeQuestion({
    required this.expression,
    required this.displayPrompt,
    required this.correctAnswer,
    required this.options,
  });
}

/// Dynamic generator for rapid mental math questions tailored by grade tier
class ArcadeQuestionEngine {
  final Random _random;

  ArcadeQuestionEngine({Random? random}) : _random = random ?? Random();

  /// Generates a question appropriate for the student's class tier
  ArcadeQuestion generateQuestion(StudentClass studentClass) {
    switch (studentClass.tier) {
      case GradeTier.earlyExplorer:
        return _generateEarlyExplorerQuestion();
      case GradeTier.primaryBuilder:
        return _generatePrimaryBuilderQuestion(studentClass);
      case GradeTier.middleAchiever:
        return _generateMiddleAchieverQuestion();
    }
  }

  /// LKG, UKG, Class 1: Single-digit addition, subtraction, doubles
  ArcadeQuestion _generateEarlyExplorerQuestion() {
    final mode = _random.nextInt(3);
    int a, b, answer;
    String expr, prompt;

    if (mode == 0) {
      // Simple addition (sum <= 18)
      a = _random.nextInt(9) + 1;
      b = _random.nextInt(9) + 1;
      answer = a + b;
      expr = '$a + $b';
      prompt = '$a + $b = ?';
    } else if (mode == 1) {
      // Subtraction (no negative numbers)
      a = _random.nextInt(12) + 4;
      b = _random.nextInt(a - 1) + 1;
      answer = a - b;
      expr = '$a - $b';
      prompt = '$a - $b = ?';
    } else {
      // Doubles or missing number
      a = _random.nextInt(6) + 1;
      answer = a * 2;
      expr = '$a + $a';
      prompt = 'Double of $a = ?';
    }

    final options = _generateDistractors(answer, minVal: 0, maxVal: 25);
    return ArcadeQuestion(
      expression: expr,
      displayPrompt: prompt,
      correctAnswer: answer,
      options: options,
    );
  }

  /// Class 2 to 5: Tables 2-12, Division facts, 2-digit sums
  ArcadeQuestion _generatePrimaryBuilderQuestion(StudentClass studentClass) {
    final mode = _random.nextInt(4);
    int a, b, answer;
    String expr, prompt;

    if (mode == 0 || mode == 1) {
      // Multiplication Tables
      final maxTable = studentClass == StudentClass.class2 ? 6 : (studentClass == StudentClass.class3 ? 9 : 12);
      a = _random.nextInt(maxTable - 1) + 2;
      b = _random.nextInt(10) + 2;
      answer = a * b;
      expr = '$a × $b';
      prompt = '$a × $b = ?';
    } else if (mode == 2) {
      // Division facts (clean integers)
      b = _random.nextInt(8) + 2; // divisor
      answer = _random.nextInt(9) + 2; // quotient
      a = b * answer; // dividend
      expr = '$a ÷ $b';
      prompt = '$a ÷ $b = ?';
    } else {
      // Quick 2-digit mental addition/subtraction
      final isAdd = _random.nextBool();
      if (isAdd) {
        a = (_random.nextInt(5) + 1) * 10 + _random.nextInt(9);
        b = (_random.nextInt(4) + 1) * 10 + _random.nextInt(9);
        answer = a + b;
        expr = '$a + $b';
        prompt = '$a + $b = ?';
      } else {
        a = (_random.nextInt(6) + 4) * 10 + _random.nextInt(9);
        b = (_random.nextInt(3) + 1) * 10 + _random.nextInt(9);
        answer = a - b;
        expr = '$a - $b';
        prompt = '$a - $b = ?';
      }
    }

    final options = _generateDistractors(answer, minVal: 1, maxVal: 200);
    return ArcadeQuestion(
      expression: expr,
      displayPrompt: prompt,
      correctAnswer: answer,
      options: options,
    );
  }

  /// Class 6 to 8: Tables up to 20, Squares, Integers, Percentages
  ArcadeQuestion _generateMiddleAchieverQuestion() {
    final mode = _random.nextInt(4);
    int a, b, answer;
    String expr, prompt;

    if (mode == 0) {
      // Tables 11 to 20
      a = _random.nextInt(9) + 12;
      b = _random.nextInt(8) + 2;
      answer = a * b;
      expr = '$a × $b';
      prompt = '$a × $b = ?';
    } else if (mode == 1) {
      // Squares 2 to 15
      a = _random.nextInt(14) + 2;
      answer = a * a;
      expr = '$a²';
      prompt = '$a² = ?';
    } else if (mode == 2) {
      // Integers (negative numbers)
      a = -(_random.nextInt(15) + 5);
      b = _random.nextInt(25) + 1;
      final isAdd = _random.nextBool();
      if (isAdd) {
        answer = a + b;
        expr = '($a) + $b';
        prompt = '($a) + $b = ?';
      } else {
        answer = a - b;
        expr = '($a) - $b';
        prompt = '($a) - $b = ?';
      }
    } else {
      // Rapid percentages (10%, 20%, 50%, 25%)
      final percents = [10, 20, 25, 50];
      final p = percents[_random.nextInt(percents.length)];
      if (p == 10) {
        b = (_random.nextInt(40) + 5) * 10;
        answer = (b * 10) ~/ 100;
      } else if (p == 50) {
        b = (_random.nextInt(45) + 5) * 2;
        answer = b ~/ 2;
      } else if (p == 25) {
        b = (_random.nextInt(25) + 2) * 4;
        answer = b ~/ 4;
      } else {
        b = (_random.nextInt(20) + 5) * 10;
        answer = (b * 20) ~/ 100;
      }
      expr = '$p% of $b';
      prompt = '$p% of $b = ?';
    }

    final options = _generateDistractors(answer, minVal: -50, maxVal: 400);
    return ArcadeQuestion(
      expression: expr,
      displayPrompt: prompt,
      correctAnswer: answer,
      options: options,
    );
  }

  /// Generates 3 intelligent distractors and shuffles them with the correct answer
  List<int> _generateDistractors(int correct, {required int minVal, required int maxVal}) {
    final Set<int> distractors = {correct};

    // Candidate offsets for smart distractors
    final candidateDeltas = [-10, 10, -1, 1, -2, 2, -5, 5, -3, 3, -4, 4];
    candidateDeltas.shuffle(_random);

    for (final delta in candidateDeltas) {
      final cand = correct + delta;
      if (cand != correct && cand >= minVal && cand <= maxVal) {
        distractors.add(cand);
        if (distractors.length == 4) break;
      }
    }

    // Fallback if needed
    int fallbackOffset = 1;
    while (distractors.length < 4) {
      final cand = correct + (distractors.length % 2 == 0 ? fallbackOffset : -fallbackOffset);
      if (cand != correct) {
        distractors.add(cand);
      }
      fallbackOffset++;
    }

    final list = distractors.toList();
    list.shuffle(_random);
    return list;
  }
}
