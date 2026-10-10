import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/activity_model.dart';
import '../models/chapter_model.dart';
import '../models/grade_tier.dart';
import '../models/student_profile.dart';
import '../models/subject_model.dart';
import '../local/local_storage_service.dart';
import '../services/english_question_generator.dart';
import '../services/hindi_question_generator.dart';
import '../services/literature_reading_service.dart';
import '../services/procedural_question_generator.dart';
import '../services/science_question_generator.dart';

abstract class ICurriculumRepository {
  Future<List<Subject>> getSubjects({StudentClass? studentClass});
  Future<List<Chapter>> getChaptersForClass(
    StudentClass studentClass, {
    BoardType? board,
    String subjectId = 'math',
    String? publisher,
    String? track,
  });
  List<Map<String, String>> getAvailablePublishers({
    required String subjectId,
    required StudentClass studentClass,
    required BoardType board,
  });
  Future<List<Activity>> getActivities({
    String? subjectId,
    GradeTier? tier,
    StudentClass? studentClass,
    String? chapterId,
  });
  Future<Activity?> getActivityById(String activityId);
  List<Activity> generateExtraActivities(StudentClass studentClass, {int count = 5});
  List<Activity> generateActivitiesForChapter(
    String chapterId,
    StudentClass studentClass, {
    int count = 3,
    Chapter? chapter,
    Set<String> existingPromptTexts = const {},
  });
}

class CurriculumRepository implements ICurriculumRepository {
  static final CurriculumRepository instance = CurriculumRepository();

  static List<Activity>? _cachedActivities;
  static List<Chapter>? _cachedChapters;
  static List<Chapter>? _cachedEnglishChapters;
  static List<Chapter>? _cachedScienceChapters;
  static List<Chapter>? _cachedEvsChapters;
  static List<Chapter>? _cachedHindiChapters;
  static final List<Activity> _dynamicallyGeneratedActivities = [];

  /// Defines which grades each subject is officially available for in the syllabus.
  /// Mathematics: LKG to Class 8
  /// English: LKG to Class 8
  /// Hindi: LKG to Class 8 (Universal Core Language CBSE/ICSE)
  /// EVS: LKG to Class 5 (Foundational & Primary Environmental Studies)
  /// Science: Class 3 to Class 8 (Standard CBSE & ICSE syllabus)
  static const Map<String, List<StudentClass>> subjectClassAvailability = {
    'math': StudentClass.values,
    'english': StudentClass.values,
    'hindi': StudentClass.values,
    'evs': [
      StudentClass.lkg,
      StudentClass.ukg,
      StudentClass.class1,
      StudentClass.class2,
      StudentClass.class3,
      StudentClass.class4,
      StudentClass.class5,
    ],
    'science': [
      StudentClass.class3,
      StudentClass.class4,
      StudentClass.class5,
      StudentClass.class6,
      StudentClass.class7,
      StudentClass.class8,
    ],
  };

  /// Returns true if the given subject is part of the curriculum for the student's class.
  static bool isSubjectAvailableForClass(String subjectId, StudentClass studentClass) {
    final available = subjectClassAvailability[subjectId.toLowerCase()];
    if (available == null) return true;
    return available.contains(studentClass);
  }

  @override
  Future<List<Subject>> getSubjects({StudentClass? studentClass}) async {
    const all = [
      Subject(
        id: 'math',
        name: 'Curio Mathematics',
        iconRef: 'assets/icons/math.svg',
        primaryColorHex: 0xFFFF7B25,
        secondaryColorHex: 0xFFFFB800,
        description: 'Explore numbers, shapes, fractions, and algebra!',
      ),
      Subject(
        id: 'english',
        name: 'Curio English',
        iconRef: 'assets/icons/english.svg',
        primaryColorHex: 0xFF6366F1,
        secondaryColorHex: 0xFF818CF8,
        description: 'Phonics, vocabulary, grammar, and creative writing!',
        isEnabled: true,
      ),
      Subject(
        id: 'hindi',
        name: 'Curio Hindi (हिन्दी)',
        iconRef: 'assets/icons/hindi.svg',
        primaryColorHex: 0xFFEA580C,
        secondaryColorHex: 0xFFF97316,
        description: 'वर्णमाला, व्याकरण, शब्द-बोध और ज्ञानवर्धक कहानियाँ!',
        isEnabled: true,
      ),
      Subject(
        id: 'evs',
        name: 'Curio EVS',
        iconRef: 'assets/icons/evs.svg',
        primaryColorHex: 0xFF059669,
        secondaryColorHex: 0xFF10B981,
        description: 'Explore nature, our body, plants, animals, and environment!',
        isEnabled: true,
      ),
      Subject(
        id: 'science',
        name: 'Curio Science',
        iconRef: 'assets/icons/science.svg',
        primaryColorHex: 0xFF10B981,
        secondaryColorHex: 0xFF34D399,
        description: 'Living worlds, chemistry, astronomy, and physics!',
        isEnabled: true,
      ),
    ];

    if (studentClass == null) return all;
    return all.where((s) => isSubjectAvailableForClass(s.id, studentClass)).toList();
  }

