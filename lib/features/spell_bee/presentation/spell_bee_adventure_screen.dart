import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../../services/ad_service.dart';
import '../domain/spell_bee_repository.dart';
import '../domain/spell_bee_word.dart';

/// Level Adventure Mode for Curio Spell Bee
/// Features 10 progressive stages per class with audio pronunciation, sentence clues, and tile builder.
class SpellBeeAdventureScreen extends ConsumerStatefulWidget {
  const SpellBeeAdventureScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpellBeeAdventureScreen()),
    );
  }

  @override
  ConsumerState<SpellBeeAdventureScreen> createState() => _SpellBeeAdventureScreenState();
}

class _SpellBeeAdventureScreenState extends ConsumerState<SpellBeeAdventureScreen> {
  int? _activeStage; // null when viewing stage selection grid, 1..10 when playing
  List<SpellBeeWord> _stageWords = [];
  int _currentWordIndex = 0;
  int _stageMistakes = 0;

  // Word Builder State
  List<String> _letterTiles = [];
  List<String?> _userSlots = [];
  List<bool> _tileUsed = [];
  bool _isChecking = false;
  bool _isSuccessAnim = false;
  bool _isErrorAnim = false;
  Timer? _speechTimer;
  final Set<String> _stageMistakeWordNames = {};

  @override
  void dispose() {
    _speechTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(studentProfileProvider);
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    if (_activeStage == null) {
      return _buildStageSelectionView(activeProfile, isHindi);
    } else {
      return _buildGameplayView(activeProfile, isHindi);
    }
  }

  // =========================================================================
  // STAGE SELECTION VIEW
  // =========================================================================

  Widget _buildStageSelectionView(dynamic activeProfile, bool isHindi) {
    final classLabel = activeProfile.studentClass.label;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
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
        title: Text(
          isHindi ? 'लेवल एडवेंचर मैप' : 'Adventure Stage Map',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Color(0xFF78350F)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subtitle banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Text('🍯', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isHindi
                            ? '$classLabel के लिए 10 चुनौतियां! प्रत्येक स्टेज में 3 स्टार जीतें।'
                            : '10 Stages for $classLabel! Clear each to earn 3 stars and unlock the next.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Grid of 10 Stages
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.25,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final stageNum = index + 1;
                  final stars = LocalStorageService.instance.getSpellBeeStageStars(classLabel, stageNum);
                  
                  // Stage 1 is always unlocked. Stage N unlocked if Stage N-1 has >= 1 star
                  final isUnlocked = stageNum == 1 ||
                      LocalStorageService.instance.getSpellBeeStageStars(classLabel, stageNum - 1) > 0;

                  return _buildStageCard(stageNum, stars, isUnlocked, isHindi);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildStageCard(int stageNum, int stars, bool isUnlocked, bool isHindi) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isUnlocked
          ? () {
              AudioService.instance.playSfx(CurioSfx.click);
              _startStage(stageNum);
            }
          : () {
              AudioService.instance.playSfx(CurioSfx.gentleWobble);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isHindi
                        ? 'इस स्टेज को अनलॉक करने के लिए पिछला स्टेज पूरा करें!'
                        : 'Complete Stage ${stageNum - 1} first to unlock this stage!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? (stars == 3
                  ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
                  : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]))
              : const LinearGradient(colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isUnlocked ? const Color(0xFF2563EB) : Colors.black).withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$stageNum',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 13),
                ),
                Icon(
                  isUnlocked ? (stars == 3 ? Icons.emoji_events_rounded : Icons.play_circle_fill_rounded) : Icons.lock_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const Spacer(),
            Text(
              isHindi ? 'स्टेज $stageNum' : 'Stage $stageNum',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            // Stars Rating (0 to 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (starIdx) {
                return Icon(
                  starIdx < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: starIdx < stars ? const Color(0xFFFDE047) : Colors.white38,
                  size: 20,
                );
              }),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // GAMEPLAY ENGINE
  // =========================================================================

  void _startStage(int stageNum) {
    final activeProfile = ref.read(studentProfileProvider);
    final words = SpellBeeRepository.instance.getWordsForStage(activeProfile.studentClass, stageNum);

    setState(() {
      _activeStage = stageNum;
      _stageWords = words;
      _currentWordIndex = 0;
      _stageMistakes = 0;
      _stageMistakeWordNames.clear();
    });

    _loadWord(_currentWordIndex);
  }

