import 'dart:math';
import '../models/activity_model.dart';
import '../models/chapter_model.dart';
import '../models/grade_tier.dart';
import '../models/student_profile.dart';

/// Algorithmic question generator engine for English language learning.
/// Produces rich, authentic, curriculum-aligned English activities across all 10 grades.
/// Adheres strictly to:
/// 1. ZERO class names in prompts or options
/// 2. Strict grade appropriateness (Class 8 gets Class 8 topics, Class 1 gets Class 1)
/// 3. Zero missing information
/// 4. Zero repetitive boilerplate
/// 5. Universal hints and concept explanations
class EnglishQuestionGenerator {
  static final EnglishQuestionGenerator instance = EnglishQuestionGenerator._();
  EnglishQuestionGenerator._();

  final Random _rng = Random();

  /// Main dispatch method generating activities for any chapter
  List<Activity> generateActivitiesForChapter(
    Chapter chapter,
    StudentClass studentClass, {
    int count = 5,
    Set<String> existingPromptTexts = const {},
  }) {
    final activities = <Activity>[];
    final seenPrompts = <String>{...existingPromptTexts.map((e) => e.trim().toLowerCase())};
    int attempts = 0;
    int idx = 1;

    while (activities.length < count && attempts < 40) {
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

  /// Generates a single dynamic English question tailored to the chapter and grade
  Activity generateSingleQuestion(
    Chapter chapter,
    StudentClass studentClass, {
    int questionIndex = 1,
  }) {
    final title = chapter.title.toLowerCase();

    // Kindergarten (LKG & UKG) gets 100% interactive, voice-narrated Bubble Pop activities!
    if (studentClass.isKindergarten) {
      if (title.contains('phonics') || title.contains('letter sound') || title.contains('alphabet')) {
        return _generateLkgPhonicsBubblePop(chapter, studentClass, questionIndex);
      } else if (title.contains('rhyming')) {
        return _generateLkgRhymingBubblePop(chapter, studentClass, questionIndex);
      } else if (title.contains('tracing') || title.contains('shapes') || title.contains('fun with letter')) {
        return _generateLkgShapesLettersBubblePop(chapter, studentClass, questionIndex);
      } else if (title.contains('action word') || title.contains('doing word') || title.contains('nursery fun') || title.contains('movement')) {
        return _generateLkgActionWordsBubblePop(chapter, studentClass, questionIndex);
      } else if (title.contains('opposite') || title.contains('antonym')) {
        return _generateLkgOppositesBubblePop(chapter, studentClass, questionIndex);
      } else if (title.contains('vowel') || title.contains('consonant')) {
        return _generateUkgVowelsBubblePop(chapter, studentClass, questionIndex);
      } else if (title.contains('sight word') || title.contains('cvc') || title.contains('three-letter')) {
        return _generateUkgSightWordsBubblePop(chapter, studentClass, questionIndex);
      } else if (title.contains('word families') || title.contains('family')) {
        return _generateUkgWordFamiliesBubblePop(chapter, studentClass, questionIndex);
      } else {
        return _generateGenericEarlyExplorerBubblePop(chapter, studentClass, questionIndex);
      }
    }

    if (title.contains('phonics') || title.contains('letter sound')) {
      return _generatePhonicsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('rhym')) {
      return _generateRhymingProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('describing') || title.contains('degree') || title.contains('adjective')) {
      return _generateAdjectivesProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('tracing') || title.contains('letter stroke') || title.contains('fun with letter')) {
      return _generateLetterTracingProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('sight word') || title.contains('cvc') || title.contains('word families') || title.contains('three-letter')) {
      return _generateCvcSightWordProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('opposite') || title.contains('antonym')) {
      return _generateOppositesProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('gender')) {
      return _generateGenderProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('punctuation') || title.contains('capital letter')) {
      return _generatePunctuationProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('vowel') || title.contains('consonant')) {
      return _generateVowelConsonantProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('article') || title.contains("'a' and 'an'")) {
      return _generateArticlesProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('naming word') || title.contains('types of noun') || (title.contains('noun') && !title.contains('pronoun'))) {
      return _generateNounsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('action word') || title.contains('doing word') || (title.contains('verb') && !title.contains('subject-verb') && !title.contains('non-finite') && !title.contains('adverb'))) {
      return _generateVerbsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('singular') || title.contains('plural') || title.contains('one and many')) {
      return _generatePluralProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('pronoun')) {
      return _generatePronounsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('preposition')) {
      return _generatePrepositionsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('conjunction')) {
      return _generateConjunctionsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('adverb')) {
      return _generateAdverbsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('subject-verb') || title.contains('concord')) {
      return _generateSubjectVerbConcordProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('passive') || title.contains('voice')) {
      return _generateVoiceProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('reported speech') || title.contains('direct and indirect')) {
      return _generateReportedSpeechProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('clause') || title.contains('synthesis')) {
      return _generateSentenceSynthesisProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('conditional')) {
      return _generateConditionalsProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('sentence') || title.contains('predicate')) {
      return _generateSubjectPredicateProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('idiom') || title.contains('vocabulary') || title.contains('synonym')) {
      return _generateVocabularyProblem(chapter, studentClass, questionIndex);
    } else if (title.contains('polite') || title.contains('greeting') || title.contains('composition')) {
      return _generatePoliteWordsProblem(chapter, studentClass, questionIndex);
    }

    // Default pedagogical fallback tailored to chapter key concepts
    return _generateGenericEnglishProblem(chapter, studentClass, questionIndex);
  }

  // =========================================================================
  // Polite Words & Greetings (Class 1 ICSE Ch 10)
  // =========================================================================
  Activity _generatePoliteWordsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'q': 'When someone gives you a wonderful gift, what polite words should you say?',
        'ans': 'Thank you! 🎁',
        'distractors': ['Sorry! 😔', 'Goodbye! 👋', 'No way! 🙅'],
        'exp': 'We say "Thank you" to show gratitude.',
      },
      {
        'q': 'If you accidentally bump into someone, what polite word should you say?',
        'ans': 'I am sorry! 🙏',
        'distractors': ['Thank you! 🎁', 'Hello! 👋', 'Good night! 🌙'],
        'exp': 'We say "Sorry" when we make an accidental mistake.',
      },
      {
        'q': 'When you ask a classmate or teacher for help, which magic word do you use?',
        'ans': 'Please 🙏',
        'distractors': ['Hurry up! 🏃', 'Move away! 🚫', 'Quiet! 🤫'],
        'exp': 'We always say "Please" when requesting something politely.',
      },
      {
        'q': 'What cheerful greeting do we say when meeting friends in the morning?',
        'ans': 'Good morning! ☀️',
        'distractors': ['Good night! 🌙', 'Goodbye! 👋', 'Sorry! 😔'],
        'exp': 'We greet people with "Good morning" at the start of the day.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['ans'] as String, ...(item['distractors'] as List<String>)]..shuffle(_rng);

    return _buildMcq(
      id: 'eng_polite_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: item['q'] as String,
      ttsText: item['q'] as String,
      options: options,
      correctAnswer: item['ans'] as String,
      hint: item['exp'] as String,
      stepWorking: [
        'Read the social situation carefully.',
        item['exp'] as String,
        'The polite response is "${item['ans']}".',
      ],
      conceptTitle: 'Polite Words & Greetings',
      conceptDetail: 'Polite words make conversations kind, respectful, and friendly.',
      rule: 'Always use polite words like Please, Thank You, and Sorry.',
      visualIcon: '🤝',
    );
  }

  // =========================================================================
  // 1. Phonics & Sounds (Early Explorer)
  // =========================================================================
  Activity _generatePhonicsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {'word': 'Sun', 'initial': 'S', 'sound': '/s/', 'options': ['S', 'B', 'M', 'T'], 'icon': '☀️'},
      {'word': 'Apple', 'initial': 'A', 'sound': '/æ/', 'options': ['A', 'E', 'O', 'I'], 'icon': '🍎'},
      {'word': 'Ball', 'initial': 'B', 'sound': '/b/', 'options': ['B', 'P', 'D', 'G'], 'icon': '⚽'},
      {'word': 'Cat', 'initial': 'C', 'sound': '/k/', 'options': ['C', 'K', 'S', 'T'], 'icon': '🐱'},
      {'word': 'Dog', 'initial': 'D', 'sound': '/d/', 'options': ['D', 'B', 'P', 'T'], 'icon': '🐶'},
      {'word': 'Fish', 'initial': 'F', 'sound': '/f/', 'options': ['F', 'V', 'P', 'T'], 'icon': '🐟'},
      {'word': 'Moon', 'initial': 'M', 'sound': '/m/', 'options': ['M', 'N', 'W', 'B'], 'icon': '🌙'},
      {'word': 'Kite', 'initial': 'K', 'sound': '/k/', 'options': ['K', 'C', 'T', 'P'], 'icon': '🪁'},
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Which letter sound does the word "${item['word']}" begin with?';

    return _buildMcq(
      id: 'eng_phon_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['initial'] as String,
      hint: 'Say the word out loud slowly: listen to the very first sound you hear!',
      stepWorking: [
        'Say "${item['word']}" aloud.',
        'The starting sound is ${item['sound']}.',
        'The letter that makes this sound is ${item['initial']}.',
      ],
      conceptTitle: 'Phonics & Initial Letter Sounds',
      conceptDetail: 'Every letter in the alphabet makes a distinct phonic sound at the beginning of words.',
      rule: 'Listen carefully to the first sound before reading the remaining letters.',
      visualIcon: item['icon'] as String,
    );
  }

  // =========================================================================
  // 2. Rhyming Words
  // =========================================================================
  Activity _generateRhymingProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {'word': 'Cat', 'correct': 'Hat', 'distractors': ['Cup', 'Dog', 'Car'], 'family': '-at family'},
      {'word': 'Bed', 'correct': 'Red', 'distractors': ['Bad', 'Box', 'Boy'], 'family': '-ed family'},
      {'word': 'Pin', 'correct': 'Win', 'distractors': ['Pan', 'Pen', 'Pot'], 'family': '-in family'},
      {'word': 'Sun', 'correct': 'Fun', 'distractors': ['Son', 'Sad', 'Star'], 'family': '-un family'},
      {'word': 'Hop', 'correct': 'Top', 'distractors': ['Hot', 'Hat', 'Hip'], 'family': '-op family'},
      {'word': 'Ring', 'correct': 'King', 'distractors': ['Rope', 'Rain', 'Run'], 'family': '-ing family'},
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['correct'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = 'Which word rhymes with "${item['word']}"?';
    return _buildMcq(
      id: 'eng_rhyme_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['correct'] as String,
      hint: 'Rhyming words end with the exact same sound!',
      stepWorking: [
        '"${item['word']}" belongs to the ${item['family']}.',
        'Compare the endings of all choices.',
        '"${item['correct']}" shares the exact same ending sound!',
      ],
      conceptTitle: 'Rhyming Word Families',
      conceptDetail: 'Rhyming words have identical ending vowel and consonant sounds.',
      rule: 'Words rhyme when their ending sounds match, even if spelled slightly differently.',
      visualIcon: '🎵',
    );
  }

