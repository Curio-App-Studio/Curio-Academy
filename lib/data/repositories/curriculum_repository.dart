import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/activity_model.dart';
import '../models/chapter_model.dart';
import '../models/grade_tier.dart';
import '../models/student_profile.dart';
import '../models/subject_model.dart';
import '../local/local_storage_service.dart';
import '../services/english_question_generator.dart';
import '../services/procedural_question_generator.dart';

abstract class ICurriculumRepository {
  Future<List<Subject>> getSubjects();
  Future<List<Chapter>> getChaptersForClass(
    StudentClass studentClass, {
    BoardType? board,
    String subjectId = 'math',
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
  static List<Activity>? _cachedActivities;
  static List<Chapter>? _cachedChapters;
  static List<Chapter>? _cachedEnglishChapters;
  static final List<Activity> _dynamicallyGeneratedActivities = [];

  @override
  Future<List<Subject>> getSubjects() async {
    return const [
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
        id: 'science',
        name: 'Curio Science',
        iconRef: 'assets/icons/science.svg',
        primaryColorHex: 0xFF10B981,
        secondaryColorHex: 0xFF34D399,
        description: 'Living worlds, chemistry, astronomy, and physics!',
        isEnabled: false,
      ),
    ];
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
            await rootBundle.loadString('assets/curriculum/chapters_data.json');
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
  }

  @override
  Future<List<Chapter>> getChaptersForClass(
    StudentClass studentClass, {
    BoardType? board,
    String subjectId = 'math',
  }) async {
    await _ensureLoaded();

    final cleanClass = studentClass.label.toLowerCase().replaceAll(' ', '');
    final selectedBoard = board ?? BoardType.cbse;
    final boardCode = selectedBoard.code.toLowerCase();

    final sourceList = (subjectId == 'english')
        ? (_cachedEnglishChapters ?? [])
        : (_cachedChapters ?? []);

    final chapters = sourceList.where((ch) {
      final chGrade = ch.grade.toLowerCase().replaceAll(' ', '');
      final gradeMatch = chGrade == cleanClass || chGrade.contains(cleanClass) || cleanClass.contains(chGrade);
      if (!gradeMatch) return false;

      final chBoard = ch.board.toLowerCase();
      // 'all' matches any board (universal kindergarten or cross-board)
      if (chBoard == 'all') return true;
      // Exact match for the board (e.g. 'cbse' or 'icse')
      if (chBoard == boardCode) return true;
      // State board fallback to cbse if no state board specific chapter
      if (selectedBoard == BoardType.stateBoard && chBoard == 'cbse') return true;
      return false;
    }).toList();

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
        final hasNonInteractiveKindergarten = isKindergarten &&
            savedActivities.any((a) => a.activityType == ActivityType.mcq);
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
        if (!hasLegacy && !hasDuplicates && !hasInappropriateLkgDistractors && !hasNonInteractiveKindergarten && !hasBubbleWithOptions && !hasObsoleteBoilerplate) {
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

      // If chapter has 0 activities, generate default ones!
      if (chapterActivities.isEmpty) {
        final generated = _generateDefaultActivitiesForChapter(ch, studentClass);
        _dynamicallyGeneratedActivities.addAll(generated);
        LocalStorageService.instance.saveChapterActivities(ch.chapterId, generated);
        return ch.copyWith(activities: generated);
      }

      LocalStorageService.instance.saveChapterActivities(ch.chapterId, chapterActivities);
      return ch.copyWith(activities: chapterActivities);
    }).toList();
  }

  List<Activity> _generateDefaultActivitiesForChapter(Chapter ch, StudentClass studentClass, {int count = 2}) {
    if (ch.subjectId == 'english' || ch.chapterId.startsWith('eng_')) {
      return EnglishQuestionGenerator.instance.generateActivitiesForChapter(
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
      final allChapters = [...?_cachedChapters, ...?_cachedEnglishChapters];
      try {
        matchingChapter = allChapters.firstWhere((ch) => ch.chapterId == chapterId);
      } catch (_) {}
    }
    matchingChapter ??= Chapter(
      chapterId: chapterId,
      chapterNumber: 1,
      title: 'Practice Challenge',
      grade: studentClass.label,
      subjectId: chapterId.startsWith('eng_') ? 'english' : 'math',
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
