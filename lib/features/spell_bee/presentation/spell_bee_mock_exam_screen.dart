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

/// Official Competition Mock Exam Simulation
/// Mimics real National Spelling Bee rounds: pronouncer, origin, definition, sentence clues,
/// timed rounds, scorecards, and certificates.
class SpellBeeMockExamScreen extends ConsumerStatefulWidget {
  const SpellBeeMockExamScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpellBeeMockExamScreen()),
    );
  }

  @override
  ConsumerState<SpellBeeMockExamScreen> createState() => _SpellBeeMockExamScreenState();
}

class _SpellBeeMockExamScreenState extends ConsumerState<SpellBeeMockExamScreen> {
  final SpellBeeRepository _repo = SpellBeeRepository.instance;
  List<SpellBeeWord> _examWords = [];
  int _currentIndex = 0;
  final List<String> _currentInput = [];
  List<String> _availableTiles = [];
  Timer? _speechTimer;
  Timer? _examTimer;
  int _secondsLeft = 45; // 45 seconds per word

  // Results tracker
  final Map<int, String> _userAnswers = {};
  int _correctCount = 0;
  bool _examCompleted = false;

  @override
  void initState() {
    super.initState();
    _startExam();
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    _examTimer?.cancel();
    super.dispose();
  }

  Future<void> _startExam() async {
    await _repo.ensureLoaded();
    final profile = ref.read(studentProfileProvider);
    final words = _repo.getMockExamWords(profile.studentClass, count: 10);

    setState(() {
      _examWords = words;
      _currentIndex = 0;
      _currentInput.clear();
      _userAnswers.clear();
      _correctCount = 0;
      _examCompleted = false;
      _secondsLeft = 45;
      if (words.isNotEmpty) {
        _availableTiles = _repo.generateLetterTiles(words[0], maxDecoys: 2);
      }
    });

    if (words.isNotEmpty) {
      _speakCurrentWord();
      _startWordTimer();
    }
  }

