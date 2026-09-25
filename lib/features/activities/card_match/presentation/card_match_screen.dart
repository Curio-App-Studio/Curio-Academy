import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../data/local/local_storage_service.dart';
import '../../../../data/models/activity_model.dart';
import '../../../../data/models/student_attempt_model.dart';
import '../../../../shared/dialogs/reward_dialog.dart';

class MatchCardItem {
  final String id;
  final String matchKey;
  final String label;
  final String? emoji;
  final Color color;

  const MatchCardItem({
    required this.id,
    required this.matchKey,
    required this.label,
    this.emoji,
    required this.color,
  });
}

class CardMatchLevelData {
  final int levelNumber;
  final String prompt;
  final List<MatchCardItem> cards;

  const CardMatchLevelData({
    required this.levelNumber,
    required this.prompt,
    required this.cards,
  });
}

/// Interactive Card Match & Memory Pairs Game for Early Learners (LKG & UKG)
class CardMatchScreen extends StatefulWidget {
  final Activity? activity;
  final List<Activity>? activities;
  final int initialLevelIndex;
  final VoidCallback? onCompleted;

  const CardMatchScreen({
    super.key,
    this.activity,
    this.activities,
    this.initialLevelIndex = 0,
    this.onCompleted,
  });

  @override
  State<CardMatchScreen> createState() => _CardMatchScreenState();
}

class _CardMatchScreenState extends State<CardMatchScreen> {
  int _currentLevel = 1;
  late String _currentPrompt;
  late List<MatchCardItem> _cards;
  final Set<String> _matchedKeys = {};

