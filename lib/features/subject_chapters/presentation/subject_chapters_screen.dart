import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../core/theme/grade_tier_extension.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../../shared/components/language_switch_button.dart';
import '../../../shared/components/scratchpad_drawer.dart';
import '../../activities/bubble_pop/presentation/bubble_pop_screen.dart';
import '../../activities/card_match/presentation/card_match_screen.dart';
import '../../activities/concept_quiz/presentation/concept_challenge_screen.dart';
import '../../activities/drag_drop/presentation/fraction_cauldron_screen.dart';
import '../../activities/grid_calc/presentation/equation_solver_screen.dart';
import '../../chapter_detail/presentation/chapter_detail_screen.dart';
import '../../concept_learning/presentation/concept_lesson_sheet.dart';
import '../../onboarding/presentation/board_class_selector_dialog.dart';
import '../../settings/presentation/voice_settings_sheet.dart';

/// Dedicated Subject Chapters Screen:
/// Displays all curriculum chapters for the selected subject (e.g. Math or English)
/// after user selects the subject from the Home Dashboard.
class SubjectChaptersScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;
  final String emoji;
  final Color primaryColor;

  const SubjectChaptersScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.emoji,
    required this.primaryColor,
  });

  @override
  ConsumerState<SubjectChaptersScreen> createState() => _SubjectChaptersScreenState();
}

class _SubjectChaptersScreenState extends ConsumerState<SubjectChaptersScreen> {
  final CurriculumRepository _repository = CurriculumRepository();
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  StudentClass? _lastLoadedClass;
  BoardType? _lastLoadedBoard;

  @override
  void initState() {
    super.initState();
    final activeProfile = ref.read(studentProfileProvider);
    _lastLoadedClass = activeProfile.studentClass;
    _lastLoadedBoard = activeProfile.board;
    _loadCurriculum();
  }

