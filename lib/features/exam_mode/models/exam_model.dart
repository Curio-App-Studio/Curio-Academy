import '../../../data/models/activity_model.dart';

/// Single question presented in a timed exam
class ExamQuestion {
  final int questionNumber;
  final Activity activity;
  final String prompt;
  final String ttsFallback;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? visualIcon;
  int? selectedOptionIndex;
  String? selectedOptionText;

  ExamQuestion({
    required this.questionNumber,
    required this.activity,
    required this.prompt,
    required this.ttsFallback,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.visualIcon,
    this.selectedOptionIndex,
    this.selectedOptionText,
  });

  bool get isAttempted => selectedOptionIndex != null;

  bool get isCorrect {
    if (!isAttempted || selectedOptionText == null) return false;
    final user = selectedOptionText!.trim().toLowerCase();
    final expected = correctAnswer.trim().toLowerCase();
    return user == expected;
  }
}

/// Comprehensive outcome of a completed timed exam
class ExamResult {
  final String examTitle;
  final String subjectId;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int unattemptedCount;
  final int timeSpentSeconds;
  final int totalTimeSeconds;
  final List<ExamQuestion> questions;

  const ExamResult({
    required this.examTitle,
    required this.subjectId,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.unattemptedCount,
    required this.timeSpentSeconds,
    required this.totalTimeSeconds,
    required this.questions,
  });

  double get percentage =>
      totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;

  int get starsEarned {
    if (percentage >= 80) return 3;
    if (percentage >= 60) return 2;
    if (percentage >= 35) return 1;
    return 0;
  }

  String get performanceGrade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    return 'D';
  }
}