  void _loadWord(int index) {
    if (index >= _stageWords.length) {
      _finishStage();
      return;
    }

    final currentWord = _stageWords[index];
    final tiles = SpellBeeRepository.instance.generateLetterTiles(currentWord, maxDecoys: 2);

    setState(() {
      _currentWordIndex = index;
      _letterTiles = tiles;
      _userSlots = List.filled(currentWord.length, null);
      _tileUsed = List.filled(tiles.length, false);
      _isChecking = false;
      _isSuccessAnim = false;
      _isErrorAnim = false;
    });

    // Auto-speak the word cleanly on entrance
    _speechTimer?.cancel();
    _speechTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _speakCurrentWord();
      }
    });
  }

  SpellBeeWord get _currentWord => _stageWords[_currentWordIndex];

  void _speakCurrentWord() {
    AudioService.instance.speakPrompt(_currentWord.word);
  }

  void _speakInSentence() {
    final prompt = 'The word is ${_currentWord.word}. ${_currentWord.exampleSentence}. ${_currentWord.word}.';
    AudioService.instance.speakPrompt(prompt);
  }

  void _speakMeaning() {
    final prompt = '${_currentWord.word}. It means: ${_currentWord.definition}.';
    AudioService.instance.speakPrompt(prompt);
  }

  void _onLetterTileTap(int tileIndex) {
    if (_isChecking || _tileUsed[tileIndex]) return;

    // Find the first empty slot
    final emptySlotIndex = _userSlots.indexOf(null);
    if (emptySlotIndex == -1) return; // All slots filled

    AudioService.instance.playSfx(CurioSfx.bubblePop);

    setState(() {
      _userSlots[emptySlotIndex] = _letterTiles[tileIndex];
      _tileUsed[tileIndex] = true;
    });

    // Check if word is complete
    if (!_userSlots.contains(null)) {
      _verifyWord();
    }
  }

  void _onSlotTap(int slotIndex) {
    if (_isChecking) return;
    final letter = _userSlots[slotIndex];
    if (letter == null) return;

    AudioService.instance.playSfx(CurioSfx.click);

    // Return letter to pool
    setState(() {
      _userSlots[slotIndex] = null;
      // Re-enable first matching used tile
      for (int i = 0; i < _letterTiles.length; i++) {
        if (_letterTiles[i] == letter && _tileUsed[i]) {
          _tileUsed[i] = false;
          break;
        }
      }
    });
  }

  void _onBackspace() {
    if (_isChecking) return;
    // Find last filled slot
    for (int i = _userSlots.length - 1; i >= 0; i--) {
      if (_userSlots[i] != null) {
        _onSlotTap(i);
        break;
      }
    }
  }

  void _onClearAll() {
    if (_isChecking) return;
    AudioService.instance.playSfx(CurioSfx.click);
    setState(() {
      for (int i = 0; i < _userSlots.length; i++) {
        _userSlots[i] = null;
      }
      for (int i = 0; i < _tileUsed.length; i++) {
        _tileUsed[i] = false;
      }
    });
  }

  void _verifyWord() async {
    setState(() {
      _isChecking = true;
    });

    final constructed = _userSlots.join('').toUpperCase();
    final target = _currentWord.word.toUpperCase();

    if (constructed == target) {
      // SUCCESS!
      AudioService.instance.playSfx(CurioSfx.correctCheer);
      AudioService.instance.playSfx(CurioSfx.applause);
      setState(() {
        _isSuccessAnim = true;
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      _loadWord(_currentWordIndex + 1);
    } else {
      // INCORRECT!
      _stageMistakes++;
      _stageMistakeWordNames.add(_currentWord.word);
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      setState(() {
        _isErrorAnim = true;
      });

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      setState(() {
        _isChecking = false;
        _isErrorAnim = false;
      });
    }
  }

  void _finishStage() async {
    final activeProfile = ref.read(studentProfileProvider);
    final classLabel = activeProfile.studentClass.label;
    final stageNum = _activeStage!;

    // 0 mistakes = 3 stars, 1-2 mistakes = 2 stars, 3+ mistakes = 1 star
    int starsEarned = 3;
    if (_stageMistakes >= 3) {
      starsEarned = 1;
    } else if (_stageMistakes > 0) {
      starsEarned = 2;
    }

    // Persist stars & bonus rewards
    await LocalStorageService.instance.saveSpellBeeStageStars(classLabel, stageNum, starsEarned);
    await LocalStorageService.instance.addBonusStars(starsEarned * 2);
    await LocalStorageService.instance.addDiscoveryPoints(50);

    if (!mounted) return;

    AudioService.instance.playSfx(CurioSfx.starAward);
    AdService().showInterstitialAdIfReady();
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              isHindi ? 'स्टेज $stageNum पूरा हुआ!' : 'Stage $stageNum Complete!',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF78350F)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (starIdx) {
                return Icon(
                  starIdx < starsEarned ? Icons.star_rounded : Icons.star_border_rounded,
                  color: starIdx < starsEarned ? const Color(0xFFF59E0B) : Colors.grey.shade300,
                  size: 36,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi ? 'शानदार स्पेलिंग! आपने +50 अंक और बोनस स्टार्स जीते।' : 'Splendid spelling! You earned +50 Discovery Points and bonus stars.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),

            // Stage Words Review
            Row(
              children: [
                const Icon(Icons.fact_check_rounded, color: Color(0xFFB45309), size: 18),
                const SizedBox(width: 6),
                Text(
                  isHindi ? 'स्टेज शब्द समीक्षा' : 'Stage Words Review',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF78350F)),
                ),
                const Spacer(),
                Text(
                  '${_stageWords.length - _stageMistakeWordNames.length}/${_stageWords.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: _stageWords.length,
                separatorBuilder: (_, _) => const Divider(height: 8, color: Color(0xFFFDE68A)),
                itemBuilder: (context, idx) {
                  final wordObj = _stageWords[idx];
                  final isFlawless = !_stageMistakeWordNames.contains(wordObj.word);

                  return Row(
                    children: [
                      Icon(
                        isFlawless ? Icons.check_circle_rounded : Icons.info_rounded,
                        color: isFlawless ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wordObj.word,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              isFlawless
                                  ? (isHindi ? '✓ पहली बार में सही' : '✓ Mastered first try')
                                  : (isHindi ? '✗ अभ्यास की आवश्यकता' : '✗ Needed practice'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isFlawless ? const Color(0xFF15803D) : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF78350F)),
                        onPressed: () => AudioService.instance.speakPrompt(wordObj.word),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _activeStage = null; // Return to stage map
              });
            },
            child: Text(isHindi ? 'जारी रखें' : 'Next Stage'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // GAMEPLAY SCREEN UI
  // =========================================================================

  Widget _buildGameplayView(dynamic activeProfile, bool isHindi) {
    final word = _currentWord;
    final totalWords = _stageWords.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF78350F)),
          onPressed: () {
            AudioService.instance.playSfx(CurioSfx.click);
            setState(() {
              _activeStage = null; // Exit to map
            });
          },
        ),
        title: Text(
          'Stage $_activeStage • Word ${_currentWordIndex + 1}/$totalWords',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF78350F)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF78350F)),
            tooltip: 'Clear Slots',
            onPressed: _onClearAll,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentWordIndex + 1) / totalWords,
                  backgroundColor: const Color(0xFFFDE68A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Word Clue & Audio Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Speaker Button (Big & Playful)
                    GestureDetector(
                      onTap: () {
                        AudioService.instance.playSfx(CurioSfx.click);
                        _speakCurrentWord();
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.volume_up_rounded, size: 48, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isHindi ? 'सुनने के लिए टैप करें 🔊' : 'Tap to Listen 🔊',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 14),

                    // Clue Buttons: Hear in Sentence & Meaning
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _speakInSentence,
                          icon: const Icon(Icons.record_voice_over_rounded, size: 16),
                          label: Text(isHindi ? 'वाक्य सुनें' : 'In a Sentence'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF78350F),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFFDE68A)),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _speakMeaning,
                          icon: const Icon(Icons.lightbulb_outline_rounded, size: 16),
                          label: Text(isHindi ? 'अर्थ / हिंट' : 'Meaning / Hint'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF78350F),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFFDE68A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Hint Box (Definition & Emoji)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          Text(word.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.definition,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF451A03),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Target Letter Slots
                    _buildLetterSlots(),
                  ],
                ),
              ),
            ),

            // Letter Tiles Keyboard
            _buildLetterTilesKeyboard(),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildLetterSlots() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(_userSlots.length, (slotIdx) {
          final letter = _userSlots[slotIdx];
          final isFilled = letter != null;

          Color borderColor = const Color(0xFFD97706);
          Color bgColor = Colors.white;

          if (_isSuccessAnim) {
            borderColor = const Color(0xFF10B981);
            bgColor = const Color(0xFFD1FAE5);
          } else if (_isErrorAnim) {
            borderColor = const Color(0xFFEF4444);
            bgColor = const Color(0xFFFEE2E2);
          }

          return GestureDetector(
            onTap: () => _onSlotTap(slotIdx),
            child: Container(
              width: 44,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFilled ? borderColor : const Color(0xFFCBD5E1),
                  width: isFilled ? 2.2 : 1.5,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  letter ?? '',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _isSuccessAnim
                        ? const Color(0xFF047857)
                        : (_isErrorAnim ? const Color(0xFFB91C1C) : const Color(0xFF1E293B)),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLetterTilesKeyboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Letter Tiles Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(_letterTiles.length, (tileIdx) {
              final letter = _letterTiles[tileIdx];
              final isUsed = _tileUsed[tileIdx];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isUsed ? null : () => _onLetterTileTap(tileIdx),
                child: Opacity(
                  opacity: isUsed ? 0.25 : 1.0,
                  child: Container(
                    width: 46,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                      boxShadow: isUsed
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Action Bar: Backspace & Clear
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _onBackspace,
                icon: const Icon(Icons.backspace_outlined, size: 18),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB45309),
                  side: const BorderSide(color: Color(0xFFFDE68A)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 14),
              OutlinedButton.icon(
                onPressed: _onClearAll,
                icon: const Icon(Icons.clear_all_rounded, size: 20),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
