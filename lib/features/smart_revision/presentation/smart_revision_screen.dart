import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/student_attempt_model.dart';
import '../../../core/profile/profile_provider.dart';
import '../domain/concept_flashcard.dart';

class SmartRevisionScreen extends ConsumerStatefulWidget {
  final int initialTabIndex; // 0 for Mistakes, 1 for Flashcards

  const SmartRevisionScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  static Future<void> push(
    BuildContext context, {
    int initialTabIndex = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SmartRevisionScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }

  @override
  ConsumerState<SmartRevisionScreen> createState() => _SmartRevisionScreenState();
}

class _SmartRevisionScreenState extends ConsumerState<SmartRevisionScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Flashcards state
  String _selectedSubject = 'all';
  int _cardIndex = 0;
  bool _isCardFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Mistake retry state
  final Set<String> _resolvedMistakes = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    AudioService.instance.playSfx(CurioSfx.click);
    if (_isCardFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isCardFlipped = !_isCardFlipped;
    });
  }

  void _nextCard(int totalCards) {
    if (_cardIndex < totalCards - 1) {
      AudioService.instance.playSfx(CurioSfx.click);
      if (_isCardFlipped) {
        _flipController.reverse();
        _isCardFlipped = false;
      }
      setState(() {
        _cardIndex++;
      });
    }
  }

  void _prevCard() {
    if (_cardIndex > 0) {
      AudioService.instance.playSfx(CurioSfx.click);
      if (_isCardFlipped) {
        _flipController.reverse();
        _isCardFlipped = false;
      }
      setState(() {
        _cardIndex--;
      });
    }
  }

  void _speakCard(ConceptFlashcard card, bool isHindi) {
    final text = _isCardFlipped
        ? (isHindi ? card.backAnswerHi : card.backAnswerEn)
        : (isHindi ? card.frontPromptHi : card.frontPromptEn);
    AudioService.instance.speakPrompt(text, isHindi: isHindi || card.subjectId == 'hindi');
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(studentProfileProvider);
    final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;

    final cards = FlashcardRepository.instance.getFlashcardsForClass(
      activeProfile.studentClass,
      filterSubject: _selectedSubject,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            AudioService.instance.playSfx(CurioSfx.click);
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          isHindi ? '🧠 स्मार्ट अध्ययन और पुनरावृत्ति' : '🧠 Smart Study & Revision',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3.5,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          tabs: [
            Tab(
              icon: const Text('🎯', style: TextStyle(fontSize: 16)),
              text: isHindi ? 'गलतियां सुधारें' : 'Mistake Bank',
            ),
            Tab(
              icon: const Text('📇', style: TextStyle(fontSize: 16)),
              text: isHindi ? 'फ्लैशकार्ड' : 'Concept Cards',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Mistake Bank / Revise Errors
          _buildMistakeBankTab(isHindi),

          // Tab 2: Smart Concept Flashcards
          _buildFlashcardsTab(isHindi, cards),
        ],
      ),
    );
  }

  // --- TAB 1: MISTAKE BANK ---
  Widget _buildMistakeBankTab(bool isHindi) {
    final storage = LocalStorageService.instance;
    final allMistakes = storage.getMistakes().where((m) => !_resolvedMistakes.contains(m.activityId)).toList();
    final spellMistakes = storage.spellBeeMistakes.where((w) => !_resolvedMistakes.contains('spell_$w')).toList();

    final totalMistakes = allMistakes.length + spellMistakes.length;

    if (totalMistakes == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌟', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isHindi ? 'वाह! कोई गलती नहीं बची!' : 'Zero Mistakes Found!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isHindi
                    ? 'आपने अपने सभी पिछले गलत उत्तर सही कर लिए हैं या अभी कोई गलती नहीं हुई है। शानदार काम!'
                    : 'You have mastered all your review topics and quizzes. Keep up the brilliant learning!',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Header Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'सुधारने के लिए $totalMistakes विषय' : '$totalMistakes Questions to Review',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isHindi
                          ? 'अभ्यास करें और अपनी गलतियों को सफलताओं में बदलें!'
                          : 'Practice and master each item to clear your mistake bank!',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Spell Bee Word Mistakes Section
        if (spellMistakes.isNotEmpty) ...[
          Text(
            isHindi ? '🐝 स्पेलिंग अभ्यास (${spellMistakes.length})' : '🐝 Spelling Errors (${spellMistakes.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          ...spellMistakes.map((word) => _buildSpellMistakeCard(word, isHindi)),
          const SizedBox(height: 16),
        ],

        // Quiz Question Mistakes Section
        if (allMistakes.isNotEmpty) ...[
          Text(
            isHindi ? '📝 क्विज़ व परीक्षा गलतियां (${allMistakes.length})' : '📝 Quiz & Test Errors (${allMistakes.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          ...allMistakes.map((attempt) => _buildQuestionMistakeCard(attempt, isHindi)),
        ],
      ],
    );
  }

  Widget _buildSpellMistakeCard(String word, bool isHindi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Text('🐝', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1.2),
                ),
                Text(
                  isHindi ? 'स्पेलिंग याद करें और सुनें' : 'Listen and master correct spelling',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFF59E0B)),
            onPressed: () {
              AudioService.instance.playSfx(CurioSfx.click);
              AudioService.instance.speakPrompt(word);
            },
          ),
          ElevatedButton(
            onPressed: () async {
              AudioService.instance.playSfx(CurioSfx.applause);
              await LocalStorageService.instance.removeSpellBeeMistake(word);
              await LocalStorageService.instance.addDiscoveryPoints(10);
              if (!mounted) return;
              setState(() {
                _resolvedMistakes.add('spell_$word');
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isHindi ? 'शाबाश! "$word" सीख लिया! (+10 अंक) ⭐' : 'Mastered "$word"! (+10 Points) ⭐',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              isHindi ? 'सीख लिया ✅' : 'Mastered ✅',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionMistakeCard(StudentQuestionAttempt attempt, bool isHindi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  attempt.chapterId.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  AudioService.instance.playSfx(CurioSfx.applause);
                  await LocalStorageService.instance.addDiscoveryPoints(15);
                  if (!mounted) return;
                  setState(() {
                    _resolvedMistakes.add(attempt.activityId);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHindi ? 'शाबाश! गलती सुधार ली गई! (+15 अंक) ⭐' : 'Mastered and reviewed! (+15 Points) ⭐',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isHindi ? 'सुधार लिया ✅' : 'Mastered ✅',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${isHindi ? "पिछला चुना गया उत्तर" : "Previous Selected"}: "${attempt.selectedOptionText}"',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 4),
          Text(
            isHindi ? 'पुनः प्रयास करें और सही अवधारणा याद करें।' : 'Revisit the chapter to strengthen this concept.',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: SMART CONCEPT FLASHCARDS ---
  Widget _buildFlashcardsTab(bool isHindi, List<ConceptFlashcard> cards) {
    if (cards.isEmpty) {
      return const Center(child: Text('No flashcards available'));
    }

    final card = cards[_cardIndex.clamp(0, cards.length - 1)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Subject Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubjectChip('all', isHindi ? 'सभी विषय 🌟' : 'All Subjects 🌟'),
                const SizedBox(width: 8),
                _buildSubjectChip('math', isHindi ? 'गणित 📐' : 'Math 📐'),
                const SizedBox(width: 8),
                _buildSubjectChip('science', isHindi ? 'विज्ञान 🔬' : 'Science 🔬'),
                const SizedBox(width: 8),
                _buildSubjectChip('english', isHindi ? 'अंग्रेजी 🔤' : 'English 🔤'),
                const SizedBox(width: 8),
                _buildSubjectChip('hindi', isHindi ? 'हिंदी 🇮🇳' : 'Hindi 🇮🇳'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress indicator: Card 3 of 15
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${card.emoji} ${card.subjectName.toUpperCase()}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF6366F1), letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_cardIndex + 1} / ${cards.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF4338CA)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Interactive 3D Flip Card
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final angle = _flipAnimation.value * math.pi;
                final isUnder = _flipAnimation.value > 0.5;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: isUnder
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildCardBack(card, isHindi),
                        )
                      : _buildCardFront(card, isHindi),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Card Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              IconButton.filledTonal(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _cardIndex > 0 ? _prevCard : null,
              ),

              // Hear Voice Button
              ElevatedButton.icon(
                onPressed: () => _speakCard(card, isHindi),
                icon: const Icon(Icons.volume_up_rounded, size: 20, color: Colors.white),
                label: Text(
                  isHindi ? 'बोलकर सुनें' : 'Listen Aloud',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              // Next Button
              IconButton.filledTonal(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _cardIndex < cards.length - 1 ? () => _nextCard(cards.length) : null,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // "I Know This" Button (Earn points)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                AudioService.instance.playSfx(CurioSfx.starAward);
                await LocalStorageService.instance.addDiscoveryPoints(5);
                if (_cardIndex < cards.length - 1) {
                  _nextCard(cards.length);
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isHindi ? 'शानदार! (+5 ज्ञान अंक अर्जित किए) 🌟' : 'Great Job! (+5 Knowledge Points) 🌟',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF6366F1),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.thumb_up_rounded, color: Color(0xFF10B981), size: 20),
              label: Text(
                isHindi ? 'मुझे यह याद है! 👍 (+5 अंक)' : 'I Know This! 👍 (+5 pts)',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857), fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFECFDF5),
                side: const BorderSide(color: Color(0xFFA7F3D0), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChip(String id, String label) {
    final isSelected = _selectedSubject == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          AudioService.instance.playSfx(CurioSfx.click);
          setState(() {
            _selectedSubject = id;
            _cardIndex = 0;
            if (_isCardFlipped) {
              _flipController.reverse();
              _isCardFlipped = false;
            }
          });
        }
      },
      selectedColor: const Color(0xFF6366F1),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
      ),
    );
  }

  // Card Front Widget
  Widget _buildCardFront(ConceptFlashcard card, bool isHindi) {
    return Container(
      width: double.infinity,
      height: 310,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${card.emoji} ${isHindi ? "प्रश्न" : "QUESTION"}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF4338CA)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isHindi ? card.frontPromptHi : card.frontPromptEn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_rounded, color: Color(0xFF94A3B8), size: 18),
              const SizedBox(width: 6),
              Text(
                isHindi ? 'उत्तर देखने के लिए कार्ड पर टैप करें 🔄' : 'Tap card to flip for answer 🔄',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card Back Widget
  Widget _buildCardBack(ConceptFlashcard card, bool isHindi) {
    return Container(
      width: double.infinity,
      height: 310,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '✅ ${isHindi ? "सही उत्तर" : "CORRECT ANSWER"}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isHindi ? card.backAnswerHi : card.backAnswerEn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHindi ? card.explanationHi : card.explanationEn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4338CA),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isHindi ? 'पुनः प्रश्न देखने के लिए टैप करें 🔄' : 'Tap to flip back to question 🔄',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }
}
