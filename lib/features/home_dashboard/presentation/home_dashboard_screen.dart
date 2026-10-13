import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../core/theme/grade_tier_extension.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/grade_tier.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../../shared/components/language_switch_button.dart';
import '../../../shared/components/scratchpad_drawer.dart';
import '../../settings/presentation/voice_settings_sheet.dart';
import '../../subject_chapters/presentation/subject_chapters_screen.dart';
import '../../../shared/dialogs/avatar_selector_dialog.dart';
import '../../../core/services/in_app_update_service.dart';
import '../../../core/services/in_app_review_service.dart';
import '../../membership/presentation/membership_paywall_sheet.dart';
import '../../arcade/presentation/speed_math_arcade_screen.dart';
import '../../arcade/presentation/split_screen_duel_screen.dart';
import '../../adventure_map/presentation/adventure_island_screen.dart';
import '../../spell_bee/presentation/spell_bee_hub_screen.dart';
import '../../math_tables/presentation/math_tables_screen.dart';
import '../../phonics_abc/presentation/phonics_abc_screen.dart';
import '../../activities/bubble_pop/presentation/bubble_pop_screen.dart';
import '../../activities/card_match/presentation/card_match_screen.dart';
import '../../rhymes_stories/presentation/rhymes_stories_screen.dart';
import '../../../shared/dialogs/data_management_sheet.dart';
import '../../tracing/presentation/tracing_screen.dart';
import '../../smart_revision/presentation/smart_revision_screen.dart';
import '../../feedback/presentation/feedback_sheet.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InAppUpdateService.instance.checkForUpdate(context: context);
      _checkMilestoneReview();
    });
  }

  Future<void> _checkMilestoneReview() async {
    final stars = LocalStorageService.instance.totalStars;
    final shouldShow = await InAppReviewService.instance.shouldPromptMilestoneReview(stars);
    if (shouldShow && mounted) {
      await InAppReviewService.instance.showMilestoneDialog(context);
    }
  }

  void _openEditProfile(BuildContext context) {
    AudioService.instance.playSfx(CurioSfx.click);
    AvatarSelectorDialog.show(context);
  }

  void _openScratchpad(BuildContext context) {
    AudioService.instance.playSfx(CurioSfx.click);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScratchpadDrawer(),
    );
  }

  void _openSubject(
    BuildContext context, {
    required String subjectId,
    required String subjectName,
    required String emoji,
    required Color primaryColor,
  }) {
    AudioService.instance.playSfx(CurioSfx.click);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectChaptersScreen(
          subjectId: subjectId,
          subjectName: subjectName,
          emoji: emoji,
          primaryColor: primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(studentProfileProvider);
    final tierTheme = Theme.of(context).extension<CurioTierTheme>() ?? CurioTierTheme.primaryBuilder();
    final theme = Theme.of(context);
    final strings = ref.strings;

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
                _openScratchpad(context);
              } else if (value == 'edit_profile' || value == 'board_class') {
                _openEditProfile(context);
              } else if (value == 'membership') {
                AudioService.instance.playSfx(CurioSfx.click);
                MembershipPaywallSheet.show(context);
              } else if (value == 'tracing') {
                AudioService.instance.playSfx(CurioSfx.click);
                TracingScreen.push(context);
              } else if (value == 'revision') {
                AudioService.instance.playSfx(CurioSfx.click);
                SmartRevisionScreen.push(context);
              } else if (value == 'feedback') {
                AudioService.instance.playSfx(CurioSfx.click);
                FeedbackBottomSheet.show(context);
              } else if (value == 'data_settings') {
                AudioService.instance.playSfx(CurioSfx.click);
                DataManagementSheet.show(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'revision',
                child: Row(
                  children: [
                    const Icon(Icons.psychology_rounded, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (ref.strings.isHindi ? 'स्मार्ट रिवीजन और फ्लैशकार्ड 🧠' : 'Smart Study & Revision 🧠'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tracing',
                child: Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (ref.strings.isHindi ? 'सुलेख और ट्रेसिंग ✏️' : 'Handwriting & Tracing ✏️'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'membership',
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFF9800), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (ref.strings.isHindi ? 'विज्ञापन हटाएं / VIP 👑' : 'Remove Ads / VIP 👑'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'voice',
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over_rounded, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(strings.voiceCompanion, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
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
                      Expanded(
                        child: Text(strings.scratchpad, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'edit_profile',
                child: Row(
                  children: [
                    const Icon(Icons.account_circle_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(strings.editProfile, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'feedback',
                child: Row(
                  children: [
                    const Icon(Icons.rate_review_rounded, color: Color(0xFF8B5CF6), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (ref.strings.isHindi ? 'प्रतिक्रिया और सुझाव 💬' : 'Feedback & Suggestions 💬'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'data_settings',
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (ref.strings.isHindi ? 'डेटा और रीसेट विकल्प 🛡️' : 'Data & Reset Options 🛡️'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
          child: activeProfile.studentClass.tier == GradeTier.earlyExplorer
              ? _buildKidsEarlyExplorerDashboard(context, theme, activeProfile, ref)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Student Greeting Card
                    _buildStudentGreetingCard(context, theme, activeProfile, ref),

                    const SizedBox(height: 14),

                    // 2. Total Stars Achievement Card
                    _buildTotalStarsHeroCard(ref),

                    // 2b. Mistake Vault Card
                    ValueListenableBuilder<int>(
                      valueListenable: LocalStorageService.instance.mistakeCountNotifier,
                      builder: (context, mistakeCount, _) {
                        if (mistakeCount == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: _buildMistakeVaultCard(context, mistakeCount, ref),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // 3. Subject Selection Cards (Tapping opens dedicated chapters screen)
                    _buildSubjectSelectionSection(context, theme, activeProfile, ref),

                    const SizedBox(height: 18),

                    // 4. Arcade & Multiplayer Fun Zone
                    _buildArcadeZoneSection(context, ref),

                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // DEDICATED EARLY EXPLORER DASHBOARD (LKG, UKG & CLASS 1)
  // -------------------------------------------------------------
  Widget _buildKidsEarlyExplorerDashboard(
    BuildContext context,
    ThemeData theme,
    StudentProfile activeProfile,
    WidgetRef ref,
  ) {
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Playful Big Mascot Greeting Card
        _buildKidsMascotHeroGreeting(context, activeProfile, strings, isHindi),

        const SizedBox(height: 14),

        // 2. Star & Sticker Celebration Pill
        _buildKidsStarCelebrationBar(isHindi),

        const SizedBox(height: 16),

        // 3. Interactive Mini-Games Front & Center: Direct 1-tap entry into fun games
        _buildKidsInteractiveMiniGamesSection(context, activeProfile, isHindi),

        const SizedBox(height: 18),

        // 4. Featured Hero: A for Apple Phonics World Banner
        _buildKidsPhonicsHeroBanner(context, isHindi),

        const SizedBox(height: 18),

        // 5. Picture/Emoji-Rich Discovery Cards (Numbers & Shapes, ABC & Phonics, Rhymes & Stories, Nature & Animals, Akshar Varnamala)
        _buildKidsDiscoveryCardsSection(context, activeProfile, strings, isHindi),

        const SizedBox(height: 18),

        // 6. Spell Bee Voice Adventure Bonus
        _buildKidsSpellBeeBanner(context, isHindi),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildKidsMascotHeroGreeting(
    BuildContext context,
    StudentProfile activeProfile,
    AppLocalizations strings,
    bool isHindi,
  ) {
    final name = activeProfile.studentName;
    final spokenGreeting = isHindi
        ? 'नमस्ते $name! आज हम A फॉर Apple और 1 2 3 सीखेंगे!'
        : 'Hello $name! Let\'s learn A for Apple and 1 2 3 today!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mascot Avatar with Change button
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              AudioService.instance.playSfx(CurioSfx.click);
              AvatarSelectorDialog.show(context);
            },
            child: Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      activeProfile.avatarIcon.isNotEmpty ? activeProfile.avatarIcon : '🦁',
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded, size: 12, color: Color(0xFFD97706)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isHindi ? 'नमस्ते $name! 👋' : 'Hello $name! 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF78350F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('🌟', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activeProfile.studentClass.label,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activeProfile.board.name.toUpperCase(),
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF4338CA)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isHindi
                      ? 'आज क्या खेलेंगे? A B C या 1 2 3?'
                      : 'Ready to play? A B C or 1 2 3?',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),

          // Big Talking Voice Button
          Material(
            color: const Color(0xFFF59E0B),
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                AudioService.instance.playSfx(CurioSfx.click);
                AudioService.instance.speakPrompt(spokenGreeting);
              },
              child: const Padding(
                padding: EdgeInsets.all(11.0),
                child: Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKidsStarCelebrationBar(bool isHindi) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStorageService.instance.totalStarsNotifier,
      builder: (context, totalStars, _) {
        return ValueListenableBuilder<int>(
          valueListenable: LocalStorageService.instance.totalPointsNotifier,
          builder: (context, totalPoints, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'कुल सितारे' : 'Total Stars',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            Text(
                              isHindi ? 'कुल कमाए सितारे' : 'Total Stars Earned',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalStars',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isHindi ? 'सुपर एक्सप्लोरर 🏆' : 'Super Explorer 🏆',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '$totalPoints',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isHindi ? 'अंक' : 'Points',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKidsPhonicsHeroBanner(BuildContext context, bool isHindi) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        PhonicsAbcScreen.push(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5253)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Big Apple & Alphabet badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('🍎', style: TextStyle(fontSize: 34)),
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
                          isHindi ? 'A फॉर ऍपल, B फॉर बॉय' : 'A for Apple, B for Boy',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🔤 PHONICS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isHindi
                        ? 'आवाज़ से A-Z सीखें • टच करें और सुनें 🎵'
                        : 'Phonics & Letter Sounds A-Z • Tap to hear 🎵',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFE8E8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidsInteractiveMiniGamesSection(
    BuildContext context,
    StudentProfile activeProfile,
    bool isHindi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                isHindi ? '🎮 मजेदार मिनी गेम्स' : '🎮 Interactive Mini-Games',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '1-TAP PLAY ⚡',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF047857),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          isHindi
              ? 'सीधे खेलें: बबल्स फोड़ें, कार्ड मिलाएँ और खजाना खोजें!'
              : 'Direct 1-tap play: Pop bubbles, match cards & find treasure!',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // 3 Games Front & Center: Bubble Pop 🫧, Card Match 🃏, Treasure Island Map 🏝️
        Row(
          children: [
            // Balloon / Bubble Pop 🫧
            Expanded(
              child: _buildKidsMiniGameCard(
                title: isHindi ? 'बबल पॉप 🫧' : 'Bubble Pop 🫧',
                subtitle: isHindi ? 'गुब्बारे फोड़ें' : 'Balloon Pop 🎈',
                badgeText: isHindi ? 'खेलें ▶' : 'PLAY ▶',
                emoji: '🫧',
                gradient: const [Color(0xFF06B6D4), Color(0xFF0284C7)],
                shadowColor: const Color(0xFF0284C7),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BubblePopScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Magic Card Match 🃏
            Expanded(
              child: _buildKidsMiniGameCard(
                title: isHindi ? 'कार्ड मैच 🃏' : 'Card Match 🃏',
                subtitle: isHindi ? 'जादुई जोड़े' : 'Magic Match 🎴',
                badgeText: isHindi ? 'खेलें ▶' : 'PLAY ▶',
                emoji: '🃏',
                gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                shadowColor: const Color(0xFF6366F1),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CardMatchScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Treasure Island Map 🏝️
            Expanded(
              child: _buildKidsMiniGameCard(
                title: isHindi ? 'द्वीप नक्शा 🏝️' : 'Island Map 🏝️',
                subtitle: isHindi ? 'खजाने की खोज' : 'Treasure Quest',
                badgeText: isHindi ? 'नक्शा 🗺️' : 'MAP 🗺️',
                emoji: '🏝️',
                gradient: const [Color(0xFF10B981), Color(0xFF0D9488)],
                shadowColor: const Color(0xFF0D9488),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  _openAdventureIslandFromDashboard(context, activeProfile);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKidsMiniGameCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required String emoji,
    required List<Color> gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: shadowColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidsDiscoveryCardsSection(
    BuildContext context,
    StudentProfile activeProfile,
    AppLocalizations strings,
    bool isHindi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                isHindi ? 'विषय चुनें 🎨' : 'Pick a Subject 🎨',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${activeProfile.studentClass.label} 🌟',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          isHindi
              ? 'तस्वीरों वाले खोज कार्ड: संख्याएं, अक्षर, कहानियां और प्रकृति!'
              : 'Picture Discovery Cards: Numbers, phonics, stories & nature!',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // 1. Numbers & Shapes 🎈 + 2. ABC & Phonics 🔤
        Row(
          children: [
            Expanded(
              child: _buildKidsSubjectChunkyCard(
                categoryTag: 'Math',
                title: isHindi ? 'संख्याएं व आकार 🎈' : 'Numbers & Shapes 🎈',
                subtitle: isHindi ? '1 2 3 और आकृतियां 🎈' : '1 2 3 & Shapes 🎈',
                emoji: '🎈',
                badgeText: '1 2 3 🔢',
                gradient: const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                borderColor: const Color(0xFFFECACA),
                accentColor: const Color(0xFFEF4444),
                onTap: () => _openSubject(
                  context,
                  subjectId: 'math',
                  subjectName: isHindi ? 'संख्याएं और आकार' : 'Numbers & Shapes',
                  emoji: '🎈',
                  primaryColor: const Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKidsSubjectChunkyCard(
                categoryTag: 'English',
                title: isHindi ? 'ABC व फोनिक्स 🔤' : 'ABC & Phonics 🔤',
                subtitle: isHindi ? 'A फॉर ऍपल, A-Z आवाजें 🎵' : 'A for Apple, Phonics 🎵',
                emoji: '🔤',
                badgeText: 'A-Z 🎵',
                gradient: const [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                borderColor: const Color(0xFFC7D2FE),
                accentColor: const Color(0xFF6366F1),
                onTap: () {
                  PhonicsAbcScreen.push(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Rhymes & Stories 📖 + 4. Nature & Animals 🐾
        Row(
          children: [
            Expanded(
              child: _buildKidsSubjectChunkyCard(
                title: isHindi ? 'कविताएं व कथाएं 📖' : 'Rhymes & Stories 📖',
                subtitle: isHindi ? 'बालगीत और कहानियां 🎶' : 'Songs & Fun Tales 🎶',
                emoji: '📖',
                badgeText: 'STORIES 📚',
                gradient: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                borderColor: const Color(0xFFDDD6FE),
                accentColor: const Color(0xFF7C3AED),
                onTap: () {
                  RhymesStoriesScreen.push(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKidsSubjectChunkyCard(
                title: isHindi ? 'प्रकृति व जानवर 🐾' : 'Nature & Animals 🐾',
                subtitle: isHindi ? 'पशु, पक्षी और पौधे 🌿' : 'Animals & Nature 🌿',
                emoji: '🐾',
                badgeText: 'ANIMALS 🌿',
                gradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                borderColor: const Color(0xFFA7F3D0),
                accentColor: const Color(0xFF059669),
                onTap: () => _openSubject(
                  context,
                  subjectId: 'evs',
                  subjectName: isHindi ? 'प्रकृति और जानवर' : 'Nature & Animals',
                  emoji: '🐾',
                  primaryColor: const Color(0xFF059669),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 5. Akshar Varnamala 🇮🇳 (Wide Discovery Banner)
        _buildKidsVarnamalaBannerCard(context, strings, isHindi),

        const SizedBox(height: 12),

        // 6. Handwriting & Tracing Canvas ✏️ (Wide Discovery Banner)
        _buildKidsTracingBannerCard(context, strings, isHindi),
      ],
    );
  }

  Widget _buildKidsVarnamalaBannerCard(
    BuildContext context,
    AppLocalizations strings,
    bool isHindi,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        _openSubject(
          context,
          subjectId: 'hindi',
          subjectName: isHindi ? 'अक्षर वर्णमाला' : 'Akshar Varnamala',
          emoji: '🇮🇳',
          primaryColor: const Color(0xFFEA580C),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFED7AA), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA580C).withValues(alpha: 0.12),
              blurRadius: 10,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Center(
                child: Text('🇮🇳', style: TextStyle(fontSize: 26)),
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
                          isHindi ? 'अक्षर वर्णमाला 🇮🇳' : 'Akshar Varnamala 🇮🇳',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEA580C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: const Text(
                          'अ आ इ 🥭',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isHindi
                        ? 'अ आ इ ई, स्वर, व्यंजन व सुंदर कविताएं 🥭'
                        : 'अ आ इ ई, Varnamala, Rhymes & Letters 🥭',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFEA580C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidsTracingBannerCard(
    BuildContext context,
    AppLocalizations strings,
    bool isHindi,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        TracingScreen.push(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
              blurRadius: 10,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Center(
                child: Text('✏️', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        isHindi ? 'सुलेख और ट्रेसिंग ✏️' : 'Letter & Number Tracing ✏️',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Text(
                          isHindi ? 'A-Z • 1-20 • क-ह' : 'ABC • 1 2 3 • क ख ग',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isHindi
                        ? 'उंगली से अक्षर और अंक लिखना सीखें • चमकीले क्रेयॉन 🌈'
                        : 'Practice writing letters & numbers with finger tracing 🌈',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF4338CA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidsSubjectChunkyCard({
    String? categoryTag,
    required String title,
    required String subtitle,
    required String emoji,
    required String badgeText,
    required List<Color> gradient,
    required Color borderColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (categoryTag != null) ...[
                          Text(
                            categoryTag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accentColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidsSpellBeeBanner(BuildContext context, bool isHindi) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        SpellBeeHubScreen.push(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('🐝', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'स्पेल बी वॉइस एडवेंचर 🐝' : 'Spell Bee Voice Adventure 🐝',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  Text(
                    isHindi ? 'आवाज से स्पेलिंग बोलना सीखें 🌟' : 'Speak letters & learn spelling with voice 🌟',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PLAY ▶',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 9.5,
                ),
              ),
            ),
          ],
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
                    const SizedBox(height: 6),
                    ValueListenableBuilder<int>(
                      valueListenable: LocalStorageService.instance.totalPointsNotifier,
                      builder: (context, totalPoints, _) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('⭐', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$totalStars',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF78350F),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    strings.totalStars,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('💎', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$totalPoints',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1E40AF),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    strings.isHindi ? 'पॉइंट्स' : 'Points',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E40AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<int>(
                              valueListenable: LocalStorageService.instance.streakNotifier,
                              builder: (context, streak, _) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFECDD3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🔥', style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$streak',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFBE123C),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        strings.dailyStreak,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF9F1239),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
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

  Widget _buildMistakeVaultCard(BuildContext context, int count, WidgetRef ref) {
    final strings = ref.strings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 22)),
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
                      strings.mistakeVault,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  strings.mistakeVaultSubtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC2410C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              AudioService.instance.playSfx(CurioSfx.click);
              SmartRevisionScreen.push(context, initialTabIndex: 0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.practiceMistakes,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArcadeZoneSection(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isHindi ? '🎮 आर्केड और गेम्स ज़ोन' : '🎮 Arcade & Fun Zone',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isHindi ? 'मल्टीप्लेयर' : 'Multiplayer',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF6D28D9)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isHindi ? 'रैपिड-फायर गणित चुनौतियां और 2-खिलाड़ी मुकाबला' : 'Rapid-fire math sprints & split-screen battles',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 1. Speed Math Card
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  SpeedMathArcadeScreen.push(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 26)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('60s', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isHindi ? 'स्पीड मैथ' : 'Speed Math',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      ValueListenableBuilder<int>(
                        valueListenable: LocalStorageService.instance.speedMathHighScoreNotifier,
                        builder: (context, highScore, _) {
                          return Text(
                            highScore > 0
                                ? '${isHindi ? "सर्वश्रेष्ठ" : "Best"}: 🏆 $highScore'
                                : (isHindi ? '60 सेकंड का स्प्रिंट' : '60s Math Sprint'),
                            style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. 2-Player Duel Card
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  SplitScreenDuelScreen.push(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7B25), Color(0xFFEA580C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7B25).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('⚔️', style: TextStyle(fontSize: 26)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('1 vs 1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isHindi ? '2-खिलाड़ी मुकाबला' : '2-Player Duel',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isHindi ? 'स्प्लिट स्क्रीन बैटल 🦁' : 'Split-Screen Duel 🦁',
                        style: const TextStyle(color: Color(0xFFFFEDD5), fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Spell Bee Champion Card
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            AudioService.instance.playSfx(CurioSfx.click);
            SpellBeeHubScreen.push(context);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🐝', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              isHindi ? 'स्पेल बी चैंपियन' : 'Spell Bee Champion',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                              isHindi ? 'नया 🌟' : 'NEW 🌟',
                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      ValueListenableBuilder<int>(
                        valueListenable: LocalStorageService.instance.spellBeeHighScoreNotifier,
                        builder: (context, highScore, _) {
                          return Text(
                            highScore > 0
                                ? '${isHindi ? "सर्वश्रेष्ठ" : "Best"}: 🏆 $highScore pts'
                                : (isHindi ? 'आवाज से स्पेलिंग सीखें • 10 स्टेज व 60s स्प्रिंट' : 'Voice Spelling • 10 Stages & 60s Sprint'),
                            style: const TextStyle(color: Color(0xFFFEF3C7), fontSize: 11.5, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Learn Tables (पहाड़े सीखें) Card
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            AudioService.instance.playSfx(CurioSfx.click);
            MathTablesScreen.push(context);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🔢', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              isHindi ? 'पहाड़े सीखें (1-20)' : 'Learn Tables (1 to 20)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                              isHindi ? 'नया 🌟' : 'NEW 🌟',
                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isHindi
                            ? 'बोलकर सीखें, 3D कार्ड्स, खाली स्थान व टेस्ट'
                            : 'Voice Chant, 3D Flashcards & Speed Test',
                        style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 11.5, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 4. Adventure Island Learning Path Map Card
        Consumer(
          builder: (context, ref, _) {
            final activeProfile = ref.watch(studentProfileProvider);
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                AudioService.instance.playSfx(CurioSfx.click);
                _openAdventureIslandFromDashboard(context, activeProfile);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.28),
                      blurRadius: 10,
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
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.map_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isHindi ? 'द्वीप यात्रा (Adventure Map)' : 'Adventure Island Map',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('QUEST 🗺️', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isHindi ? 'अध्याय नक्शा, खजाना और पाथवे एडवेंचर' : 'Visual chapter quest, treasure chests & avatar trail',
                            style: const TextStyle(color: Color(0xFFCCFBF1), fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _openAdventureIslandFromDashboard(BuildContext context, StudentProfile profile) {
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.map_rounded, color: Color(0xFF0D9488), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? 'द्वीप यात्रा चुनें' : 'Choose Adventure Island',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            isHindi ? 'विषय चुनें और अपनी यात्रा शुरू करें' : 'Select a subject to begin your quest map',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildIslandSubjectTile(
                  ctx,
                  subjectId: 'mathematics',
                  subjectName: strings.math,
                  emoji: '📐',
                  color: const Color(0xFF2563EB),
                  profile: profile,
                ),
                const SizedBox(height: 8),
                _buildIslandSubjectTile(
                  ctx,
                  subjectId: 'english',
                  subjectName: strings.english,
                  emoji: '📖',
                  color: const Color(0xFF7C3AED),
                  profile: profile,
                ),
                if (!profile.studentClass.isKindergarten) ...[
                  const SizedBox(height: 8),
                  _buildIslandSubjectTile(
                    ctx,
                    subjectId: 'science',
                    subjectName: strings.science,
                    emoji: '🔬',
                    color: const Color(0xFF059669),
                    profile: profile,
                  ),
                ],
                const SizedBox(height: 8),
                _buildIslandSubjectTile(
                  ctx,
                  subjectId: 'hindi',
                  subjectName: strings.hindiShort,
                  emoji: '🇮🇳',
                  color: const Color(0xFFEA580C),
                  profile: profile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIslandSubjectTile(
    BuildContext sheetContext, {
    required String subjectId,
    required String subjectName,
    required String emoji,
    required Color color,
    required StudentProfile profile,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        Navigator.pop(sheetContext);
        final defaultPub = profile.board == BoardType.icse
            ? (subjectId == 'english' ? 'orient_blackswan' : (subjectId == 'hindi' ? 'miranda' : null))
            : (profile.board == BoardType.cbse ? 'ncert' : null);
        final chapters = await CurriculumRepository().getChaptersForClass(
          profile.studentClass,
          board: profile.board,
          subjectId: subjectId,
          publisher: defaultPub,
        );
        if (mounted) {
          AdventureIslandScreen.push(
            context,
            chapters: chapters,
            subjectId: subjectId,
            subjectName: subjectName,
            emoji: emoji,
            primaryColor: color,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subjectName,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }



  Widget _buildStudentGreetingCard(
    BuildContext context,
    ThemeData theme,
    StudentProfile activeProfile,
    WidgetRef ref,
  ) {
    final strings = ref.strings;
    final greetingText = strings.formatGreeting(activeProfile.studentName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          // 1. Mascot Avatar Circle with Edit Badge & Tap to Change
          InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              AudioService.instance.playSfx(CurioSfx.click);
              AvatarSelectorDialog.show(context);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                  child: Center(
                    child: Text(
                      activeProfile.avatarIcon,
                      style: const TextStyle(fontSize: 27),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 11,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: LocalStorageService.instance.closedTesterNotifier,
                  builder: (context, isClosed, _) {
                    final isPremium = isClosed || LocalStorageService.instance.isPremiumUser;
                    if (!isPremium) return const SizedBox.shrink();
                    return Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text('👑', style: TextStyle(fontSize: 10)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 2. Greeting Title ("Hello <name> 👋") & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    AvatarSelectorDialog.show(context);
                  },
                  child: Text(
                    greetingText,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7C2D12),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),
                  Wrap(
                    spacing: 5,
                    runSpacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Text(
                          activeProfile.board.code,
                          style: const TextStyle(
                            color: Color(0xFFC2410C),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          AudioService.instance.playSfx(CurioSfx.click);
                          MembershipPaywallSheet.show(context);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: LocalStorageService.instance.closedTesterNotifier,
                          builder: (context, isClosed, _) {
                            final isPremium = isClosed || LocalStorageService.instance.isPremiumUser;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: isPremium
                                    ? const LinearGradient(
                                        colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                                      )
                                    : null,
                                color: isPremium ? null : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isPremium ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                                  width: 1,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPremium ? Icons.workspace_premium_rounded : Icons.star_border_rounded,
                                      size: 11,
                                      color: isPremium ? const Color(0xFFD97706) : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      isPremium ? 'PREMIUM USER 👑' : 'GET PREMIUM ⭐',
                                      style: TextStyle(
                                        color: isPremium ? const Color(0xFF92400E) : const Color(0xFF475569),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),

          // 3. Audio Narration Button
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 1,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                AudioService.instance.playSfx(CurioSfx.click);
                AudioService.instance.speakPrompt(
                  '$greetingText. ${strings.studentGreetingSubtitle}',
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



  Widget _buildSubjectSelectionSection(
    BuildContext context,
    ThemeData theme,
    StudentProfile activeProfile,
    WidgetRef ref,
  ) {
    final strings = ref.strings;
    final showScience = CurriculumRepository.isSubjectAvailableForClass('science', activeProfile.studentClass);
    final showEvs = CurriculumRepository.isSubjectAvailableForClass('evs', activeProfile.studentClass);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                strings.selectSubjectTitle,
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
            Text(
              '${activeProfile.studentClass.label} Syllabus',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSubjectCard(
                key: const Key('subject_card_math'),
                title: strings.math,
                subtitle: strings.mathSubtitle,
                emoji: '📐',
                primaryColor: const Color(0xFFFF7B25),
                lightBgColor: const Color(0xFFFFF4EC),
                actionText: 'View Chapters ➔',
                onTap: () => _openSubject(
                  context,
                  subjectId: 'math',
                  subjectName: strings.math,
                  emoji: '📐',
                  primaryColor: const Color(0xFFFF7B25),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSubjectCard(
                key: const Key('subject_card_english'),
                title: strings.english,
                subtitle: strings.englishSubtitle,
                emoji: '📚',
                primaryColor: const Color(0xFF6366F1),
                lightBgColor: const Color(0xFFEEF2FF),
                actionText: 'View Chapters ➔',
                onTap: () => _openSubject(
                  context,
                  subjectId: 'english',
                  subjectName: strings.english,
                  emoji: '📚',
                  primaryColor: const Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        // Secondary Subject Row(s)
        if (showScience && showEvs) ...[
          // Class 3-5: Science & EVS + full width Hindi
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSubjectCard(
                  title: strings.science,
                  subtitle: strings.scienceSubtitle,
                  emoji: '🔬',
                  primaryColor: const Color(0xFF10B981),
                  lightBgColor: const Color(0xFFECFDF5),
                  actionText: 'View Chapters ➔',
                  onTap: () => _openSubject(
                    context,
                    subjectId: 'science',
                    subjectName: strings.science,
                    emoji: '🔬',
                    primaryColor: const Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSubjectCard(
                  title: strings.evsShort,
                  subtitle: strings.evsSubtitle,
                  emoji: '🌿',
                  primaryColor: const Color(0xFF059669),
                  lightBgColor: const Color(0xFFECFDF5),
                  actionText: 'View Chapters ➔',
                  onTap: () => _openSubject(
                    context,
                    subjectId: 'evs',
                    subjectName: strings.evs,
                    emoji: '🌿',
                    primaryColor: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildHindiSubjectCard(context, strings, activeProfile),
        ] else if (showScience) ...[
          // Class 6-8: Science & Hindi (2x2 grid)
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSubjectCard(
                  title: strings.science,
                  subtitle: strings.scienceSubtitle,
                  emoji: '🔬',
                  primaryColor: const Color(0xFF10B981),
                  lightBgColor: const Color(0xFFECFDF5),
                  actionText: 'View Chapters ➔',
                  onTap: () => _openSubject(
                    context,
                    subjectId: 'science',
                    subjectName: strings.science,
                    emoji: '🔬',
                    primaryColor: const Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSubjectCard(
                  title: strings.hindiShort,
                  subtitle: strings.hindiSubtitle,
                  emoji: '🔤',
                  primaryColor: const Color(0xFFEA580C),
                  lightBgColor: const Color(0xFFFFF7ED),
                  actionText: 'View Chapters ➔',
                  onTap: () => _openSubject(
                    context,
                    subjectId: 'hindi',
                    subjectName: strings.hindi,
                    emoji: '🔤',
                    primaryColor: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
        ] else if (showEvs) ...[
          // LKG - Class 2: EVS & Hindi (2x2 grid)
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSubjectCard(
                  title: strings.hindiShort,
                  subtitle: strings.hindiSubtitle,
                  emoji: '🔤',
                  primaryColor: const Color(0xFFEA580C),
                  lightBgColor: const Color(0xFFFFF7ED),
                  actionText: 'View Chapters ➔',
                  onTap: () => _openSubject(
                    context,
                    subjectId: 'hindi',
                    subjectName: strings.hindi,
                    emoji: '🔤',
                    primaryColor: const Color(0xFFEA580C),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSubjectCard(
                  title: strings.evsShort,
                  subtitle: strings.evsSubtitle,
                  emoji: '🌿',
                  primaryColor: const Color(0xFF059669),
                  lightBgColor: const Color(0xFFECFDF5),
                  actionText: 'View Chapters ➔',
                  onTap: () => _openSubject(
                    context,
                    subjectId: 'evs',
                    subjectName: strings.evs,
                    emoji: '🌿',
                    primaryColor: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 10),
          _buildHindiSubjectCard(context, strings, activeProfile),
        ],
      ],
    );
  }

  Widget _buildSubjectCard({
    Key? key,
    required String title,
    required String subtitle,
    required String emoji,
    required Color primaryColor,
    required Color lightBgColor,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: lightBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: lightBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHindiSubjectCard(BuildContext context, AppLocalizations strings, StudentProfile profile) {
    const hindiColor = Color(0xFFEA580C);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        _openSubject(
          context,
          subjectId: 'hindi',
          subjectName: strings.hindi,
          emoji: '🔤',
          primaryColor: hindiColor,
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
              color: hindiColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔤', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          strings.hindi,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          strings.isHindi ? 'नया! ✨' : 'NEW! ✨',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings.hindiSubtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFEA580C)),
          ],
        ),
      ),
    );
  }
}
