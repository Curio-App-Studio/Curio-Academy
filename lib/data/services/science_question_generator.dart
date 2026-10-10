import 'dart:math';
import '../models/activity_model.dart';
import '../models/chapter_model.dart';
import '../models/grade_tier.dart';
import '../models/student_profile.dart';

/// Algorithmic question generator engine for Science & EVS (Environmental Studies).
/// Produces authentic, curriculum-aligned activities across LKG to Class 8:
/// - Kindergarten EVS (LKG & UKG): Living Things, Animals, Plants, Senses Bubble Pop & Card Match.
/// - Primary & Middle (Class 1 to 8): Biology, Physics, Chemistry, Nature, Ecosystems (ZERO math distractors).
class ScienceQuestionGenerator {
  static final ScienceQuestionGenerator instance = ScienceQuestionGenerator._();
  ScienceQuestionGenerator._();

  final Random _rng = Random();

  /// Main dispatch method generating activities for any Science or EVS chapter
  List<Activity> generateActivitiesForChapter(
    Chapter chapter,
    StudentClass studentClass, {
    int count = 4,
    Set<String> existingPromptTexts = const {},
  }) {
    final activities = <Activity>[];
    final seenPrompts = <String>{...existingPromptTexts.map((e) => e.trim().toLowerCase())};
    int attempts = 0;
    int idx = 1;

    while (activities.length < count && attempts < 30) {
      attempts++;
      final act = generateSingleQuestion(chapter, studentClass, questionIndex: idx);
      final promptKey = act.promptData.text.trim().toLowerCase();
      if (!seenPrompts.contains(promptKey)) {
        seenPrompts.add(promptKey);
        activities.add(act);
      }
      idx++;
    }

    while (activities.length < count) {
      final fallback = generateSingleQuestion(chapter, studentClass, questionIndex: activities.length + 1);
      activities.add(fallback);
    }
    return activities;
  }

  /// Generates a single dynamic Science/EVS question tailored to the chapter and grade
  Activity generateSingleQuestion(
    Chapter chapter,
    StudentClass studentClass, {
    int questionIndex = 1,
  }) {
    // 1. Kindergarten Tier (LKG & UKG EVS): Zero MCQs, exclusively Bubble Pop & Card Match games
    if (studentClass.isKindergarten) {
      if (questionIndex % 2 == 0) {
        return _generateKindergartenEvsCardMatch(chapter, studentClass, questionIndex);
      } else {
        return _generateKindergartenEvsBubblePop(chapter, studentClass, questionIndex);
      }
    }

    // 2. Primary & Middle School Tier (Class 1 to 8): Authentic Science / EVS question synthesis
    return _generateCurriculumScienceMCQ(chapter, studentClass, questionIndex);
  }

  // ---------------------------------------------------------------------------
  // KINDERGARTEN EVS GAMES (LKG & UKG)
  // ---------------------------------------------------------------------------

  Activity _generateKindergartenEvsCardMatch(Chapter chapter, StudentClass studentClass, int idx) {
    final pools = [
      // Animals and their Babies
      [
        {'key': 'cow', 'itemA': 'Cow 🐮', 'emojiA': '🐮', 'itemB': 'Calf 🐄', 'emojiB': '🐄'},
        {'key': 'dog', 'itemA': 'Dog 🐶', 'emojiA': '🐶', 'itemB': 'Puppy 🐕', 'emojiB': '🐕'},
        {'key': 'cat', 'itemA': 'Cat 🐱', 'emojiA': '🐱', 'itemB': 'Kitten 🐈', 'emojiB': '🐈'},
      ],
      // Animals and their Homes
      [
        {'key': 'lion', 'itemA': 'Lion 🦁', 'emojiA': '🦁', 'itemB': 'Den 🏔️', 'emojiB': '🏔️'},
        {'key': 'bird', 'itemA': 'Bird 🐦', 'emojiA': '🐦', 'itemB': 'Nest 🪺', 'emojiB': '🪺'},
        {'key': 'bee', 'itemA': 'Bee 🐝', 'emojiA': '🐝', 'itemB': 'Beehive 🍯', 'emojiB': '🍯'},
      ],
      // Sense Organs and Functions
      [
        {'key': 'eyes', 'itemA': 'Eyes 👁️', 'emojiA': '👁️', 'itemB': 'Seeing 👓', 'emojiB': '👓'},
        {'key': 'ears', 'itemA': 'Ears 👂', 'emojiA': '👂', 'itemB': 'Hearing 🎵', 'emojiB': '🎵'},
        {'key': 'nose', 'itemA': 'Nose 👃', 'emojiA': '👃', 'itemB': 'Smelling 🌸', 'emojiB': '🌸'},
      ],
      // Plants & Nature
      [
        {'key': 'flower', 'itemA': 'Flower 🌸', 'emojiA': '🌸', 'itemB': 'Rose Plant 🌹', 'emojiB': '🌹'},
        {'key': 'fruit', 'itemA': 'Fruit 🍎', 'emojiA': '🍎', 'itemB': 'Apple Tree 🌳', 'emojiB': '🌳'},
        {'key': 'leaf', 'itemA': 'Leaf 🍃', 'emojiA': '🍃', 'itemB': 'Green Plant 🌿', 'emojiB': '🌿'},
      ],
      // Day & Night Sky
      [
        {'key': 'sun', 'itemA': 'Sun ☀️', 'emojiA': '☀️', 'itemB': 'Daytime Sky 🌤️', 'emojiB': '🌤️'},
        {'key': 'moon', 'itemA': 'Moon 🌙', 'emojiA': '🌙', 'itemB': 'Night Stars 🌟', 'emojiB': '🌟'},
        {'key': 'rain', 'itemA': 'Rain 🌧️', 'emojiA': '🌧️', 'itemB': 'Rainbow 🌈', 'emojiB': '🌈'},
      ],
    ];

    final pairs = pools[(idx - 1) % pools.length];
    final id = 'evs_k_card_${DateTime.now().microsecondsSinceEpoch}_$idx';
    const prompt = 'Match the nature and animal pairs! 🌿';

    return Activity(
      activityId: id,
      topicId: 'evs_nature_pairs',
      subjectId: chapter.subjectId.isNotEmpty ? chapter.subjectId : 'evs',
      targetGrade: studentClass.label,
      gradeTier: GradeTier.earlyExplorer,
      activityType: ActivityType.cardMatch,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: const PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': '🌿',
        'pairs': pairs,
        'gameType': 'cardMatch',
        'explanation': 'Super job! You matched all the nature pairs correctly.',
      },
      validationRule: const ValidationRule(format: 'pair_matching', expectedAnswer: 'all_pairs'),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }

