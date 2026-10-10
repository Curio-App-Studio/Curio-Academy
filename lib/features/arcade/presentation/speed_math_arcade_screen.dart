import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../../services/ad_service.dart';
import '../domain/arcade_question_engine.dart';

/// 60-Second Speed Math Arcade Screen
/// A rapid-fire mental math sprint with combos, timer, and high score tracking.
class SpeedMathArcadeScreen extends ConsumerStatefulWidget {
  const SpeedMathArcadeScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpeedMathArcadeScreen()),
    );
  }

  @override
  ConsumerState<SpeedMathArcadeScreen> createState() => _SpeedMathArcadeScreenState();
}

class _SpeedMathArcadeScreenState extends ConsumerState<SpeedMathArcadeScreen> with SingleTickerProviderStateMixin {
  late final ArcadeQuestionEngine _engine;
  Timer? _gameTimer;
  int _secondsRemaining = 60;
  bool _isPlaying = false;
  bool _isGameOver = false;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _totalAnswered = 0;
  int _correctAnswered = 0;
  bool _isNewHighScore = false;

  ArcadeQuestion? _currentQuestion;
  int? _selectedOption;
  bool? _isSelectionCorrect;

  @override
  void initState() {
    super.initState();
    _engine = ArcadeQuestionEngine();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
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
      _selectedOption = null;
      _isSelectionCorrect = null;
    });

    _nextQuestion();
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 5) {
          AudioService.instance.playSfx(CurioSfx.click);
        }
      } else {
        _endGame();
      }
    });
  }

  void _nextQuestion() {
    final activeProfile = ref.read(studentProfileProvider);
    _currentQuestion = _engine.generateQuestion(activeProfile.studentClass);
    _selectedOption = null;
    _isSelectionCorrect = null;
  }

  void _onOptionSelected(int option) async {
    if (!_isPlaying || _selectedOption != null || _currentQuestion == null) return;

    final isCorrect = option == _currentQuestion!.correctAnswer;
    _totalAnswered++;

    setState(() {
      _selectedOption = option;
      _isSelectionCorrect = isCorrect;
    });

    if (isCorrect) {
      _correctAnswered++;
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;

      // Base 10 points + combo multiplier
      final comboBonus = _combo > 1 ? (_combo * 2) : 0;
      _score += (10 + comboBonus);

      AudioService.instance.playSfx(CurioSfx.bubblePop);
    } else {
      _combo = 0;
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
    }

    // Brief delay for tactile visual feedback before next card
    await Future.delayed(const Duration(milliseconds: 220));
    if (mounted && _isPlaying) {
      setState(() {
        _nextQuestion();
      });
    }
  }

  void _endGame() async {
    _gameTimer?.cancel();
    _isPlaying = false;
    _isGameOver = true;

    AudioService.instance.playSfx(CurioSfx.starAward);

    // Save high score
    _isNewHighScore = await LocalStorageService.instance.updateSpeedMathHighScore(_score);

    // Grant stars: 1 bonus star for every 5 correct answers
    final starsEarned = (_correctAnswered ~/ 5);
    if (starsEarned > 0) {
      await LocalStorageService.instance.addBonusStars(starsEarned);
    }

    AdService().showInterstitialAdIfReady();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Arcade Night theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              isHindi ? 'स्पीड मैथ आर्केड' : 'Speed Math Arcade',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 16),
                const SizedBox(width: 4),
                ValueListenableBuilder<int>(
                  valueListenable: LocalStorageService.instance.speedMathHighScoreNotifier,
                  builder: (context, highScore, _) {
                    return Text(
                      '$highScore',
                      style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.w900, fontSize: 13),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isGameOver ? _buildGameOverView(isHindi) : _buildGameActiveView(isHindi),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildGameActiveView(bool isHindi) {
    final timerColor = _secondsRemaining <= 10
        ? const Color(0xFFEF4444)
        : (_secondsRemaining <= 25 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // 1. Top HUD: Timer & Score & Combo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E293B),
                  const Color(0xFF334155),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timer Indicator
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: CircularProgressIndicator(
                            value: _secondsRemaining / 60,
                            strokeWidth: 4.5,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                          ),
                        ),
                        Text(
                          '$_secondsRemaining',
                          style: TextStyle(
                            color: timerColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'समय शेष' : 'TIME LEFT',
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        Text(
                          '${_secondsRemaining}s',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),

                // Combo Badge
                if (_combo > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '🔥 ${_combo}x COMBO',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ),

                // Score Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isHindi ? 'स्कोर' : 'SCORE',
                      style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    Text(
                      '$_score',
                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // 2. Question Prompt Hero Card
          if (_currentQuestion != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentQuestion!.displayPrompt,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

          const Spacer(),

          // 3. 4-Option Grid Keypad
          if (_currentQuestion != null && _currentQuestion!.options.length >= 4) ...[
            Row(
              children: [
                Expanded(child: _buildKeypadButton(_currentQuestion!.options[0])),
                const SizedBox(width: 14),
                Expanded(child: _buildKeypadButton(_currentQuestion!.options[1])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildKeypadButton(_currentQuestion!.options[2])),
                const SizedBox(width: 14),
                Expanded(child: _buildKeypadButton(_currentQuestion!.options[3])),
              ],
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(int opt) {
    final isSelected = _selectedOption == opt;
    Color btnColor = const Color(0xFF1E293B);
    Color textColor = Colors.white;
    Border border = Border.all(color: Colors.white12, width: 1.5);

    if (isSelected) {
      if (_isSelectionCorrect == true) {
        btnColor = const Color(0xFF10B981); // Green
        border = Border.all(color: Colors.white, width: 2);
      } else {
        btnColor = const Color(0xFFEF4444); // Red
        border = Border.all(color: Colors.white, width: 2);
      }
    } else if (_selectedOption != null && opt == _currentQuestion!.correctAnswer) {
      // Reveal correct answer if wrong
      btnColor = const Color(0xFF10B981).withValues(alpha: 0.6);
    }

    return SizedBox(
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onOptionSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(20),
              border: border,
              boxShadow: [
                BoxShadow(
                  color: btnColor.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$opt',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverView(bool isHindi) {
    final accuracy = _totalAnswered > 0 ? ((_correctAnswered / _totalAnswered) * 100).toInt() : 0;
    final starsEarned = _correctAnswered ~/ 5;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero Trophy
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 16),

            if (_isNewHighScore) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isHindi ? '🎉 नया हाई स्कोर! 🎉' : '🎉 NEW HIGH SCORE! 🎉',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 10),
            ],

            Text(
              isHindi ? 'समय समाप्त!' : "Time's Up!",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi ? 'शानदार मानसिक गणित अभ्यास!' : 'Great mental math sprint!',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // Score Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(isHindi ? 'स्कोर' : 'Score', '$_score', const Color(0xFFFBBF24)),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildStatColumn(isHindi ? 'सटीकता' : 'Accuracy', '$accuracy%', const Color(0xFF10B981)),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildStatColumn(isHindi ? 'अधिकतम कॉम्बो' : 'Max Combo', '${_maxCombo}x', const Color(0xFFFF9800)),
                    ],
                  ),
                  if (starsEarned > 0) ...[
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(
                          isHindi ? '+$starsEarned बोनस सितारे अर्जित!' : '+$starsEarned Bonus Stars Earned!',
                          style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.replay_rounded, size: 22),
                label: Text(
                  isHindi ? 'फिर से खेलें ⚡' : 'Play Again ⚡',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7B25),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isHindi ? 'होम पर वापस जाएं' : 'Back to Home',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
