import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../core/theme/grade_tier_extension.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../../../shared/components/scratchpad_drawer.dart';
import '../../activities/bubble_pop/presentation/bubble_pop_screen.dart';
import '../../activities/card_match/presentation/card_match_screen.dart';
import '../../activities/drag_drop/presentation/fraction_cauldron_screen.dart';
import '../../activities/grid_calc/presentation/equation_solver_screen.dart';
import '../../activities/concept_quiz/presentation/concept_challenge_screen.dart';
import '../../chapter_detail/presentation/chapter_detail_screen.dart';
import '../../concept_learning/presentation/concept_lesson_sheet.dart';
import '../../onboarding/presentation/board_class_selector_dialog.dart';
import '../../settings/presentation/voice_settings_sheet.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/components/language_switch_button.dart';

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

    // Auto reload if user switched class or board
    if (_lastLoadedClass != activeProfile.studentClass || _lastLoadedBoard != activeProfile.board) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurriculum());
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/curio_logo_mark.png',
              height: 26,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            const Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Curio ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: -0.3,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(
                      text: 'Academy',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: -0.3,
                        color: Color(0xFFFF7B25),
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                tooltip: isMuted ? ref.strings.unmuteSpeaker : ref.strings.muteSpeaker,
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
                    Text(ref.strings.voiceCompanion, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
                      Text(ref.strings.scratchpad, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'board_class',
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Text(ref.strings.changeBoard, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(),
          _buildBottomSubjectMenu(theme, activeProfile),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Student Greeting Card
              _buildStudentGreetingCard(theme, activeProfile, ref),

              const SizedBox(height: 14),

              // 2. Total Stars Achievement Card
              _buildTotalStarsHeroCard(ref),

              const SizedBox(height: 18),

              // 3. Class Selection (Direct kid-friendly carousel & changer)
              _buildClassSelectionSection(activeProfile, theme, ref),

              const SizedBox(height: 18),

              // 4. Subject Selection Cards
              _buildSubjectSelectionSection(theme, activeProfile, ref),

              const SizedBox(height: 22),

              // 5. Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _activeSubjectId == 'english' ? ref.strings.englishChapters : ref.strings.mathChapters,
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

              // 6. Clean Chapter Cards (Tap to open that specific chapter!)
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

  Widget _buildTotalStarsHeroCard(WidgetRef ref) {
    final strings = ref.strings;
    return ValueListenableBuilder<int>(
      valueListenable: LocalStorageService.instance.totalStarsNotifier,
      builder: (context, totalStars, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.star_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            strings.starsEarned,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE68A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            strings.superExplorer,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$totalStars',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF78350F),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            strings.totalStars,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.keepPracticingMotivation,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFA16207),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSubjectMenu(ThemeData theme, StudentProfile profile) {
    final strings = ref.strings;
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
                label: strings.math,
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
                label: strings.english,
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
                label: strings.science,
                emoji: '🔬',
                accentColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                isActive: false,
                badgeText: strings.comingSoon,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 12,
                    color: isActive ? accentColor : const Color(0xFF64748B),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 1),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentGreetingCard(ThemeData theme, StudentProfile activeProfile, WidgetRef ref) {
    final strings = ref.strings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7B25).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text('🦊', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.studentGreeting,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7C2D12),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.studentGreetingSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A3412),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 1,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                AudioService.instance.playSfx(CurioSfx.click);
                AudioService.instance.speakPrompt(
                  '${strings.studentGreeting}. ${strings.studentGreetingSubtitle}',
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.volume_up_rounded, color: Color(0xFFEA580C), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelectionSection(StudentProfile activeProfile, ThemeData theme, WidgetRef ref) {
    final strings = ref.strings;
    final classIcons = <StudentClass, String>{
      StudentClass.lkg: '🐥',
      StudentClass.ukg: '🎈',
      StudentClass.class1: '🚀',
      StudentClass.class2: '🎨',
      StudentClass.class3: '🌟',
      StudentClass.class4: '⚡',
      StudentClass.class5: '🎯',
      StudentClass.class6: '🔬',
      StudentClass.class7: '🏆',
      StudentClass.class8: '👑',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                strings.selectClassTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _openBoardClassSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${activeProfile.board.code} ⚙️',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: StudentClass.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final c = StudentClass.values[index];
              final isSelected = c == activeProfile.studentClass;
              final emoji = classIcons[c] ?? '🎒';

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (isSelected) return;
                  AudioService.instance.playSfx(CurioSfx.click);
                  ref.read(studentProfileProvider.notifier).updateProfile(
                    board: activeProfile.board,
                    studentClass: c,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF7B25), Color(0xFFF97316)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFEA580C) : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF7B25).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 19)),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          if (isSelected)
                            Text(
                              strings.active,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFF7ED),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelectionSection(ThemeData theme, StudentProfile activeProfile, WidgetRef ref) {
    final strings = ref.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.selectSubjectTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSubjectCard(
                title: strings.math,
                subtitle: strings.mathSubtitle,
                emoji: '📐',
                isActive: _activeSubjectId == 'math',
                primaryColor: const Color(0xFFFF7B25),
                lightBgColor: const Color(0xFFFFF4EC),
                onTap: () => _switchSubject('math'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSubjectCard(
                title: strings.english,
                subtitle: strings.englishSubtitle,
                emoji: '📚',
                isActive: _activeSubjectId == 'english',
                primaryColor: const Color(0xFF6366F1),
                lightBgColor: const Color(0xFFEEF2FF),
                onTap: () => _switchSubject('english'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildScienceSubjectCard(strings, activeProfile),
      ],
    );
  }

  Widget _buildSubjectCard({
    required String title,
    required String subtitle,
    required String emoji,
    required bool isActive,
    required Color primaryColor,
    required Color lightBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? lightBgColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? primaryColor : const Color(0xFFE2E8F0),
            width: isActive ? 2 : 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor.withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isActive ? primaryColor : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? primaryColor.withValues(alpha: 0.8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScienceSubjectCard(AppLocalizations strings, StudentProfile profile) {
    const scienceColor = Color(0xFF10B981);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔬', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.science,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    strings.scienceSubtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scienceColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                strings.comingSoon,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: scienceColor,
                ),
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