  // =========================================================================
  // 2B. Opposites & Antonyms (Early Explorer & Higher Grades)
  // =========================================================================
  Activity _generateOppositesProblem(Chapter ch, StudentClass sc, int idx) {
    final isEarly = sc == StudentClass.lkg ||
        sc == StudentClass.ukg ||
        sc == StudentClass.class1 ||
        sc == StudentClass.class2;

    if (isEarly) {
      final pool = [
        {'word': 'Up ⬆️', 'antonym': 'Down ⬇️', 'distractors': ['Left ⬅️', 'In 📥', 'Cold ❄️']},
        {'word': 'Big 🐘', 'antonym': 'Small 🐜', 'distractors': ['Fast 🐆', 'Hot ☀️', 'Red 🔴']},
        {'word': 'Hot ☀️', 'antonym': 'Cold ❄️', 'distractors': ['Warm 🔥', 'Bright 🌟', 'Big 🐘']},
        {'word': 'Day ☀️', 'antonym': 'Night 🌙', 'distractors': ['Morning 🌅', 'Sun 🌞', 'Star ⭐']},
        {'word': 'Happy 😊', 'antonym': 'Sad 😢', 'distractors': ['Glad 😄', 'Funny 🤡', 'Little 🐣']},
        {'word': 'In 📥', 'antonym': 'Out 📤', 'distractors': ['Up ⬆️', 'Down ⬇️', 'Over 🌈']},
        {'word': 'Open 🚪', 'antonym': 'Closed 🔒', 'distractors': ['Wide ↔️', 'High 🏔️', 'Near 📍']},
        {'word': 'Fast 🚀', 'antonym': 'Slow 🐢', 'distractors': ['Quick ⚡', 'Big 🐘', 'Far 🔭']},
        {'word': 'Tall 🦒', 'antonym': 'Short 🐁', 'distractors': ['High 🏔️', 'Wide ↔️', 'Green 🍃']},
        {'word': 'Heavy 🪨', 'antonym': 'Light 🪶', 'distractors': ['Hard 💎', 'Soft ☁️', 'Dark 🌑']},
        {'word': 'Wet 🌧️', 'antonym': 'Dry 🏜️', 'distractors': ['Clean ✨', 'Cold ❄️', 'Deep 🌊']},
        {'word': 'Clean ✨', 'antonym': 'Dirty 🐾', 'distractors': ['Soft ☁️', 'Fast ⚡', 'Bright 💡']},
        {'word': 'Full 🥛', 'antonym': 'Empty 🫙', 'distractors': ['Big 🐘', 'Blue 💧', 'Heavy 🪨']},
        {'word': 'Sweet 🍬', 'antonym': 'Sour 🍋', 'distractors': ['Tasty 😋', 'Red 🍎', 'Soft ☁️']},
      ];
      final item = pool[(idx - 1) % pool.length];
      final options = [item['antonym'] as String, ...(item['distractors'] as List<String>)];
      options.shuffle(_rng);

      final prompt = 'What is the opposite of "${item['word']}"?';
      return _buildMcq(
        id: 'eng_opp_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: item['antonym'] as String,
        hint: 'Opposites are completely reverse pairs, like Day and Night!',
        stepWorking: [
          '"${item['word']}" is the starting word.',
          'Think of the opposite concept.',
          'The opposite of "${item['word']}" is "${item['antonym']}".',
        ],
        conceptTitle: 'Opposite Words',
        conceptDetail: 'Opposites are word pairs that mean the exact reverse of each other.',
        rule: 'Every opposite pair expresses contrary ideas like up vs down, hot vs cold.',
        visualIcon: '🌓',
      );
    }

    final pool = [
      {'word': 'Ancient', 'antonym': 'Modern', 'distractors': ['Old', 'Historic', 'Antique']},
      {'word': 'Courageous', 'antonym': 'Cowardly', 'distractors': ['Brave', 'Heroic', 'Bold']},
      {'word': 'Abundant', 'antonym': 'Scarce', 'distractors': ['Plentiful', 'Ample', 'Rich']},
      {'word': 'Optimistic', 'antonym': 'Pessimistic', 'distractors': ['Hopeful', 'Confident', 'Cheerful']},
      {'word': 'Trivial', 'antonym': 'Significant', 'distractors': ['Minor', 'Unimportant', 'Petty']},
      {'word': 'Generous', 'antonym': 'Selfish', 'distractors': ['Kind', 'Helpful', 'Charitable']},
      {'word': 'Frequent', 'antonym': 'Rare', 'distractors': ['Often', 'Constant', 'Daily']},
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['antonym'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = 'Which word is the ANTONYM (opposite) of "${item['word']}"?';
    return _buildMcq(
      id: 'eng_ant_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['antonym'] as String,
      hint: 'An antonym means the exact opposite meaning!',
      stepWorking: [
        '"${item['word']}" expresses a specific quality.',
        'The exact opposite concept is "${item['antonym']}".',
      ],
      conceptTitle: 'Antonyms & Word Meanings',
      conceptDetail: 'Antonyms are words having opposite or contrasting meanings.',
      rule: 'An antonym must belong to the same part of speech as the original word.',
      visualIcon: '🧠',
    );
  }

  // =========================================================================
  // 2C. Fun with Letters: Tracing & Shapes (LKG)
  // =========================================================================
  Activity _generateLetterTracingProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'q': 'Which letter is shaped like a round circle with no straight lines?',
        'ans': 'Letter O 🍩',
        'distractors': ['Letter T 🔨', 'Letter L 📐', 'Letter X ⚔️'],
        'hint': 'Think of a ball or a donut - it has no sharp corners!',
        'work': 'Letter O is drawn with one continuous curved circle.'
      },
      {
        'q': 'Which letter is made of one standing line and one sleeping line?',
        'ans': 'Letter L 📐',
        'distractors': ['Letter O 🍩', 'Letter C 🌙', 'Letter S 🐍'],
        'hint': 'One line goes straight down, and one line sleeps flat along the bottom!',
        'work': 'Letter L has a vertical standing line and a horizontal sleeping line.'
      },
      {
        'q': 'Which letter has a sleeping line resting on top of a standing line?',
        'ans': 'Letter T 🔨',
        'distractors': ['Letter O 🍩', 'Letter B 🎈', 'Letter P 🏓'],
        'hint': 'Like a roof on a pillar!',
        'work': 'Letter T is formed with a top sleeping line over a standing line.'
      },
      {
        'q': 'Which letter is curved like a crescent moon in the night sky?',
        'ans': 'Letter C 🌙',
        'distractors': ['Letter I 📏', 'Letter H 🪜', 'Letter E 🚪'],
        'hint': 'Look at the half-moon in the sky!',
        'work': 'Letter C is an open curved stroke like the crescent moon.'
      },
      {
        'q': 'Which letter has two slanting lines that meet at the top with a middle bridge?',
        'ans': 'Letter A ⛺',
        'distractors': ['Letter O 🍩', 'Letter U 🧲', 'Letter D 🏹'],
        'hint': 'Like a tent or a mountain with a little path across!',
        'work': 'Letter A has two slanting lines and one sleeping middle bar.'
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['ans'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = item['q'] as String;
    return _buildMcq(
      id: 'eng_trace_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['ans'] as String,
      hint: item['hint'] as String,
      stepWorking: [
        'Examine the shape and strokes in the question.',
        item['work'] as String,
        'The correct answer is "${item['ans']}".',
      ],
      conceptTitle: 'Letter Shapes & Strokes',
      conceptDetail: 'Letters are formed by combinations of standing lines, sleeping lines, slanting lines, and curves.',
      rule: 'Recognize strokes: standing (|), sleeping (-), slanting (/), and curves (C, O).',
      visualIcon: '✏️',
    );
  }

  // =========================================================================
  // 2D. Sight Words, CVC Words & Word Families (UKG)
  // =========================================================================
  Activity _generateCvcSightWordProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'q': 'Fill the missing middle vowel sound for: C _ T (Meow 🐱)',
        'ans': 'A (CAT)',
        'distractors': ['O (COT)', 'E (CET)', 'U (CUT)'],
        'hint': 'Say the word "Cat" aloud: what sound is in the middle?',
        'work': 'C-A-T makes the word "Cat".'
      },
      {
        'q': 'Fill the missing middle vowel sound for: D _ G (Woof 🐶)',
        'ans': 'O (DOG)',
        'distractors': ['A (DAG)', 'I (DIG)', 'U (DUG)'],
        'hint': 'Say the word "Dog" aloud: /d/ /ɒ/ /g/!',
        'work': 'D-O-G spells "Dog".'
      },
      {
        'q': 'Which three-letter word matches the shining star in the sky: ☀️?',
        'ans': 'SUN',
        'distractors': ['SIT', 'SAD', 'SONG'],
        'hint': 'S-U-N shines bright in the day!',
        'work': 'S-U-N is the 3-letter CVC word for Sun.'
      },
      {
        'q': 'Which three-letter word matches what we sleep on: 🛏️?',
        'ans': 'BED',
        'distractors': ['BAT', 'BAG', 'BUG'],
        'hint': 'B-E-D ends with /ed/!',
        'work': 'B-E-D spells Bed.'
      },
      {
        'q': 'Which word belongs to the -at rhyming word family?',
        'ans': 'BAT 🦇',
        'distractors': ['CUP ☕', 'PIG 🐷', 'PEN 🖊️'],
        'hint': 'Words in the -at family end with -at: Cat, Hat, Bat!',
        'work': 'BAT ends with -at and rhymes with Cat.'
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['ans'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = item['q'] as String;
    return _buildMcq(
      id: 'eng_cvc_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['ans'] as String,
      hint: item['hint'] as String,
      stepWorking: [
        'Read the word carefully and sound out each phoneme.',
        item['work'] as String,
        'The correct answer is "${item['ans']}".',
      ],
      conceptTitle: 'CVC Three-Letter Words',
      conceptDetail: 'Consonant-Vowel-Consonant (CVC) words are simple 3-letter words foundational to early reading.',
      rule: 'A CVC word has a beginning consonant, a short middle vowel, and an ending consonant.',
      visualIcon: '📖',
    );
  }

  // =========================================================================
  // 2E. Noun Gender (Class 2 & 3)
  // =========================================================================
  Activity _generateGenderProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {'masculine': 'King 👑', 'feminine': 'Queen 👸', 'distractors': ['Princess 👧', 'Lady 👩', 'Waitress 🍵']},
      {'masculine': 'Boy 👦', 'feminine': 'Girl 👧', 'distractors': ['Mother 👩', 'Aunt 👩', 'Sister 👧']},
      {'masculine': 'Prince 🤴', 'feminine': 'Princess 👸', 'distractors': ['Queen 👑', 'Empress 🏛️', 'Duchess 💎']},
      {'masculine': 'Father 👨', 'feminine': 'Mother 👩', 'distractors': ['Sister 👧', 'Daughter 👧', 'Aunt 👩']},
      {'masculine': 'Brother 👦', 'feminine': 'Sister 👧', 'distractors': ['Mother 👩', 'Niece 👧', 'Cousin 👶']},
      {'masculine': 'Lion 🦁', 'feminine': 'Lioness 🐾', 'distractors': ['Tigress 🐯', 'Cub 🐾', 'Mare 🐴']},
      {'masculine': 'Bull 🐂', 'feminine': 'Cow 🐄', 'distractors': ['Goat 🐐', 'Sheep 🐑', 'Hen 🐔']},
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['feminine'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = 'What is the feminine (female) gender of "${item['masculine']}"?';
    return _buildMcq(
      id: 'eng_gender_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['feminine'] as String,
      hint: 'Masculine is for males, and feminine is for females!',
      stepWorking: [
        '"${item['masculine']}" is a masculine noun.',
        'Its feminine counterpart is "${item['feminine']}".',
      ],
      conceptTitle: 'Noun Gender',
      conceptDetail: 'Nouns can be masculine (male) or feminine (female).',
      rule: 'Pairs like King-Queen and Boy-Girl represent masculine and feminine forms.',
      visualIcon: '👑',
    );
  }

  // =========================================================================
  // 2F. Punctuation & Capital Letters (Class 2 & 3)
  // =========================================================================
  Activity _generatePunctuationProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'q': 'Which sentence is written correctly with a capital letter and full stop?',
        'ans': 'The dog is barking.',
        'distractors': ['the dog is barking.', 'The dog is barking', 'the dog is barking'],
        'hint': 'Sentences always start with a CAPITAL letter and end with a full stop (.)!'
      },
      {
        'q': 'What mark is placed at the end of an asking question?',
        'ans': 'Question mark (?)',
        'distractors': ['Full stop (.)', 'Comma (,)', 'Exclamation mark (!)'],
        'hint': 'When we ask something (e.g., "Where are you?"), what mark do we use?'
      },
      {
        'q': 'Which mark is placed at the end of a regular telling sentence?',
        'ans': 'Full stop (.)',
        'distractors': ['Question mark (?)', 'Comma (,)', 'Slash (/)'],
        'hint': 'Every simple statement ends with a little dot called a full stop.'
      },
      {
        'q': 'Which letter in the sentence "my name is Alex." should be capitalized?',
        'ans': 'The first letter "m" -> "My"',
        'distractors': ['The letter "n" in name', 'The letter "i" in is', 'No letters'],
        'hint': 'The very first letter of every new sentence MUST be a capital letter!'
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['ans'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = item['q'] as String;
    return _buildMcq(
      id: 'eng_punct_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['ans'] as String,
      hint: item['hint'] as String,
      stepWorking: [
        'Recall standard sentence punctuation rules.',
        'Every sentence begins with a capital letter and ends with a full stop or question mark.',
        'The correct answer is "${item['ans']}".',
      ],
      conceptTitle: 'Punctuation & Capitalization',
      conceptDetail: 'Proper punctuation clarifies meaning and marks the beginning and end of ideas.',
      rule: 'Capitalize the first letter of a sentence; terminate with a full stop or question mark.',
      visualIcon: '✍️',
    );
  }

  // =========================================================================
  // 3. Vowels & Consonants
  // =========================================================================
  Activity _generateVowelConsonantProblem(Chapter ch, StudentClass sc, int idx) {
    final isVowelQuery = (idx % 2 == 1);
    if (isVowelQuery) {
      final vowels = ['A', 'E', 'I', 'O', 'U'];
      final consonants = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'R', 'S', 'T'];
      final correct = vowels[(idx - 1) % vowels.length];
      consonants.shuffle(_rng);
      final options = [correct, consonants[0], consonants[1], consonants[2]];
      options.shuffle(_rng);

      final prompts = [
        'Which of the following letters is a VOWEL?',
        'Select the VOWEL letter from the options below:',
        'Which letter makes an open vowel sound (A, E, I, O, U)?',
        'Find the special VOWEL letter:',
      ];
      final prompt = prompts[(idx - 1) % prompts.length];
      return _buildMcq(
        id: 'eng_vow_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: correct,
        hint: 'There are only 5 special vowels: A, E, I, O, U!',
        stepWorking: [
          'Recall the 5 English vowels: A, E, I, O, U.',
          'All other 21 letters are consonants.',
          'Among the choices, $correct is one of the 5 vowels.',
        ],
        conceptTitle: 'Vowels vs Consonants',
        conceptDetail: 'The English alphabet has 26 letters: 5 vowels (A, E, I, O, U) and 21 consonants.',
        rule: 'Every English word requires at least one vowel or vowel sound.',
        visualIcon: '⭐',
      );
    } else {
      final vowels = ['A', 'E', 'I', 'O', 'U'];
      final consonants = ['B', 'D', 'M', 'P', 'S', 'T'];
      final correct = consonants[(idx - 1) % consonants.length];
      vowels.shuffle(_rng);
      final options = [correct, vowels[0], vowels[1], vowels[2]];
      options.shuffle(_rng);

      final prompts = [
        'Which of the following letters is a CONSONANT?',
        'Select the CONSONANT letter from the options below:',
        'Which letter is a consonant (not one of A, E, I, O, U)?',
        'Find the CONSONANT letter:',
      ];
      final prompt = prompts[(idx - 1) % prompts.length];
      return _buildMcq(
        id: 'eng_cons_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: correct,
        hint: 'The 5 vowels are A, E, I, O, U. Any other letter is a consonant!',
        stepWorking: [
          'Recall the 5 vowels: A, E, I, O, U.',
          'The remaining 21 letters are consonants.',
          '$correct is not a vowel, making it a consonant.',
        ],
        conceptTitle: 'Vowels and Consonants',
        conceptDetail: 'Consonants are speech sounds produced with some obstruction of airflow.',
        rule: 'The letters A, E, I, O, U are vowels; the other 21 letters are consonants.',
        visualIcon: '🔤',
      );
    }
  }

  // =========================================================================
  // 4. Articles: A vs An vs The
  // =========================================================================
  Activity _generateArticlesProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {'noun': 'apple', 'article': 'An', 'options': ['An', 'A', 'The', 'None'], 'reason': 'starts with vowel sound /æ/'},
      {'noun': 'umbrella', 'article': 'An', 'options': ['An', 'A', 'The', 'None'], 'reason': 'starts with vowel sound /ʌ/'},
      {'noun': 'elephant', 'article': 'An', 'options': ['An', 'A', 'The', 'None'], 'reason': 'starts with vowel sound /e/'},
      {'noun': 'orange', 'article': 'An', 'options': ['An', 'A', 'The', 'None'], 'reason': 'starts with vowel sound /ɒ/'},
      {'noun': 'honest man', 'article': 'An', 'options': ['An', 'A', 'The', 'None'], 'reason': 'silent "h", starts with vowel sound /ɒ/'},
      {'noun': 'book', 'article': 'A', 'options': ['A', 'An', 'The', 'None'], 'reason': 'starts with consonant sound /b/'},
      {'noun': 'tiger', 'article': 'A', 'options': ['A', 'An', 'The', 'None'], 'reason': 'starts with consonant sound /t/'},
      {'noun': 'university', 'article': 'A', 'options': ['A', 'An', 'The', 'None'], 'reason': 'starts with consonant sound /juː/ (like "you")'},
      {'noun': 'European country', 'article': 'A', 'options': ['A', 'An', 'The', 'None'], 'reason': 'starts with consonant sound /j/ (like "you")'},
      {'noun': 'sun rising in the east', 'article': 'The', 'options': ['The', 'A', 'An', 'None'], 'reason': 'unique celestial object'},
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Fill in the blank with the correct article: "______ ${item['noun']}."';

    return _buildMcq(
      id: 'eng_art_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['article'] as String,
      hint: 'Listen to the SOUND of the first letter: vowel sounds take "An", consonant sounds take "A"!',
      stepWorking: [
        'Examine the phrase "${item['noun']}".',
        'Sound analysis: it ${item['reason']}.',
        'Therefore, the correct article is "${item['article']}".',
      ],
      conceptTitle: 'Articles: A, An, and The',
      conceptDetail: 'Choice of A vs An depends on sound, not spelling. "An" is used before vowel sounds; "A" before consonant sounds.',
      rule: 'Use "An" before vowel sounds (a, e, i, o, u); use "A" before consonant sounds.',
      visualIcon: '🍎',
    );
  }