  void _startWordTimer() {
    _examTimer?.cancel();
    _secondsLeft = 45;
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        _submitCurrentWord(isTimeout: true);
      }
    });
  }

  void _speakCurrentWord() {
    if (_currentIndex < _examWords.length) {
      _speechTimer?.cancel();
      _speechTimer = Timer(const Duration(milliseconds: 350), () {
        if (mounted) {
          AudioService.instance.speakPrompt(_examWords[_currentIndex].word);
        }
      });
    }
  }

  void _onLetterTap(String letter) {
    if (_currentInput.length < _examWords[_currentIndex].word.length) {
      AudioService.instance.playSfx(CurioSfx.click);
      setState(() {
        _currentInput.add(letter);
      });
    }
  }

  void _onBackspace() {
    if (_currentInput.isNotEmpty) {
      AudioService.instance.playSfx(CurioSfx.click);
      setState(() {
        _currentInput.removeLast();
      });
    }
  }

  void _onClear() {
    if (_currentInput.isNotEmpty) {
      AudioService.instance.playSfx(CurioSfx.click);
      setState(() {
        _currentInput.clear();
      });
    }
  }

  void _submitCurrentWord({bool isTimeout = false}) {
    _examTimer?.cancel();
    final currentWord = _examWords[_currentIndex];
    final answer = _currentInput.join('').toUpperCase();
    _userAnswers[_currentIndex] = answer;

    final isCorrect = answer == currentWord.word.toUpperCase();
    if (isCorrect) {
      _correctCount++;
      AudioService.instance.playSfx(CurioSfx.correctCheer);
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      // Record to Mistake Vault
      LocalStorageService.instance.addSpellBeeMistake(currentWord.word);
    }

    if (_currentIndex + 1 < _examWords.length) {
      setState(() {
        _currentIndex++;
        _currentInput.clear();
        _availableTiles = _repo.generateLetterTiles(_examWords[_currentIndex], maxDecoys: 2);
      });
      _speakCurrentWord();
      _startWordTimer();
    } else {
      _finishExam();
    }
  }

  void _finishExam() {
    _examTimer?.cancel();
    _speechTimer?.cancel();

    // Persist exam stats
    final score = _correctCount * 10;
    LocalStorageService.instance.recordSpellBeeExamResult(
      score: score,
      total: _examWords.length * 10,
    );

    setState(() {
      _examCompleted = true;
    });

    AudioService.instance.playSfx(CurioSfx.applause);
    AdService().showInterstitialAdIfReady();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    if (_examWords.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
      );
    }

    if (_examCompleted) {
      return _buildExamReportScreen(isHindi);
    }

    final currentWord = _examWords[_currentIndex];
    final targetLength = currentWord.word.length;

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
          isHindi ? 'स्पेल बी मॉक परीक्षा' : 'Spell Bee Mock Exam',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF78350F)),
        ),
        actions: [
          // Countdown Timer
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _secondsLeft <= 10 ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _secondsLeft <= 10 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 16,
                  color: _secondsLeft <= 10 ? const Color(0xFFEF4444) : const Color(0xFFB45309),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_secondsLeft}s',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _secondsLeft <= 10 ? const Color(0xFFEF4444) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Exam Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isHindi ? "शब्द" : "Word"} ${_currentIndex + 1} of ${_examWords.length}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                  ),
                  Text(
                    '${isHindi ? "लंबाई:" : "Length:"} $targetLength letters',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _examWords.length,
                  backgroundColor: const Color(0xFFFDE68A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),

              // Pronouncer Clues Console
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(currentWord.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isHindi ? 'प्रश्नोत्तरी परीक्षक (Pronouncer)' : 'Official Pronouncer',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ),
                        // Listen button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _speakCurrentWord,
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                          label: Text(
                            isHindi ? 'उच्चारण' : 'Pronounce',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    // Definition
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFFB45309)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentWord.definition,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.25),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Origin, Part of Speech & Sentence Clue (Wrap prevents overflow)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Origin: ${currentWord.origin}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentWord.partOfSpeech,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3730A3)),
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => AudioService.instance.speakPrompt(currentWord.exampleSentence),
                          icon: const Icon(Icons.record_voice_over_rounded, size: 15, color: Color(0xFFB45309)),
                          label: Text(
                            isHindi ? 'वाक्य में सुनें' : 'In Sentence',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Interactive Letter Slots
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(targetLength, (idx) {
                      final hasLetter = idx < _currentInput.length;
                      final letter = hasLetter ? _currentInput[idx] : '';
                      return Container(
                        width: 36,
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: hasLetter ? const Color(0xFFFEF3C7) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasLetter ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                            width: hasLetter ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const Spacer(),

              // Letter Keyboard Tiles
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _availableTiles.map((tile) {
                  return InkWell(
                    onTap: () => _onLetterTap(tile),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          tile,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Action Buttons: Clear, Backspace, Submit
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF991B1B),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _onClear,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(isHindi ? 'मिटाएं' : 'Clear'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF78350F),
                      side: const BorderSide(color: Color(0xFFB45309)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _onBackspace,
                    child: const Icon(Icons.backspace_rounded, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _currentInput.isNotEmpty ? () => _submitCurrentWord() : null,
                      child: Text(
                        _currentIndex + 1 < _examWords.length
                            ? (isHindi ? 'जमा करें (Submit)' : 'Submit Word')
                            : (isHindi ? 'परीक्षा समाप्त करें' : 'Finish Exam'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildExamReportScreen(bool isHindi) {
    final total = _examWords.length;
    final score = _correctCount * 10;
    final maxScore = total * 10;
    final pct = total > 0 ? ((_correctCount / total) * 100).round() : 0;

    String rankBadge = '🥉 Bronze Speller';
    Color rankColor = const Color(0xFFB45309);
    if (pct >= 90) {
      rankBadge = '🏆 National Champion (Gold)';
      rankColor = const Color(0xFFD97706);
    } else if (pct >= 70) {
      rankBadge = '🥈 Silver Distinction';
      rankColor = const Color(0xFF6B7280);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF78350F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isHindi ? 'परीक्षा स्कोरकार्ड' : 'Mock Exam Scorecard',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF78350F)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Certificate Badge Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF3C7), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('🐝', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 6),
                    Text(
                      isHindi ? 'स्पेल बी परीक्षा प्रमाणपत्र' : 'Curio Spell Bee Certificate',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: rankColor),
                      ),
                      child: Text(
                        rankBadge,
                        style: TextStyle(fontWeight: FontWeight.w900, color: rankColor, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatTile(
                          label: isHindi ? 'कुल अंक' : 'Score',
                          value: '$score / $maxScore',
                          color: const Color(0xFFB45309),
                        ),
                        _buildStatTile(
                          label: isHindi ? 'सटीकता' : 'Accuracy',
                          value: '$pct%',
                          color: const Color(0xFF10B981),
                        ),
                        _buildStatTile(
                          label: isHindi ? 'सही शब्द' : 'Correct',
                          value: '$_correctCount / $total',
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Word Breakdown List
              Text(
                isHindi ? 'शब्द समीक्षा (Word Breakdown)' : 'Word Review Breakdown',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF78350F)),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _examWords.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final wordObj = _examWords[idx];
                  final userAns = _userAnswers[idx] ?? '';
                  final isCorrect = userAns.toUpperCase() == wordObj.word.toUpperCase();

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wordObj.word,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                              Text(
                                '${isHindi ? "आपका उत्तर:" : "Your answer:"} ${userAns.isEmpty ? "(Blank)" : userAns}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCorrect ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFF78350F)),
                          onPressed: () => AudioService.instance.speakPrompt(wordObj.word),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Action Buttons
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _startExam(),
                icon: const Icon(Icons.replay_rounded),
                label: Text(
                  isHindi ? 'पुनः परीक्षा दें' : 'Retake Mock Exam',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF78350F),
                  side: const BorderSide(color: Color(0xFFB45309)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  SpellBeeMistakesScreen.push(context);
                },
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(
                  isHindi ? 'गलतियों की डायरी (Mistake Vault)' : 'Open Mistake Vault',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
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

  Widget _buildStatTile({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
      ],
    );
  }
}
