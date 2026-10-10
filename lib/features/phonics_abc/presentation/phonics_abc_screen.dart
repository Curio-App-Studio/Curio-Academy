import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../domain/phonics_letter.dart';

/// Full interactive Phonics & ABC Learning Screen for LKG, UKG & Class 1
class PhonicsAbcScreen extends StatefulWidget {
  final int initialIndex;

  const PhonicsAbcScreen({
    super.key,
    this.initialIndex = 0,
  });

  static Future<void> push(BuildContext context, {int initialIndex = 0}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhonicsAbcScreen(initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<PhonicsAbcScreen> createState() => _PhonicsAbcScreenState();
}

class _PhonicsAbcScreenState extends State<PhonicsAbcScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;

  // Quiz Mode State
  int _quizTargetIndex = 0;
  List<int> _quizOptions = [];
  int? _quizSelectedOption;
  bool _quizAnswered = false;
  int _quizScore = 0;
  int _quizTotalCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _stopAutoPlay();
      }
    });
    _initQuizRound();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    AudioService.instance.stopAudio();
    _tabController.dispose();
    super.dispose();
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    AudioService.instance.stopAudio();
    if (_isAutoPlaying) {
      setState(() => _isAutoPlaying = false);
    }
  }

  void _speakLetter(PhonicsLetter item) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';
    final chant = isHindi ? item.phonicChantHi : item.phonicChant;
    AudioService.instance.playSfx(CurioSfx.click);
    AudioService.instance.speakPrompt(chant, isHindi: isHindi);
  }

  void _startAutoPlay() {
    if (_isAutoPlaying) {
      _stopAutoPlay();
      return;
    }

    setState(() {
      _isAutoPlaying = true;
    });

    _speakLetter(PhonicsLetter.all[_selectedIndex]);

    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_selectedIndex + 1 < PhonicsLetter.all.length) {
        setState(() => _selectedIndex++);
        _speakLetter(PhonicsLetter.all[_selectedIndex]);
      } else {
        _stopAutoPlay();
        AudioService.instance.playSfx(CurioSfx.applause);
      }
    });
  }

  void _initQuizRound() {
    final rand = DateTime.now().millisecondsSinceEpoch;
    final target = rand % PhonicsLetter.all.length;
    final Set<int> opts = {target};
    int delta = 1;
    while (opts.length < 4) {
      final cand = (target + delta * 3 + rand) % PhonicsLetter.all.length;
      opts.add(cand);
      delta++;
    }
    final optList = opts.toList()..shuffle();

    setState(() {
      _quizTargetIndex = target;
      _quizOptions = optList;
      _quizSelectedOption = null;
      _quizAnswered = false;
    });

    final targetLetter = PhonicsLetter.all[target];
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';
    final prompt = isHindi
        ? '${targetLetter.upper} फॉर ${targetLetter.word}! ${targetLetter.upper} कहाँ है?'
        : 'Find letter ${targetLetter.upper} for ${targetLetter.word}!';
    AudioService.instance.speakPrompt(prompt);
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // Gentle Warm Sunshine Yellow
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFB45309)),
          onPressed: () {
            _stopAutoPlay();
            AudioService.instance.stopAudio();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔤 ', style: TextStyle(fontSize: 20)),
            Flexible(
              child: Text(
                isHindi ? 'A फॉर Apple' : 'Phonics & ABC',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF92400E)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Autoplay / Sing Along Button
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              icon: Icon(_isAutoPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 18),
              label: Text(
                _isAutoPlaying
                    ? (isHindi ? 'रोकें' : 'Stop')
                    : (isHindi ? 'सुनें 🎵' : 'Sing-along 🎵'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAutoPlaying ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _startAutoPlay,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD97706),
          indicatorWeight: 3.5,
          labelColor: const Color(0xFF92400E),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: [
            Tab(text: isHindi ? '🎈 चार्ट (A-Z)' : '🎈 Chart (A-Z)'),
            Tab(text: isHindi ? '🃏 बड़ा कार्ड' : '🃏 Big Card'),
            Tab(text: isHindi ? '🎯 खोजो खेल' : '🎯 Find Letter'),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlphabetGridTab(isHindi),
          _buildBigFlashcardTab(isHindi),
          _buildFindLetterQuizTab(isHindi),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: ALPHABET GRID (A to Z)
  // -------------------------------------------------------------
  Widget _buildAlphabetGridTab(bool isHindi) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: PhonicsLetter.all.length,
      itemBuilder: (context, index) {
        final item = PhonicsLetter.all[index];
        final isSelected = index == _selectedIndex;
        final color = _parseColor(item.colorHex);

        return InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            _speakLetter(item);
          },
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? color : const Color(0xFFFED7AA),
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isSelected ? 0.25 : 0.08),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Big Upper + Lower letters
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.letterPair,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Phonics Sound badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isHindi ? item.soundPhonicHi : item.soundPhonic,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Cute Emoji
                Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 38),
                ),
                const Spacer(),
                // Word ("Apple", "Boy")
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${item.upper} for ${item.word}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.volume_up_rounded, size: 14, color: color),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: BIG FLASHCARD & CHANT
  // -------------------------------------------------------------
  Widget _buildBigFlashcardTab(bool isHindi) {
    final item = PhonicsLetter.all[_selectedIndex];
    final color = _parseColor(item.colorHex);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Big Hero Card
          InkWell(
            onTap: () => _speakLetter(item),
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Upper & Lower
                  Text(
                    '${item.upper}  ${item.lower}',
                    style: TextStyle(
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Huge Emoji
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 74),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Word Title
                  Text(
                    '${item.upper} for ${item.word}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isHindi
                        ? 'ध्वनि: ${item.soundPhonicHi}'
                        : 'Phonics: "${item.soundPhonic}"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Phonics Chant Bubble
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, color: color, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isHindi ? item.phonicChantHi : item.phonicChant,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Previous & Next Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: Text(isHindi ? 'पिछला' : 'Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF92400E),
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFFED7AA)),
                  ),
                ),
                onPressed: _selectedIndex > 0
                    ? () {
                        setState(() => _selectedIndex--);
                        _speakLetter(PhonicsLetter.all[_selectedIndex]);
                      }
                    : null,
              ),
              ElevatedButton.icon(
                label: Text(isHindi ? 'अगला' : 'Next'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _selectedIndex + 1 < PhonicsLetter.all.length
                    ? () {
                        setState(() => _selectedIndex++);
                        _speakLetter(PhonicsLetter.all[_selectedIndex]);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: FIND THE LETTER QUIZ
  // -------------------------------------------------------------
  Widget _buildFindLetterQuizTab(bool isHindi) {
    final target = PhonicsLetter.all[_quizTargetIndex];
    final color = _parseColor(target.colorHex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Score pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌟 ', style: TextStyle(fontSize: 18)),
                Text(
                  isHindi ? 'स्कोर: $_quizScore / $_quizTotalCount' : 'Score: $_quizScore / $_quizTotalCount',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB45309), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Target prompt card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  target.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 8),
                Text(
                  target.word,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHindi
                      ? '${target.word} किस अक्षर से शुरू होता है?'
                      : 'Which letter starts the word "${target.word}"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4 Big Choice Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: _quizOptions.map((optIdx) {
              final optLetter = PhonicsLetter.all[optIdx];
              final isTarget = optIdx == _quizTargetIndex;
              final isChosen = optIdx == _quizSelectedOption;

              Color bg = Colors.white;
              Color border = const Color(0xFFFED7AA);
              Color textColor = const Color(0xFF92400E);

              if (_quizAnswered) {
                if (isTarget) {
                  bg = const Color(0xFFD1FAE5);
                  border = const Color(0xFF10B981);
                  textColor = const Color(0xFF065F46);
                } else if (isChosen) {
                  bg = const Color(0xFFFEE2E2);
                  border = const Color(0xFFEF4444);
                  textColor = const Color(0xFF991B1B);
                }
              }

              return InkWell(
                onTap: _quizAnswered
                    ? null
                    : () {
                        setState(() {
                          _quizSelectedOption = optIdx;
                          _quizAnswered = true;
                          _quizTotalCount++;
                          if (isTarget) {
                            _quizScore++;
                            AudioService.instance.playSfx(CurioSfx.correctCheer);
                          } else {
                            AudioService.instance.playSfx(CurioSfx.gentleWobble);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: border, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      '${optLetter.upper} ${optLetter.lower}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          if (_quizAnswered)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _initQuizRound,
              child: Text(
                isHindi ? 'अगला अक्षर ➔' : 'Next Letter ➔',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}