  Future<void> _loadCurriculum() async {
    final activeProfile = ref.read(studentProfileProvider);
    _lastLoadedClass = activeProfile.studentClass;
    _lastLoadedBoard = activeProfile.board;
    setState(() => _isLoading = true);

    try {
      final chapters = await _repository.getChaptersForClass(
        activeProfile.studentClass,
        board: activeProfile.board,
        subjectId: widget.subjectId,
      );
      if (mounted) {
        setState(() {
          _chapters = chapters;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openBoardClassSelector() {
    AudioService.instance.playSfx(CurioSfx.click);
    BoardClassSelectorDialog.show(context).then((_) {
      _loadCurriculum();
    });
  }

  void _openScratchpad() {
    AudioService.instance.playSfx(CurioSfx.click);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScratchpadDrawer(),
    );
  }

  void _openChapter(Chapter chapter) {
    AudioService.instance.playSfx(CurioSfx.click);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterDetailScreen(chapter: chapter),
      ),
    ).then((_) {
      _loadCurriculum();
    });
  }

  void _practiceChapter(Chapter chapter) {
    AudioService.instance.playSfx(CurioSfx.click);
    final activeProfile = ref.read(studentProfileProvider);

    final saved = LocalStorageService.instance.getChapterActivities(chapter.chapterId);
    final activities = (saved != null && saved.isNotEmpty)
        ? saved
        : (chapter.activities.isNotEmpty
            ? chapter.activities
            : _repository.generateActivitiesForChapter(
                chapter.chapterId,
                activeProfile.studentClass,
                count: 3,
                chapter: chapter,
              ));

    final nextIndex = LocalStorageService.instance.getNextQuestionIndexForChapter(
      chapter.chapterId,
      activities,
    );

    final safeIndex = activities.isNotEmpty
        ? nextIndex.clamp(0, activities.length - 1)
        : 0;

    final targetActivity = activities.isNotEmpty ? activities[safeIndex] : null;
    Widget targetScreen;

    if (targetActivity != null && targetActivity.activityType == ActivityType.cardMatch) {
      targetScreen = CardMatchScreen(
        activity: targetActivity,
        activities: activities,
        initialLevelIndex: safeIndex,
      );
    } else if (targetActivity != null &&
        (targetActivity.activityType == ActivityType.bubblePop ||
            activeProfile.studentClass.isKindergarten)) {
      targetScreen = BubblePopScreen(
        activity: targetActivity,
        activities: activities,
        initialLevelIndex: safeIndex,
      );
    } else if (targetActivity != null && targetActivity.activityType == ActivityType.dragDrop) {
      targetScreen = FractionCauldronScreen(activity: targetActivity);
    } else if (targetActivity != null && targetActivity.activityType == ActivityType.gridCalc) {
      targetScreen = EquationSolverScreen(activity: targetActivity);
    } else {
      targetScreen = ConceptChallengeScreen(
        chapter: chapter.copyWith(activities: activities),
        activities: activities,
        initialIndex: safeIndex,
        studentClass: activeProfile.studentClass,
        onActivitiesUpdated: (updatedActivities) {
          LocalStorageService.instance.saveChapterActivities(chapter.chapterId, updatedActivities);
        },
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => targetScreen),
    ).then((_) {
      _loadCurriculum();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(studentProfileProvider);
    final tierTheme = Theme.of(context).extension<CurioTierTheme>() ?? CurioTierTheme.primaryBuilder();
    final theme = Theme.of(context);
    final strings = ref.strings;

    if (_lastLoadedClass != null &&
        (_lastLoadedClass != activeProfile.studentClass || _lastLoadedBoard != activeProfile.board)) {
      _lastLoadedClass = activeProfile.studentClass;
      _lastLoadedBoard = activeProfile.board;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurriculum());
    }

    final isEnglish = widget.subjectId == 'english';
    final localizedSubjectName = isEnglish ? strings.english : strings.math;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          tooltip: 'Back',
          onPressed: () {
            AudioService.instance.playSfx(CurioSfx.click);
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizedSubjectName,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.5,
                      color: widget.primaryColor,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${activeProfile.studentClass.label} • ${activeProfile.board.code}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const LanguageSwitchButton(),
          const SizedBox(width: 2),
          ValueListenableBuilder<bool>(
            valueListenable: AudioService.instance.muteNotifier,
            builder: (context, isMuted, child) {
              return IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF475569),
                  size: 21,
                ),
                tooltip: isMuted ? strings.unmuteSpeaker : strings.muteSpeaker,
                onPressed: () {
                  AudioService.instance.toggleMute();
                },
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF475569), size: 21),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'voice') {
                AudioService.instance.playSfx(CurioSfx.click);
                VoiceSettingsSheet.show(context);
              } else if (value == 'scratchpad') {
                _openScratchpad();
              } else if (value == 'board_class') {
                _openBoardClassSelector();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'voice',
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over_rounded, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 10),
                    Text(strings.voiceCompanion, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
              if (tierTheme.enableScratchpad)
                PopupMenuItem(
                  value: 'scratchpad',
                  child: Row(
                    children: [
                      const Icon(Icons.draw_rounded, color: Color(0xFFFF7B25), size: 20),
                      const SizedBox(width: 10),
                      Text(strings.scratchpad, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'board_class',
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Text(strings.changeBoard, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AdBannerWidget(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Hero Banner
              _buildSubjectHeroBanner(activeProfile, strings),

              const SizedBox(height: 18),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEnglish ? strings.englishChapters : strings.mathChapters,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_chapters.length} Chapters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Chapter Cards
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_chapters.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          'No syllabus chapters found for ${activeProfile.studentClass.label}.',
                          style: TextStyle(fontSize: tierTheme.promptFontSize),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._chapters.map((ch) => _buildChapterCard(ch, tierTheme, theme, activeProfile)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectHeroBanner(StudentProfile activeProfile, AppLocalizations strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.primaryColor.withValues(alpha: 0.08),
            widget.primaryColor.withValues(alpha: 0.16),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeProfile.studentClass.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: widget.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        activeProfile.board.code,
                        style: TextStyle(
                          color: widget.primaryColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subjectId == 'english'
                      ? strings.englishSubtitle
                      : strings.mathSubtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: widget.primaryColor.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(
    Chapter chapter,
    CurioTierTheme tierTheme,
    ThemeData theme,
    StudentProfile activeProfile,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openChapter(chapter),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(chapter.icon, style: const TextStyle(fontSize: 26)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'CHAPTER ${chapter.chapterNumber}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: widget.primaryColor,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Builder(
                                builder: (_) {
                                  final solvedCount = chapter.activities.where((a) {
                                    final attempt = LocalStorageService.instance.getQuestionAttempt(a.activityId);
                                    return attempt != null && attempt.isCorrect;
                                  }).length;
                                  if (solvedCount > 0) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$solvedCount/${chapter.activities.length} Solved ✓',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    );
                                  }
                                  return Text(
                                    '${chapter.activities.length} Practice Sets',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chapter.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (chapter.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              chapter.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey.shade600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Key Concept Pills
                if (chapter.keyConcepts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: chapter.keyConcepts.take(3).map((concept) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          concept,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Action Row
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        AudioService.instance.playSfx(CurioSfx.click);
                        ConceptLessonSheet.show(
                          context,
                          chapter: chapter,
                          profile: activeProfile,
                          onStartPractice: () => _openChapter(chapter),
                        );
                      },
                      icon: const Text('📖', style: TextStyle(fontSize: 14)),
                      label: const Text(
                        'Learn',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC2410C),
                        backgroundColor: const Color(0xFFFFF7ED),
                        side: const BorderSide(color: Color(0xFFFDBA74), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _practiceChapter(chapter),
                      icon: const Text('Practice & Play', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      label: const Icon(Icons.arrow_forward_rounded, size: 16),
                      style: TextButton.styleFrom(
                        foregroundColor: widget.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
