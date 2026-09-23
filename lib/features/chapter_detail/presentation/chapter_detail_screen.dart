import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../core/theme/grade_tier_extension.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../../../shared/components/gamified_card.dart';
import '../../activities/bubble_pop/presentation/bubble_pop_screen.dart';
import '../../activities/concept_quiz/presentation/concept_challenge_screen.dart';
import '../../activities/drag_drop/presentation/fraction_cauldron_screen.dart';
import '../../activities/grid_calc/presentation/equation_solver_screen.dart';
import '../../concept_learning/presentation/concept_lesson_sheet.dart';

/// Dedicated Chapter View: Shows only this chapter's concept lesson and practice activities
class ChapterDetailScreen extends ConsumerStatefulWidget {
  final Chapter chapter;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
  });

  @override
  ConsumerState<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends ConsumerState<ChapterDetailScreen> {
  final CurriculumRepository _repository = CurriculumRepository();
  late Chapter _currentChapter;

  @override
  void initState() {
    super.initState();
    _currentChapter = _ensureValidActivities(widget.chapter);
  }

  Chapter _ensureValidActivities(Chapter ch) {
    final activeProfile = ref.read(studentProfileProvider);
    final isKindergarten = activeProfile.studentClass.isKindergarten;

    final candidateActivities = LocalStorageService.instance.getChapterActivities(ch.chapterId) ?? ch.activities;

    final prompts = candidateActivities.map((a) => a.promptData.text.trim().toLowerCase()).toSet();
    final hasDuplicates = candidateActivities.length > 1 && prompts.length < candidateActivities.length;
    final hasInappropriateDistractors = isKindergarten &&
        candidateActivities.any((a) {
          final opts = (a.interactionPayload['options'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
          return opts.any((o) => o.contains('clause') || o.contains('predicate') || o.contains('prepositional'));
        });
    // For kindergarten (LKG/UKG), children require interactive activities (Bubble Pop) rather than reading text MCQs
    final hasTextMcqInKindergarten = isKindergarten &&
        candidateActivities.any((a) => a.activityType == ActivityType.mcq);
    final hasBubbleWithOptions = isKindergarten &&
        candidateActivities.any((a) =>
            a.activityType == ActivityType.bubblePop &&
            a.interactionPayload.containsKey('options'));
    final hasObsoleteBoilerplate = candidateActivities.any((a) {
      final text = a.promptData.text.toLowerCase();
      return text.contains('elementary practice topic') ||
          text.contains('which foundational rule') ||
          text.contains('which core topic in') ||
          text.contains('what is the governing formula') ||
          text.contains('primary study focus of');
    });

    if (candidateActivities.isEmpty || hasDuplicates || hasInappropriateDistractors || hasTextMcqInKindergarten || hasBubbleWithOptions || hasObsoleteBoilerplate) {
      final generated = _repository.generateActivitiesForChapter(
        ch.chapterId,
        activeProfile.studentClass,
        count: 3,
        chapter: ch,
      );
      LocalStorageService.instance.saveChapterActivities(ch.chapterId, generated);
      return ch.copyWith(activities: generated);
    }
    LocalStorageService.instance.saveChapterActivities(ch.chapterId, candidateActivities);
    return ch.copyWith(activities: candidateActivities);
  }

  void _launchActivity(Activity activity, [int index = 0]) {
    AudioService.instance.playSfx(CurioSfx.click);
    final activeProfile = ref.read(studentProfileProvider);
    Widget targetScreen;

    switch (activity.activityType) {
      case ActivityType.bubblePop:
        targetScreen = BubblePopScreen(
          activity: activity,
          activities: _currentChapter.activities,
          initialLevelIndex: index,
        );
        break;
      case ActivityType.dragDrop:
        targetScreen = FractionCauldronScreen(activity: activity);
        break;
      case ActivityType.gridCalc:
        targetScreen = EquationSolverScreen(activity: activity);
        break;
      case ActivityType.mcq:
      default:
        targetScreen = ConceptChallengeScreen(
          activity: activity,
          chapter: _currentChapter,
          activities: _currentChapter.activities,
          initialIndex: index,
          studentClass: activeProfile.studentClass,
          onActivitiesUpdated: (updatedActivities) {
            LocalStorageService.instance.saveChapterActivities(_currentChapter.chapterId, updatedActivities);
            setState(() {
              _currentChapter = _currentChapter.copyWith(activities: updatedActivities);
            });
          },
        );
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => targetScreen),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(studentProfileProvider);
    final tierTheme = Theme.of(context).extension<CurioTierTheme>() ?? CurioTierTheme.primaryBuilder();
    final nextIndex = LocalStorageService.instance.getNextQuestionIndexForChapter(
      _currentChapter.chapterId,
      _currentChapter.activities,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ch ${_currentChapter.chapterNumber}: ${_currentChapter.title}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Read Aloud',
            onPressed: () {
              AudioService.instance.speakPrompt(
                'Chapter ${_currentChapter.chapterNumber}: ${_currentChapter.title}. ${_currentChapter.description}',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          children: [
            // Chapter Hero Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFEDD5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(_currentChapter.icon, style: const TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${activeProfile.board.shortCode} • ${_currentChapter.grade} • CHAPTER ${_currentChapter.chapterNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentChapter.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentChapter.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C2D12),
                      height: 1.35,
                    ),
                  ),
                  if (_currentChapter.keyConcepts.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _currentChapter.keyConcepts.map((concept) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDBA74).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            concept,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A3412),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            AudioService.instance.playSfx(CurioSfx.click);
                            ConceptLessonSheet.show(
                              context,
                              chapter: _currentChapter,
                              profile: activeProfile,
                              onStartPractice: () {
                                if (_currentChapter.activities.isNotEmpty) {
                                  final safeIndex = nextIndex.clamp(0, _currentChapter.activities.length - 1);
                                  _launchActivity(_currentChapter.activities[safeIndex], safeIndex);
                                }
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC2410C),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFFDBA74), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('📖', style: TextStyle(fontSize: 15)),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Learn Concept',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentChapter.activities.isNotEmpty) {
                              final safeIndex = nextIndex.clamp(0, _currentChapter.activities.length - 1);
                              _launchActivity(_currentChapter.activities[safeIndex], safeIndex);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7B25),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  nextIndex == 0 ? 'Start Practice 🚀' : 'Resume (Q${nextIndex + 1}) 🚀',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Practice Questions Section Header
            Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Practice Questions (${_currentChapter.activities.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Activities List
            if (_currentChapter.activities.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 8),
                    Text(
                      'No activities yet for this chapter.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            else
              ..._currentChapter.activities.asMap().entries.map((entry) {
                final idx = entry.key;
                final activity = entry.value;
                return _buildActivityCard(activity, idx + 1, tierTheme, nextIndex);
              }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity, int index, CurioTierTheme tierTheme, int nextIndex) {
    final visualIcon = activity.interactionPayload['visualIcon'] as String? ??
        (activity.activityType == ActivityType.bubblePop
            ? '🫧'
            : (activity.activityType == ActivityType.dragDrop
                ? '🍯'
                : (activity.activityType == ActivityType.gridCalc
                    ? '⚖️'
                    : '📝')));

    final topicTitle = (activity.interactionPayload['topicTitle'] as String? ??
            activity.chapterName ??
            activity.activityType.name)
        .toUpperCase();

    final attempt = LocalStorageService.instance.getQuestionAttempt(activity.activityId);
    final isNextUp = (index - 1) == nextIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GamifiedCard(
        onTap: () => _launchActivity(activity, index - 1),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(visualIcon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'QUESTION $index',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      if (attempt != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: attempt.isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            attempt.isCorrect ? '✓ Done' : '⚠️ Attempted',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: attempt.isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ] else if (isNextUp) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '▶ NEXT UP',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          topicTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.promptData.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: attempt != null
                    ? (attempt.isCorrect ? const Color(0xFF16A34A) : const Color(0xFF2563EB))
                    : (isNextUp ? const Color(0xFFFF7B25) : const Color(0xFFF97316)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                attempt != null
                    ? (attempt.isCorrect ? 'Review' : 'Retry')
                    : (isNextUp ? 'Play 🚀' : 'Play'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
