/// Records a student's attempt on an activity/question
class StudentQuestionAttempt {
  final String activityId;
  final String chapterId;
  final int selectedOptionIndex;
  final String selectedOptionText;
  final bool isCorrect;
  final int starsEarned;
  final DateTime timestamp;

  const StudentQuestionAttempt({
    required this.activityId,
    required this.chapterId,
    required this.selectedOptionIndex,
    required this.selectedOptionText,
    required this.isCorrect,
    required this.starsEarned,
    required this.timestamp,
  });

  factory StudentQuestionAttempt.fromJson(Map<String, dynamic> json) {
    return StudentQuestionAttempt(
      activityId: json['activityId'] as String? ?? '',
      chapterId: json['chapterId'] as String? ?? '',
      selectedOptionIndex: json['selectedOptionIndex'] as int? ?? 0,
      selectedOptionText: json['selectedOptionText'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      starsEarned: json['starsEarned'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'chapterId': chapterId,
        'selectedOptionIndex': selectedOptionIndex,
        'selectedOptionText': selectedOptionText,
        'isCorrect': isCorrect,
        'starsEarned': starsEarned,
        'timestamp': timestamp.toIso8601String(),
      };
}
