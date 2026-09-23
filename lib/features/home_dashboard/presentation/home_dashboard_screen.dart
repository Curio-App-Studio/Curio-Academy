import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../core/theme/grade_tier_extension.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/grade_tier.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../../../shared/components/scratchpad_drawer.dart';
import '../../activities/bubble_pop/presentation/bubble_pop_screen.dart';
import '../../activities/drag_drop/presentation/fraction_cauldron_screen.dart';
import '../../activities/grid_calc/presentation/equation_solver_screen.dart';
import '../../activities/concept_quiz/presentation/concept_challenge_screen.dart';
import '../../chapter_detail/presentation/chapter_detail_screen.dart';
import '../../concept_learning/presentation/concept_lesson_sheet.dart';
import '../../onboarding/presentation/board_class_selector_dialog.dart';
import '../../settings/presentation/voice_settings_sheet.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  final CurriculumRepository _repository = CurriculumRepository();
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  StudentClass? _lastLoadedClass;
  BoardType? _lastLoadedBoard;
  String _activeSubjectId = 'math';

  @override
  void initState() {
    super.initState();
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
        subjectId: _activeSubjectId,
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

  void _switchSubject(String subjectId) {
    if (_activeSubjectId == subjectId) return;
    AudioService.instance.playSfx(CurioSfx.click);
    setState(() {
      _activeSubjectId = subjectId;
    });
    _loadCurriculum();
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
      // Refresh curriculum in case new questions were generated
      _loadCurriculum();
    });
  }

  void _practiceChapter(Chapter chapter) {
    AudioService.instance.playSfx(CurioSfx.click);
    final activeProfile = ref.read(studentProfileProvider);

    // Retrieve saved activities or default activities
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

    if (targetActivity != null &&
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

    // Auto reload if user switched class or board
    if (_lastLoadedClass != activeProfile.studentClass || _lastLoadedBoard != activeProfile.board) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurriculum());
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/curio_logo_mark.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Curio ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.3,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text: 'Academy',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.3,
                      color: Color(0xFFFF7B25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: AudioService.instance.muteNotifier,
            builder: (context, isMuted, child) {
              return IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF475569),
                  size: 22,
                ),
                tooltip: isMuted ? 'Unmute Speaker' : 'Mute Speaker',
                onPressed: () {
                  AudioService.instance.toggleMute();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.record_voice_over_rounded,
              color: Color(0xFF475569),
              size: 22,
            ),
            tooltip: 'Voice Companion',
            onPressed: () {
              AudioService.instance.playSfx(CurioSfx.click);
              VoiceSettingsSheet.show(context);
            },
          ),
          if (tierTheme.enableScratchpad)
            IconButton(
              icon: const Icon(
                Icons.draw_rounded,
                color: Color(0xFF475569),
                size: 22,
              ),
              tooltip: 'Scratchpad',
              onPressed: _openScratchpad,
            ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _buildBottomSubjectMenu(theme, activeProfile),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Class Banner
              _buildClassBanner(activeProfile, tierTheme),

              const SizedBox(height: 20),

              // 2. Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeSubjectId == 'english' ? '📚 English Chapters' : '📐 Math Chapters',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_activeSubjectId == 'english'
                              ? const Color(0xFF6366F1)
                              : theme.colorScheme.primary)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_chapters.length} Chapters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _activeSubjectId == 'english'
                            ? const Color(0xFF6366F1)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 3. Clean Chapter Cards (Tap to open that specific chapter!)
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

  Widget _buildBottomSubjectMenu(ThemeData theme, StudentProfile profile) {
    return SafeArea(
      top: false,
      child: Container(
        height: 50,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            // Mathematics
            Expanded(
              child: _buildBottomSubjectItem(
                subjectId: 'math',
                label: 'Math',
                emoji: '📐',
                accentColor: const Color(0xFFFF7B25),
                bgColor: const Color(0xFFFFF4EC),
                isActive: _activeSubjectId == 'math',
                onTap: () => _switchSubject('math'),
              ),
            ),
            const SizedBox(width: 4),

            // English
            Expanded(
              child: _buildBottomSubjectItem(
                subjectId: 'english',
                label: 'English',
                emoji: '📚',
                accentColor: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
                isActive: _activeSubjectId == 'english',
                onTap: () => _switchSubject('english'),
              ),
            ),
            const SizedBox(width: 4),

            // Science (Coming Soon)
            Expanded(
              child: _buildBottomSubjectItem(
                subjectId: 'science',
                label: 'Science',
                emoji: '🔬',
                accentColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                isActive: false,
                badgeText: 'Soon',
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Text('🔬', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Curio Science is launching soon for ${profile.studentClass.label}! 🧪✨',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: const Color(0xFF0F766E),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSubjectItem({
    required String subjectId,
    required String label,
    required String emoji,
    required Color accentColor,
    required Color bgColor,
    required bool isActive,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isActive ? bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
          border: isActive
              ? Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 13,
                  color: isActive ? accentColor : const Color(0xFF64748B),
                  letterSpacing: 0.1,
                ),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassBanner(StudentProfile profile, CurioTierTheme tierTheme) {
    final isEng = _activeSubjectId == 'english';
    final subjectTitle = isEng ? 'English' : 'Mathematics';
    final subjectColor = isEng ? const Color(0xFF6366F1) : const Color(0xFFFF7B25);
    final bannerIcon = isEng
        ? '📚'
        : (profile.studentClass.tier == GradeTier.earlyExplorer
            ? '🐥'
            : (profile.studentClass.tier == GradeTier.primaryBuilder ? '🚀' : '📐'));

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _openBoardClassSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: subjectColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: subjectColor.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  bannerIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${profile.board.code} • ${profile.studentClass.label}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: subjectColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subjectTitle,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_chapters.length} Chapters • Tap to change board & class',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF475569),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.edit_rounded, size: 12, color: Color(0xFF475569)),
                ],
              ),
            ),
          ],
        ),
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'CHAPTER ${chapter.chapterNumber}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
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
                        foregroundColor: theme.colorScheme.primary,
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
