import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_attempt_model.dart';
import 'package:curio_math/data/services/concept_solution_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Persistent Stars & LocalStorageService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Total stars is aggregate of earned question stars and persists across re-init', () async {
      final storage = LocalStorageService.instance;
      await storage.init();

      expect(storage.totalStars, equals(0));

      // Attempt 1: earns 3 stars
      final attempt1 = StudentQuestionAttempt(
        activityId: 'q1',
        chapterId: 'ch1',
        selectedOptionIndex: 0,
        selectedOptionText: 'Option A',
        isCorrect: true,
        starsEarned: 3,
        timestamp: DateTime.now(),
      );
      await storage.saveQuestionAttempt(attempt1);

      expect(storage.totalStars, equals(3));
      expect(storage.getStarsForActivity('q1'), equals(3));

      // Attempt 2: earns 2 stars
      final attempt2 = StudentQuestionAttempt(
        activityId: 'q2',
        chapterId: 'ch1',
        selectedOptionIndex: 1,
        selectedOptionText: 'Option B',
        isCorrect: true,
        starsEarned: 2,
        timestamp: DateTime.now(),
      );
      await storage.saveQuestionAttempt(attempt2);

      expect(storage.totalStars, equals(5));
      expect(storage.getStarsForActivity('q2'), equals(2));

      // Retry Attempt 2 with better score (3 stars)
      final attempt2Retry = StudentQuestionAttempt(
        activityId: 'q2',
        chapterId: 'ch1',
        selectedOptionIndex: 1,
        selectedOptionText: 'Option B',
        isCorrect: true,
        starsEarned: 3,
        timestamp: DateTime.now(),
      );
      await storage.saveQuestionAttempt(attempt2Retry);

      expect(storage.totalStars, equals(6));
      expect(storage.getStarsForActivity('q2'), equals(3));

      // Re-initialize storage (simulating app restart)
      await storage.init();
      expect(storage.totalStars, equals(6));
    });
  });

  group('Dynamic Question-Specific Hints Tests', () {
    test('Generates distinct, question-specific hints without generic chapter rule fallback', () {
      final chapter = Chapter(
        chapterId: 'ch_bricks',
        chapterNumber: 1,
        title: 'Building with Bricks',
        grade: 'Class 4',
        icon: '🧱',
        rules: ['A brick has 6 rectangular faces, 12 edges, and 8 corners.'],
      );

      // Question A: Addition calculation
      final actAdd = Activity(
        activityId: 'act_add',
        topicId: 'topic_math',
        subjectId: 'math',
        targetGrade: 'Class 4',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        difficultyLevel: 1,
        pointsReward: 30,
        promptData: const PromptData(text: 'What is 45 + 32?'),
        interactionPayload: {'options': ['77', '67', '87', '75']},
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: '77'),
      );
      final detailsAdd = ConceptSolutionHelper.instance.getDetails(actAdd, chapter: chapter);
      expect(detailsAdd.hint, contains('45 + 32'));
      expect(detailsAdd.hint, contains('Break it down into tens and ones'));
      expect(detailsAdd.hint.contains('Key Rule to Apply: A brick has 6'), isFalse);

      // Question B: Brick shapes
      final actBrick = Activity(
        activityId: 'act_brick',
        topicId: 'topic_math',
        subjectId: 'math',
        targetGrade: 'Class 4',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        difficultyLevel: 1,
        pointsReward: 30,
        promptData: const PromptData(text: 'How many faces does a brick have?'),
        interactionPayload: {'options': ['6', '8', '12', '4']},
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: '6'),
      );
      final detailsBrick = ConceptSolutionHelper.instance.getDetails(actBrick, chapter: chapter);
      expect(detailsBrick.hint, contains('6 rectangular flat faces'));

      // Question C: English Noun identification
      final actNoun = Activity(
        activityId: 'act_noun',
        topicId: 'topic_eng',
        subjectId: 'english',
        targetGrade: 'Class 4',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        difficultyLevel: 1,
        pointsReward: 30,
        promptData: const PromptData(text: 'Identify the noun in: The tiger runs fast.'),
        interactionPayload: {'options': ['tiger', 'runs', 'fast', 'the']},
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: 'tiger'),
      );
      final detailsNoun = ConceptSolutionHelper.instance.getDetails(actNoun, chapter: chapter);
      expect(detailsNoun.hint, contains('A noun names a person, place, animal, or thing'));
      expect(detailsNoun.hint.contains('Key Rule to Apply: A brick has 6'), isFalse);
    });
  });
}
