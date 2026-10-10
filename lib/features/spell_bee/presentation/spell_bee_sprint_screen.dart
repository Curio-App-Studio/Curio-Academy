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

/// 60-Second Speed Spell Bee Sprint Screen
/// Rapid-fire spelling challenge with combos, timer countdown, and high score tracking.
class SpellBeeSprintScreen extends ConsumerStatefulWidget {
  const SpellBeeSprintScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpellBeeSprintScreen()),
    );
  }

  @override
  ConsumerState<SpellBeeSprintScreen> createState() => _SpellBeeSprintScreenState();
}

class _SpellBeeSprintScreenState extends ConsumerState<SpellBeeSprintScreen> {
  Timer? _timer;
  Timer? _speechTimer;
  int _secondsRemaining = 60;
  bool _isPlaying = false;
  bool _isGameOver = false;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _totalAnswered = 0;
  int _correctAnswered = 0;
  bool _isNewHighScore = false;

  SpellBeeWord? _currentWord;
  List<String> _letterTiles = [];
  List<String?> _userSlots = [];
  List<bool> _tileUsed = [];
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startSprint();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speechTimer?.cancel();
    super.dispose();
  }

  void _startSprint() {
    setState(() {
      _secondsRemaining = 60;
      _score = 0;
      _combo = 0;
      _maxCombo = 0;
      _totalAnswered = 0;
      _correctAnswered = 0;
      _isPlaying = true;
      _isGameOver = false;
      _isNewHighScore = false;
    });

    _nextWord();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 5) {
          AudioService.instance.playSfx(CurioSfx.click);
        }
      } else {
        _endSprint();
      }
    });
  }

  void _nextWord() {
    final activeProfile = ref.read(studentProfileProvider);
    final word = SpellBeeRepository.instance.getRandomSprintWord(activeProfile.studentClass);
    final tiles = SpellBeeRepository.instance.generateLetterTiles(word, maxDecoys: 1);

    setState(() {
      _currentWord = word;
      _letterTiles = tiles;
      _userSlots = List.filled(word.length, null);
      _tileUsed = List.filled(tiles.length, false);
      _isChecking = false;
    });

    // Auto-speak word aloud
    _speechTimer?.cancel();
    _speechTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted && _isPlaying) {
        AudioService.instance.speakPrompt(word.word);
      }
    });
  }

  void _onTileTap(int index) {
    if (!_isPlaying || _isChecking || _tileUsed[index]) return;

    final emptySlot = _userSlots.indexOf(null);
    if (emptySlot == -1) return;

    AudioService.instance.playSfx(CurioSfx.bubblePop);

    setState(() {
      _userSlots[emptySlot] = _letterTiles[index];
      _tileUsed[index] = true;
    });

    if (!_userSlots.contains(null)) {
      _verifyWord();
    }
  }

  void _onSlotTap(int index) {
    if (!_isPlaying || _isChecking) return;
    final letter = _userSlots[index];
    if (letter == null) return;

    AudioService.instance.playSfx(CurioSfx.click);

    setState(() {
      _userSlots[index] = null;
      for (int i = 0; i < _letterTiles.length; i++) {
        if (_letterTiles[i] == letter && _tileUsed[i]) {
          _tileUsed[i] = false;
          break;
        }
      }
    });
  }

  void _onBackspace() {
    if (!_isPlaying || _isChecking) return;
    for (int i = _userSlots.length - 1; i >= 0; i--) {
      if (_userSlots[i] != null) {
        _onSlotTap(i);
        break;
      }
    }
  }

  void _verifyWord() async {
    setState(() {
      _isChecking = true;
    });

    _totalAnswered++;
    final constructed = _userSlots.join('').toUpperCase();
    final target = _currentWord!.word.toUpperCase();

    if (constructed == target) {
      _correctAnswered++;
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;

      // Scoring: 10 base + combo bonus
      final points = 10 + (_combo * 5);
      _score += points;

      AudioService.instance.playSfx(CurioSfx.correctCheer);

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || !_isPlaying) return;

      _nextWord();
    } else {
      _combo = 0; // Break combo streak
      AudioService.instance.playSfx(CurioSfx.gentleWobble);

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || !_isPlaying) return;

      // Reset slots for retry
      setState(() {
        for (int i = 0; i < _userSlots.length; i++) {
          _userSlots[i] = null;
        }
        for (int i = 0; i < _tileUsed.length; i++) {
          _tileUsed[i] = false;
        }
        _isChecking = false;
      });
    }
  }

  void _skipWord() {
    if (!_isPlaying) return;
    AudioService.instance.playSfx(CurioSfx.click);
    _combo = 0;
    _nextWord();
  }

  void _endSprint() async {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });

    // Save high score
    final isNew = await LocalStorageService.instance.updateSpellBeeHighScore(_score);
    if (isNew) {
      _isNewHighScore = true;
    }

    // Award discovery points based on score
    if (_score > 0) {
      await LocalStorageService.instance.addDiscoveryPoints(_score);
      await LocalStorageService.instance.addBonusStars((_score / 30).clamp(1, 10).toInt());
    }

    AudioService.instance.playSfx(CurioSfx.applause);
    AdService().showInterstitialAdIfReady();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

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
          isHindi ? 'स्पीड स्पेल बी (60s)' : '60s Speed Spell Bee',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF78350F)),
        ),
      ),
      body: SafeArea(
        child: _isGameOver ? _buildGameOverView(isHindi) : _buildSprintPlayfield(isHindi),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildSprintPlayfield(bool isHindi) {
    final word = _currentWord;
    if (word == null) return const SizedBox.shrink();

    final isUrgent = _secondsRemaining <= 10;

    return Column(
      children: [
        // Top Header: Score, Timer & Combo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$_score',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),

              // Countdown Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isUrgent
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isUrgent ? const Color(0xFFEF4444) : const Color(0xFFD97706)).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$_secondsRemaining s',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),

              // Streak Combo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _combo >= 2 ? const Color(0xFFFEF3C7) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _combo >= 2 ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(_combo >= 2 ? '🔥' : '✨', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      _combo >= 2 ? '${_combo}x' : '1x',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: _combo >= 2 ? const Color(0xFFD97706) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Middle Section: Word Speaker & Hint
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    AudioService.instance.speakPrompt(word.word);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.volume_up_rounded, size: 42, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${word.emoji} ${word.definition}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF78350F)),
                ),
                const SizedBox(height: 20),

                // Slots
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: List.generate(_userSlots.length, (slotIdx) {
                    final letter = _userSlots[slotIdx];
                    final isFilled = letter != null;
                    return GestureDetector(
                      onTap: () => _onSlotTap(slotIdx),
                      child: Container(
                        width: 42,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isFilled ? const Color(0xFFFEF3C7) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFilled ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                            width: isFilled ? 2 : 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letter ?? '',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF78350F)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        // Letter Tiles Keyboard
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(_letterTiles.length, (tileIdx) {
                  final letter = _letterTiles[tileIdx];
                  final isUsed = _tileUsed[tileIdx];

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: isUsed ? null : () => _onTileTap(tileIdx),
                    child: Opacity(
                      opacity: isUsed ? 0.25 : 1.0,
                      child: Container(
                        width: 44,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF78350F)),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: _onBackspace,
                    icon: const Icon(Icons.backspace_outlined, size: 16),
                    label: const Text('Del'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB45309),
                      side: const BorderSide(color: Color(0xFFFDE68A)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _skipWord,
                    icon: const Icon(Icons.skip_next_rounded, size: 18),
                    label: Text(isHindi ? 'छोड़ें' : 'Skip'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverView(bool isHindi) {
    final accuracy = _totalAnswered > 0 ? ((_correctAnswered / _totalAnswered) * 100).toInt() : 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isNewHighScore ? '🏆' : '🐝', style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              if (_isNewHighScore) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Text(
                    isHindi ? 'नया रिकॉर्ड! 🌟' : 'NEW HIGH SCORE! 🌟',
                    style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                isHindi ? 'स्प्रिंट समाप्त!' : 'Sprint Finished!',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF78350F)),
              ),
              const SizedBox(height: 16),

              Text(
                '$_score',
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
              ),
              Text(
                isHindi ? 'कुल अंक' : 'Total Points',
                style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 18),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('🎯', isHindi ? 'सटीकता' : 'Accuracy', '$accuracy%'),
                  _buildStatItem('🔥', isHindi ? 'मैक्स स्ट्रीक' : 'Max Combo', '${_maxCombo}x'),
                  _buildStatItem('✅', isHindi ? 'सही शब्द' : 'Correct', '$_correctAnswered'),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _startSprint,
                icon: const Icon(Icons.replay_rounded),
                label: Text(isHindi ? 'फिर से खेलें' : 'Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
      ],
    );
  }
}