  Activity _generateKindergartenEvsBubblePop(Chapter chapter, StudentClass studentClass, int idx) {
    final colors = ['#10B981', '#34D399', '#059669', '#3B82F6', '#F59E0B', '#EC4899'];

    final gamePools = [
      // 1. Living Things
      {
        'prompt': 'Pop all LIVING things! 🌿',
        'target': 'living',
        'matches': ['Tree 🌳', 'Puppy 🐶', 'Butterfly 🦋'],
        'distractors': ['Toy Car 🚗', 'Stone 🪨', 'Chair 🪑'],
      },
      // 2. Animals
      {
        'prompt': 'Pop all ANIMALS! 🐾',
        'target': 'animal',
        'matches': ['Lion 🦁', 'Elephant 🐘', 'Cat 🐱'],
        'distractors': ['Book 📖', 'Pencil ✏️', 'Ball ⚽'],
      },
      // 3. Healthy Fruits
      {
        'prompt': 'Pop all HEALTHY FRUITS! 🍎',
        'target': 'fruit',
        'matches': ['Apple 🍎', 'Banana 🍌', 'Mango 🥭'],
        'distractors': ['Plate 🍽️', 'Clock ⏰', 'Bag 🎒'],
      },
      // 4. Sense Organs
      {
        'prompt': 'Pop all SENSE ORGANS of our body! 👁️',
        'target': 'sense',
        'matches': ['Eyes 👁️', 'Ears 👂', 'Nose 👃'],
        'distractors': ['Shoe 👟', 'Cup ☕', 'Key 🔑'],
      },
      // 5. Day Sky Objects
      {
        'prompt': 'Pop all DAYTIME sky objects! ☀️',
        'target': 'day',
        'matches': ['Sun ☀️', 'White Cloud ☁️', 'Rainbow 🌈'],
        'distractors': ['Moon 🌙', 'Night Star 🌟', 'Bed 🛌'],
      },
    ];

    final selected = gamePools[(idx - 1) % gamePools.length];
    final prompt = selected['prompt'] as String;
    final target = selected['target'] as String;
    final matches = selected['matches'] as List<String>;
    final distractors = selected['distractors'] as List<String>;

    final bubbles = <Map<String, dynamic>>[];
    int bId = 1;

    for (int i = 0; i < 3; i++) {
      bubbles.add({
        'id': 'b_${bId++}',
        'label': matches[i],
        'value': target,
        'displayType': 'label',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    final shuffledDistractors = List<String>.from(distractors)..shuffle(_rng);
    for (int i = 0; i < 3 && i < shuffledDistractors.length; i++) {
      bubbles.add({
        'id': 'b_${bId++}',
        'label': shuffledDistractors[i],
        'value': 'other',
        'displayType': 'label',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    bubbles.shuffle(_rng);

    final id = 'evs_k_bubble_${DateTime.now().microsecondsSinceEpoch}_$idx';
    final subject = chapter.subjectId.isNotEmpty ? chapter.subjectId : 'evs';

    return Activity(
      activityId: id,
      topicId: 'evs_nature_bubble',
      subjectId: subject,
      targetGrade: studentClass.label,
      gradeTier: GradeTier.earlyExplorer,
      activityType: ActivityType.bubblePop,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': '🫧',
        'targetValue': target,
        'bubbles': bubbles,
        'gameType': 'bubblePop',
        'explanation': 'Awesome! You popped all the correct nature items.',
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: target),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }

  // ---------------------------------------------------------------------------
  // PRIMARY & MIDDLE SCIENCE / EVS QUESTIONS (Class 1 to 8)
  // ---------------------------------------------------------------------------

  Activity _generateCurriculumScienceMCQ(Chapter chapter, StudentClass studentClass, int idx) {
    String prompt = '';
    String answer = '';
    List<String> options = [];
    String explanation = '';

    final hasValidExample = chapter.exampleQuestion != null &&
        chapter.exampleQuestion!.trim().length > 10 &&
        chapter.exampleAnswer != null &&
        chapter.exampleAnswer!.isNotEmpty;

    final subject = chapter.subjectId.isNotEmpty ? chapter.subjectId : 'science';
    final isEvs = subject == 'evs';

    // Strategy 1: Chapter's worked example
    if (hasValidExample && (idx % 3 == 1 || chapter.rules.isEmpty)) {
      prompt = chapter.exampleQuestion!;
      answer = chapter.exampleAnswer!;
      explanation = chapter.exampleExplanation ?? 'This is directly explained in "${chapter.title}".';

      final distractors = <String>[];
      for (final kc in chapter.keyConcepts) {
        if (kc != answer && !distractors.contains(kc) && distractors.length < 3) {
          distractors.add(kc);
        }
      }

      final defaultScienceDistractors = isEvs
          ? ['Pollution Increase', 'Artificial Habitat', 'Seasonal Migration', 'Non-renewable Resource']
          : ['Chemical Neutralization', 'Gravitational Friction', 'Cellular Decomposition', 'Electromagnetic Resistance'];

      for (final d in defaultScienceDistractors) {
        if (d != answer && !distractors.contains(d) && distractors.length < 3) {
          distractors.add(d);
        }
      }

      options = [answer, ...distractors.take(3)]..shuffle(_rng);
    }
    // Strategy 2: Authentic scientific rule application
    else if (chapter.rules.isNotEmpty) {
      final ruleIdx = (idx ~/ 2) % chapter.rules.length;
      final trueRule = chapter.rules[ruleIdx];

      prompt = 'Which scientific fact is TRUE for "${chapter.title}"?';
      answer = trueRule;

      final distractors = <String>[];
      for (int i = 0; i < chapter.rules.length; i++) {
        if (i != ruleIdx && distractors.length < 2) {
          final other = chapter.rules[i];
          if (other != trueRule && !distractors.contains(other)) {
            distractors.add(other);
          }
        }
      }

      final genericDistractors = [
        'This process occurs without any energy transformation',
        'It is an irreversible change violating natural laws',
        'Living organisms can survive completely without this factor',
      ];

      for (final gd in genericDistractors) {
        if (distractors.length < 3 && !distractors.contains(gd)) {
          distractors.add(gd);
        }
      }

      options = [answer, ...distractors.take(3)]..shuffle(_rng);
      explanation = 'According to the curriculum: $trueRule.';
    }
    // Strategy 3: Key scientific concept
    else {
      final conceptIdx = idx % (chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts.length : 1);
      final targetConcept = chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts[conceptIdx] : chapter.title;

      prompt = 'What is the primary scientific concept studied in "${chapter.title}"?';
      answer = targetConcept;

      final distractors = <String>[];
      for (final kc in chapter.keyConcepts) {
        if (kc != targetConcept && !distractors.contains(kc) && distractors.length < 3) {
          distractors.add(kc);
        }
      }

      final defaultConcepts = isEvs
          ? ['Ecosystem Balance', 'Environmental Conservation', 'Community Living', 'Natural Resources']
          : ['Scientific Observation', 'Energy Conservation', 'Matter Properties', 'Biological Adaptation'];

      for (final dc in defaultConcepts) {
        if (dc != targetConcept && !distractors.contains(dc) && distractors.length < 3) {
          distractors.add(dc);
        }
      }

      options = [answer, ...distractors.take(3)]..shuffle(_rng);
      explanation = 'In "${chapter.title}", we explore "$targetConcept".';
    }

    final id = '${subject}_mcq_${DateTime.now().microsecondsSinceEpoch}_$idx';
    final icon = isEvs ? '🌿' : '🔬';

    return Activity(
      activityId: id,
      topicId: '${subject}_${chapter.chapterId}',
      subjectId: subject,
      targetGrade: studentClass.label,
      gradeTier: studentClass.tier,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': icon,
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }
}