  Future<void> _ensureLoaded() async {
    if (_cachedActivities == null) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/curriculum/math_sample.json');
        final dynamic parsed = json.decode(jsonString);
        if (parsed is List) {
          _cachedActivities = parsed
              .map((item) => Activity.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _cachedActivities = [];
        }
      } catch (e) {
        _cachedActivities = [];
      }
    }

    if (_cachedChapters == null) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/curriculum/math_chapters.json');
        final dynamic parsed = json.decode(jsonString);
        if (parsed is List) {
          _cachedChapters = parsed
              .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _cachedChapters = [];
        }
      } catch (e) {
        _cachedChapters = [];
      }
    }
    if (_cachedEnglishChapters == null) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/curriculum/english_chapters.json');
        final dynamic parsed = json.decode(jsonString);
        if (parsed is List) {
          _cachedEnglishChapters = parsed
              .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _cachedEnglishChapters = [];
        }
      } catch (e) {
        _cachedEnglishChapters = [];
      }
    }
    if (_cachedScienceChapters == null) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/curriculum/science_chapters.json');
        final dynamic parsed = json.decode(jsonString);
        if (parsed is List) {
          _cachedScienceChapters = parsed
              .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _cachedScienceChapters = [];
        }
      } catch (e) {
        _cachedScienceChapters = [];
      }
    }
    if (_cachedEvsChapters == null) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/curriculum/evs_chapters.json');
        final dynamic parsed = json.decode(jsonString);
        if (parsed is List) {
          _cachedEvsChapters = parsed
              .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _cachedEvsChapters = [];
        }
      } catch (e) {
        _cachedEvsChapters = [];
      }
    }
    if (_cachedHindiChapters == null) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/curriculum/hindi_chapters.json');
        final dynamic parsed = json.decode(jsonString);
        if (parsed is List) {
          _cachedHindiChapters = parsed
              .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _cachedHindiChapters = [];
        }
      } catch (e) {
        _cachedHindiChapters = [];
      }
    }
    await LiteratureReadingService.instance.init();
  }

  @override
  List<Map<String, String>> getAvailablePublishers({
    required String subjectId,
    required StudentClass studentClass,
    required BoardType board,
  }) {
    if (studentClass == StudentClass.class4) {
      if (subjectId == 'hindi') {
        return [
          {
            'id': 'miranda',
            'name': 'Miranda Publisher',
            'book': 'मृदुला हिंदी पाठ्य पुस्तक 4',
            'badge': 'ICSE 📚',
          },
          {
            'id': 'ncert',
            'name': 'NCERT / CBSE',
            'book': 'रिमझिम भाग 4 (Rimjhim)',
            'badge': 'National 🇮🇳',
          },
          {
            'id': 'all',
            'name': 'सभी पाठ व कहानियाँ',
            'book': 'सम्पूर्ण पाठ्यपुस्तक पुस्तकालय',
            'badge': 'सभी 🌟',
          },
        ];
      }
    }
    return [];
  }

  @override
  Future<List<Chapter>> getChaptersForClass(
    StudentClass studentClass, {
    BoardType? board,
    String subjectId = 'math',
    String? publisher,
    String? track,
  }) async {
    // Return immediately if the subject is not part of this class syllabus
    if (!isSubjectAvailableForClass(subjectId, studentClass)) {
      return [];
    }

    await _ensureLoaded();

    final cleanClass = studentClass.label.toLowerCase().replaceAll(' ', '');
    final selectedBoard = board ?? BoardType.cbse;
    final boardCode = selectedBoard.code.toLowerCase();

    final sourceList = (subjectId == 'english')
        ? (_cachedEnglishChapters ?? [])
        : (subjectId == 'science')
            ? (_cachedScienceChapters ?? [])
            : (subjectId == 'evs')
                ? (_cachedEvsChapters ?? [])
                : (subjectId == 'hindi')
                    ? (_cachedHindiChapters ?? [])
                    : (_cachedChapters ?? []);

    final activePublisher = (subjectId == 'english')
        ? null
        : (publisher ?? LocalStorageService.instance.getPreferredPublisher(subjectId));

    var chapters = sourceList.where((ch) {
      final normChGrade = ch.grade.toLowerCase().replaceAll(' ', '').replaceAll('grade', 'class');
      final normCleanClass = cleanClass.replaceAll('grade', 'class');
      final gradeMatch = normChGrade == normCleanClass;
      if (!gradeMatch) return false;

      // 1. Language Track filtering
      if (track == 'grammar') {
        if (subjectId != 'english' && ch.publisher != 'grammar') return false;
        final chBoard = ch.board.toLowerCase();
        if (chBoard == 'all') return true;
        if (chBoard == boardCode) return true;
        if (selectedBoard == BoardType.stateBoard && chBoard == 'cbse') return true;
        if (subjectId == 'hindi') return true;
        return false;
      } else if (track == 'literature') {
        if (ch.publisher == 'grammar') return false;
        if (activePublisher != null && activePublisher != 'all') {
          return ch.publisher == activePublisher;
        }
        return true;
      }

      // 2. Direct Publisher filtering if requested
      if (activePublisher != null && activePublisher != 'all') {
        if (ch.publisher == activePublisher) return true;
        return false;
      }

      // 3. Default board filtering
      final chBoard = ch.board.toLowerCase();
      if (chBoard == 'all') return true;
      if (chBoard == boardCode) return true;
      if (selectedBoard == BoardType.stateBoard && chBoard == 'cbse') return true;
      if (subjectId == 'evs') return true; // EVS is universal foundational curriculum for all boards
      return false;
    }).toList();

    // Fallback: if track, publisher, or board filter returned 0 chapters, return available matching grade
    if (chapters.isEmpty) {
      chapters = sourceList.where((ch) {
        final normChGrade = ch.grade.toLowerCase().replaceAll(' ', '').replaceAll('grade', 'class');
        final normCleanClass = cleanClass.replaceAll('grade', 'class');
        if (normChGrade != normCleanClass) return false;
        if (track == 'grammar') return ch.publisher == 'grammar';
        final chBoard = ch.board.toLowerCase();
        if (chBoard == 'all' || chBoard == boardCode || (selectedBoard == BoardType.stateBoard && chBoard == 'cbse') || subjectId == 'evs') {
          return true;
        }
        return true; // Graceful fallback to available grade chapters
      }).toList();
    }

    // Attach activities to chapters
    final allActivities = [..._cachedActivities!, ..._dynamicallyGeneratedActivities];

    return chapters.map((ch) {
      // 1. Check local storage first
      final savedActivities = LocalStorageService.instance.getChapterActivities(ch.chapterId);
      if (savedActivities != null && savedActivities.isNotEmpty) {
        final hasLegacy = savedActivities.any((a) {
          if (a.promptData.text.contains('(Class') || a.promptData.text.contains('mathematically TRUE')) {
            return true;
          }
          // Discard activities from a different subject
          if (a.subjectId.isNotEmpty && ch.subjectId.isNotEmpty && a.subjectId != ch.subjectId) {
            return true;
          }
          if (ch.subjectId == 'english' && (a.subjectId == 'math' || a.activityId.startsWith('act_lkg_') || a.activityId.startsWith('act_ukg_'))) {
            return true;
          }
          if (ch.subjectId == 'math' && a.subjectId == 'english') {
            return true;
          }
          // Discard math activities accidentally cached under hindi, science, or evs
          if ((ch.subjectId == 'hindi' || ch.subjectId == 'science' || ch.subjectId == 'evs') &&
              (a.subjectId == 'math' ||
                  a.activityId.startsWith('math_') ||
                  a.activityId.startsWith('proc_') ||
                  a.promptData.text.contains('equal 5') ||
                  a.promptData.text.contains('mathematical') ||
                  a.promptData.text.contains('multiplying by zero') ||
                  a.promptData.text.contains('Count the items'))) {
            return true;
          }
          return false;
        });
        final prompts = savedActivities.map((a) => a.promptData.text.trim().toLowerCase()).toSet();
        final hasDuplicates = savedActivities.length > 1 && prompts.length < savedActivities.length;
        final isKindergarten = studentClass.isKindergarten;
        final hasInappropriateLkgDistractors = isKindergarten &&
            savedActivities.any((a) {
              final opts = (a.interactionPayload['options'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
              return opts.any((o) => o.contains('clause') || o.contains('predicate') || o.contains('prepositional'));
            });
        final hasBubbleWithOptions = isKindergarten &&
            savedActivities.any((a) =>
                a.activityType == ActivityType.bubblePop &&
                a.interactionPayload.containsKey('options'));
        final hasObsoleteBoilerplate = savedActivities.any((a) {
          final text = a.promptData.text.toLowerCase();
          return text.contains('elementary practice topic') ||
              text.contains('which foundational rule') ||
              text.contains('which core topic in') ||
              text.contains('what is the governing formula') ||
              text.contains('primary study focus of');
        });
        final hasOnlyBubblePop = isKindergarten &&
            savedActivities.every((a) => a.activityType == ActivityType.bubblePop);
        final hasMcqInKindergarten = isKindergarten &&
            savedActivities.any((a) => a.activityType == ActivityType.mcq);
        final isShortHindi = (ch.subjectId == 'hindi' || ch.chapterId.startsWith('hin_')) &&
            !isKindergarten &&
            savedActivities.length < 5;
        if (!hasLegacy && !hasDuplicates && !hasInappropriateLkgDistractors && !hasBubbleWithOptions && !hasObsoleteBoilerplate && !hasOnlyBubblePop && !hasMcqInKindergarten && !isShortHindi) {
          return ch.copyWith(activities: savedActivities);
        }
      }

      final chapterActivities = allActivities.where((act) {
        // Enforce strict subject match: an English chapter must never take Math activities, and vice versa
        if (act.subjectId.isNotEmpty && ch.subjectId.isNotEmpty && act.subjectId != ch.subjectId) {
          return false;
        }
        if (act.chapterId != null && act.chapterId == ch.chapterId) return true;
        // Fallback topic/grade matching only for matching subject
        final actGrade = act.targetGrade.toLowerCase().replaceAll(' ', '');
        return actGrade == cleanClass && (act.topicId.contains(ch.chapterId.split('_').last));
      }).toList();

      final isOnlyBubbleInSample = studentClass.isKindergarten &&
          chapterActivities.isNotEmpty &&
          chapterActivities.every((a) => a.activityType == ActivityType.bubblePop);
      final hasMcqInSample = studentClass.isKindergarten &&
          chapterActivities.any((a) => a.activityType == ActivityType.mcq);

      final needsHindiExpansion = (ch.subjectId == 'hindi' || ch.chapterId.startsWith('hin_')) &&
          !studentClass.isKindergarten &&
          chapterActivities.length < 5;

      // If chapter has < 3 activities, only bubble pop, or MCQs in kindergarten, generate early childhood games!
      if (chapterActivities.length < 3 || isOnlyBubbleInSample || hasMcqInSample || needsHindiExpansion) {
        final generated = _generateDefaultActivitiesForChapter(ch, studentClass, count: 5);
        _dynamicallyGeneratedActivities.addAll(generated);
        LocalStorageService.instance.saveChapterActivities(ch.chapterId, generated);
        return ch.copyWith(activities: generated);
      }

      LocalStorageService.instance.saveChapterActivities(ch.chapterId, chapterActivities);
      return ch.copyWith(activities: chapterActivities);
    }).toList();
  }

  List<Activity> _generateDefaultActivitiesForChapter(Chapter ch, StudentClass studentClass, {int count = 3}) {
    if (ch.subjectId == 'english' || ch.chapterId.startsWith('eng_')) {
      return EnglishQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        studentClass,
        count: count,
      );
    }
    if (ch.subjectId == 'hindi' || ch.chapterId.startsWith('hin_')) {
      return HindiQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        studentClass,
        count: count,
      );
    }
    if (ch.subjectId == 'science' || ch.chapterId.startsWith('sci_') || ch.subjectId == 'evs' || ch.chapterId.startsWith('evs_')) {
      return ScienceQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        studentClass,
        count: count,
      );
    }
    return ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
      ch,
      studentClass,
      count: count,
    );
  }

  @override
  Future<List<Activity>> getActivities({
    String? subjectId,
    GradeTier? tier,
    StudentClass? studentClass,
    String? chapterId,
  }) async {
    await _ensureLoaded();

    final all = [..._cachedActivities!, ..._dynamicallyGeneratedActivities];

    return all.where((activity) {
      if (subjectId != null && activity.subjectId != subjectId) return false;
      if (chapterId != null && activity.chapterId != chapterId) return false;
      if (studentClass != null) {
        final target = activity.targetGrade.toLowerCase().replaceAll(' ', '');
        final current = studentClass.label.toLowerCase().replaceAll(' ', '');
        if (!target.contains(current) && !current.contains(target)) {
          return false;
        }
      } else if (tier != null && activity.gradeTier != tier) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  List<Activity> generateExtraActivities(StudentClass studentClass, {int count = 5}) {
    final newActivities = ProceduralQuestionGenerator.instance
        .generatePlaylistForClass(studentClass, count: count);
    _dynamicallyGeneratedActivities.addAll(newActivities);
    return newActivities;
  }

  @override
  List<Activity> generateActivitiesForChapter(
    String chapterId,
    StudentClass studentClass, {
    int count = 3,
    Chapter? chapter,
    Set<String> existingPromptTexts = const {},
  }) {
    Chapter? matchingChapter = chapter;
    if (matchingChapter == null) {
      final allChapters = [
        ...?_cachedChapters,
        ...?_cachedEnglishChapters,
        ...?_cachedScienceChapters,
        ...?_cachedEvsChapters,
        ...?_cachedHindiChapters,
      ];
      try {
        matchingChapter = allChapters.firstWhere((ch) => ch.chapterId == chapterId);
      } catch (_) {}
    }
    matchingChapter ??= Chapter(
      chapterId: chapterId,
      chapterNumber: 1,
      title: 'Practice Challenge',
      grade: studentClass.label,
      subjectId: chapterId.startsWith('eng_')
          ? 'english'
          : chapterId.startsWith('hin_')
              ? 'hindi'
              : chapterId.startsWith('sci_')
                  ? 'science'
                  : chapterId.startsWith('evs_')
                      ? 'evs'
                      : 'math',
      icon: '✨',
    );

    if (matchingChapter.subjectId == 'english' || chapterId.startsWith('eng_')) {
      final list = EnglishQuestionGenerator.instance.generateActivitiesForChapter(
        matchingChapter,
        studentClass,
        count: count,
        existingPromptTexts: existingPromptTexts,
      );
      _dynamicallyGeneratedActivities.addAll(list);
      return list;
    }

    if (matchingChapter.subjectId == 'hindi' || chapterId.startsWith('hin_')) {
      final list = HindiQuestionGenerator.instance.generateActivitiesForChapter(
        matchingChapter,
        studentClass,
        count: count,
        existingPromptTexts: existingPromptTexts,
      );
      _dynamicallyGeneratedActivities.addAll(list);
      return list;
    }

    if (matchingChapter.subjectId == 'science' ||
        chapterId.startsWith('sci_') ||
        matchingChapter.subjectId == 'evs' ||
        chapterId.startsWith('evs_')) {
      final list = ScienceQuestionGenerator.instance.generateActivitiesForChapter(
        matchingChapter,
        studentClass,
        count: count,
        existingPromptTexts: existingPromptTexts,
      );
      _dynamicallyGeneratedActivities.addAll(list);
      return list;
    }

    final list = ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
      matchingChapter,
      studentClass,
      count: count,
      existingPromptTexts: existingPromptTexts,
    );
    _dynamicallyGeneratedActivities.addAll(list);
    return list;
  }

  @override
  Future<Activity?> getActivityById(String activityId) async {
    final list = await getActivities();
    try {
      return list.firstWhere((a) => a.activityId == activityId);
    } catch (_) {
      return null;
    }
  }
}
