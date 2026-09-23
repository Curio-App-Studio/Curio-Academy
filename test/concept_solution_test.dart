import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/services/concept_solution_helper.dart';
import 'package:curio_math/data/services/procedural_question_generator.dart';

void main() {
  group('ConceptSolutionHelper Universal Scaffolding Tests', () {
    test('Synthesizes complete solution details for Coordinate Geometry questions', () {
      final act = Activity(
        activityId: 'coord_1',
        topicId: 'topic_coord',
        subjectId: 'math',
        targetGrade: 'Class 8',
        gradeTier: GradeTier.middleAchiever,
        activityType: ActivityType.mcq,
        difficultyLevel: 2,
        pointsReward: 30,
        promptData: const PromptData(
          text: 'In which quadrant does the point (-3, 5) lie on the Cartesian plane?',
        ),
        interactionPayload: {
          'visualIcon': '📈',
          'options': ['Quadrant I', 'Quadrant II', 'Quadrant III', 'Quadrant IV'],
          'explanation': 'In (-3, 5), x is negative and y is positive, which belongs to Quadrant II.',
        },
        validationRule: const ValidationRule(
          format: 'exact',
          expectedAnswer: 'Quadrant II',
        ),
      );

      final details = ConceptSolutionHelper.instance.getDetails(act);
      expect(details.correctAnswer, equals('Quadrant II'));
      expect(details.hint, contains('Quadrant'));
      expect(details.hint, contains('Quadrant II: (−, +)'));
      expect(details.steps.isNotEmpty, isTrue);
      expect(details.conceptTitle, contains('Coordinate'));
      expect(details.formulasAndRules.isNotEmpty, isTrue);
      expect(details.proTip, contains('Pitfall'));
      expect(details.speechNarration, contains('Quadrant II'));
    });

    test('Synthesizes complete solution details for Rational Numbers / Reciprocals', () {
      final act = Activity(
        activityId: 'rational_1',
        topicId: 'topic_rational',
        subjectId: 'math',
        targetGrade: 'Class 8',
        gradeTier: GradeTier.middleAchiever,
        activityType: ActivityType.mcq,
        difficultyLevel: 2,
        pointsReward: 30,
        promptData: const PromptData(
          text: 'What is the reciprocal (multiplicative inverse) of -5/7?',
        ),
        interactionPayload: {
          'visualIcon': '🔢',
          'options': ['-7/5', '7/5', '5/7', '1'],
          'explanation': 'The reciprocal of a/b is b/a, keeping the negative sign.',
        },
        validationRule: const ValidationRule(
          format: 'exact',
          expectedAnswer: '-7/5',
        ),
      );

      final details = ConceptSolutionHelper.instance.getDetails(act);
      expect(details.correctAnswer, equals('-7/5'));
      expect(details.hint, contains('reciprocal'));
      expect(details.conceptTitle, contains('Multiplicative Inverse'));
      expect(details.formulasAndRules.any((f) => f.contains('b/a')), isTrue);
      expect(details.proTip, contains('reciprocal'));
    });

    test('Synthesizes complete solution details for Linear Equations with step working', () {
      final act = Activity(
        activityId: 'eq_1',
        topicId: 'topic_eq',
        subjectId: 'math',
        targetGrade: 'Class 7',
        gradeTier: GradeTier.middleAchiever,
        activityType: ActivityType.gridCalc,
        difficultyLevel: 2,
        pointsReward: 30,
        promptData: const PromptData(
          text: 'Solve for x: 3x + 4 = 19',
        ),
        interactionPayload: {
          'visualIcon': '⚖️',
          'finalResult': 'x = 5',
          'stepsRequired': [
            {
              'step': 1,
              'action': 'subtract_both_sides',
              'operand': 4,
              'resultPrompt': '3x = 15',
            },
            {
              'step': 2,
              'action': 'divide_both_sides',
              'operand': 3,
              'resultPrompt': 'x = 5',
            },
          ],
        },
        validationRule: const ValidationRule(
          format: 'exact',
          expectedAnswer: 5,
        ),
      );

      final details = ConceptSolutionHelper.instance.getDetails(act);
      expect(details.correctAnswer, equals('5'));
      expect(details.steps.length, greaterThanOrEqualTo(2));
      expect(details.steps.first, contains('subtract_both_sides'));
      expect(details.steps.any((s) => s.contains('Final Answer')), isTrue);
      expect(details.conceptTitle, contains('Linear Equations'));
    });

    test('Integrates authentic chapter formulas and rules when provided', () {
      final chapter = Chapter(
        chapterId: 'ch_perimeter',
        chapterNumber: 4,
        title: 'Perimeter and Area',
        grade: 'Class 4',
        icon: '📐',
        rules: [
          'Perimeter of Rectangle = 2 × (Length + Breadth)',
          'Area of Rectangle = Length × Breadth',
        ],
        keyConcepts: ['Boundary Measurement', 'Square Grid Counting'],
      );

      final act = Activity(
        activityId: 'peri_1',
        topicId: 'topic_peri',
        subjectId: 'math',
        targetGrade: 'Class 4',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        difficultyLevel: 1,
        pointsReward: 20,
        promptData: const PromptData(
          text: 'Find the perimeter of a rectangle with length 6 cm and breadth 4 cm.',
        ),
        interactionPayload: {
          'visualIcon': '📐',
          'options': ['20 cm', '24 cm', '10 cm', '12 cm'],
        },
        validationRule: const ValidationRule(
          format: 'exact',
          expectedAnswer: '20 cm',
        ),
      );

      final details = ConceptSolutionHelper.instance.getDetails(act, chapter: chapter);
      expect(details.correctAnswer, equals('20 cm'));
      expect(details.formulasAndRules, contains('Perimeter of Rectangle = 2 × (Length + Breadth)'));
      expect(details.steps.any((s) => s.contains('Perimeter') || s.contains('formula')), isTrue);
    });

    test('Zero class name in prompts and high variety for Large Numbers & Place Value', () {
      final ch = Chapter(
        chapterId: 'icse_class4_ch01',
        chapterNumber: 1,
        title: 'Large Numbers & Place Value',
        grade: 'Class 4',
        icon: '🔢',
        rules: [
          'Indian System periods: Ones (H, T, O), Thousands (T-Th, Th), Lakhs (T-L, L). Commas: 3, 2, 2.',
          'International System periods: Ones (H, T, O), Thousands (H-Th, T-Th, Th), Millions (H-M, T-M, M). Commas: 3, 3, 3.',
        ],
        keyConcepts: ['Indian Place Value', 'International Place Value', 'Expanded Form'],
      );

      final acts = ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        StudentClass.class4,
        count: 5,
      );

      expect(acts.length, equals(5));
      for (final a in acts) {
        // Assert no Class name in prompt text
        expect(a.promptData.text.contains('(Class'), isFalse);
        expect(a.promptData.text.contains('Class 4'), isFalse);
        expect(a.promptData.text.contains('Class 8'), isFalse);
        expect(a.promptData.text.contains('mathematically TRUE'), isFalse);
      }

      // Assert diversity: all prompts are unique
      final promptSet = acts.map((a) => a.promptData.text).toSet();
      expect(promptSet.length, equals(5));
    });

    test('Zero class name in prompts and high variety for Roman Numerals', () {
      final ch = Chapter(
        chapterId: 'icse_class4_ch02',
        chapterNumber: 2,
        title: 'Roman Numerals',
        grade: 'Class 4',
        icon: '🏛️',
        rules: [
          'I, X, C can be repeated up to 3 times. V and L are NEVER repeated.',
        ],
        keyConcepts: ['Symbols: I=1, V=5, X=10, L=50, C=100', 'Writing 2-Digit Numbers in Roman Numerals'],
      );

      final acts = ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        StudentClass.class4,
        count: 5,
      );

      expect(acts.length, equals(5));
      for (final a in acts) {
        expect(a.promptData.text.contains('(Class'), isFalse);
        expect(a.promptData.text.contains('Class 4'), isFalse);
        expect(a.promptData.text.contains('mathematically TRUE'), isFalse);
      }

      final promptSet = acts.map((a) => a.promptData.text).toSet();
      expect(promptSet.length, equals(5));
    });
  });
}
