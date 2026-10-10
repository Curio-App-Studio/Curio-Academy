import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import 'spell_bee_adventure_screen.dart';
import 'spell_bee_sprint_screen.dart';
import 'spell_bee_mock_exam_screen.dart';
import 'spell_bee_mcq_screen.dart';
import 'spell_bee_mistakes_screen.dart';
import 'spell_bee_syllabus_screen.dart';

/// Central Hub for Curio Spell Bee
/// Offers both Level Adventure Mode (Stages 1-10) and 60-Second Speed Spell Bee Sprint.
class SpellBeeHubScreen extends ConsumerWidget {
  const SpellBeeHubScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpellBeeHubScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(studentProfileProvider);
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // Soft warm honey amber
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF78350F)),
          onPressed: () {
            AudioService.instance.playSfx(CurioSfx.click);
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            const Text('🐝', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Text(
              isHindi ? 'स्पेल बी चैंपियन' : 'Spell Bee Champion',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Color(0xFF78350F),
              ),
            ),
          ],
        ),
        actions: [
          // Audio Mute Toggle Button
          ValueListenableBuilder<bool>(
            valueListenable: AudioService.instance.muteNotifier,
            builder: (context, isMuted, _) {
              return IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: const Color(0xFF78350F),
                ),
                tooltip: isMuted ? 'Unmute Audio' : 'Mute Audio',
                onPressed: () {
                  AudioService.instance.toggleMute();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner with Bee & Grade Badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      ),
                      child: const Center(
                        child: Text('🐝', style: TextStyle(fontSize: 38)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${activeProfile.studentClass.label} • ${activeProfile.board.code}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isHindi ? 'सुनो, समझो और सही स्पेलिंग लिखो!' : 'Listen, Understand & Spell Correctly!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHindi
                                ? 'ध्वन्यात्मक उच्चारण और उदाहरण वाक्य के साथ।'
                                : 'With native audio voice & sentence hints.',
                            style: const TextStyle(
                              color: Color(0xFFFEF3C7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Official Exam Preparation
              Text(
                isHindi ? '🏆 प्रतियोगिता परीक्षा तैयारी (Exam Prep)' : '🏆 Competition Exam Preparation',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF78350F),
                ),
              ),
              const SizedBox(height: 12),

              // Mock Exam Card
              _buildModeCard(
                context: context,
                icon: '🎓',
                title: isHindi ? 'आधिकारिक मॉक परीक्षा (Mock Exam)' : 'Official Spell Bee Mock Exam',
                subtitle: isHindi
                  ? 'टाइम्ड परीक्षा, परीक्षक की आवाज, रूट वर्ड्स और प्रमाणपत्र स्कोरकार्ड।'
                  : 'Timed simulation with pronouncer, etymology clues, and certified scorecard!',
                gradientColors: const [Color(0xFF4F46E5), Color(0xFF3730A3)],
                badgeText: isHindi ? 'मॉक टेस्ट 📜' : 'OFFICIAL SIMULATION 📜',
                badgeColor: const Color(0xFF312E81),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  SpellBeeMockExamScreen.push(context);
                },
              ),
              const SizedBox(height: 14),

              // Spot the Correct Spelling MCQ Card
              _buildModeCard(
                context: context,
                icon: '🎯',
                title: isHindi ? 'सही स्पेलिंग पहचानो (MCQ)' : 'Spot The Correct Spelling',
                subtitle: isHindi
                  ? 'सिल्वरज़ोन व ओलंपियाड शैली 4-विकल्प परीक्षा। तुरंत फीडबैक।'
                  : 'Olympiad & SilverZone IEO style 4-choice questions with instant feedback.',
                gradientColors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                badgeText: isHindi ? 'ओलंपियाड 🌟' : 'OLYMPIAD MCQ 🎯',
                badgeColor: const Color(0xFF115E59),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  SpellBeeMcqScreen.push(context);
                },
              ),
              const SizedBox(height: 14),

              // Spelling Mistake Vault Card
              ValueListenableBuilder<List<String>>(
                valueListenable: LocalStorageService.instance.spellBeeMistakesNotifier,
                builder: (context, mistakes, _) {
                  final count = mistakes.length;
                  return _buildModeCard(
                    context: context,
                    icon: '📝',
                    title: isHindi ? 'मिस्टेक वॉल्ट व फ्लैशकार्ड्स' : 'Mistake Vault & Flashcards',
                    subtitle: count > 0
                      ? '${isHindi ? "समीक्षा के लिए" : "Pending words to review"}: $count words'
                      : (isHindi ? 'सभी कठिन शब्द हल हो चुके हैं!' : 'No mistakes pending! Practice to keep sharp.'),
                    gradientColors: count > 0
                      ? const [Color(0xFFDC2626), Color(0xFFB91C1C)]
                      : const [Color(0xFF64748B), Color(0xFF475569)],
                    badgeText: count > 0 ? '$count WORDS TO REVIEW ⚠️' : 'ALL MASTERED ✨',
                    badgeColor: count > 0 ? const Color(0xFF991B1B) : const Color(0xFF334155),
                    onTap: () {
                      AudioService.instance.playSfx(CurioSfx.click);
                      SpellBeeMistakesScreen.push(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 14),

              // Competition Word Banks Card (500+ Words)
              _buildModeCard(
                context: context,
                icon: '📖',
                title: isHindi ? 'प्रतियोगिता वर्ड बैंक (500+ Words)' : 'Competition Word Banks (500+)',
                subtitle: isHindi
                  ? 'कक्षावार शब्दकोश, उच्चारण, मूल भाषा (Latin, Greek) व अर्थ।'
                  : 'Official word banks by grade with root origins (Latin/Greek), phonetics & audio.',
                gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                badgeText: 'WORD BANKS 📚',
                badgeColor: const Color(0xFF5B21B6),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  SpellBeeSyllabusScreen.push(context);
                },
              ),
              const SizedBox(height: 24),

              // Section 2: Practice & Arcade Modes
              Text(
                isHindi ? '🎮 अभ्यास व आर्केड (Arcade & Practice)' : '🎮 Practice & Arcade Modes',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF78350F),
                ),
              ),
              const SizedBox(height: 12),

              // Mode: Level Adventure (Stage by Stage with 3-Star Rating)
              _buildModeCard(
                context: context,
                icon: '🗺️',
                title: isHindi ? 'लेवल एडवेंचर (Stages 1-10)' : 'Level Adventure (Stages 1–10)',
                subtitle: isHindi
                    ? 'स्तर दर स्तर शब्दों की यात्रा। 3-स्टार रेटिंग जीतें!'
                    : '10 progressive stages tailored for ${activeProfile.studentClass.label}. Earn up to 3 stars per stage!',
                gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                badgeText: isHindi ? 'अनुशंसित 🌟' : 'PROGRESSION 🌟',
                badgeColor: const Color(0xFF047857),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  SpellBeeAdventureScreen.push(context);
                },
              ),
              const SizedBox(height: 14),

              // Mode: 60-Second Speed Spell Bee Sprint
              ValueListenableBuilder<int>(
                valueListenable: LocalStorageService.instance.spellBeeHighScoreNotifier,
                builder: (context, highScore, _) {
                  return _buildModeCard(
                    context: context,
                    icon: '⚡',
                    title: isHindi ? '60-सेकंड स्पीड स्प्रिंट' : '60-Second Speed Sprint',
                    subtitle: highScore > 0
                        ? '${isHindi ? "सर्वश्रेष्ठ स्कोर" : "Your Best Score"}: 🏆 $highScore pts'
                        : (isHindi
                            ? 'तेज़ गति से स्पेलिंग लिखें और कॉम्बो स्ट्रीक बनाएं!'
                            : 'Rapid-fire spelling sprint with combo multipliers & high scores!'),
                    gradientColors: const [Color(0xFFFF7B25), Color(0xFFEA580C)],
                    badgeText: highScore > 0 ? 'BEST: 🏆 $highScore' : 'ARCADE MODE ⚡',
                    badgeColor: const Color(0xFFC2410C),
                    onTap: () {
                      AudioService.instance.playSfx(CurioSfx.click);
                      SpellBeeSprintScreen.push(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Quick How-To-Play Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'कैसे खेलें?' : 'How to Play Spell Bee',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRuleRow('🔊', isHindi ? 'आवाज से शब्द और वाक्य सुनने के लिए स्पीकर पर टैप करें।' : 'Tap Speaker 🔊 to hear the word & sentence pronounced clearly.'),
                    const SizedBox(height: 6),
                    _buildRuleRow('🔤', isHindi ? 'नीचे दिए गए अक्षरों को सही क्रम में टैप करके शब्द बनाएं।' : 'Tap letter tiles in order to build the word in slots.'),
                    const SizedBox(height: 6),
                    _buildRuleRow('⭐', isHindi ? 'बिना गलती के स्पेलिंग पूरी करने पर अतिरिक्त बोनस स्टार्स पाएं!' : 'Earn bonus stars & Discovery Points for perfect streaks!'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildRuleRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF52525B),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 26)),
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
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
