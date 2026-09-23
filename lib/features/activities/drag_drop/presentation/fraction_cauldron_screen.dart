import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../data/models/activity_model.dart';
import '../../../../data/services/procedural_question_generator.dart';
import '../../../../shared/components/curio_progress_bar.dart';
import '../../../../shared/dialogs/reward_dialog.dart';

class FractionCardItem {
  final String id;
  final int numerator;
  final int denominator;
  final bool isEquivalent;
  bool isDropped;

  FractionCardItem({
    required this.id,
    required this.numerator,
    required this.denominator,
    required this.isEquivalent,
    this.isDropped = false,
  });

  String get displayText => '$numerator/$denominator';
}

class FractionCauldronScreen extends StatefulWidget {
  final Activity? activity;

  const FractionCauldronScreen({super.key, this.activity});

  @override
  State<FractionCauldronScreen> createState() => _FractionCauldronScreenState();
}

class _FractionCauldronScreenState extends State<FractionCauldronScreen> {
  late List<FractionCardItem> _cards;
  int _correctDroppedCount = 0;
  int _totalTargetCount = 3;
  String _targetBaseString = '1/2';
  String _mascotMessage = '';
  bool _isCauldronHovered = false;
  int _roundCount = 1;

  @override
  void initState() {
    super.initState();
    _loadActivity(widget.activity);
  }

  void _loadActivity(Activity? act) {
    _correctDroppedCount = 0;
    final payload = act?.interactionPayload;

    if (payload != null && payload.containsKey('draggableItems')) {
      _targetBaseString = payload['targetBase'] as String? ??
          (payload['targetDenominatorRatio'] != null
              ? (payload['targetDenominatorRatio'] == 0.5 ? '1/2' : '1/3')
              : '1/2');

      final rawList = payload['draggableItems'] as List<dynamic>;
      _cards = rawList.map((item) {
        final map = item as Map<String, dynamic>;
        return FractionCardItem(
          id: map['itemId'] as String? ?? 'f_${map['numerator']}_${map['denominator']}',
          numerator: map['numerator'] as int? ?? 1,
          denominator: map['denominator'] as int? ?? 2,
          isEquivalent: map['isEquivalent'] as bool? ?? false,
        );
      }).toList();
    } else {
      // Default fallback if launched standalone
      _targetBaseString = '1/2';
      _cards = [
        FractionCardItem(id: 'f1', numerator: 2, denominator: 4, isEquivalent: true),
        FractionCardItem(id: 'f2', numerator: 3, denominator: 6, isEquivalent: true),
        FractionCardItem(id: 'f3', numerator: 2, denominator: 5, isEquivalent: false),
        FractionCardItem(id: 'f4', numerator: 4, denominator: 8, isEquivalent: true),
        FractionCardItem(id: 'f5', numerator: 3, denominator: 4, isEquivalent: false),
        FractionCardItem(id: 'f6', numerator: 5, denominator: 9, isEquivalent: false),
      ];
    }

    _totalTargetCount = _cards.where((c) => c.isEquivalent).length;
    _mascotMessage = 'Drag all fractions equal to $_targetBaseString into the Golden Cauldron!';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AudioService.instance.speakPrompt(
        act?.promptData.ttsFallback ??
            'Drag all fractions equivalent to $_targetBaseString into the Golden Cauldron!',
      );
    });
  }

  void _handleDrop(FractionCardItem card) {
    if (card.isEquivalent) {
      AudioService.instance.playSfx(CurioSfx.correctCheer);
      setState(() {
        card.isDropped = true;
        _correctDroppedCount++;
        _mascotMessage = 'Awesome! ${card.displayText} is equivalent to $_targetBaseString! ✨';
      });

      if (_correctDroppedCount >= _totalTargetCount) {
        _onComplete();
      }
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      setState(() {
        _mascotMessage = 'Oops! ${card.displayText} is not equal to $_targetBaseString. Try another!';
      });
    }
  }

  void _onComplete() {
    AudioService.instance.playSfx(CurioSfx.starAward);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      RewardDialog.show(
        context,
        starsAwarded: 3,
        totalPoints: (widget.activity?.pointsReward ?? 35) * _roundCount,
        message: 'You brewed all the equivalent fractions correctly! 🧪✨',
        onContinue: () {
          // Generate next procedural fraction activity dynamically!
          final next = ProceduralQuestionGenerator.instance.generateEquivalentFractions(
            targetGrade: widget.activity?.targetGrade ?? 'Class 4',
          );
          setState(() {
            _roundCount++;
            _loadActivity(next);
          });
        },
        onReplay: () {
          setState(() {
            _loadActivity(widget.activity);
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressFraction = _totalTargetCount > 0
        ? _correctDroppedCount / _totalTargetCount
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: Text(
          'Fraction Cauldron #$_roundCount',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: CurioProgressBar(
                progress: progressFraction,
                currentStars: _correctDroppedCount,
                totalStars: _totalTargetCount,
                barColor: const Color(0xFF16A34A),
              ),
            ),

            const SizedBox(height: 8),

            // Drop Zone Cauldron with Dynamic Target
            Expanded(
              flex: 4,
              child: DragTarget<FractionCardItem>(
                onWillAcceptWithDetails: (details) {
                  setState(() => _isCauldronHovered = true);
                  return true;
                },
                onLeave: (_) {
                  setState(() => _isCauldronHovered = false);
                },
                onAcceptWithDetails: (details) {
                  setState(() => _isCauldronHovered = false);
                  _handleDrop(details.data);
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isCauldronHovered
                          ? const Color(0xFFFEF08A)
                          : const Color(0xFFFEF9C3),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _isCauldronHovered
                            ? const Color(0xFFCA8A04)
                            : const Color(0xFFEAB308),
                        width: _isCauldronHovered ? 3.5 : 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEAB308).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🍯', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 8),
                          Text(
                            'Cauldron: Target $_targetBaseString',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF854D0E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Collected: $_correctDroppedCount of $_totalTargetCount equivalent fractions',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFA16207),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Draggable Cards Area
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: _cards.map((card) {
                    if (card.isDropped) {
                      return const SizedBox(width: 80, height: 75);
                    }
                    return Draggable<FractionCardItem>(
                      data: card,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildFractionCard(card, isDragging: true),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildFractionCard(card),
                      ),
                      child: _buildFractionCard(card),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Bottom Prompt & Mascot Dialogue
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Text('🦊', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _mascotMessage,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFractionCard(FractionCardItem card, {bool isDragging = false}) {
    return Container(
      width: 80,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: isDragging ? 0.4 : 0.15),
            blurRadius: isDragging ? 14 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${card.numerator}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
              ),
            ),
            Container(
              width: 32,
              height: 2.5,
              color: const Color(0xFF1E3A8A),
            ),
            Text(
              '${card.denominator}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