  // =========================================================================
  // 5. Nouns (Common, Proper, Collective, Abstract)
  // =========================================================================
  Activity _generateNounsProblem(Chapter ch, StudentClass sc, int idx) {
    if (sc.tier == GradeTier.earlyExplorer) {
      // Identifying naming words
      final pool = [
        {'sent': 'The brown dog barked loudly.', 'noun': 'dog', 'distractors': ['brown', 'barked', 'loudly'], 'type': 'animal'},
        {'sent': 'Mother baked sweet cookies.', 'noun': 'Mother', 'distractors': ['baked', 'sweet', 'softly'], 'type': 'person'},
        {'sent': 'We went to the big park.', 'noun': 'park', 'distractors': ['went', 'big', 'to'], 'type': 'place'},
        {'sent': 'Rohan read an exciting book.', 'noun': 'book', 'distractors': ['read', 'exciting', 'an'], 'type': 'thing'},
      ];
      final item = pool[(idx - 1) % pool.length];
      final options = [item['noun'] as String, ...(item['distractors'] as List<String>)];
      options.shuffle(_rng);

      final prompt = 'Identify the naming word (Noun) in the sentence: "${item['sent']}"';
      return _buildMcq(
        id: 'eng_noun_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: item['noun'] as String,
        hint: 'A noun is the name of a person, place, animal, or thing!',
        stepWorking: [
          'Read the sentence: "${item['sent']}".',
          '"${item['noun']}" names a ${item['type']}.',
          'Words that name persons, places, animals, or things are nouns.',
        ],
        conceptTitle: 'Naming Words (Nouns)',
        conceptDetail: 'Nouns are words used to identify any of a class of people, places, animals, or things.',
        rule: 'Every person, place, animal, or thing in the world is identified by a noun.',
        visualIcon: '🏷️',
      );
    } else {
      // Collective or Proper Nouns
      final pool = [
        {'group': 'wolves hunting together', 'collective': 'pack', 'options': ['pack', 'flock', 'herd', 'swarm']},
        {'group': 'bees buzzing in a garden', 'collective': 'swarm', 'options': ['swarm', 'pride', 'school', 'gang']},
        {'group': 'lions resting under a tree', 'collective': 'pride', 'options': ['pride', 'herd', 'pack', 'colony']},
        {'group': 'sheep grazing on the hill', 'collective': 'flock', 'options': ['flock', 'pack', 'fleet', 'bundle']},
        {'group': 'ships sailing in the navy', 'collective': 'fleet', 'options': ['fleet', 'flock', 'crew', 'batch']},
        {'group': 'musicians playing in an orchestra', 'collective': 'band', 'options': ['band', 'team', 'mob', 'bunch']},
      ];
      final item = pool[(idx - 1) % pool.length];
      final prompt = 'What is the correct collective noun for a group of ${item['group']}?';

      return _buildMcq(
        id: 'eng_collnoun_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: List<String>.from(item['options'] as List),
        correctAnswer: item['collective'] as String,
        hint: 'A collective noun names a specific group of animals, people, or things taken as one whole!',
        stepWorking: [
          'Examine the group: ${item['group']}.',
          'The special collective noun for this group is "${item['collective']}".',
          'Hence, we say: a ${item['collective']} of ${item['group'].toString().split(' ')[0]}.',
        ],
        conceptTitle: 'Collective Nouns',
        conceptDetail: 'A collective noun is a noun that denotes a collection of persons or things regarded as one unit.',
        rule: 'Use specific traditional collective nouns for distinct groups of animals and people.',
        visualIcon: '🦁',
      );
    }
  }

  // =========================================================================
  // 6. Plural Nouns
  // =========================================================================
  Activity _generatePluralProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {'singular': 'box', 'plural': 'boxes', 'distractors': ['boxs', 'boxies', 'boxen'], 'rule': 'ends in -x -> add -es'},
      {'singular': 'brush', 'plural': 'brushes', 'distractors': ['brushs', 'brushies', 'brushez'], 'rule': 'ends in -sh -> add -es'},
      {'singular': 'watch', 'plural': 'watches', 'distractors': ['watchs', 'watchies', 'watchez'], 'rule': 'ends in -ch -> add -es'},
      {'singular': 'baby', 'plural': 'babies', 'distractors': ['babys', 'babyes', 'babiez'], 'rule': 'consonant + y -> change y to -ies'},
      {'singular': 'leaf', 'plural': 'leaves', 'distractors': ['leafs', 'leafes', 'leavez'], 'rule': 'ends in -f -> change to -ves'},
      {'singular': 'child', 'plural': 'children', 'distractors': ['childs', 'childrens', 'childes'], 'rule': 'irregular plural'},
      {'singular': 'foot', 'plural': 'feet', 'distractors': ['foots', 'feets', 'footies'], 'rule': 'vowel change irregular plural'},
      {'singular': 'tooth', 'plural': 'teeth', 'distractors': ['tooths', 'toothes', 'teethes'], 'rule': 'vowel change irregular plural'},
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['plural'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = 'What is the correct plural form of the word "${item['singular']}"?';
    return _buildMcq(
      id: 'eng_plur_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['plural'] as String,
      hint: 'Check the ending letter of the word: does it follow a special plural spelling rule?',
      stepWorking: [
        'Singular word: "${item['singular']}".',
        'Spelling rule: ${item['rule']}.',
        'The correct plural form is "${item['plural']}".',
      ],
      conceptTitle: 'Singular and Plural Nouns',
      conceptDetail: 'Most nouns form plurals by adding -s, but words ending in hissing sounds add -es, and irregular nouns change internally.',
      rule: 'Words ending in -s, -sh, -ch, -x, -z add -es. Words ending in consonant + y change y to -ies.',
      visualIcon: '📦',
    );
  }

