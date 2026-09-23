import 'activity_model.dart';

/// Represents an authentic textbook chapter aligned with CBSE/ICSE syllabus
/// including rich concept learning data (formulas, rules, worked examples, key topics).
class Chapter {
  final String chapterId;
  final int chapterNumber;
  final String title;
  final String grade;
  final String board; // 'cbse', 'icse', or 'all'
  final String icon;
  final String description;
  final List<String> keyConcepts;
  final List<String> rules;
  final String? exampleQuestion;
  final String? exampleExplanation;
  final String? exampleAnswer;
  final String? funFact;
  final String? mascotAdvice;
  final String subjectId;
  final List<String> activityIds;
  List<Activity> activities;

  Chapter({
    required this.chapterId,
    required this.chapterNumber,
    required this.title,
    required this.grade,
    this.board = 'cbse',
    this.subjectId = 'math',
    required this.icon,
    this.description = '',
    this.keyConcepts = const [],
    this.rules = const [],
    this.exampleQuestion,
    this.exampleExplanation,
    this.exampleAnswer,
    this.funFact,
    this.mascotAdvice,
    this.activityIds = const [],
    this.activities = const [],
  });

  String get displayName => 'Ch $chapterNumber: $title';

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] as String? ?? '',
      chapterNumber: json['chapterNumber'] as int? ?? 1,
      title: json['title'] as String? ?? 'Untitled Chapter',
      grade: json['grade'] as String? ?? 'Class 1',
      board: (json['board'] as String?)?.toLowerCase() ?? 'cbse',
      subjectId: (json['subjectId'] as String?)?.toLowerCase() ?? 'math',
      icon: json['icon'] as String? ?? '📖',
      description: json['description'] as String? ?? '',
      keyConcepts: (json['keyConcepts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      exampleQuestion: json['exampleQuestion'] as String?,
      exampleExplanation: json['exampleExplanation'] as String?,
      exampleAnswer: json['exampleAnswer'] as String?,
      funFact: json['funFact'] as String?,
      mascotAdvice: json['mascotAdvice'] as String?,
      activityIds: (json['activityIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      activities: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'chapterNumber': chapterNumber,
        'title': title,
        'grade': grade,
        'board': board,
        'subjectId': subjectId,
        'icon': icon,
        'description': description,
        'keyConcepts': keyConcepts,
        'rules': rules,
        if (exampleQuestion != null) 'exampleQuestion': exampleQuestion,
        if (exampleExplanation != null) 'exampleExplanation': exampleExplanation,
        if (exampleAnswer != null) 'exampleAnswer': exampleAnswer,
        if (funFact != null) 'funFact': funFact,
        if (mascotAdvice != null) 'mascotAdvice': mascotAdvice,
        'activityIds': activityIds,
      };

  Chapter copyWith({
    String? chapterId,
    int? chapterNumber,
    String? title,
    String? grade,
    String? board,
    String? subjectId,
    String? icon,
    String? description,
    List<String>? keyConcepts,
    List<String>? rules,
    String? exampleQuestion,
    String? exampleExplanation,
    String? exampleAnswer,
    String? funFact,
    String? mascotAdvice,
    List<String>? activityIds,
    List<Activity>? activities,
  }) {
    return Chapter(
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      grade: grade ?? this.grade,
      board: board ?? this.board,
      subjectId: subjectId ?? this.subjectId,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      keyConcepts: keyConcepts ?? this.keyConcepts,
      rules: rules ?? this.rules,
      exampleQuestion: exampleQuestion ?? this.exampleQuestion,
      exampleExplanation: exampleExplanation ?? this.exampleExplanation,
      exampleAnswer: exampleAnswer ?? this.exampleAnswer,
      funFact: funFact ?? this.funFact,
      mascotAdvice: mascotAdvice ?? this.mascotAdvice,
      activityIds: activityIds ?? this.activityIds,
      activities: activities ?? this.activities,
    );
  }
}