  int? _firstSelectedCardIndex;
  int? _secondSelectedCardIndex;
  bool _isProcessing = false;
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevelIndex + 1;
    _loadLevel(_currentLevel);
  }

  void _loadLevel(int level) {
    _matchedKeys.clear();
    _firstSelectedCardIndex = null;
    _secondSelectedCardIndex = null;
    _isProcessing = false;
    _mistakes = 0;

    final generated = _generateLevelData(level);
    setState(() {
      _currentPrompt = generated.prompt;
      _cards = generated.cards;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AudioService.instance.speakPrompt(_currentPrompt);
      }
    });
  }

  CardMatchLevelData _generateLevelData(int level) {
    // Check if widget passed an activity payload
    final payload = widget.activity?.interactionPayload;
    if (payload != null && payload.containsKey('pairs') && (payload['pairs'] as List).isNotEmpty) {
      final pairs = payload['pairs'] as List;
      final cardsList = <MatchCardItem>[];
      final colors = [
        const Color(0xFF38BDF8),
        const Color(0xFFF472B6),
        const Color(0xFF4ADE80),
        const Color(0xFFFBBF24),
      ];

      for (int i = 0; i < min(pairs.length, 3); i++) {
        final pair = pairs[i] as Map<String, dynamic>;
        final key = pair['key']?.toString() ?? '$i';
        final col = colors[i % colors.length];
        cardsList.add(MatchCardItem(
          id: 'card_${key}_a',
          matchKey: key,
          label: pair['itemA']?.toString() ?? '',
          emoji: pair['emojiA']?.toString(),
          color: col,
        ));
        cardsList.add(MatchCardItem(
          id: 'card_${key}_b',
          matchKey: key,
          label: pair['itemB']?.toString() ?? '',
          emoji: pair['emojiB']?.toString(),
          color: col,
        ));
      }
      cardsList.shuffle(Random(level * 42));
      return CardMatchLevelData(
        levelNumber: level,
        prompt: widget.activity?.promptData.text ?? 'Tap the matching pairs!',
        cards: cardsList,
      );
    }

    // Procedural early learning pairs catalog
    final pairPools = [
      // Pool 1: Alphabet & Visual Words
      [
        {'key': 'A', 'a': 'A', 'emojiA': '🅰️', 'b': 'Apple', 'emojiB': '🍎', 'color': const Color(0xFFEF4444)},
        {'key': 'B', 'a': 'B', 'emojiA': '🅱️', 'b': 'Ball', 'emojiB': '⚽', 'color': const Color(0xFF3B82F6)},
        {'key': 'C', 'a': 'C', 'emojiA': '©️', 'b': 'Cat', 'emojiB': '🐱', 'color': const Color(0xFF10B981)},
      ],
      // Pool 2: Counting & Stars
      [
        {'key': '2', 'a': '2', 'emojiA': '2️⃣', 'b': 'Two Stars', 'emojiB': '⭐⭐', 'color': const Color(0xFFF59E0B)},
        {'key': '3', 'a': '3', 'emojiA': '3️⃣', 'b': 'Three Stars', 'emojiB': '⭐⭐⭐', 'color': const Color(0xFF8B5CF6)},
        {'key': '4', 'a': '4', 'emojiA': '4️⃣', 'b': 'Four Stars', 'emojiB': '⭐⭐⭐⭐', 'color': const Color(0xFFEC4899)},
      ],
      // Pool 3: Shapes & Colors
      [
        {'key': 'circle', 'a': 'Circle', 'emojiA': '🔴', 'b': 'Round', 'emojiB': '⭕', 'color': const Color(0xFFEF4444)},
        {'key': 'square', 'a': 'Square', 'emojiA': '🟩', 'b': 'Box', 'emojiB': '⏹️', 'color': const Color(0xFF10B981)},
        {'key': 'star', 'a': 'Star', 'emojiA': '⭐', 'b': 'Shining Star', 'emojiB': '🌟', 'color': const Color(0xFFFBBF24)},
      ],
      // Pool 4: Animals & Sounds
      [
        {'key': 'dog', 'a': 'Dog', 'emojiA': '🐶', 'b': 'Woof Woof', 'emojiB': '🦴', 'color': const Color(0xFFF97316)},
        {'key': 'cat', 'a': 'Cat', 'emojiA': '🐱', 'b': 'Meow Meow', 'emojiB': '🐟', 'color': const Color(0xFF06B6D4)},
        {'key': 'duck', 'a': 'Duck', 'emojiA': '🦆', 'b': 'Quack Quack', 'emojiB': '🌊', 'color': const Color(0xFF84CC16)},
      ],
      // Pool 5: Opposites
      [
        {'key': 'up_down', 'a': 'Up ⬆️', 'emojiA': '🎈', 'b': 'Down ⬇️', 'emojiB': '⚓', 'color': const Color(0xFF6366F1)},
        {'key': 'big_small', 'a': 'Big 🐘', 'emojiA': '🐘', 'b': 'Small 🐭', 'emojiB': '🐭', 'color': const Color(0xFF0D9488)},
        {'key': 'hot_cold', 'a': 'Hot ☀️', 'emojiA': '🔥', 'b': 'Cold ❄️', 'emojiB': '🍦', 'color': const Color(0xFFEA580C)},
      ],
    ];

    final poolIndex = (level - 1) % pairPools.length;
    final selectedPairs = pairPools[poolIndex];
    final cardsList = <MatchCardItem>[];

    for (int i = 0; i < selectedPairs.length; i++) {
      final p = selectedPairs[i];
      final col = p['color'] as Color;
      final key = p['key'] as String;

      cardsList.add(MatchCardItem(
        id: 'card_${key}_a',
        matchKey: key,
        label: p['a'] as String,
        emoji: p['emojiA'] as String?,
        color: col,
      ));
      cardsList.add(MatchCardItem(
        id: 'card_${key}_b',
        matchKey: key,
        label: p['b'] as String,
        emoji: p['emojiB'] as String?,
        color: col,
      ));
    }

    cardsList.shuffle(Random(level * 31 + 7));

    final promptText = poolIndex == 1
        ? 'Match each number with its shining stars!'
        : (poolIndex == 2
            ? 'Match each shape with its picture!'
            : (poolIndex == 4
                ? 'Find the opposites that go together!'
                : 'Tap cards to find the matching pairs!'));

    return CardMatchLevelData(
      levelNumber: level,
      prompt: promptText,
      cards: cardsList,
    );
  }

  void _onCardTapped(int index) {
    if (_isProcessing) return;
    if (_matchedKeys.contains(_cards[index].matchKey)) return;
    if (_firstSelectedCardIndex == index) return;

    AudioService.instance.playSfx(CurioSfx.click);

    if (_firstSelectedCardIndex == null) {
      setState(() {
        _firstSelectedCardIndex = index;
      });
      return;
    }

    // Second card selected
    setState(() {
      _secondSelectedCardIndex = index;
      _isProcessing = true;
    });

    final first = _cards[_firstSelectedCardIndex!];
    final second = _cards[index];

    if (first.matchKey == second.matchKey) {
      // MATCH FOUND!
      AudioService.instance.playSfx(CurioSfx.correctCheer);
      setState(() {
        _matchedKeys.add(first.matchKey);
        _firstSelectedCardIndex = null;
        _secondSelectedCardIndex = null;
        _isProcessing = false;
      });

      // Check if all pairs are matched
      final totalPairs = _cards.length ~/ 2;
      if (_matchedKeys.length >= totalPairs) {
        _handleGameCompletion();
      }
    } else {
      // NO MATCH
      _mistakes++;
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _firstSelectedCardIndex = null;
            _secondSelectedCardIndex = null;
            _isProcessing = false;
          });
        }
      });
    }
  }

  void _handleGameCompletion() {
    AudioService.instance.playSfx(CurioSfx.starAward);
    final starsEarned = _mistakes <= 1 ? 3 : (_mistakes <= 3 ? 2 : 1);

    // Save student attempt to ensure total stars persist
    final actId = widget.activity?.activityId ?? 'card_match_l$_currentLevel';
    final chapterId = widget.activity?.chapterId ?? 'ch_early_games';

    final attempt = StudentQuestionAttempt(
      activityId: actId,
      chapterId: chapterId,
      selectedOptionIndex: 0,
      selectedOptionText: 'matched_all',
      isCorrect: true,
      starsEarned: starsEarned,
      timestamp: DateTime.now(),
    );
    LocalStorageService.instance.saveQuestionAttempt(attempt);

    RewardDialog.show(
      context,
      starsAwarded: starsEarned,
      totalPoints: starsEarned * 15,
      message: starsEarned == 3
          ? 'Brilliant! You matched all pairs like a superstar! 🌟'
          : 'Great job! You found all the matching pairs! ⭐',
      onContinue: () {
        // Seamlessly load next level!
        setState(() {
          _currentLevel++;
          _loadLevel(_currentLevel);
        });
      },
      onReplay: () {
        setState(() {
          _loadLevel(_currentLevel);
        });
      },
    );
  }

  void _skipToNextLevel() {
    AudioService.instance.playSfx(CurioSfx.click);
    setState(() {
      _currentLevel++;
      _loadLevel(_currentLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPairs = _cards.length ~/ 2;
    final pairsLeft = totalPairs - _matchedKeys.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDCFCE7), // Soft mint green
              Color(0xFFF0FDF4),
              Color(0xFFFEF3C7), // Sunny bottom
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF15803D)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    // Level Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Game $_currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Total Stars Pill
                    ValueListenableBuilder<int>(
                      valueListenable: LocalStorageService.instance.totalStarsNotifier,
                      builder: (context, totalStars, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '$totalStars',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    // Skip / Next Button
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _skipToNextLevel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF15803D),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.skip_next_rounded, size: 18, color: Color(0xFF15803D)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      iconSize: 26,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF3C7),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFB45309)),
                      onPressed: () => AudioService.instance.speakPrompt(_currentPrompt),
                    ),
                  ],
                ),
              ),

              // Pairs Left Goal Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🃏', style: TextStyle(fontSize: 20)),
                    Expanded(
                      child: Text(
                        _currentPrompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14532D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Pairs left: $pairsLeft',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Cards Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: _cards.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final isMatched = _matchedKeys.contains(card.matchKey);
                      final isSelected = index == _firstSelectedCardIndex || index == _secondSelectedCardIndex;

                      return _buildCardWidget(card, index, isMatched, isSelected);
                    },
                  ),
                ),
              ),

              // Mascot Bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🦊', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isMatchedAll
                            ? 'Awesome! You found all matches! 🎉'
                            : (_isProcessing
                                ? 'Checking your pair... 👀'
                                : 'Tap two cards to match them together! ⭐'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
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
  }

  bool get isMatchedAll => _cards.isNotEmpty && _matchedKeys.length >= (_cards.length ~/ 2);

  Widget _buildCardWidget(MatchCardItem card, int index, bool isMatched, bool isSelected) {
    Color cardBg = Colors.white;
    Border? border;

    if (isMatched) {
      cardBg = const Color(0xFFDCFCE7);
      border = Border.all(color: const Color(0xFF22C55E), width: 2.5);
    } else if (isSelected) {
      cardBg = card.color.withValues(alpha: 0.15);
      border = Border.all(color: card.color, width: 3.0);
    } else {
      border = Border.all(color: const Color(0xFFE2E8F0), width: 1.5);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _onCardTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: border,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? card.color.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (card.emoji != null) ...[
                  Text(
                    card.emoji!,
                    style: const TextStyle(fontSize: 34),
                  ),
                  const SizedBox(height: 4),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    card.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: card.label.length > 8 ? 15 : 20,
                      fontWeight: FontWeight.w900,
                      color: isMatched
                          ? const Color(0xFF15803D)
                          : (isSelected ? card.color : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              ],
            ),
            if (isMatched)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
