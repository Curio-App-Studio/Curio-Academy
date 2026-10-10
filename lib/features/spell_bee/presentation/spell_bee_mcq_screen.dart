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
import 'spell_bee_mistakes_screen.dart';

/// "Spot the Correct Spelling" - Olympiad & SilverZone IEO style 4-choice MCQ Mode
class SpellBeeMcqScreen extends ConsumerStatefulWidget {
  const SpellBeeMcqScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpellBeeMcqScreen()),
    );
  }

  @override
  ConsumerState<SpellBeeMcqScreen> createState() => _SpellBeeMcqScreenState();
}

class _SpellBeeMcqScreenState extends ConsumerState<SpellBeeMcqScreen> {
  final SpellBeeRepository _repo = SpellBeeRepository.instance;
  List<SpellBeeWord> _questions = [];
  int _currentIndex = 0;
  List<String> _currentChoices = [];
  String? _selectedChoice;
  bool _answered = false;
  int _score = 0;
  int _streak = 0;
  Timer? _speechTimer;
  final Map<int, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    super.dispose();
  }

  Future<void> _initQuiz() async {
    await _repo.ensureLoaded();
    final profile = ref.read(studentProfileProvider);
    final words = _repo.getMcqWords(profile.studentClass, count: 10);
    setState(() {
      _questions = words;
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _answered = false;
      _selectedChoice = null;
      _userAnswers.clear();
      if (words.isNotEmpty) {
        _currentChoices = words[0].getMcqChoices();
      }
    });

    if (words.isNotEmpty) {
      _speakWordDelayed(words[0].word);
    }
  }

  void _speakWordDelayed(String word) {
    _speechTimer?.cancel();
    _speechTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        AudioService.instance.speakPrompt(word);
      }
    });
  }

  void _handleChoice(String choice) {
    if (_answered) return;
    final currentWord = _questions[_currentIndex];
    final isCorrect = choice.toUpperCase() == currentWord.word.toUpperCase();

    setState(() {
      _answered = true;
      _selectedChoice = choice;
      _userAnswers[_currentIndex] = choice;
      if (isCorrect) {
        _score += 10;
        _streak++;
        AudioService.instance.playSfx(CurioSfx.correctCheer);
      } else {
        _streak = 0;
        AudioService.instance.playSfx(CurioSfx.gentleWobble);
        // Automatically save to mistake vault
        LocalStorageService.instance.addSpellBeeMistake(currentWord.word);
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedChoice = null;
        _currentChoices = _questions[_currentIndex].getMcqChoices();
      });
      _speakWordDelayed(_questions[_currentIndex].word);
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    AdService().showInterstitialAdIfReady();
    final total = _questions.length;
    final pct = total > 0 ? ((_score / (total * 10)) * 100).round() : 0;
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pct >= 80 ? '🏆' : (pct >= 50 ? '🌟' : '💪'),
                  style: const TextStyle(fontSize: 42),
                ),
                const SizedBox(height: 6),
                Text(
                  pct >= 80
                      ? (isHindi ? 'शानदार स्कोर!' : 'Master Speller!')
                      : (isHindi ? 'अच्छा प्रयास!' : 'Good Effort!'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF78350F)),
                ),
                const SizedBox(height: 4),
                Text(
                  isHindi
                      ? 'आपने $total में से ${_score ~/ 10} सही स्पेलिंग पहचानी ($pct%)।'
                      : 'You identified ${_score ~/ 10} out of $total correct spellings ($pct%).',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$_score',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFB45309)),
                          ),
                          Text(
                            isHindi ? 'अंक (Points)' : 'Points',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$pct%',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFB45309)),
                          ),
                          Text(
                            isHindi ? 'सटीकता' : 'Accuracy',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Question Review Header
                Row(
                  children: [
                    const Icon(Icons.fact_check_rounded, color: Color(0xFFB45309), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      isHindi ? 'प्रश्नोत्तरी समीक्षा' : 'Question Review',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF78350F)),
                    ),
                    const Spacer(),
                    Text(
                      '${_score ~/ 10}/$total',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Scrollable Question Review List
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10),
                      itemCount: _questions.length,
                      separatorBuilder: (_, _) => const Divider(height: 10, color: Color(0xFFFDE68A)),
                      itemBuilder: (context, idx) {
                        final word = _questions[idx];
                        final userAns = _userAnswers[idx];
                        final isCorrect = userAns != null && userAns.toUpperCase() == word.word.toUpperCase();

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Q${idx + 1}: ${word.word}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  if (isCorrect)
                                    Text(
                                      '✓ ${isHindi ? "आपका उत्तर:" : "Your answer:"} $userAns',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D),
                                      ),
                                    )
                                  else
                                    Text(
                                      '✗ ${isHindi ? "आपका उत्तर:" : "Your answer:"} ${userAns ?? (isHindi ? "छूटा हुआ" : "Skipped")}  ➔  ✓ ${isHindi ? "सही:" : "Actual:"} ${word.word}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFB91C1C),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF78350F)),
                              onPressed: () => AudioService.instance.speakPrompt(word.word),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          SpellBeeMistakesScreen.push(context);
                        },
                        child: Text(
                          isHindi ? 'गलतियां देखें' : 'Review Mistakes',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _initQuiz();
                        },
                        child: Text(
                          isHindi ? 'फिर से खेलें' : 'Play Again',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
      );
    }

    final currentWord = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF78350F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isHindi ? 'सही स्पेलिंग पहचानो' : 'Spot The Correct Spelling',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF78350F)),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              children: [
                const Text('🔥 ', style: TextStyle(fontSize: 14)),
                Text(
                  '$_streak',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isHindi ? "प्रश्न" : "Question"} ${_currentIndex + 1}/${_questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  ),
                  Text(
                    'Score: $_score',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: const Color(0xFFFDE68A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),

              // Clue & Audio Pronouncer Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(currentWord.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentWord.partOfSpeech,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Definition / Meaning
                    Text(
                      currentWord.definition,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 10),
                    // Listen Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onPressed: () => AudioService.instance.speakPrompt(currentWord.word),
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      label: Text(
                        isHindi ? 'उच्चारण सुनें (Hear Word)' : 'Pronounce Word',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4 MCQ Choices
              Expanded(
                child: ListView.separated(
                  itemCount: _currentChoices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final choice = _currentChoices[idx];
                    final isCorrect = choice.toUpperCase() == currentWord.word.toUpperCase();
                    final isSelected = choice == _selectedChoice;

                    Color cardBg = Colors.white;
                    Color borderColor = const Color(0xFFE5E7EB);
                    Color textColor = const Color(0xFF1F2937);

                    if (_answered) {
                      if (isCorrect) {
                        cardBg = const Color(0xFFD1FAE5);
                        borderColor = const Color(0xFF10B981);
                        textColor = const Color(0xFF065F46);
                      } else if (isSelected) {
                        cardBg = const Color(0xFFFEE2E2);
                        borderColor = const Color(0xFFEF4444);
                        textColor = const Color(0xFF991B1B);
                      }
                    }

                    return InkWell(
                      onTap: () => _handleChoice(choice),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + idx), // A, B, C, D
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                choice,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (_answered && isCorrect)
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24)
                            else if (_answered && isSelected)
                              const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Next Question Button
              if (_answered)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB45309),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex + 1 < _questions.length
                        ? (isHindi ? 'अगला प्रश्न ➔' : 'Next Question ➔')
                        : (isHindi ? 'परिणाम देखें' : 'View Results'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
