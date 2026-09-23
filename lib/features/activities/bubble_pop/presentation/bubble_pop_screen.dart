import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/theme/grade_tier_extension.dart';
import '../../../../data/local/local_storage_service.dart';
import '../../../../data/models/activity_model.dart';
import '../../../../data/models/student_attempt_model.dart';
import '../../../../shared/components/curio_progress_bar.dart';
import '../../../../shared/dialogs/reward_dialog.dart';
import '../models/bubble_item.dart';

class BubbleLevelData {
  final int levelNumber;
  final String title;
  final dynamic targetValue;
  final String promptText;
  final List<BubbleItem> bubbles;

  const BubbleLevelData({
    required this.levelNumber,
    required this.title,
    required this.targetValue,
    required this.promptText,
    required this.bubbles,
  });
}

/// Playable Mini-Game: "Bubble Pop Counting & Early Learning" with Multi-Level Progression
class BubblePopScreen extends StatefulWidget {
  final Activity? activity;
  final List<Activity>? activities;
  final int initialLevelIndex;

  const BubblePopScreen({
    super.key,
    this.activity,
    this.activities,
    this.initialLevelIndex = 0,
  });

  @override
  State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen>
    with TickerProviderStateMixin {
  late AnimationController _physicsController;
  late AnimationController _wobbleController;

  int _currentLevelIndex = 0;
  late List<BubbleLevelData> _levels;

  late List<BubbleItem> _bubbles;
  late dynamic _targetValue;
  int _targetTotalCount = 0;
  int _poppedCorrectCount = 0;
  int _levelMistakes = 0;
  String _mascotMessage = '';
  String? _encouragementDetail;

  @override
  void initState() {
    super.initState();
    _buildLevels();
    _loadLevel(_currentLevelIndex);

    // Smooth physics ticker for continuous buoyant floating
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_tickBubblePhysics)..repeat();

    // Controller for gentle wobble oscillations on incorrect selection
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Auto-trigger voice prompt on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _announceCurrentPrompt();
    });
  }

  void _announceCurrentPrompt() {
    final prompt = _levels[_currentLevelIndex].promptText;
    AudioService.instance.speakPrompt(prompt);
  }

  bool _isTargetMatch(dynamic val1, dynamic val2) {
    if (val1 == null || val2 == null) return false;
    if (val1 == val2) return true;
    final s1 = val1.toString().toLowerCase().trim();
    final s2 = val2.toString().toLowerCase().trim();
    return s1 == s2;
  }

  void _buildLevels() {
    final acts = widget.activities ??
        (widget.activity != null ? [widget.activity!] : <Activity>[]);
    final customLevels = <BubbleLevelData>[];

    for (int i = 0; i < acts.length; i++) {
      final act = acts[i];
      final payload = act.interactionPayload;
      if (payload.containsKey('bubbles') && (payload['bubbles'] as List).isNotEmpty) {
        final rawBubbles = payload['bubbles'] as List;
        final target = payload['targetValue'];
        final prompt = act.promptData.ttsFallback ?? act.promptData.text;
        customLevels.add(
          BubbleLevelData(
            levelNumber: i + 1,
            title: act.promptData.text,
            targetValue: target,
            promptText: prompt,
            bubbles: rawBubbles.asMap().entries.map((be) {
              return BubbleItem.fromJson(
                be.value as Map<String, dynamic>,
                be.key,
                rawBubbles.length,
              );
            }).toList(),
          ),
        );
      }
    }

    if (customLevels.isNotEmpty) {
      _levels = customLevels;
      _currentLevelIndex = widget.initialLevelIndex.clamp(0, _levels.length - 1);
      return;
    }

    // Default Math fallback levels
    _levels = [
      // Level 1: Numbers & Stars equal to 5 (CBSE LKG/UKG)
      BubbleLevelData(
        levelNumber: 1,
        title: 'Level 1: Find 5',
        targetValue: 5,
        promptText: 'Pop all bubbles that equal 5!',
        bubbles: [
          BubbleItem(id: 'l1_1', label: '5', value: 5, displayType: 'number', color: const Color(0xFF4ADE80), x: 0.15, y: 0.22, vx: 0.0012, vy: -0.0010),
          BubbleItem(id: 'l1_2', label: '⭐⭐⭐⭐⭐', value: 5, displayType: 'objects', color: const Color(0xFFFBBF24), x: 0.65, y: 0.20, vx: -0.0011, vy: 0.0013),
          BubbleItem(id: 'l1_3', label: '3', value: 3, displayType: 'number', color: const Color(0xFF60A5FA), x: 0.25, y: 0.55, vx: 0.0009, vy: 0.0012),
          BubbleItem(id: 'l1_4', label: '2 + 3', value: 5, displayType: 'expression', color: const Color(0xFFF472B6), x: 0.70, y: 0.60, vx: -0.0010, vy: -0.0009),
          BubbleItem(id: 'l1_5', label: '⭐⭐', value: 2, displayType: 'objects', color: const Color(0xFFA78BFA), x: 0.45, y: 0.35, vx: 0.0010, vy: 0.0008),
          BubbleItem(id: 'l1_6', label: '5', value: 5, displayType: 'number', color: const Color(0xFF38BDF8), x: 0.10, y: 0.72, vx: -0.0008, vy: -0.0014),
        ],
      ),
      // Level 2: Numbers & Stars equal to 7 (CBSE Class 1 Addition Bonds)
      BubbleLevelData(
        levelNumber: 2,
        title: 'Level 2: Target 7',
        targetValue: 7,
        promptText: 'Great! Now pop all bubbles that equal 7!',
        bubbles: [
          BubbleItem(id: 'l2_1', label: '7', value: 7, displayType: 'number', color: const Color(0xFFEC4899), x: 0.20, y: 0.25, vx: 0.0011, vy: 0.0009),
          BubbleItem(id: 'l2_2', label: '4 + 3', value: 7, displayType: 'expression', color: const Color(0xFF10B981), x: 0.60, y: 0.30, vx: -0.0013, vy: -0.0008),
          BubbleItem(id: 'l2_3', label: '6', value: 6, displayType: 'number', color: const Color(0xFFF59E0B), x: 0.30, y: 0.65, vx: 0.0008, vy: -0.0011),
          BubbleItem(id: 'l2_4', label: '5 + 2', value: 7, displayType: 'expression', color: const Color(0xFF3B82F6), x: 0.75, y: 0.60, vx: -0.0009, vy: 0.0012),
          BubbleItem(id: 'l2_5', label: '4', value: 4, displayType: 'number', color: const Color(0xFF8B5CF6), x: 0.12, y: 0.45, vx: 0.0012, vy: -0.0007),
          BubbleItem(id: 'l2_6', label: '⭐⭐⭐⭐⭐⭐⭐', value: 7, displayType: 'objects', color: const Color(0xFF14B8A6), x: 0.45, y: 0.75, vx: -0.0010, vy: -0.0010),
        ],
      ),
      // Level 3: Numbers & Bonds equal to 10 (CBSE Class 1/2 Mastery)
      BubbleLevelData(
        levelNumber: 3,
        title: 'Level 3: Power of 10',
        targetValue: 10,
        promptText: 'Superstar! Pop all bubbles that equal 10!',
        bubbles: [
          BubbleItem(id: 'l3_1', label: '10', value: 10, displayType: 'number', color: const Color(0xFF6366F1), x: 0.18, y: 0.30, vx: 0.0010, vy: -0.0011),
          BubbleItem(id: 'l3_2', label: '5 + 5', value: 10, displayType: 'expression', color: const Color(0xFFEF4444), x: 0.65, y: 0.25, vx: -0.0012, vy: 0.0009),
          BubbleItem(id: 'l3_3', label: '8', value: 8, displayType: 'number', color: const Color(0xFF10B981), x: 0.35, y: 0.60, vx: 0.0009, vy: 0.0013),
          BubbleItem(id: 'l3_4', label: '7 + 3', value: 10, displayType: 'expression', color: const Color(0xFFF97316), x: 0.72, y: 0.68, vx: -0.0011, vy: -0.0010),
          BubbleItem(id: 'l3_5', label: '9', value: 9, displayType: 'number', color: const Color(0xFF06B6D4), x: 0.15, y: 0.70, vx: 0.0013, vy: -0.0008),
          BubbleItem(id: 'l3_6', label: '6 + 4', value: 10, displayType: 'expression', color: const Color(0xFF84CC16), x: 0.50, y: 0.40, vx: -0.0008, vy: 0.0011),
        ],
      ),
    ];
    _currentLevelIndex = widget.initialLevelIndex.clamp(0, _levels.length - 1);
  }

  void _loadLevel(int levelIdx) {
    final level = _levels[levelIdx];
    _targetValue = level.targetValue;
    _poppedCorrectCount = 0;
    _levelMistakes = 0;
    _encouragementDetail = null;
    _mascotMessage = 'Level ${level.levelNumber}: ${level.promptText}';

    // Clone bubbles for fresh interactive play
    _bubbles = level.bubbles.map((b) {
      return BubbleItem(
        id: b.id,
        label: b.label,
        value: b.value,
        displayType: b.displayType,
        color: b.color,
        x: b.x,
        y: b.y,
        vx: b.vx,
        vy: b.vy,
        radius: b.radius,
      );
    }).toList();

    _targetTotalCount = _bubbles.where((b) {
      return _isTargetMatch(b.value, _targetValue) || b.id == _targetValue.toString();
    }).length;
    if (_targetTotalCount == 0) {
      _targetTotalCount = 1;
    }
  }

  void _tickBubblePhysics() {
    for (final b in _bubbles) {
      if (b.isPopped) continue;

      b.x += b.vx;
      b.y += b.vy;

      if (b.x < 0.02 || b.x > 0.98) {
        b.vx = -b.vx;
        b.x = b.x.clamp(0.02, 0.98);
      }
      if (b.y < 0.02 || b.y > 0.98) {
        b.vy = -b.vy;
        b.y = b.y.clamp(0.02, 0.98);
      }
    }
  }

  void _handleBubbleTap(BubbleItem bubble) {
    if (bubble.isPopped) return;

    final isCorrect = _isTargetMatch(bubble.value, _targetValue) || (bubble.id == _targetValue.toString());

    if (isCorrect) {
      AudioService.instance.playSfx(CurioSfx.bubblePop);

      setState(() {
        bubble.isPopped = true;
        _poppedCorrectCount++;
        _mascotMessage = 'Super! That is ${bubble.label}! 🌟';
        _encouragementDetail = null;
      });

      if (_poppedCorrectCount >= _targetTotalCount) {
        _onLevelCompleted();
      }
    } else {
      _levelMistakes++;
      AudioService.instance.playSfx(CurioSfx.gentleWobble);

      setState(() {
        bubble.isWobbling = true;
        _mascotMessage = 'Almost! That is ${bubble.label}.';
        _encouragementDetail = 'Look for bubbles that match the question!';
      });

      _wobbleController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            bubble.isWobbling = false;
          });
        }
      });
    }
  }

  void _onLevelCompleted() {
    AudioService.instance.playSfx(CurioSfx.starAward);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final hasNextLevel = _currentLevelIndex < _levels.length - 1;

      final int starsAwarded;
      if (_levelMistakes == 0) {
        starsAwarded = 3;
      } else if (_levelMistakes <= 2) {
        starsAwarded = 2;
      } else {
        starsAwarded = 1;
      }

      final currentAct = (widget.activities != null && _currentLevelIndex < widget.activities!.length)
          ? widget.activities![_currentLevelIndex]
          : widget.activity;

      final basePoints = (currentAct?.pointsReward ?? 20) * (_currentLevelIndex + 1);
      final points = ((basePoints * starsAwarded) ~/ 3).clamp(5, 100);

      if (currentAct != null) {
        final attempt = StudentQuestionAttempt(
          activityId: currentAct.activityId,
          chapterId: currentAct.chapterId ?? '',
          selectedOptionIndex: 0,
          selectedOptionText: 'popped_all',
          isCorrect: true,
          starsEarned: starsAwarded,
          timestamp: DateTime.now(),
        );
        LocalStorageService.instance.saveQuestionAttempt(attempt);
      }

      final congratMessage = starsAwarded == 3
          ? 'You popped all the correct bubbles without missing a single one! 🌟'
          : 'You popped all the correct bubbles! Great job! ⭐';

      RewardDialog.show(
        context,
        starsAwarded: starsAwarded,
        totalPoints: points,
        message: congratMessage,
        onContinue: () {
          if (hasNextLevel) {
            setState(() {
              _currentLevelIndex++;
              _loadLevel(_currentLevelIndex);
            });
            _announceCurrentPrompt();
          } else {
            // Completed all levels
            Navigator.of(context).maybePop();
          }
        },
        onReplay: () {
          setState(() {
            _loadLevel(_currentLevelIndex);
          });
          _announceCurrentPrompt();
        },
      );
    });
  }

  @override
  void dispose() {
    _physicsController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tierTheme = context.tierTheme;
    final progressFraction = _targetTotalCount > 0
        ? _poppedCorrectCount / _targetTotalCount
        : 0.0;
    final currentLevel = _levels[_currentLevelIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFBAE6FD),
      body: SizedBox.expand(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFBAE6FD), // Sky blue
                Color(0xFFE0F2FE), // Soft ice blue
                Color(0xFFFEF08A), // Sunny sandy bottom
              ],
              stops: [0.0, 0.65, 1.0],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final bubbleDiameter = tierTheme.bubbleSize;

                final topMargin = 78.0;
                final bottomMargin = 100.0;
                final playWidth = max(screenWidth - bubbleDiameter, 1.0);
                final playHeight = max(screenHeight - topMargin - bottomMargin - bubbleDiameter, 1.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Play Area: Animated Floating Bubbles
                    AnimatedBuilder(
                      animation: _physicsController,
                      builder: (context, _) {
                        return Stack(
                          fit: StackFit.expand,
                          children: _bubbles.map((bubble) {
                            if (bubble.isPopped) return const SizedBox.shrink();

                            final px = bubble.x * playWidth;
                            final py = topMargin + (bubble.y * playHeight);

                            return Positioned(
                              left: px,
                              top: py,
                              child: _BubbleWidget(
                                bubble: bubble,
                                wobbleAnimation: _wobbleController,
                                onTap: () => _handleBubbleTap(bubble),
                                bubbleDiameter: bubbleDiameter,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    // 2. Top Header: Back Button, Level Badge, Progress & Audio Trigger
                    Positioned(
                      top: 8,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          IconButton(
                            iconSize: 30,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: tierTheme.minTouchTarget,
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0369A1)),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 6),
                          // Level Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'L${currentLevel.levelNumber}/${_levels.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Progress Bar
                          Expanded(
                            child: CurioProgressBar(
                              progress: progressFraction,
                              currentStars: _poppedCorrectCount,
                              totalStars: _targetTotalCount,
                              barColor: const Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ValueListenableBuilder<bool>(
                            valueListenable: AudioService.instance.muteNotifier,
                            builder: (context, isMuted, _) {
                              return IconButton(
                                iconSize: 26,
                                style: IconButton.styleFrom(
                                  backgroundColor: isMuted ? const Color(0xFFFEE2E2) : Colors.white,
                                  minimumSize: tierTheme.minTouchTarget,
                                  elevation: 4,
                                ),
                                icon: Icon(
                                  isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                  color: isMuted ? const Color(0xFFDC2626) : const Color(0xFF0369A1),
                                ),
                                tooltip: isMuted ? 'Unmute Speaker' : 'Mute Speaker',
                                onPressed: () {
                                  AudioService.instance.toggleMute();
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            iconSize: 30,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD54F),
                              minimumSize: tierTheme.minTouchTarget,
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF78350F)),
                            onPressed: _announceCurrentPrompt,
                          ),
                        ],
                      ),
                    ),

                    // 3. Bottom Prompt & Mascot Dialogue Bar
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: _MascotPromptBar(
                        mascotMessage: _mascotMessage,
                        encouragementDetail: _encouragementDetail,
                        targetValue: _targetValue,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleWidget extends StatelessWidget {
  final BubbleItem bubble;
  final AnimationController wobbleAnimation;
  final VoidCallback onTap;
  final double bubbleDiameter;

  const _BubbleWidget({
    required this.bubble,
    required this.wobbleAnimation,
    required this.onTap,
    required this.bubbleDiameter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wobbleAnimation,
      builder: (context, child) {
        double angle = 0.0;
        double offsetX = 0.0;
        if (bubble.isWobbling) {
          final val = wobbleAnimation.value;
          angle = sin(val * pi * 4) * 0.18 * (1.0 - val);
          offsetX = sin(val * pi * 4) * 10.0 * (1.0 - val);
        }

        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: Transform.rotate(
            angle: angle,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: bubbleDiameter,
            height: bubbleDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.4),
                radius: 0.85,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  bubble.color.withValues(alpha: 0.65),
                  bubble.color.withValues(alpha: 0.45),
                  Colors.white.withValues(alpha: 0.25),
                ],
                stops: const [0.05, 0.45, 0.8, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: bubble.color.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  left: 14,
                  child: Container(
                    width: 12,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      bubble.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bubble.displayType == 'objects' ? 18 : 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        shadows: const [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotPromptBar extends StatelessWidget {
  final String mascotMessage;
  final String? encouragementDetail;
  final dynamic targetValue;

  const _MascotPromptBar({
    required this.mascotMessage,
    this.encouragementDetail,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF9800),
            ),
            child: const Center(
              child: Text(
                '🦊',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mascotMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (encouragementDetail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    encouragementDetail!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
