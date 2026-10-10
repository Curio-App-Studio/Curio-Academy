import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/hindi_curriculum_translator.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../core/theme/grade_tier_extension.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../../shared/components/language_switch_button.dart';
import '../../../shared/components/scratchpad_drawer.dart';
import '../../../shared/dialogs/avatar_selector_dialog.dart';
import '../../chapter_detail/presentation/chapter_detail_screen.dart';
import '../../concept_learning/presentation/concept_lesson_sheet.dart';
import '../../concept_learning/presentation/textbook_reader_screen.dart';
import '../../diagram_explorer/presentation/diagram_explorer_sheet.dart';
import '../../exam_mode/presentation/timed_exam_screen.dart';
import '../../settings/presentation/voice_settings_sheet.dart';
import '../../adventure_map/presentation/adventure_island_screen.dart';
import '../../../data/services/literature_reading_service.dart';
import '../../spell_bee/presentation/spell_bee_hub_screen.dart';
import '../../math_tables/presentation/math_tables_screen.dart';

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
  String _activeLanguageTrack = 'literature'; // 'literature' vs 'grammar'

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

    if (!CurriculumRepository.isSubjectAvailableForClass(widget.subjectId, activeProfile.studentClass)) {
      if (mounted) {
        final strings = ref.strings;
        final rangeMsg = widget.subjectId == 'science'
            ? (strings.isHindi ? 'कक्षा 3 से उपलब्ध है।' : 'available starting from Class 3.')
            : (strings.isHindi ? 'कक्षा 5 तक उपलब्ध है।' : 'available for LKG to Class 5.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.isHindi
                  ? '${widget.subjectName} $rangeMsg'
                  : '${widget.subjectName} is $rangeMsg',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isLanguage = widget.subjectId == 'hindi';
      final currentPref = LocalStorageService.instance.getPreferredPublisher(widget.subjectId);
      final defaultPub = activeProfile.board == BoardType.icse
          ? (widget.subjectId == 'hindi' ? 'miranda' : null)
          : (activeProfile.board == BoardType.cbse ? 'ncert' : null);
      final activePub = (widget.subjectId == 'english') ? null : (currentPref ?? defaultPub);

      final chapters = await _repository.getChaptersForClass(
        activeProfile.studentClass,
        board: activeProfile.board,
        subjectId: widget.subjectId,
        publisher: activePub,
        track: isLanguage ? _activeLanguageTrack : null,
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

  void _openEditProfile() {
    AudioService.instance.playSfx(CurioSfx.click);
    AvatarSelectorDialog.show(context).then((_) {
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
    _openChapter(chapter);
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
    final isScience = widget.subjectId == 'science';
    final isEvs = widget.subjectId == 'evs';
    final isHindi = widget.subjectId == 'hindi';
    final isMath = widget.subjectId == 'math' || widget.subjectId == 'mathematics';
    final localizedSubjectName = isEnglish
        ? strings.english
        : isScience
            ? strings.science
            : isEvs
                ? strings.evsShort
                : isHindi
                    ? strings.hindiShort
                    : strings.math;

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
          if (_chapters.isNotEmpty)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Color(0xFF0D9488),
                  size: 18,
                ),
              ),
              tooltip: strings.isHindi ? 'द्वीप यात्रा (Island Map)' : 'Island Map',
              onPressed: () {
                AudioService.instance.playSfx(CurioSfx.click);
                AdventureIslandScreen.push(
                  context,
                  chapters: _chapters,
                  subjectId: widget.subjectId,
                  subjectName: localizedSubjectName,
                  emoji: widget.emoji,
                  primaryColor: widget.primaryColor,
                );
              },
            ),
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
              if (value == 'island_map' && _chapters.isNotEmpty) {
                AudioService.instance.playSfx(CurioSfx.click);
                AdventureIslandScreen.push(
                  context,
                  chapters: _chapters,
                  subjectId: widget.subjectId,
                  subjectName: localizedSubjectName,
                  emoji: widget.emoji,
                  primaryColor: widget.primaryColor,
                );
              } else if (value == 'voice') {
                AudioService.instance.playSfx(CurioSfx.click);
                VoiceSettingsSheet.show(context);
              } else if (value == 'scratchpad') {
                _openScratchpad();
              } else if (value == 'edit_profile' || value == 'board_class') {
                _openEditProfile();
              }
            },
            itemBuilder: (context) => [
              if (_chapters.isNotEmpty)
                PopupMenuItem(
                  value: 'island_map',
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded, color: Color(0xFF0D9488), size: 20),
                      const SizedBox(width: 10),
                      Text(strings.isHindi ? 'द्वीप यात्रा (Island Map)' : 'Adventure Island Map', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
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
                value: 'edit_profile',
                child: Row(
                  children: [
                    const Icon(Icons.account_circle_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Text(strings.editProfile, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Hero Banner
              _buildSubjectHeroBanner(activeProfile, strings),

              const SizedBox(height: 14),

              if (isMath) ...[
                _buildLearnTablesBanner(context, strings),
                const SizedBox(height: 14),
              ],

              if (isEnglish) ...[
                _buildSpellBeeBanner(context, strings),
                const SizedBox(height: 14),
              ],

              if (isHindi) ...[
                _buildLanguageTrackSelector(activeProfile, strings),
                if (_activeLanguageTrack == 'literature')
                  _buildPublisherSelectorBar(activeProfile, strings)
                else
                  _buildGrammarInfoBanner(strings),
              ] else ...[
                _buildPublisherSelectorBar(activeProfile, strings),
              ],

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEnglish
                          ? strings.englishChapters
                          : isScience
                              ? strings.scienceChapters
                              : isEvs
                                  ? strings.evsChapters
                                  : isHindi
                                      ? (_activeLanguageTrack == 'grammar'
                                          ? (strings.isHindi ? 'व्याकरण पाठ' : 'Grammar Chapters')
                                          : (strings.isHindi ? 'साहित्य पाठ व कविताएं' : 'Literature Stories & Poems'))
                                      : strings.mathChapters,
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
    final isEnglish = widget.subjectId == 'english';
    final isScience = widget.subjectId == 'science';
    final isEvs = widget.subjectId == 'evs';
    final isHindi = widget.subjectId == 'hindi';
    final localizedSubjectName = isEnglish
        ? strings.english
        : isScience
            ? strings.science
            : isEvs
                ? strings.evsShort
                : isHindi
                    ? strings.hindiShort
                    : strings.math;

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
                      : widget.subjectId == 'science'
                          ? strings.scienceSubtitle
                          : widget.subjectId == 'evs'
                              ? strings.evsSubtitle
                              : widget.subjectId == 'hindi'
                                  ? strings.hindiSubtitle
                                  : strings.mathSubtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: widget.primaryColor.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        AudioService.instance.playSfx(CurioSfx.click);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TimedExamScreen(
                              chapters: _chapters,
                              subjectId: widget.subjectId,
                              subjectName: localizedSubjectName,
                              primaryColor: widget.primaryColor,
                            ),
                          ),
                        );
                      },
                      icon: const Text('📝', style: TextStyle(fontSize: 13)),
                      label: Text(
                        strings.startTimedExam,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    if (widget.subjectId == 'science' || widget.subjectId == 'evs')
                      OutlinedButton.icon(
                        onPressed: () {
                          AudioService.instance.playSfx(CurioSfx.click);
                          DiagramExplorerSheet.show(context);
                        },
                        icon: const Text('🔬', style: TextStyle(fontSize: 13)),
                        label: Text(
                          strings.exploreDiagram,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.primaryColor,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: widget.primaryColor.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    if (_chapters.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () {
                          AudioService.instance.playSfx(CurioSfx.click);
                          AdventureIslandScreen.push(
                            context,
                            chapters: _chapters,
                            subjectId: widget.subjectId,
                            subjectName: localizedSubjectName,
                            emoji: widget.emoji,
                            primaryColor: widget.primaryColor,
                          );
                        },
                        icon: const Icon(Icons.map_rounded, size: 14),
                        label: Text(
                          strings.isHindi ? 'द्वीप यात्रा' : 'Island Map',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D9488),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF0D9488), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnTablesBanner(BuildContext context, AppLocalizations strings) {
    final isHindiUi = strings.isHindi;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        MathTablesScreen.push(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔢', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isHindiUi ? 'पहाड़े सीखें (Tables 1-20) 🌟' : 'Learn Tables (1 to 20) 🌟',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isHindiUi ? 'नया' : 'NEW',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isHindiUi
                        ? 'बोलकर सीखें, 3D कार्ड्स, खाली स्थान व स्पीड टेस्ट!'
                        : 'Voice chant, visual dots, flashcards & speed quiz!',
                    style: const TextStyle(
                      color: Color(0xFFD1FAE5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isHindiUi ? 'सीखें' : 'Learn',
                style: const TextStyle(
                  color: Color(0xFF065F46),
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpellBeeBanner(BuildContext context, AppLocalizations strings) {
    final isHindiUi = strings.isHindi;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        SpellBeeHubScreen.push(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐝', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isHindiUi ? 'स्पेल बी चैंपियन 🏆' : 'Spell Bee Champion 🏆',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isHindiUi ? 'विशेष गेम' : 'FEATURED',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isHindiUi
                        ? 'आवाज से स्पेलिंग सीखें • 10 स्टेज एडवेंचर व 60s स्प्रिंट!'
                        : 'Interactive voice spelling • 10 Stage Adventure & 60s Sprint!',
                    style: const TextStyle(
                      color: Color(0xFFFEF3C7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isHindiUi ? 'खेलें' : 'Play',
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
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
    final strings = ref.strings;
    final isHindi = strings.isHindi;
    final isEnglish = widget.subjectId == 'english';
    final isScience = widget.subjectId == 'science';
    final isEvs = widget.subjectId == 'evs';
    final isHindiSub = widget.subjectId == 'hindi';
    final localizedSubjectName = isEnglish
        ? strings.english
        : isScience
            ? strings.science
            : isEvs
                ? strings.evsShort
                : isHindiSub
                    ? strings.hindiShort
                    : strings.math;

    final displayedTitle = isHindi
        ? HindiCurriculumTranslator.translateChapterTitle(chapter.title)
        : chapter.title;
    final displayedDescription = isHindi
        ? HindiCurriculumTranslator.translateChapterDescription(chapter.chapterId, chapter.description)
        : chapter.description;

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
                                  isHindi
                                      ? 'अध्याय ${chapter.chapterNumber}'
                                      : 'CHAPTER ${chapter.chapterNumber}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: widget.primaryColor,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              if (LiteratureReadingService.instance.isLiteratureChapter(chapter)) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    chapter.icon == '📜' ? (isHindi ? '📜 कविता' : '📜 Poem') : (isHindi ? '📖 कहानी' : '📖 Story'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFC2410C),
                                    ),
                                  ),
                                ),
                              ],
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
                                        isHindi
                                            ? '$solvedCount/${chapter.activities.length} हल किया ✓'
                                            : '$solvedCount/${chapter.activities.length} Solved ✓',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    );
                                  }
                                  return Text(
                                    isHindi
                                        ? '${chapter.activities.length} अभ्यास सेट'
                                        : '${chapter.activities.length} Practice Sets',
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
                            displayedTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (chapter.author != null && chapter.author!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              isHindi ? 'रचयिता: ${chapter.author}' : 'By ${chapter.author}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: widget.primaryColor,
                              ),
                            ),
                          ],
                          if (displayedDescription.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              displayedDescription,
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
                    Builder(
                      builder: (_) {
                        final isLit = LiteratureReadingService.instance.isLiteratureChapter(chapter);
                        return OutlinedButton.icon(
                          onPressed: () {
                            AudioService.instance.playSfx(CurioSfx.click);
                            if (isLit) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TextbookReaderScreen(
                                    chapter: chapter,
                                    profile: activeProfile,
                                    onStartPractice: () => _openChapter(chapter),
                                  ),
                                ),
                              );
                            } else {
                              ConceptLessonSheet.show(
                                context,
                                chapter: chapter,
                                profile: activeProfile,
                                onStartPractice: () => _openChapter(chapter),
                              );
                            }
                          },
                          icon: Text(chapter.icon == '📜' ? '📜' : '📖', style: const TextStyle(fontSize: 14)),
                          label: Text(
                            isLit
                                ? (chapter.icon == '📜'
                                    ? (isHindi ? 'कविता पढ़ें' : 'Read Poem')
                                    : (isHindi ? 'कहानी पढ़ें' : 'Read Story'))
                                : (isHindi ? 'सीखें (Learn)' : 'Learn'),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC2410C),
                            backgroundColor: const Color(0xFFFFF7ED),
                            side: const BorderSide(color: Color(0xFFFDBA74), width: 1.2),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        AudioService.instance.playSfx(CurioSfx.click);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TimedExamScreen(
                              chapter: chapter,
                              subjectId: widget.subjectId,
                              subjectName: localizedSubjectName,
                              primaryColor: widget.primaryColor,
                            ),
                          ),
                        );
                      },
                      icon: const Text('📝', style: TextStyle(fontSize: 13)),
                      label: Text(
                        isHindi ? 'टेस्ट' : 'Test',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.primaryColor,
                        side: BorderSide(color: widget.primaryColor.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _practiceChapter(chapter),
                      icon: Text(
                        isHindi ? 'अभ्यास खेलें' : 'Practice & Play',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
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

  Widget _buildLanguageTrackSelector(StudentProfile activeProfile, AppLocalizations strings) {
    final isLiterature = _activeLanguageTrack == 'literature';
    final isHindiUi = strings.isHindi;

    final litTitle = widget.subjectId == 'hindi'
        ? (isHindiUi ? 'पाठ्यपुस्तक (Reader)' : 'Literature Reader')
        : (isHindiUi ? 'साहित्य (Reader)' : 'Literature Reader');

    final gramTitle = widget.subjectId == 'hindi'
        ? (isHindiUi ? 'व्याकरण (Grammar)' : 'Hindi Grammar')
        : (isHindiUi ? 'व्याकरण (Grammar)' : 'English Grammar');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (_activeLanguageTrack != 'literature') {
                  AudioService.instance.playSfx(CurioSfx.click);
                  setState(() {
                    _activeLanguageTrack = 'literature';
                  });
                  _loadCurriculum();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isLiterature ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLiterature
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        litTitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isLiterature ? FontWeight.w900 : FontWeight.w700,
                          color: isLiterature ? widget.primaryColor : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (_activeLanguageTrack != 'grammar') {
                  AudioService.instance.playSfx(CurioSfx.click);
                  setState(() {
                    _activeLanguageTrack = 'grammar';
                  });
                  _loadCurriculum();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: !isLiterature ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isLiterature
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✍️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        gramTitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: !isLiterature ? FontWeight.w900 : FontWeight.w700,
                          color: !isLiterature ? widget.primaryColor : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarInfoBanner(AppLocalizations strings) {
    final isHindiUi = strings.isHindi;
    final isHindiSub = widget.subjectId == 'hindi';

    final text = isHindiSub
        ? (isHindiUi
            ? 'सम्पूर्ण हिंदी व्याकरण व रचना — संज्ञा, सर्वनाम, क्रिया, काल, विलोम, पर्यायवाची आदि।'
            : 'Complete Hindi Grammar & Composition — Nouns, Pronouns, Verbs, Tenses & Vocabulary.')
        : (isHindiUi
            ? 'सम्पूर्ण अंग्रेजी व्याकरण व रचना — Nouns, Verbs, Tenses, Prepositions व Skills।'
            : 'Universal English Grammar & Skills — Nouns, Verbs, Tenses, Prepositions & Composition.');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: widget.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('✍️', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindiSub
                      ? (isHindiUi ? 'व्याकरण पुस्तक' : 'Grammar & Composition')
                      : (isHindiUi ? 'ग्रामर पुस्तक' : 'English Grammar & Composition'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublisherSelectorBar(StudentProfile activeProfile, AppLocalizations strings) {
    final publishers = _repository.getAvailablePublishers(
      subjectId: widget.subjectId,
      studentClass: activeProfile.studentClass,
      board: activeProfile.board,
    );
    if (publishers.isEmpty) return const SizedBox.shrink();

    final currentPref = LocalStorageService.instance.getPreferredPublisher(widget.subjectId);
    final defaultPub = activeProfile.board == BoardType.icse
        ? (widget.subjectId == 'english' ? 'orient_blackswan' : (widget.subjectId == 'hindi' ? 'miranda' : 'all'))
        : (activeProfile.board == BoardType.cbse ? 'ncert' : 'all');
    final activeId = currentPref ?? defaultPub;
    final activeItem = publishers.firstWhere(
      (p) => p['id'] == activeId,
      orElse: () => publishers.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openPublisherBottomSheet(publishers, activeId, strings),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.menu_book_rounded, color: widget.primaryColor, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            strings.isHindi ? 'पाठ्यपुस्तक (Book)' : 'School Book',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activeItem['badge'] ?? '',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: widget.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activeItem['book'] ?? activeItem['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.isHindi ? 'बदलें' : 'Change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: widget.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: widget.primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPublisherBottomSheet(
    List<Map<String, String>> publishers,
    String currentId,
    AppLocalizations strings,
  ) {
    AudioService.instance.playSfx(CurioSfx.click);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text('🎒', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.isHindi ? 'स्कूल की पाठ्यपुस्तक चुनें' : 'Choose Your School Book',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          strings.isHindi
                              ? 'पाठ्यक्रम आपके बच्चे की स्कूल पुस्तक से मेल खाएगा'
                              : 'Curio Academy matches your child’s actual school bag!',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...publishers.map((pub) {
                final isSelected = pub['id'] == currentId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      AudioService.instance.playSfx(CurioSfx.correctCheer);
                      await LocalStorageService.instance.savePreferredPublisher(widget.subjectId, pub['id']!);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted) {
                        _loadCurriculum();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? widget.primaryColor.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? widget.primaryColor : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? widget.primaryColor : const Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                isSelected ? Icons.check_rounded : Icons.menu_book_rounded,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pub['name'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? widget.primaryColor : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        pub['badge'] ?? '',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pub['book'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
