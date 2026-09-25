import 'grade_tier.dart';

/// Supported types of interactive activity engines
enum ActivityType {
  bubblePop('BUBBLE_POP'),
  dragDrop('DRAG_DROP'),
  gridCalc('GRID_CALC'),
  mcq('MCQ'),
  scratchpadPrompt('SCRATCHPAD_PROMPT'),
  cardMatch('CARD_MATCH');

  final String value;
  const ActivityType(this.value);

  static ActivityType fromJson(dynamic json) {
    final str = json?.toString().toUpperCase() ?? 'BUBBLE_POP';
    return ActivityType.values.firstWhere(
      (t) => t.value == str || t.name.toUpperCase() == str,
      orElse: () => ActivityType.bubblePop,
    );
  }

  String toJson() => value;
}

/// Prompt metadata delivered to the learner (Visual, Textual, Auditory)
class PromptData {
  final String text;
  final String? audioAsset;
  final String? visualAsset;
  final String? ttsFallback;

  const PromptData({
    required this.text,
    this.audioAsset,
    this.visualAsset,
    this.ttsFallback,
  });

  factory PromptData.fromJson(Map<String, dynamic> json) {
    return PromptData(
      text: json['text'] as String? ?? '',
      audioAsset: json['audioAsset'] as String?,
      visualAsset: json['visualAsset'] as String?,
      ttsFallback: json['ttsFallback'] as String? ?? json['text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'audioAsset': audioAsset,
    'visualAsset': visualAsset,
    'ttsFallback': ttsFallback,
  };
}

/// A step in the pedagogical scaffolding hint tree
class StepHint {
  final int stepIndex;
  final String hintText;
  final String? audioAsset;
  final String? visualKey;

  const StepHint({
    required this.stepIndex,
    required this.hintText,
    this.audioAsset,
    this.visualKey,
  });

  factory StepHint.fromJson(Map<String, dynamic> json) {
    return StepHint(
      stepIndex: json['stepIndex'] as int? ?? 1,
      hintText: json['hintText'] as String? ?? '',
      audioAsset: json['audioAsset'] as String?,
      visualKey: json['visualKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'stepIndex': stepIndex,
    'hintText': hintText,
    'audioAsset': audioAsset,
    'visualKey': visualKey,
  };
}

/// Validation rules defining acceptable inputs, formats, and pedagogical feedback
class ValidationRule {
  /// 'exact', 'set_match', 'numeric_range', 'ordered_sequence'
  final String format;
  final dynamic expectedAnswer;
  final double tolerance;
  final List<StepHint> hintTree;

  const ValidationRule({
    required this.format,
    required this.expectedAnswer,
    this.tolerance = 0.0,
    this.hintTree = const [],
  });

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    final hintsList = json['hintTree'] as List<dynamic>? ?? [];
    return ValidationRule(
      format: json['format'] as String? ?? 'exact',
      expectedAnswer: json['expectedAnswer'],
      tolerance: (json['tolerance'] as num?)?.toDouble() ?? 0.0,
      hintTree: hintsList
          .map((item) => StepHint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'format': format,
    'expectedAnswer': expectedAnswer,
    'tolerance': tolerance,
    'hintTree': hintTree.map((h) => h.toJson()).toList(),
  };
}

/// Universal Activity Model: Core currency of Curio's adaptive learning engine
class Activity {
  final String activityId;
  final String topicId;
  final String subjectId;
  final String targetGrade; // e.g. "LKG", "UKG", "Class 4", "Class 7"
  final GradeTier gradeTier;
  final ActivityType activityType;
  final PromptData promptData;
  final Map<String, dynamic> interactionPayload;
  final ValidationRule validationRule;
  final String? chapterId;
  final String? chapterName;
  final int pointsReward;
  final int difficultyLevel; // 1 (Easy) to 5 (Mastery)

  const Activity({
    required this.activityId,
    required this.topicId,
    required this.subjectId,
    required this.targetGrade,
    required this.gradeTier,
    required this.activityType,
    required this.promptData,
    required this.interactionPayload,
    required this.validationRule,
    this.chapterId,
    this.chapterName,
    this.pointsReward = 10,
    this.difficultyLevel = 1,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? 'math',
      targetGrade: json['targetGrade'] as String? ?? 'Class 1',
      gradeTier: GradeTier.fromJson(json['gradeTier']),
      activityType: ActivityType.fromJson(json['activityType']),
      promptData: PromptData.fromJson(
        json['promptData'] as Map<String, dynamic>? ?? {},
      ),
      interactionPayload:
          Map<String, dynamic>.from(json['interactionPayload'] as Map? ?? {}),
      validationRule: ValidationRule.fromJson(
        json['validationRule'] as Map<String, dynamic>? ?? {},
      ),
      chapterId: json['chapterId'] as String?,
      chapterName: json['chapterName'] as String?,
      pointsReward: json['pointsReward'] as int? ?? 10,
      difficultyLevel: json['difficultyLevel'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'topicId': topicId,
    'subjectId': subjectId,
    'targetGrade': targetGrade,
    'gradeTier': gradeTier.toJson(),
    'activityType': activityType.toJson(),
    'promptData': promptData.toJson(),
    'interactionPayload': interactionPayload,
    'validationRule': validationRule.toJson(),
    'chapterId': chapterId,
    'chapterName': chapterName,
    'pointsReward': pointsReward,
    'difficultyLevel': difficultyLevel,
  };
}