  // =========================================================================
  // 7. Pronouns
  // =========================================================================
  Activity _generatePronounsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'Riya is an honest girl. ______ always speaks the truth.',
        'correct': 'She',
        'options': ['She', 'He', 'It', 'They'],
        'reason': 'Riya is singular female, requiring the subject pronoun "She".',
      },
      {
        'sent': 'Aman and I play tennis every evening. ______ are good partners.',
        'correct': 'We',
        'options': ['We', 'They', 'Us', 'Them'],
        'reason': '"Aman and I" includes the speaker, so the first-person plural pronoun "We" is used.',
      },
      {
        'sent': 'This blue jacket belongs to me. It is ______.',
        'correct': 'mine',
        'options': ['mine', 'my', 'me', 'myself'],
        'reason': 'A possessive pronoun standing alone without a following noun must be "mine".',
      },
      {
        'sent': 'The puppy was happy and wagged ______ little tail.',
        'correct': 'its',
        'options': ['its', "it's", 'their', 'his'],
        'reason': '"Its" is the possessive pronoun for animals/objects. "It\'s" means "it is".',
      },
      {
        'sent': 'The girl ______ won the gold medal is my sister.',
        'correct': 'who',
        'options': ['who', 'which', 'whose', 'whom'],
        'reason': 'Use the relative pronoun "who" when referring to a person as the subject.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Fill in the blank with the correct pronoun: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_pron_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Ask yourself: who or what is being replaced by this pronoun?',
      stepWorking: [
        'Analyze the context of the sentence.',
        'Reasoning: ${item['reason']}',
        'The correct pronoun is "${item['correct']}".',
      ],
      conceptTitle: 'Pronouns & Types of Pronouns',
      conceptDetail: 'Pronouns replace nouns to prevent tedious repetition and provide grammatical cohesion.',
      rule: 'Ensure pronouns match their antecedents in number, person, and gender.',
      visualIcon: '👥',
    );
  }

  // =========================================================================
  // 8. Verbs & Tenses
  // =========================================================================
  Activity _generateVerbsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'Yesterday evening, we ______ (watch) an interesting documentary.',
        'correct': 'watched',
        'options': ['watched', 'watch', 'are watching', 'will watch'],
        'reason': '"Yesterday" indicates an action completed in the past: Simple Past tense.',
      },
      {
        'sent': 'Look! The colorful birds ______ (fly) across the lake right now.',
        'correct': 'are flying',
        'options': ['are flying', 'flew', 'fly', 'will fly'],
        'reason': '"Look!" and "right now" show an action in progress at this moment: Present Continuous.',
      },
      {
        'sent': 'The sun ______ in the east every morning.',
        'correct': 'rises',
        'options': ['rises', 'rose', 'is rising', 'will rise'],
        'reason': 'Universal scientific truths and daily habits always use the Simple Present tense.',
      },
      {
        'sent': 'By the time the doctor arrived, the patient ______ (recover).',
        'correct': 'had recovered',
        'options': ['had recovered', 'has recovered', 'recovers', 'will recover'],
        'reason': 'When two actions happened in the past, the earlier action takes the Past Perfect tense (had + V3).',
      },
      {
        'sent': 'Tomorrow at 10 AM, our team ______ the final match.',
        'correct': 'will play',
        'options': ['will play', 'played', 'has played', 'is played'],
        'reason': '"Tomorrow" signifies a future action: Simple Future tense (will + V1).',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Select the correct form of the verb: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_verb_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Look for time clues like "yesterday", "right now", "every morning", or "tomorrow"!',
      stepWorking: [
        'Identify the time indicator in the sentence.',
        'Reasoning: ${item['reason']}',
        'The correct verb form is "${item['correct']}".',
      ],
      conceptTitle: 'Verb Tenses and Temporal Harmony',
      conceptDetail: 'Verbs indicate the time of action through their tense forms: Past, Present, and Future.',
      rule: 'Match the verb tense to the chronological time marker in the sentence.',
      visualIcon: '⏳',
    );
  }

  // =========================================================================
  // 9. Adjectives & Degrees of Comparison
  // =========================================================================
  Activity _generateAdjectivesProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'Mount Everest is the ______ mountain peak on Earth.',
        'correct': 'highest',
        'options': ['highest', 'higher', 'high', 'most high'],
        'reason': 'Comparing one peak against all others requires the Superlative degree (-est) with "the".',
      },
      {
        'sent': 'An airplane is ______ than a passenger train.',
        'correct': 'faster',
        'options': ['faster', 'fast', 'fastest', 'more fast'],
        'reason': 'Comparing two items with "than" requires the Comparative degree (-er).',
      },
      {
        'sent': 'Honesty is the ______ policy.',
        'correct': 'best',
        'options': ['best', 'better', 'good', 'most good'],
        'reason': 'Irregular comparison: good -> better -> best. Superlative with "the" is "best".',
      },
      {
        'sent': 'This puzzle is ______ than the one we solved yesterday.',
        'correct': 'more difficult',
        'options': ['more difficult', 'difficulter', 'most difficult', 'difficultest'],
        'reason': 'Adjectives with three or more syllables use "more" for the comparative degree.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Fill in the blank with the correct degree of adjective: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_adj_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Are we describing 1 item (positive), comparing 2 items (comparative -er), or picking the champion of 3+ (superlative -est)?',
      stepWorking: [
        'Analyze how many things are being compared.',
        'Reasoning: ${item['reason']}',
        'The correct adjective form is "${item['correct']}".',
      ],
      conceptTitle: 'Degrees of Comparison',
      conceptDetail: 'Adjectives have three degrees: Positive (base), Comparative (-er / more), and Superlative (-est / most).',
      rule: 'Use comparative with "than" for two items; use superlative with "the" for three or more.',
      visualIcon: '📏',
    );
  }

  // =========================================================================
  // 10. Prepositions
  // =========================================================================
  Activity _generatePrepositionsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'India gained its independence ______ 15th August 1947.',
        'correct': 'on',
        'options': ['on', 'in', 'at', 'by'],
        'reason': 'Specific calendar dates and days always take the preposition "on".',
      },
      {
        'sent': 'Our school assembly begins sharp ______ 8:00 AM.',
        'correct': 'at',
        'options': ['at', 'on', 'in', 'during'],
        'reason': 'Exact clock times always take the preposition "at".',
      },
      {
        'sent': 'Leaves turn golden and fall ______ autumn.',
        'correct': 'in',
        'options': ['in', 'at', 'on', 'with'],
        'reason': 'Seasons, months, and years take the preposition "in".',
      },
      {
        'sent': 'The excited child jumped ______ the swimming pool.',
        'correct': 'into',
        'options': ['into', 'in', 'on', 'onto'],
        'reason': '"Into" indicates movement from outside to inside an enclosed space.',
      },
      {
        'sent': 'Divide the sweet mangoes ______ the two brothers.',
        'correct': 'between',
        'options': ['between', 'among', 'with', 'in'],
        'reason': 'Use "between" when dividing or choosing between exactly two persons or things.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Fill in the blank with the correct preposition: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_prep_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Remember: AT for precise clock time, ON for days and dates, IN for months and seasons!',
      stepWorking: [
        'Identify what follows the blank (date, clock time, or season).',
        'Reasoning: ${item['reason']}',
        'The correct preposition is "${item['correct']}".',
      ],
      conceptTitle: 'Prepositions of Time and Place',
      conceptDetail: 'Prepositions demonstrate relationships of time, space, and direction between nouns and other sentence elements.',
      rule: 'AT = exact time; ON = days/dates; IN = months/years/seasons. BETWEEN = 2 entities; AMONG = 3+ entities.',
      visualIcon: '📍',
    );
  }

  // =========================================================================
  // 11. Conjunctions
  // =========================================================================
  Activity _generateConjunctionsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'Aarav ran very fast, ______ he missed the school bus by a few seconds.',
        'correct': 'but',
        'options': ['but', 'and', 'because', 'so'],
        'reason': 'Running fast and missing the bus are opposing/contrasting results, so "but" is required.',
      },
      {
        'sent': 'We carried an umbrella ______ the weather forecast predicted rain.',
        'correct': 'because',
        'options': ['because', 'or', 'so', 'although'],
        'reason': '"Because" introduces the reason/cause for carrying the umbrella.',
      },
      {
        'sent': 'Would you prefer a cup of hot chocolate ______ chilled lemonade?',
        'correct': 'or',
        'options': ['or', 'and', 'but', 'nor'],
        'reason': '"Or" provides an alternative choice between two drinks.',
      },
      {
        'sent': '______ she was exhausted from the journey, she finished her assignment.',
        'correct': 'Although',
        'options': ['Although', 'Because', 'Unless', 'Since'],
        'reason': '"Although" introduces a concession/contrast clause.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Choose the most suitable conjunction to connect the ideas: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_conj_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Think about how the two thoughts relate: are they adding, contrasting, or giving a reason?',
      stepWorking: [
        'Analyze the relationship between the two clauses.',
        'Reasoning: ${item['reason']}',
        'The correct conjunction is "${item['correct']}".',
      ],
      conceptTitle: 'Conjunctions and Sentence Connectors',
      conceptDetail: 'Conjunctions join words, phrases, or clauses, establishing logical relationships like addition, contrast, or cause.',
      rule: 'Use "and" for addition, "but" for contrast, "because" for cause, and "or" for choices.',
      visualIcon: '🔗',
    );
  }

  // =========================================================================
  // 12. Adverbs
  // =========================================================================
  Activity _generateAdverbsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'The pianist played the melody ______ and captivated the audience.',
        'correct': 'gracefully',
        'options': ['gracefully', 'graceful', 'graced', 'grace'],
        'reason': 'An adverb of manner ending in -ly modifies how the pianist played.',
      },
      {
        'sent': 'The sprinter ran extremely ______ to break the tournament record.',
        'correct': 'fast',
        'options': ['fast', 'fastly', 'fasterly', 'fastness'],
        'reason': '"Fast" serves as both an adjective and an adverb; "fastly" does not exist in standard English.',
      },
      {
        'sent': 'In the sentence "She spoke quite softly", what part of speech is "softly"?',
        'correct': 'Adverb',
        'options': ['Adverb', 'Adjective', 'Noun', 'Verb'],
        'reason': '"Softly" tells HOW she spoke (modifies verb "spoke"), making it an adverb.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Answer the question regarding adverbs: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_adv_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Adverbs tell HOW, WHEN, or WHERE an action takes place!',
      stepWorking: [
        'Identify what word is being modified (usually the verb).',
        'Reasoning: ${item['reason']}',
        'The correct answer is "${item['correct']}".',
      ],
      conceptTitle: 'Adverbs and Verb Modification',
      conceptDetail: 'Adverbs describe or modify verbs, adjectives, or other adverbs, indicating manner, time, place, or degree.',
      rule: 'Form adverbs of manner by adding -ly to adjectives, watching out for irregulars like fast and well.',
      visualIcon: '⚡',
    );
  }

  // =========================================================================
  // 13. Subject-Verb Concord (Agreement)
  // =========================================================================
  Activity _generateSubjectVerbConcordProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'Neither the teacher nor the students ______ present in the lab.',
        'correct': 'were',
        'options': ['were', 'was', 'is', 'has'],
        'reason': 'With "neither...nor", the verb agrees with the closer subject ("students" -> plural "were").',
      },
      {
        'sent': 'The quality of these mangoes ______ not up to the standard.',
        'correct': 'is',
        'options': ['is', 'are', 'were', 'have'],
        'reason': 'The true subject is the singular noun "quality", not the intervening plural "mangoes".',
      },
      {
        'sent': 'Mathematics ______ considered by many to be a fascinating subject.',
        'correct': 'is',
        'options': ['is', 'are', 'were', 'have been'],
        'reason': '"Mathematics" ends in -s but names a single discipline, taking a singular verb.',
      },
      {
        'sent': 'The captain, along with all his crew members, ______ rescued safely.',
        'correct': 'was',
        'options': ['was', 'were', 'are', 'have been'],
        'reason': 'Parenthetical phrases like "along with" do not alter the singular subject "captain".',
      },
      {
        'sent': 'Ten kilometers ______ a long distance to walk on foot.',
        'correct': 'is',
        'options': ['is', 'are', 'were', 'being'],
        'reason': 'A unit of measurement, distance, or sum of money regarded as a whole takes a singular verb.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Choose the verb that correctly agrees with the subject: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_concord_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Find the real subject of the sentence, ignoring extra words inside commas!',
      stepWorking: [
        'Locate the primary subject of the clause.',
        'Determine if the subject is singular or plural.',
        'Reasoning: ${item['reason']}',
        'The agreeing verb is "${item['correct']}".',
      ],
      conceptTitle: 'Subject-Verb Concord Rules',
      conceptDetail: 'A verb must agree with its subject in number and person, regardless of intervening phrases.',
      rule: 'Singular subjects require singular verbs; plural subjects require plural verbs.',
      visualIcon: '⚖️',
    );
  }

  // =========================================================================
  // 14. Active & Passive Voice
  // =========================================================================
  Activity _generateVoiceProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'active': 'The chef prepares delicious meals every evening.',
        'passive': 'Delicious meals are prepared by the chef every evening.',
        'distractors': [
          'Delicious meals were prepared by the chef every evening.',
          'Delicious meals is prepared by the chef every evening.',
          'The chef is preparing delicious meals every evening.',
        ],
        'tense': 'Simple Present (Object + are + V3 + by + Subject)',
      },
      {
        'active': 'Shakespeare wrote Hamlet.',
        'passive': 'Hamlet was written by Shakespeare.',
        'distractors': [
          'Hamlet is written by Shakespeare.',
          'Hamlet had written by Shakespeare.',
          'Hamlet was being written by Shakespeare.',
        ],
        'tense': 'Simple Past (Object + was + V3 + by + Subject)',
      },
      {
        'active': 'The engineers are building a new suspension bridge.',
        'passive': 'A new suspension bridge is being built by the engineers.',
        'distractors': [
          'A new suspension bridge has been built by the engineers.',
          'A new suspension bridge was built by the engineers.',
          'A new suspension bridge is built by the engineers.',
        ],
        'tense': 'Present Continuous (Object + is being + V3 + by + Subject)',
      },
      {
        'active': 'They have solved all the challenging problems.',
        'passive': 'All the challenging problems have been solved by them.',
        'distractors': [
          'All the challenging problems has been solved by them.',
          'All the challenging problems were solved by them.',
          'All the challenging problems are solved by them.',
        ],
        'tense': 'Present Perfect (Object + have been + V3 + by + Subject)',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['passive'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = 'Select the correct PASSIVE VOICE transformation for: "${item['active']}"';
    return _buildMcq(
      id: 'eng_voice_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['passive'] as String,
      hint: 'The object becomes the subject: check the auxiliary verb ("be" form) and make sure the verb is in past participle (V3)!',
      stepWorking: [
        'Active sentence: "${item['active']}".',
        'Transformation rule for ${item['tense']}.',
        'Passive form: "${item['passive']}".',
      ],
      conceptTitle: 'Active and Passive Voice Transformation',
      conceptDetail: 'In active voice, the subject performs the action. In passive voice, the subject receives the action.',
      rule: 'Passive formula: Object + appropriate "be" verb + past participle (V3) + by + Subject.',
      visualIcon: '🔄',
    );
  }

  // =========================================================================
  // 15. Reported Speech (Direct to Indirect)
  // =========================================================================
  Activity _generateReportedSpeechProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'direct': 'Rohan said, "I am reading a captivating historical novel."',
        'indirect': 'Rohan said that he was reading a captivating historical novel.',
        'distractors': [
          'Rohan said that he is reading a captivating historical novel.',
          'Rohan says that he was reading a captivating historical novel.',
          'Rohan said that I was reading a captivating historical novel.',
        ],
        'rule': 'Present Continuous ("am reading") shifts back to Past Continuous ("was reading").',
      },
      {
        'direct': 'The teacher said, "The Earth revolves around the Sun."',
        'indirect': 'The teacher said that the Earth revolves around the Sun.',
        'distractors': [
          'The teacher said that the Earth revolved around the Sun.',
          'The teacher said that the Earth had revolved around the Sun.',
          'The teacher told that the Earth will revolve around the Sun.',
        ],
        'rule': 'Universal truths and scientific facts DO NOT backshift in reported speech.',
      },
      {
        'direct': 'Ananya asked me, "Are you joining the debate competition?"',
        'indirect': 'Ananya asked me whether I was joining the debate competition.',
        'distractors': [
          'Ananya asked me that was I joining the debate competition.',
          'Ananya asked me if are you joining the debate competition.',
          'Ananya asked me whether you were joining the debate competition.',
        ],
        'rule': 'Yes/No questions use "if" or "whether", changing word order from question to statement.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final options = [item['indirect'] as String, ...(item['distractors'] as List<String>)];
    options.shuffle(_rng);

    final prompt = 'Choose the correct INDIRECT (Reported) SPEECH for: ${item['direct']}';
    return _buildMcq(
      id: 'eng_speech_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: item['indirect'] as String,
      hint: 'Watch for tense backshifts, pronoun updates, and whether the statement is a universal truth!',
      stepWorking: [
        'Direct quote: ${item['direct']}.',
        'Transformation rule: ${item['rule']}',
        'Reported speech: "${item['indirect']}".',
      ],
      conceptTitle: 'Direct and Indirect (Reported) Speech',
      conceptDetail: 'Reported speech conveys the message of a speaker without using quotation marks, adapting pronouns and tenses.',
      rule: 'Backshift tenses when the reporting verb is in the past, except for universal truths and scientific laws.',
      visualIcon: '💬',
    );
  }

  // =========================================================================
  // 16. Sentence Synthesis & Clauses
  // =========================================================================
  Activity _generateSentenceSynthesisProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'Although it was raining heavily, the dedicated volunteers continued the relief work.',
        'type': 'Complex Sentence',
        'options': ['Complex Sentence', 'Compound Sentence', 'Simple Sentence', 'Compound-Complex'],
        'reason': 'Contains one dependent clause ("Although it was raining heavily") and one main clause.',
      },
      {
        'sent': 'The bell rang and the excited students rushed out to the playground.',
        'type': 'Compound Sentence',
        'options': ['Compound Sentence', 'Simple Sentence', 'Complex Sentence', 'Fragment'],
        'reason': 'Contains two independent clauses joined by coordinating conjunction "and".',
      },
      {
        'sent': 'Despite having a high fever, Nikhil attended the annual ceremony.',
        'type': 'Simple Sentence',
        'options': ['Simple Sentence', 'Complex Sentence', 'Compound Sentence', 'Compound-Complex'],
        'reason': 'Contains only one finite verb ("attended") and one independent clause with a prepositional phrase.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Identify the structure of the sentence: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_synth_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['type'] as String,
      hint: 'Count the independent clauses and check what conjunction joins them!',
      stepWorking: [
        'Analyze clause count in: "${item['sent']}".',
        'Reasoning: ${item['reason']}',
        'The structural classification is "${item['type']}".',
      ],
      conceptTitle: 'Synthesis of Sentences (Simple, Compound, Complex)',
      conceptDetail: 'Sentences are classified by clause structure: Simple (1 independent), Compound (2+ independent), Complex (1 independent + 1+ dependent).',
      rule: 'FANBOYS conjunctions create Compound sentences; subordinating conjunctions create Complex sentences.',
      visualIcon: '🏗️',
    );
  }

  // =========================================================================
  // 17. Conditionals
  // =========================================================================
  Activity _generateConditionalsProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sent': 'If you heat water to 100°C, it ______ (boil).',
        'correct': 'boils',
        'options': ['boils', 'will boil', 'would boil', 'boiled'],
        'reason': 'Zero Conditional (scientific law): If + simple present, simple present.',
      },
      {
        'sent': 'If it rains this evening, we ______ (stay) indoors and read.',
        'correct': 'will stay',
        'options': ['will stay', 'stayed', 'would stay', 'would have stayed'],
        'reason': 'First Conditional (realistic future possibility): If + simple present, will + V1.',
      },
      {
        'sent': 'If I were a bird, I ______ (fly) across the seven seas.',
        'correct': 'would fly',
        'options': ['would fly', 'will fly', 'flew', 'would have flown'],
        'reason': 'Second Conditional (hypothetical/imaginary): If + past subjunctive ("were"), would + V1.',
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final prompt = 'Complete the conditional sentence: "${item['sent']}"';

    return _buildMcq(
      id: 'eng_cond_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: List<String>.from(item['options'] as List),
      correctAnswer: item['correct'] as String,
      hint: 'Is the condition a scientific fact (Zero), a real future chance (First), or an imaginary wish (Second)?',
      stepWorking: [
        'Examine the if-clause and main clause.',
        'Reasoning: ${item['reason']}',
        'The correct completion is "${item['correct']}".',
      ],
      conceptTitle: 'Conditionals (Zero, First, Second)',
      conceptDetail: 'Conditionals express causes and their outcomes under various degrees of reality.',
      rule: 'Zero = present + present. First = present + will. Second = past + would.',
      visualIcon: '🔀',
    );
  }

  // =========================================================================
  // 18. Vocabulary, Synonyms, Antonyms & Idioms
  // =========================================================================
  Activity _generateVocabularyProblem(Chapter ch, StudentClass sc, int idx) {
    final isAntonym = (idx % 2 == 1);
    if (isAntonym) {
      final pool = [
        {'word': 'Ancient', 'antonym': 'Modern', 'distractors': ['Old', 'Historic', 'Antique']},
        {'word': 'Courageous', 'antonym': 'Cowardly', 'distractors': ['Brave', 'Heroic', 'Bold']},
        {'word': 'Abundant', 'antonym': 'Scarce', 'distractors': ['Plentiful', 'Ample', 'Rich']},
        {'word': 'Optimistic', 'antonym': 'Pessimistic', 'distractors': ['Hopeful', 'Confident', 'Cheerful']},
        {'word': 'Trivial', 'antonym': 'Significant', 'distractors': ['Minor', 'Unimportant', 'Petty']},
      ];
      final item = pool[(idx - 1) % pool.length];
      final options = [item['antonym'] as String, ...(item['distractors'] as List<String>)];
      options.shuffle(_rng);

      final prompt = 'Which word is the ANTONYM (opposite) of "${item['word']}"?';
      return _buildMcq(
        id: 'eng_ant_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: item['antonym'] as String,
        hint: 'An antonym means the exact opposite!',
        stepWorking: [
          '"${item['word']}" expresses the quality of something.',
          'The exact opposite concept is "${item['antonym']}".',
        ],
        conceptTitle: 'Antonyms & Word Meanings',
        conceptDetail: 'Antonyms are words having opposite or contrasting meanings.',
        rule: 'An antonym must belong to the same part of speech as the original word.',
        visualIcon: '🧠',
      );
    } else {
      // Idiom
      final pool = [
        {
          'idiom': 'Bite the bullet',
          'meaning': 'Face a difficult situation with courage',
          'distractors': [
            'Chew on dangerous metal pieces',
            'Run away from danger swiftly',
            'Fire an antique weapon',
          ],
        },
        {
          'idiom': 'Piece of cake',
          'meaning': 'Something very easy to accomplish',
          'distractors': [
            'A sweet dessert served at a party',
            'A very complicated task',
            'A small portion of food',
          ],
        },
        {
          'idiom': 'Burn the midnight oil',
          'meaning': 'Work or study late into the night',
          'distractors': [
            'Start a campfire in the dark',
            'Waste valuable cooking oil',
            'Wake up very early in the morning',
          ],
        },
        {
          'idiom': 'See eye to eye',
          'meaning': 'Agree completely with someone',
          'distractors': [
            'Stare angrily into someone\'s eyes',
            'Visit an optician for glasses',
            'Dispute an argument strongly',
          ],
        },
      ];
      final item = pool[(idx - 1) % pool.length];
      final options = [item['meaning'] as String, ...(item['distractors'] as List<String>)];
      options.shuffle(_rng);

      final prompt = 'What is the figurative meaning of the idiom "${item['idiom']}"?';
      return _buildMcq(
        id: 'eng_idiom_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: item['meaning'] as String,
        hint: 'Never take an idiom literally: think of the figurative lesson behind it!',
        stepWorking: [
          'Examine the expression "${item['idiom']}".',
          'Idioms have symbolic meanings beyond individual words.',
          'The real meaning is "${item['meaning']}".',
        ],
        conceptTitle: 'Idioms and Figurative Language',
        conceptDetail: 'An idiom is an established expression whose meaning is not deducible from the individual words.',
        rule: 'Interpret idioms contextually and metaphorically rather than literally.',
        visualIcon: '💡',
      );
    }
  }

  // =========================================================================
  // 19. Subject and Predicate / Sentence Structure
  // =========================================================================
  Activity _generateSubjectPredicateProblem(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'sentence': 'The brave firefighter rescued the scared cat.',
        'subject': 'The brave firefighter',
        'predicate': 'rescued the scared cat',
        'object': 'the scared cat',
        'verb': 'rescued',
        'icon': '🚒',
      },
      {
        'sentence': 'My elder sister plays the violin beautifully.',
        'subject': 'My elder sister',
        'predicate': 'plays the violin beautifully',
        'object': 'the violin',
        'verb': 'plays',
        'icon': '🎻',
      },
      {
        'sentence': 'A flock of white swans flew across the azure sky.',
        'subject': 'A flock of white swans',
        'predicate': 'flew across the azure sky',
        'object': 'the azure sky',
        'verb': 'flew',
        'icon': '🦢',
      },
      {
        'sentence': 'The curious astronomer observed the distant galaxy.',
        'subject': 'The curious astronomer',
        'predicate': 'observed the distant galaxy',
        'object': 'the distant galaxy',
        'verb': 'observed',
        'icon': '🔭',
      },
      {
        'sentence': 'Heavy tropical rain poured down through the evening.',
        'subject': 'Heavy tropical rain',
        'predicate': 'poured down through the evening',
        'object': 'the evening',
        'verb': 'poured',
        'icon': '🌧️',
      },
      {
        'sentence': 'Our school basketball team won the championship trophy.',
        'subject': 'Our school basketball team',
        'predicate': 'won the championship trophy',
        'object': 'the championship trophy',
        'verb': 'won',
        'icon': '🏆',
      },
    ];

    final item = pool[(idx - 1) % pool.length];
    final askForSubject = (idx % 2 != 0);

    if (askForSubject) {
      final prompt = "Identify the SUBJECT in the sentence:\n\"${item['sentence']}\"";
      final correct = item['subject']!;
      final options = [
        item['subject']!,
        item['predicate']!,
        item['object']!,
        item['verb']!,
      ]..shuffle(_rng);

      return _buildMcq(
        id: 'eng_subj_${item['subject'].hashCode}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: correct,
        hint: 'Ask: Who or what performs the action or is the sentence about?',
        stepWorking: [
          'Find the action or verb in the sentence: "${item['verb']}".',
          'Ask "Who or what ${item['verb']}?": Answer is "${item['subject']}".',
          'Therefore, "${item['subject']}" is the complete subject.',
        ],
        conceptTitle: 'Subject and Predicate',
        conceptDetail: 'The Subject is the person, place, or thing performing the action. The Predicate contains the verb and tells what the subject does.',
        rule: 'The subject names who or what; the predicate contains the verb and completes the thought.',
        visualIcon: item['icon']!,
      );
    } else {
      final prompt = "Identify the PREDICATE in the sentence:\n\"${item['sentence']}\"";
      final correct = item['predicate']!;
      final options = [
        item['predicate']!,
        item['subject']!,
        item['object']!,
        item['verb']!,
      ]..shuffle(_rng);

      return _buildMcq(
        id: 'eng_pred_${item['predicate'].hashCode}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: prompt,
        ttsText: prompt,
        options: options,
        correctAnswer: correct,
        hint: 'The predicate starts with the verb and tells everything the subject is or does.',
        stepWorking: [
          'Identify the subject: "${item['subject']}".',
          'Everything else starting from the verb "${item['verb']}" is the predicate: "${item['predicate']}".',
          'Therefore, "${item['predicate']}" is the complete predicate.',
        ],
        conceptTitle: 'Subject and Predicate',
        conceptDetail: 'The Predicate tells what the subject does, feels, or experiences, including the main verb and modifiers.',
        rule: 'The predicate always contains the verb and expresses action or state of being.',
        visualIcon: item['icon']!,
      );
    }
  }

  // =========================================================================
  // Fallback: Generic High-Quality Concept Question from Chapter Notes
  // =========================================================================
  Activity _generateGenericEnglishProblem(Chapter ch, StudentClass sc, int idx) {
    final isKindergartenOrPrimary = sc == StudentClass.lkg ||
        sc == StudentClass.ukg ||
        sc == StudentClass.class1 ||
        sc == StudentClass.class2;

    String prompt;
    String correct;
    List<String> distractors;

    if (isKindergartenOrPrimary) {
      final kindergartenFallbackPool = [
        {
          'q': ch.exampleQuestion ?? 'Which of these is a fun learning activity?',
          'ans': ch.exampleAnswer ?? 'Reading fun picture books 📚',
          'distractors': ['Running on the busy road 🚗', 'Throwing hard stones 💥', 'Crying loudly 😭'],
        },
        {
          'q': 'What helps us speak English words happily?',
          'ans': 'Singing alphabet rhymes and songs 🎵',
          'distractors': ['Sleeping all day long 😴', 'Breaking crayons ✏️', 'Shouting loudly 📢'],
        },
        {
          'q': 'Which item helps us draw and trace neat letters?',
          'ans': 'Pencil & Paper 📝',
          'distractors': ['Spoon & Fork 🍴', 'Soap & Water 🧼', 'Shoe & Socks 👟'],
        },
      ];
      final item = kindergartenFallbackPool[(idx - 1) % kindergartenFallbackPool.length];
      prompt = item['q'] as String;
      correct = item['ans'] as String;
      distractors = List<String>.from(item['distractors'] as List);
    } else {
      final concept = ch.keyConcepts.isNotEmpty ? ch.keyConcepts[(idx - 1) % ch.keyConcepts.length] : ch.title;
      prompt = idx == 1 && ch.exampleQuestion != null
          ? ch.exampleQuestion!
          : 'Which principle relates directly to "$concept"?';
      correct = idx == 1 && ch.exampleAnswer != null
          ? ch.exampleAnswer!
          : concept;

      distractors = [];
      for (final kc in ch.keyConcepts) {
        if (kc != correct && distractors.length < 3) distractors.add(kc);
      }
      final fallbacks = sc.tier == GradeTier.primaryBuilder
          ? ['Proper Noun', 'Action Verb', 'Describing Word', 'Rhyming Word']
          : ['Adverbial Phrase', 'Coordinating Conjunction', 'Relative Pronoun', 'Independent Clause'];
      for (final fb in fallbacks) {
        if (fb != correct && !distractors.contains(fb) && distractors.length < 3) {
          distractors.add(fb);
        }
      }
    }

    final options = <String>[correct];
    for (final d in distractors) {
      if (d != correct && options.length < 4) {
        options.add(d);
      }
    }
    options.shuffle(_rng);

    final rule = ch.rules.isNotEmpty ? ch.rules[(idx - 1) % ch.rules.length] : 'Follow standard language and grammar rules.';

    return _buildMcq(
      id: 'eng_gen_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: prompt,
      ttsText: prompt,
      options: options,
      correctAnswer: correct,
      hint: rule,
      stepWorking: [
        'Focus on the chapter theme: "${ch.title}".',
        'Review the key lesson: "$rule".',
        'The correct answer is "$correct".',
      ],
      conceptTitle: '${ch.title} Concept',
      conceptDetail: ch.description.isNotEmpty ? ch.description : 'Mastering key language principles in English.',
      rule: rule,
      visualIcon: ch.icon,
    );
  }

  // =========================================================================
  // Helper: Constructs a complete Activity model with StepHints and payload
  // =========================================================================
  Activity _buildMcq({
    required String id,
    required Chapter chapter,
    required StudentClass studentClass,
    required String promptText,
    required String ttsText,
    required List<String> options,
    required String correctAnswer,
    required String hint,
    required List<String> stepWorking,
    required String conceptTitle,
    required String conceptDetail,
    required String rule,
    required String visualIcon,
  }) {
    final steps = <StepHint>[];
    for (int i = 0; i < stepWorking.length; i++) {
      steps.add(StepHint(stepIndex: i + 1, hintText: stepWorking[i]));
    }

    return Activity(
      activityId: id,
      topicId: chapter.chapterId,
      subjectId: 'english',
      targetGrade: studentClass.label,
      gradeTier: studentClass.tier,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(
        text: promptText,
        ttsFallback: ttsText,
      ),
      interactionPayload: {
        'question': promptText,
        'options': options,
        'correctAnswer': correctAnswer,
        'finalResult': correctAnswer,
        'hint': hint,
        'stepWorking': stepWorking,
        'conceptTitle': conceptTitle,
        'conceptDetail': conceptDetail,
        'rules': [rule],
        'visualIcon': visualIcon,
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: correctAnswer,
        hintTree: steps,
      ),
    );
  }

  // =========================================================================
  // Early Explorer Interactive Generators (Bubble Pop Engine)
  // =========================================================================

  Activity _buildBubblePop({
    required String id,
    required Chapter chapter,
    required StudentClass studentClass,
    required String promptText,
    required String ttsText,
    required dynamic targetValue,
    required List<Map<String, dynamic>> bubbles,
    required String visualIcon,
  }) {
    final correctBubbleIds = bubbles
        .where((b) => b['value'].toString().toLowerCase().trim() == targetValue.toString().toLowerCase().trim())
        .map((b) => b['id'] as String)
        .toList();

    return Activity(
      activityId: id,
      topicId: chapter.chapterId,
      subjectId: 'english',
      targetGrade: studentClass.label,
      gradeTier: studentClass.tier,
      activityType: ActivityType.bubblePop,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(
        text: promptText,
        ttsFallback: ttsText,
      ),
      interactionPayload: {
        'targetValue': targetValue,
        'topicTitle': chapter.title,
        'visualIcon': visualIcon,
        'bubbles': bubbles,
        'hint': 'Listen closely and tap the matching bubbles!',
        'stepWorking': [
          'Listen to the prompt: "$promptText"',
          'Find and pop all bubbles with $targetValue',
        ],
        'conceptTitle': chapter.title,
        'conceptDetail': chapter.description,
        'rules': chapter.rules,
      },
      validationRule: ValidationRule(
        format: 'bubble_pop',
        expectedAnswer: correctBubbleIds,
        hintTree: [
          StepHint(stepIndex: 1, hintText: 'Listen to the prompt: "$promptText"'),
          StepHint(stepIndex: 2, hintText: 'Pop all bubbles that match $targetValue!'),
        ],
      ),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }

  Activity _generateLkgPhonicsBubblePop(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'letter': 'A',
        'icon': '🍎',
        'correct': [
          {'label': 'A 🍎', 'val': 'A'},
          {'label': 'A 🐜', 'val': 'A'},
          {'label': 'A ✈️', 'val': 'A'},
        ],
        'distractors': [
          {'label': 'B ⚽', 'val': 'B'},
          {'label': 'C 🐱', 'val': 'C'},
          {'label': 'D 🐶', 'val': 'D'},
        ],
      },
      {
        'letter': 'B',
        'icon': '⚽',
        'correct': [
          {'label': 'B ⚽', 'val': 'B'},
          {'label': 'B 🐻', 'val': 'B'},
          {'label': 'B 🍌', 'val': 'B'},
        ],
        'distractors': [
          {'label': 'S ☀️', 'val': 'S'},
          {'label': 'M 🌙', 'val': 'M'},
          {'label': 'T 🌴', 'val': 'T'},
        ],
      },
      {
        'letter': 'C',
        'icon': '🐱',
        'correct': [
          {'label': 'C 🐱', 'val': 'C'},
          {'label': 'C ☕', 'val': 'C'},
          {'label': 'C 🚗', 'val': 'C'},
        ],
        'distractors': [
          {'label': 'A 🍎', 'val': 'A'},
          {'label': 'P 🐼', 'val': 'P'},
          {'label': 'D 🐶', 'val': 'D'},
        ],
      },
      {
        'letter': 'S',
        'icon': '☀️',
        'correct': [
          {'label': 'S ☀️', 'val': 'S'},
          {'label': 'S 🐍', 'val': 'S'},
          {'label': 'S ⭐', 'val': 'S'},
        ],
        'distractors': [
          {'label': 'M 🌙', 'val': 'M'},
          {'label': 'B ⚽', 'val': 'B'},
          {'label': 'A 🍎', 'val': 'A'},
        ],
      },
      {
        'letter': 'M',
        'icon': '🌙',
        'correct': [
          {'label': 'M 🌙', 'val': 'M'},
          {'label': 'M 🥭', 'val': 'M'},
          {'label': 'M 🐒', 'val': 'M'},
        ],
        'distractors': [
          {'label': 'N 🪺', 'val': 'N'},
          {'label': 'F 🐟', 'val': 'F'},
          {'label': 'W 🌊', 'val': 'W'},
        ],
      },
      {
        'letter': 'D',
        'icon': '🐶',
        'correct': [
          {'label': 'D 🐶', 'val': 'D'},
          {'label': 'D 🦆', 'val': 'D'},
          {'label': 'D 🥁', 'val': 'D'},
        ],
        'distractors': [
          {'label': 'B ⚽', 'val': 'B'},
          {'label': 'T 🌴', 'val': 'T'},
          {'label': 'P 🐼', 'val': 'P'},
        ],
      },
    ];

    final item = pool[(idx - 1) % pool.length];
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];
    int bIdx = 1;

    for (final c in (item['correct'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': c['label']!,
        'value': c['val']!,
        'displayType': 'letter',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    for (final d in (item['distractors'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': d['label']!,
        'value': d['val']!,
        'displayType': 'letter',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    bubbles.shuffle(_rng);

    final letter = item['letter'] as String;
    final icon = item['icon'] as String;

    return _buildBubblePop(
      id: 'eng_bubble_phon_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop all bubbles with the letter $letter! $icon',
      ttsText: 'Pop all bubbles with the letter $letter!',
      targetValue: letter,
      bubbles: bubbles,
      visualIcon: icon,
    );
  }

  Activity _generateLkgRhymingBubblePop(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'word': 'CAT',
        'icon': '🐱',
        'target': 'rhyme_cat',
        'correct': [
          {'label': 'HAT 🎩', 'val': 'rhyme_cat'},
          {'label': 'BAT 🦇', 'val': 'rhyme_cat'},
          {'label': 'MAT 🧘', 'val': 'rhyme_cat'},
        ],
        'distractors': [
          {'label': 'DOG 🐶', 'val': 'dog'},
          {'label': 'SUN ☀️', 'val': 'sun'},
          {'label': 'PIG 🐷', 'val': 'pig'},
        ],
      },
      {
        'word': 'PIN',
        'icon': '📌',
        'target': 'rhyme_pin',
        'correct': [
          {'label': 'WIN 🏆', 'val': 'rhyme_pin'},
          {'label': 'BIN 🗑️', 'val': 'rhyme_pin'},
          {'label': 'TIN 🥫', 'val': 'rhyme_pin'},
        ],
        'distractors': [
          {'label': 'CUP ☕', 'val': 'cup'},
          {'label': 'BED 🛏️', 'val': 'bed'},
          {'label': 'BUS 🚌', 'val': 'bus'},
        ],
      },
      {
        'word': 'SUN',
        'icon': '☀️',
        'target': 'rhyme_sun',
        'correct': [
          {'label': 'RUN 🏃', 'val': 'rhyme_sun'},
          {'label': 'FUN 🎉', 'val': 'rhyme_sun'},
          {'label': 'BUN 🥐', 'val': 'rhyme_sun'},
        ],
        'distractors': [
          {'label': 'CAT 🐱', 'val': 'cat'},
          {'label': 'CAR 🚗', 'val': 'car'},
          {'label': 'TOP 🪀', 'val': 'top'},
        ],
      },
      {
        'word': 'HOP',
        'icon': '🐰',
        'target': 'rhyme_hop',
        'correct': [
          {'label': 'MOP 🧹', 'val': 'rhyme_hop'},
          {'label': 'TOP 🪀', 'val': 'rhyme_hop'},
          {'label': 'POP 🎈', 'val': 'rhyme_hop'},
        ],
        'distractors': [
          {'label': 'FISH 🐟', 'val': 'fish'},
          {'label': 'PEN 🖊️', 'val': 'pen'},
          {'label': 'COW 🐮', 'val': 'cow'},
        ],
      },
      {
        'word': 'BED',
        'icon': '🛏️',
        'target': 'rhyme_bed',
        'correct': [
          {'label': 'RED 🔴', 'val': 'rhyme_bed'},
          {'label': 'FED 🍼', 'val': 'rhyme_bed'},
          {'label': 'LED 💡', 'val': 'rhyme_bed'},
        ],
        'distractors': [
          {'label': 'MAT 🧘', 'val': 'mat'},
          {'label': 'BUS 🚌', 'val': 'bus'},
          {'label': 'CUP ☕', 'val': 'cup'},
        ],
      },
    ];

    final item = pool[(idx - 1) % pool.length];
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];
    int bIdx = 1;

    for (final c in (item['correct'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': c['label']!,
        'value': c['val']!,
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    for (final d in (item['distractors'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': d['label']!,
        'value': d['val']!,
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    bubbles.shuffle(_rng);

    final word = item['word'] as String;
    final icon = item['icon'] as String;
    final target = item['target'] as String;

    return _buildBubblePop(
      id: 'eng_bubble_rhyme_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop all words that rhyme with $word! $icon',
      ttsText: 'Pop all words that rhyme with $word!',
      targetValue: target,
      bubbles: bubbles,
      visualIcon: icon,
    );
  }

  Activity _generateLkgShapesLettersBubblePop(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'title': 'round circle letters like O',
        'tts': 'round circle letters like O',
        'target': 'round',
        'icon': '🍩',
        'correct': [
          {'label': 'O 🍩', 'val': 'round'},
          {'label': 'C 🌙', 'val': 'round'},
          {'label': 'Q 🎈', 'val': 'round'},
        ],
        'distractors': [
          {'label': 'T 🌴', 'val': 'straight'},
          {'label': 'L 📏', 'val': 'straight'},
          {'label': 'I ✏️', 'val': 'straight'},
        ],
      },
      {
        'title': 'straight line letters like T & L',
        'tts': 'straight line letters like T and L',
        'target': 'straight',
        'icon': '📏',
        'correct': [
          {'label': 'T 🌴', 'val': 'straight'},
          {'label': 'L 📏', 'val': 'straight'},
          {'label': 'H 🪜', 'val': 'straight'},
        ],
        'distractors': [
          {'label': 'O 🍩', 'val': 'round'},
          {'label': 'S 🐍', 'val': 'curve'},
          {'label': 'C 🌙', 'val': 'round'},
        ],
      },
      {
        'title': 'slanting line letters like A & V',
        'tts': 'slanting line letters like A and V',
        'target': 'slant',
        'icon': '📐',
        'correct': [
          {'label': 'A 🔺', 'val': 'slant'},
          {'label': 'V ✌️', 'val': 'slant'},
          {'label': 'X ✖️', 'val': 'slant'},
        ],
        'distractors': [
          {'label': 'B ⚽', 'val': 'curve'},
          {'label': 'D 🚪', 'val': 'straight'},
          {'label': 'P 🅿️', 'val': 'straight'},
        ],
      },
      {
        'title': 'curvy wave letters like S & U',
        'tts': 'curvy wave letters like S and U',
        'target': 'curve',
        'icon': '🐍',
        'correct': [
          {'label': 'S 🐍', 'val': 'curve'},
          {'label': 'B 🧸', 'val': 'curve'},
          {'label': 'U 🧲', 'val': 'curve'},
        ],
        'distractors': [
          {'label': 'T 🌴', 'val': 'straight'},
          {'label': 'L 📏', 'val': 'straight'},
          {'label': 'I ✏️', 'val': 'straight'},
        ],
      },
    ];

    final item = pool[(idx - 1) % pool.length];
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];
    int bIdx = 1;

    for (final c in (item['correct'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': c['label']!,
        'value': c['val']!,
        'displayType': 'letter',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    for (final d in (item['distractors'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': d['label']!,
        'value': d['val']!,
        'displayType': 'letter',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    bubbles.shuffle(_rng);

    final title = item['title'] as String;
    final tts = item['tts'] as String;
    final target = item['target'] as String;
    final icon = item['icon'] as String;

    return _buildBubblePop(
      id: 'eng_bubble_shapes_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop the $title! $icon',
      ttsText: 'Pop the $tts!',
      targetValue: target,
      bubbles: bubbles,
      visualIcon: icon,
    );
  }

  Activity _generateLkgActionWordsBubblePop(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'prompt': 'Pop all the action words! 🏃',
        'tts': 'Pop all the action words!',
        'target': 'action',
        'icon': '🏃',
        'correct': [
          {'label': 'JUMP 🦘', 'val': 'action'},
          {'label': 'CLAP 👏', 'val': 'action'},
          {'label': 'DANCE 💃', 'val': 'action'},
        ],
        'distractors': [
          {'label': 'TREE 🌳', 'val': 'thing'},
          {'label': 'BOOK 📖', 'val': 'thing'},
          {'label': 'SPOON 🥄', 'val': 'thing'},
        ],
      },
      {
        'prompt': 'Pop what happy feet can do! 👟',
        'tts': 'Pop what happy feet can do!',
        'target': 'feet',
        'icon': '👟',
        'correct': [
          {'label': 'RUN 🏃', 'val': 'feet'},
          {'label': 'HOP 🐰', 'val': 'feet'},
          {'label': 'SKIP 🦘', 'val': 'feet'},
        ],
        'distractors': [
          {'label': 'PENCIL ✏️', 'val': 'thing'},
          {'label': 'CUP ☕', 'val': 'thing'},
          {'label': 'HAT 🎩', 'val': 'thing'},
        ],
      },
      {
        'prompt': 'Pop what joyful hands can do! ✋',
        'tts': 'Pop what joyful hands can do!',
        'target': 'hands',
        'icon': '✋',
        'correct': [
          {'label': 'CLAP 👏', 'val': 'hands'},
          {'label': 'WAVE 👋', 'val': 'hands'},
          {'label': 'CATCH ⚾', 'val': 'hands'},
        ],
        'distractors': [
          {'label': 'SHOE 👟', 'val': 'thing'},
          {'label': 'APPLE 🍎', 'val': 'thing'},
          {'label': 'CAR 🚗', 'val': 'thing'},
        ],
      },
      {
        'prompt': 'Pop what a happy face can do! 😊',
        'tts': 'Pop what a happy face can do!',
        'target': 'face',
        'icon': '😊',
        'correct': [
          {'label': 'SMILE 😊', 'val': 'face'},
          {'label': 'LAUGH 😄', 'val': 'face'},
          {'label': 'SING 🎤', 'val': 'face'},
        ],
        'distractors': [
          {'label': 'CHAIR 🪑', 'val': 'thing'},
          {'label': 'BALL ⚽', 'val': 'thing'},
          {'label': 'DOOR 🚪', 'val': 'thing'},
        ],
      },
    ];

    final item = pool[(idx - 1) % pool.length];
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];
    int bIdx = 1;

    for (final c in (item['correct'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': c['label']!,
        'value': c['val']!,
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    for (final d in (item['distractors'] as List<Map<String, String>>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': d['label']!,
        'value': d['val']!,
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    bubbles.shuffle(_rng);

    return _buildBubblePop(
      id: 'eng_bubble_act_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: item['prompt'] as String,
      ttsText: item['tts'] as String,
      targetValue: item['target'] as String,
      bubbles: bubbles,
      visualIcon: item['icon'] as String,
    );
  }

  Activity _generateLkgOppositesBubblePop(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'word': 'UP ⬆️',
        'tts': 'Up',
        'opposite': 'DOWN',
        'oppositeLabel': 'DOWN ⬇️',
        'icon': '⬆️',
        'distractors': ['BIG 🐘', 'HOT ☀️', 'HAPPY 😄', 'FAST 🚀'],
      },
      {
        'word': 'BIG 🐘',
        'tts': 'Big',
        'opposite': 'SMALL',
        'oppositeLabel': 'SMALL 🐭',
        'icon': '🐘',
        'distractors': ['UP ⬆️', 'COLD ❄️', 'FAST 🚀', 'DAY 🌅'],
      },
      {
        'word': 'HOT ☀️',
        'tts': 'Hot',
        'opposite': 'COLD',
        'oppositeLabel': 'COLD ❄️',
        'icon': '☀️',
        'distractors': ['DOWN ⬇️', 'BIG 🐘', 'DAY 🌅', 'HAPPY 😄'],
      },
      {
        'word': 'DAY ☀️',
        'tts': 'Day',
        'opposite': 'NIGHT',
        'oppositeLabel': 'NIGHT 🌙',
        'icon': '☀️',
        'distractors': ['SMALL 🐭', 'HOT ☀️', 'FAST 🚀', 'UP ⬆️'],
      },
      {
        'word': 'HAPPY 😄',
        'tts': 'Happy',
        'opposite': 'SAD',
        'oppositeLabel': 'SAD 😢',
        'icon': '😄',
        'distractors': ['UP ⬆️', 'COLD ❄️', 'DOWN ⬇️', 'BIG 🐘'],
      },
      {
        'word': 'IN 📥',
        'tts': 'In',
        'opposite': 'OUT',
        'oppositeLabel': 'OUT 📤',
        'icon': '📥',
        'distractors': ['DAY ☀️', 'BIG 🐘', 'HOT ☀️', 'FAST 🚀'],
      },
      {
        'word': 'FAST 🚀',
        'tts': 'Fast',
        'opposite': 'SLOW',
        'oppositeLabel': 'SLOW 🐢',
        'icon': '🚀',
        'distractors': ['DOWN ⬇️', 'HAPPY 😄', 'IN 📥', 'HOT ☀️'],
      },
      {
        'word': 'OPEN 🚪',
        'tts': 'Open',
        'opposite': 'CLOSE',
        'oppositeLabel': 'CLOSE 🔒',
        'icon': '🚪',
        'distractors': ['BIG 🐘', 'UP ⬆️', 'FAST 🚀', 'HOT ☀️'],
      },
    ];

    final item = pool[(idx - 1) % pool.length];
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];
    int bIdx = 1;

    final oppVal = item['opposite'] as String;
    final oppLabel = item['oppositeLabel'] as String;
    for (int i = 0; i < 3; i++) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': oppLabel,
        'value': oppVal,
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    final dists = (item['distractors'] as List<String>);
    for (int i = 0; i < 3; i++) {
      final d = dists[i % dists.length];
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': d,
        'value': d.split(' ')[0],
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    bubbles.shuffle(_rng);

    final word = item['word'] as String;
    final tts = item['tts'] as String;

    return _buildBubblePop(
      id: 'eng_bubble_opp_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop the opposite of $word!',
      ttsText: 'Pop the opposite of $tts!',
      targetValue: oppVal,
      bubbles: bubbles,
      visualIcon: item['icon'] as String,
    );
  }

  Activity _generateUkgVowelsBubblePop(Chapter ch, StudentClass sc, int idx) {
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final vowels = ['A 🍎', 'E 🥚', 'I 🍦', 'O 🍩', 'U ☂️'];
    final consonants = ['B ⚽', 'C 🐱', 'D 🐶', 'F 🐟', 'G 🍇', 'H 🪜', 'T 🌴', 'S ☀️'];
    final targetVowel = vowels[(idx - 1) % vowels.length];
    final targetVal = targetVowel.split(' ')[0];

    final bubbles = <Map<String, dynamic>>[];
    bubbles.add({'id': 'b_1', 'label': targetVowel, 'value': targetVal, 'displayType': 'letter', 'color': colors[0]});
    bubbles.add({'id': 'b_2', 'label': targetVowel, 'value': targetVal, 'displayType': 'letter', 'color': colors[1]});
    bubbles.add({'id': 'b_3', 'label': targetVowel, 'value': targetVal, 'displayType': 'letter', 'color': colors[2]});

    for (int i = 0; i < 3; i++) {
      final c = consonants[(idx + i) % consonants.length];
      bubbles.add({'id': 'b_${4 + i}', 'label': c, 'value': c.split(' ')[0], 'displayType': 'letter', 'color': colors[3 + i]});
    }
    bubbles.shuffle(_rng);

    return _buildBubblePop(
      id: 'eng_bubble_vow_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop all bubbles with the Vowel $targetVowel!',
      ttsText: 'Pop all bubbles with the vowel $targetVal!',
      targetValue: targetVal,
      bubbles: bubbles,
      visualIcon: '🌟',
    );
  }

  Activity _generateUkgSightWordsBubblePop(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {'word': 'CAT 🐱', 'target': 'CAT', 'distractors': ['DOG 🐶', 'PIG 🐷', 'SUN ☀️']},
      {'word': 'PEN 🖊️', 'target': 'PEN', 'distractors': ['BOX 📦', 'HAT 🎩', 'CUP ☕']},
      {'word': 'SUN ☀️', 'target': 'SUN', 'distractors': ['CAT 🐱', 'BED 🛏️', 'PIN 📌']},
      {'word': 'PIG 🐷', 'target': 'PIG', 'distractors': ['RUN 🏃', 'FOX 🦊', 'BAT 🦇']},
    ];
    final item = pool[(idx - 1) % pool.length];
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];

    for (int i = 0; i < 3; i++) {
      bubbles.add({
        'id': 'b_${i + 1}',
        'label': item['word'] as String,
        'value': item['target'] as String,
        'displayType': 'word',
        'color': colors[i],
      });
    }
    final dists = item['distractors'] as List<String>;
    for (int i = 0; i < 3; i++) {
      bubbles.add({
        'id': 'b_${4 + i}',
        'label': dists[i],
        'value': dists[i].split(' ')[0],
        'displayType': 'word',
        'color': colors[3 + i],
      });
    }
    bubbles.shuffle(_rng);

    return _buildBubblePop(
      id: 'eng_bubble_cvc_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop the word ${item['word']}!',
      ttsText: 'Pop the word ${item['target']}!',
      targetValue: item['target'] as String,
      bubbles: bubbles,
      visualIcon: '👁️',
    );
  }

  Activity _generateUkgWordFamiliesBubblePop(Chapter ch, StudentClass sc, int idx) {
    final pool = [
      {
        'family': '-UG',
        'prompt': 'Pop words in the -UG family! ☕',
        'tts': 'Pop words in the ug family!',
        'target': 'ug',
        'correct': ['MUG ☕', 'BUG 🐛', 'JUG 🏺'],
        'distractors': ['CAT 🐱', 'PIN 📌', 'BED 🛏️'],
      },
      {
        'family': '-AT',
        'prompt': 'Pop words in the -AT family! 🐱',
        'tts': 'Pop words in the at family!',
        'target': 'at',
        'correct': ['CAT 🐱', 'BAT 🦇', 'HAT 🎩'],
        'distractors': ['DOG 🐶', 'SUN ☀️', 'PEN 🖊️'],
      },
      {
        'family': '-IN',
        'prompt': 'Pop words in the -IN family! 📌',
        'tts': 'Pop words in the in family!',
        'target': 'in',
        'correct': ['PIN 📌', 'BIN 🗑️', 'WIN 🏆'],
        'distractors': ['CUP ☕', 'HOP 🐰', 'RED 🔴'],
      },
    ];
    final item = pool[(idx - 1) % pool.length];
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];
    int bIdx = 1;

    for (final c in (item['correct'] as List<String>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': c,
        'value': item['target'] as String,
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    for (final d in (item['distractors'] as List<String>)) {
      bubbles.add({
        'id': 'b_${bIdx++}',
        'label': d,
        'value': d.split(' ')[0],
        'displayType': 'word',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }
    bubbles.shuffle(_rng);

    return _buildBubblePop(
      id: 'eng_bubble_fam_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: item['prompt'] as String,
      ttsText: item['tts'] as String,
      targetValue: item['target'] as String,
      bubbles: bubbles,
      visualIcon: '🏠',
    );
  }

  Activity _generateGenericEarlyExplorerBubblePop(Chapter ch, StudentClass sc, int idx) {
    final colors = ['#4ADE80', '#FBBF24', '#60A5FA', '#F472B6', '#A78BFA', '#38BDF8'];
    final bubbles = <Map<String, dynamic>>[];
    final letters = ['A 🍎', 'B ⚽', 'C 🐱', 'D 🐶', 'S ☀️', 'M 🌙'];
    final targetLetter = letters[(idx - 1) % letters.length];
    final targetVal = targetLetter.split(' ')[0];

    bubbles.add({
      'id': 'b_1',
      'label': targetLetter,
      'value': targetVal,
      'displayType': 'letter',
      'color': colors[0],
    });
    bubbles.add({
      'id': 'b_2',
      'label': targetLetter,
      'value': targetVal,
      'displayType': 'letter',
      'color': colors[1],
    });

    int bIdx = 3;
    for (final l in letters) {
      if (l != targetLetter && bubbles.length < 6) {
        bubbles.add({
          'id': 'b_${bIdx++}',
          'label': l,
          'value': l.split(' ')[0],
          'displayType': 'letter',
          'color': colors[_rng.nextInt(colors.length)],
        });
      }
    }
    bubbles.shuffle(_rng);

    return _buildBubblePop(
      id: 'eng_bubble_gen_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop the bubbles with $targetLetter!',
      ttsText: 'Pop the bubbles with letter $targetVal!',
      targetValue: targetVal,
      bubbles: bubbles,
      visualIcon: '🌟',
    );
  }
}
