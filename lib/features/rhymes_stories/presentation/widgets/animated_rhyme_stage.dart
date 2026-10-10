import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../domain/rhyme_story_model.dart';

/// Interactive animated musical stage for Nursery Rhymes
class AnimatedRhymeStage extends StatefulWidget {
  final RhymeItem rhyme;
  final bool isPlaying;
  final bool isHindi;

  const AnimatedRhymeStage({
    super.key,
    required this.rhyme,
    required this.isPlaying,
    this.isHindi = false,
  });

  @override
  State<AnimatedRhymeStage> createState() => _AnimatedRhymeStageState();
}

class _AnimatedRhymeStageState extends State<AnimatedRhymeStage>
    with TickerProviderStateMixin {
  late AnimationController _danceController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final List<_StageSparkle> _sparkles = [];
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _danceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 25),
    ]).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _danceController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onStageTapped(TapDownDetails details) {
    AudioService.instance.playSfx(CurioSfx.bubblePop);
    _bounceController.forward(from: 0.0);

    setState(() {
      _tapCount++;
      final renderBox = context.findRenderObject() as RenderBox?;
      final localPos = renderBox != null
          ? renderBox.globalToLocal(details.globalPosition)
          : const Offset(150, 75);

      final musicEmojis = ['🎵', '🎶', '⭐', '✨', '🎈', '💖'];
      final chosenEmoji = musicEmojis[_tapCount % musicEmojis.length];

      _sparkles.add(_StageSparkle(
        id: DateTime.now().millisecondsSinceEpoch,
        position: localPos,
        emoji: chosenEmoji,
      ));

      if (_sparkles.length > 6) {
        _sparkles.removeAt(0);
      }
    });

    Future.delayed(const Duration(milliseconds: 850), () {
      if (mounted && _sparkles.isNotEmpty) {
        setState(() {
          _sparkles.removeWhere((s) =>
              DateTime.now().millisecondsSinceEpoch - s.id >= 800);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rhyme = widget.rhyme;
    final themeColor = rhyme.themeColor;

    return GestureDetector(
      onTapDown: _onStageTapped,
      child: Container(
        height: 165,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              themeColor.withValues(alpha: 0.18),
              themeColor.withValues(alpha: 0.05),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: widget.isPlaying
                ? themeColor
                : themeColor.withValues(alpha: 0.35),
            width: widget.isPlaying ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: widget.isPlaying ? 0.2 : 0.06),
              blurRadius: widget.isPlaying ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Stage Scenery & Props
            _buildRhymeBackdrop(rhyme.id, themeColor),

            // 2. Main Animated Character
            AnimatedBuilder(
              animation: _danceController,
              builder: (context, _) {
                final danceOffset = math.sin(_danceController.value * math.pi * 2) *
                    (widget.isPlaying ? 8.0 : 4.0);
                final danceRotate = math.cos(_danceController.value * math.pi * 2) *
                    (widget.isPlaying ? 0.08 : 0.03);

                return Center(
                  child: ScaleTransition(
                    scale: _bounceAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _buildRhymeActors(rhyme.id, danceOffset, danceRotate, themeColor),
                    ),
                  ),
                );
              },
            ),

            // 3. Floating Tap Sparkles
            ..._sparkles.map((sparkle) => _buildSparkle(sparkle)),

            // 4. Header Badges
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(rhyme.emoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          rhyme.character,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isPlaying)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMusicEqualizer(),
                          const SizedBox(width: 4),
                          Text(
                            widget.isHindi ? 'गाना चालू ♫' : 'Sing-Along ♫',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 3),
                          Text(
                            widget.isHindi ? 'टच करें 🎈' : 'Tap Stage 🎈',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
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

  Widget _buildRhymeActors(
      String rhymeId, double floatOffset, double rotateAngle, Color themeColor) {
    switch (rhymeId) {
      case 'twinkle_star':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: rotateAngle * 2,
              child: const Text('✨', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),
            Transform.translate(
              offset: Offset(0, floatOffset),
              child: const Text('🌟', style: TextStyle(fontSize: 60)),
            ),
            const SizedBox(width: 14),
            Transform.rotate(
              angle: -rotateAngle * 2,
              child: const Text('🌙', style: TextStyle(fontSize: 36)),
            ),
          ],
        );
      case 'baa_baa_black_sheep':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, floatOffset),
              child: Transform.flip(
                flipX: true,
                child: const Text('🐑', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(width: 16),
            const Text('🧶', style: TextStyle(fontSize: 38)),
            const SizedBox(width: 8),
            const Text('🧶', style: TextStyle(fontSize: 28)),
          ],
        );
      case 'humpty_dumpty':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: rotateAngle * 3,
              child: const Text('👑', style: TextStyle(fontSize: 22)),
            ),
            Transform.translate(
              offset: Offset(0, floatOffset * 0.5),
              child: const Text('🥚', style: TextStyle(fontSize: 50)),
            ),
            const Text('🧱🧱🧱', style: TextStyle(fontSize: 18)),
          ],
        );
      case 'wheels_on_bus':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(floatOffset * 1.2, 0),
              child: Transform.flip(
                flipX: true,
                child: const Text('🚌', style: TextStyle(fontSize: 62)),
              ),
            ),
            const SizedBox(width: 12),
            Transform.rotate(
              angle: floatOffset * 0.5,
              child: const Text('🚏', style: TextStyle(fontSize: 34)),
            ),
          ],
        );
      case 'johny_johny':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, floatOffset),
              child: const Text('👦', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(width: 14),
            const Text('🍬', style: TextStyle(fontSize: 34)),
            const SizedBox(width: 6),
            const Text('🍭', style: TextStyle(fontSize: 28)),
          ],
        );
      case 'jack_and_jill':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, floatOffset),
              child: const Text('👦', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(width: 6),
            Transform.translate(
              offset: Offset(0, -floatOffset),
              child: const Text('👧', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(width: 12),
            const Text('⛰️', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 6),
            const Text('🪣', style: TextStyle(fontSize: 26)),
          ],
        );
      case 'incy_wincy_spider':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, floatOffset * 1.5),
              child: const Text('🕷️', style: TextStyle(fontSize: 50)),
            ),
            const SizedBox(width: 16),
            const Text('🌧️', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 10),
            const Text('☀️', style: TextStyle(fontSize: 34)),
          ],
        );
      case 'row_row_boat':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, floatOffset),
              child: Transform.flip(
                flipX: true,
                child: const Text('🚣', style: TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(width: 14),
            const Text('🌊', style: TextStyle(fontSize: 38)),
            const SizedBox(width: 6),
            const Text('🌊', style: TextStyle(fontSize: 28)),
          ],
        );
      case 'five_little_monkeys':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, floatOffset * 1.5),
              child: Transform.flip(
                flipX: true,
                child: const Text('🐒', style: TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(width: 14),
            const Text('🛏️', style: TextStyle(fontSize: 38)),
            const SizedBox(width: 8),
            const Text('🍌', style: TextStyle(fontSize: 28)),
          ],
        );
      case 'hickory_dickory_dock':
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⏰', style: TextStyle(fontSize: 50)),
            const SizedBox(width: 14),
            Transform.translate(
              offset: Offset(0, floatOffset * 1.8),
              child: const Text('🐭', style: TextStyle(fontSize: 44)),
            ),
          ],
        );
    }
  }

  Widget _buildRhymeBackdrop(String rhymeId, Color themeColor) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 18,
            left: 20,
            child: Opacity(
              opacity: 0.25,
              child: const Text('🎵', style: TextStyle(fontSize: 22)),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: Opacity(
              opacity: 0.25,
              child: const Text('🎶', style: TextStyle(fontSize: 20)),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            right: -10,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkle(_StageSparkle sparkle) {
    return Positioned(
      left: sparkle.position.dx - 12,
      top: sparkle.position.dy - 12,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.2, end: 1.3),
        duration: const Duration(milliseconds: 650),
        builder: (context, val, child) {
          final opacity = (1.3 - val).clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, -val * 22),
            child: Opacity(
              opacity: opacity,
              child: Text(sparkle.emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicEqualizer() {
    return AnimatedBuilder(
      animation: _danceController,
      builder: (context, _) {
        final h1 = 4.0 + math.sin(_danceController.value * math.pi * 3).abs() * 8.0;
        final h2 = 4.0 + math.cos(_danceController.value * math.pi * 4).abs() * 10.0;
        final h3 = 4.0 + math.sin(_danceController.value * math.pi * 5).abs() * 7.0;

        return Row(
          children: [
            _bar(h1),
            const SizedBox(width: 1.5),
            _bar(h2),
            const SizedBox(width: 1.5),
            _bar(h3),
          ],
        );
      },
    );
  }

  Widget _bar(double h) {
    return Container(
      width: 2,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}

class _StageSparkle {
  final int id;
  final Offset position;
  final String emoji;

  _StageSparkle({
    required this.id,
    required this.position,
    required this.emoji,
  });
}
