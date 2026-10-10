import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../domain/rhyme_story_model.dart';

/// Dynamic, interactive picture-book illustration canvas for children's moral stories
class AnimatedStorySceneIllustration extends StatefulWidget {
  final StoryItem story;
  final int currentSceneIndex;
  final bool isSpeaking;
  final bool isHindi;

  const AnimatedStorySceneIllustration({
    super.key,
    required this.story,
    required this.currentSceneIndex,
    required this.isSpeaking,
    this.isHindi = false,
  });

  @override
  State<AnimatedStorySceneIllustration> createState() =>
      _AnimatedStorySceneIllustrationState();
}

class _AnimatedStorySceneIllustrationState
    extends State<AnimatedStorySceneIllustration>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final List<_TapSparkle> _sparkles = [];
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
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
          : const Offset(150, 90);

      final stars = ['⭐', '✨', '🎈', '💖', '🌟', '🎶'];
      final chosenEmoji = stars[_tapCount % stars.length];

      _sparkles.add(_TapSparkle(
        id: DateTime.now().millisecondsSinceEpoch,
        position: localPos,
        emoji: chosenEmoji,
      ));

      if (_sparkles.length > 6) {
        _sparkles.removeAt(0);
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _sparkles.isNotEmpty) {
        setState(() {
          _sparkles.removeWhere((s) =>
              DateTime.now().millisecondsSinceEpoch - s.id >= 850);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sceneIndex = widget.currentSceneIndex.clamp(0, widget.story.scenes.length - 1);
    final scene = widget.story.scenes[sceneIndex];
    final themeColor = widget.story.themeColor;

    return GestureDetector(
      onTapDown: _onStageTapped,
      child: Container(
        height: 200,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: _getSceneGradient(widget.story.id, sceneIndex, themeColor),
          border: Border.all(
            color: widget.isSpeaking
                ? themeColor
                : themeColor.withValues(alpha: 0.35),
            width: widget.isSpeaking ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: widget.isSpeaking ? 0.22 : 0.08),
              blurRadius: widget.isSpeaking ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Illustrated Landscape Background
            _buildLandscapeBackground(widget.story.id, sceneIndex, themeColor),

            // 2. Main Animated Stage Actors
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey('${widget.story.id}_scene_$sceneIndex'),
                child: _buildSceneActorLayout(widget.story.id, sceneIndex, scene, themeColor),
              ),
            ),

            // 3. Floating Tap Sparkles
            ..._sparkles.map((sparkle) => _buildSparkleWidget(sparkle)),

            // 4. Top Status Header (Speaking soundwaves or interactive hint)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Scene Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${sceneIndex + 1}/${widget.story.scenes.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getSceneName(widget.story.id, sceneIndex, widget.isHindi),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Speaking Equalizer or Tap Hint
                  if (widget.isSpeaking)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMiniEqualizer(),
                          const SizedBox(width: 5),
                          Text(
                            widget.isHindi ? 'बोल रहे हैं 🗣️' : 'Reading 🗣️',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👆', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(
                            widget.isHindi ? 'टच करके देखें ✨' : 'Tap to play ✨',
                            style: const TextStyle(
                              fontSize: 10,
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

  // ---------------------------------------------------------------------------
  // ACTOR LAYOUT TAILORED PER STORY SCENE
  // ---------------------------------------------------------------------------
  Widget _buildSceneActorLayout(
      String storyId, int sceneIndex, StoryScene scene, Color themeColor) {
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, _) {
        final idleFloat = math.sin(_idleController.value * math.pi * 2) * 5.0;
        final idleSway = math.cos(_idleController.value * math.pi * 2) * 0.04;

        return ScaleTransition(
          scale: _bounceAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: _buildStorySpecificStage(
                storyId,
                sceneIndex,
                scene,
                idleFloat,
                idleSway,
                themeColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStorySpecificStage(
    String storyId,
    int sceneIndex,
    StoryScene scene,
    double idleFloat,
    double idleSway,
    Color themeColor,
  ) {
    switch (storyId) {
      case 'thirsty_crow':
        return _buildThirstyCrowStage(sceneIndex, idleFloat, idleSway);
      case 'hare_and_tortoise':
        return _buildHareAndTortoiseStage(sceneIndex, idleFloat, idleSway);
      case 'lion_and_mouse':
        return _buildLionAndMouseStage(sceneIndex, idleFloat, idleSway);
      case 'boy_cried_wolf':
        return _buildBoyCriedWolfStage(sceneIndex, idleFloat, idleSway);
      case 'ant_and_dove':
        return _buildAntAndDoveStage(sceneIndex, idleFloat, idleSway);
      default:
        return _buildDefaultActorStage(scene, idleFloat, idleSway, themeColor);
    }
  }

  // 1. Thirsty Crow Animated Stage
  Widget _buildThirstyCrowStage(int sceneIndex, double idleFloat, double idleSway) {
    switch (sceneIndex) {
      case 0: // Flying under hot sun
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦅', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(width: 32),
            Transform.rotate(
              angle: idleSway * 2,
              child: const Text('☀️', style: TextStyle(fontSize: 48)),
            ),
          ],
        );
      case 1: // Spotting pitcher with little water
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦅', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(width: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                const Text('🏺', style: TextStyle(fontSize: 54)),
                Positioned(
                  bottom: 6,
                  child: Transform.scale(
                    scale: 0.9 + (_idleController.value * 0.2),
                    child: const Text('💧', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        );
      case 2: // Looking at smooth pebbles with bright idea!
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: Offset(0, idleFloat),
                  child: const Text('🦅', style: TextStyle(fontSize: 52)),
                ),
                Positioned(
                  top: -16,
                  right: -4,
                  child: Transform.scale(
                    scale: 1.0 + (_idleController.value * 0.25),
                    child: const Text('💡', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: const [
                Text('🪨', style: TextStyle(fontSize: 26)),
                SizedBox(width: 4),
                Text('🪨', style: TextStyle(fontSize: 32)),
                SizedBox(width: 4),
                Text('🪨', style: TextStyle(fontSize: 22)),
              ],
            ),
          ],
        );
      case 3: // Dropping pebbles one by one into pitcher
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦅', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(width: 8),
            Transform.translate(
              offset: Offset(0, 4 + idleFloat.abs()),
              child: const Text('🪨', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 8),
            const Text('🏺', style: TextStyle(fontSize: 54)),
          ],
        );
      case 4: // Water risen! Happy drinking & sparkles
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦅', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 16),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                const Text('🏺', style: TextStyle(fontSize: 54)),
                Positioned(
                  top: -6,
                  child: Transform.scale(
                    scale: 1.0 + (_idleController.value * 0.3),
                    child: const Text('🌊', style: TextStyle(fontSize: 26)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            const Text('✨', style: TextStyle(fontSize: 28)),
          ],
        );
    }
  }

  // 2. Hare and Tortoise Animated Stage
  Widget _buildHareAndTortoiseStage(int sceneIndex, double idleFloat, double idleSway) {
    switch (sceneIndex) {
      case 0: // Challenge at start line
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🐇', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(width: 16),
            const Text('⚡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Transform.translate(
              offset: Offset(0, -idleFloat * 0.5),
              child: const Text('🐢', style: TextStyle(fontSize: 48)),
            ),
          ],
        );
      case 1: // Hare sprinting ahead like wind
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(idleFloat * 1.5, 0),
              child: Row(
                children: const [
                  Text('💨', style: TextStyle(fontSize: 28)),
                  Text('🐇', style: TextStyle(fontSize: 56)),
                ],
              ),
            ),
            const SizedBox(width: 30),
            const Text('🐢', style: TextStyle(fontSize: 34)),
          ],
        );
      case 2: // Hare sleeping under shady tree
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌳', style: TextStyle(fontSize: 56)),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Text('🐇', style: TextStyle(fontSize: 48)),
                Positioned(
                  top: -16,
                  right: -10,
                  child: Transform.translate(
                    offset: Offset(0, -idleFloat.abs() * 1.5),
                    child: const Text('💤', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            ),
          ],
        );
      case 3: // Tortoise walking past steadily
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌳', style: TextStyle(fontSize: 46)),
            const SizedBox(width: 4),
            const Text('💤', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 24),
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Row(
                children: const [
                  Text('🐢', style: TextStyle(fontSize: 52)),
                  SizedBox(width: 4),
                  Text('🐾', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        );
      case 4: // Tortoise wins trophy at finish line!
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🐢', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 16),
            Transform.scale(
              scale: 1.0 + (_idleController.value * 0.2),
              child: const Text('🏆', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(width: 12),
            const Text('🏁', style: TextStyle(fontSize: 42)),
          ],
        );
    }
  }

  // 3. Lion and Mouse Animated Stage
  Widget _buildLionAndMouseStage(int sceneIndex, double idleFloat, double idleSway) {
    switch (sceneIndex) {
      case 0: // Lion sleeping, mouse tickles nose
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat * 0.4),
              child: const Text('🦁', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(width: 8),
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🐭', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 6),
            const Text('💤', style: TextStyle(fontSize: 20)),
          ],
        );
      case 1: // Lion traps mouse under paw
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🦁', style: TextStyle(fontSize: 58)),
            const SizedBox(width: 10),
            Transform.scale(
              scale: 0.9 + (_idleController.value * 0.15),
              child: const Text('🐭', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 6),
            const Text('🙏', style: TextStyle(fontSize: 22)),
          ],
        );
      case 2: // Lion smiles and frees mouse
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦁', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(width: 20),
            const Text('✨', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 16),
            Transform.translate(
              offset: Offset(0, -idleFloat),
              child: const Text('🐭', style: TextStyle(fontSize: 36)),
            ),
          ],
        );
      case 3: // Lion trapped in hunter's rope net
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Text('🦁', style: TextStyle(fontSize: 56)),
                Transform.scale(
                  scale: 1.05 + (_idleController.value * 0.1),
                  child: const Text('🕸️', style: TextStyle(fontSize: 60)),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('📢', style: TextStyle(fontSize: 26)),
            ),
          ],
        );
      case 4: // Mouse chews ropes, best friends!
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦁', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 10),
            Transform.scale(
              scale: 1.0 + (_idleController.value * 0.2),
              child: const Text('💖', style: TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 10),
            Transform.translate(
              offset: Offset(0, -idleFloat),
              child: const Text('🐭', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(width: 8),
            const Text('👑', style: TextStyle(fontSize: 26)),
          ],
        );
    }
  }

  // 4. Boy Who Cried Wolf Stage
  Widget _buildBoyCriedWolfStage(int sceneIndex, double idleFloat, double idleSway) {
    switch (sceneIndex) {
      case 0: // Shepherd boy with sheep
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('👦', style: TextStyle(fontSize: 50)),
            ),
            const SizedBox(width: 16),
            const Text('🐑', style: TextStyle(fontSize: 38)),
            const SizedBox(width: 8),
            const Text('🐑', style: TextStyle(fontSize: 30)),
          ],
        );
      case 1: // Shouting wolf for fun
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('👦', style: TextStyle(fontSize: 50)),
            ),
            const SizedBox(width: 12),
            Transform.scale(
              scale: 1.0 + (_idleController.value * 0.2),
              child: const Text('📢', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(width: 10),
            const Text('😆', style: TextStyle(fontSize: 30)),
          ],
        );
      case 2: // Villagers running up hill
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(idleFloat, 0),
              child: const Text('🏃‍♂️', style: TextStyle(fontSize: 42)),
            ),
            const SizedBox(width: 6),
            Transform.translate(
              offset: Offset(-idleFloat, 0),
              child: const Text('🏃‍♀️', style: TextStyle(fontSize: 42)),
            ),
            const SizedBox(width: 20),
            const Text('👦', style: TextStyle(fontSize: 44)),
          ],
        );
      case 3: // Real wolf emerges from dark forest
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('👦', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(width: 24),
            Transform.scale(
              scale: 1.0 + (_idleController.value * 0.15),
              child: const Text('🐺', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(width: 10),
            const Text('🌲', style: TextStyle(fontSize: 38)),
          ],
        );
      case 4: // Learning lesson: tell truth
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('👦', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(width: 18),
            Transform.scale(
              scale: 1.0 + (_idleController.value * 0.25),
              child: const Text('🌟', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(width: 14),
            const Text('🤝', style: TextStyle(fontSize: 34)),
          ],
        );
    }
  }

  // 5. Ant and Dove Stage
  Widget _buildAntAndDoveStage(int sceneIndex, double idleFloat, double idleSway) {
    switch (sceneIndex) {
      case 0: // Ant falling in river
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🐜', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(width: 14),
            Transform.scale(
              scale: 1.0 + (_idleController.value * 0.2),
              child: const Text('🌊', style: TextStyle(fontSize: 52)),
            ),
          ],
        );
      case 1: // Dove drops leaf into water
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🕊️', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(width: 14),
            Transform.translate(
              offset: Offset(0, idleFloat.abs() * 2),
              child: const Text('🍃', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 12),
            const Text('🌊', style: TextStyle(fontSize: 40)),
          ],
        );
      case 2: // Ant safe on floating leaf
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Text('🍃', style: TextStyle(fontSize: 58)),
                  Positioned(
                    top: 10,
                    child: Text('🐜', style: TextStyle(fontSize: 30)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            const Text('✨', style: TextStyle(fontSize: 32)),
          ],
        );
      case 3: // Hunter aims at dove, ant bites
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏹', style: TextStyle(fontSize: 44)),
            const SizedBox(width: 14),
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🐜', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(width: 16),
            const Text('🕊️', style: TextStyle(fontSize: 48)),
          ],
        );
      case 4: // Dove safe & best friends
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🕊️', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 14),
            Transform.scale(
              scale: 1.0 + (_idleController.value * 0.25),
              child: const Text('💖', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(width: 14),
            Transform.translate(
              offset: Offset(0, -idleFloat),
              child: const Text('🐜', style: TextStyle(fontSize: 42)),
            ),
          ],
        );
    }
  }

  // Fallback default actor stage
  Widget _buildDefaultActorStage(
      StoryScene scene, double idleFloat, double idleSway, Color themeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, idleFloat),
          child: Text(scene.emoji, style: const TextStyle(fontSize: 54)),
        ),
        const SizedBox(width: 20),
        Transform.scale(
          scale: 1.0 + (_idleController.value * 0.2),
          child: Text(widget.story.emoji, style: const TextStyle(fontSize: 46)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SCENERY BACKGROUND
  // ---------------------------------------------------------------------------
  Widget _buildLandscapeBackground(String storyId, int sceneIndex, Color themeColor) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Gentle floating cloud in the sky
          Positioned(
            top: 24,
            left: 20,
            child: AnimatedBuilder(
              animation: _idleController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_idleController.value * 12, 0),
                  child: Opacity(
                    opacity: 0.35,
                    child: const Text('☁️', style: TextStyle(fontSize: 26)),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 36,
            right: 40,
            child: AnimatedBuilder(
              animation: _idleController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(-_idleController.value * 10, 0),
                  child: Opacity(
                    opacity: 0.3,
                    child: const Text('☁️', style: TextStyle(fontSize: 20)),
                  ),
                );
              },
            ),
          ),

          // Ground Curve at bottom
          Positioned(
            bottom: -30,
            left: -20,
            right: -20,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(80)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SPARKLE WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildSparkleWidget(_TapSparkle sparkle) {
    return Positioned(
      left: sparkle.position.dx - 14,
      top: sparkle.position.dy - 14,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.2, end: 1.4),
        duration: const Duration(milliseconds: 700),
        builder: (context, val, child) {
          final opacity = (1.4 - val).clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, -val * 24),
            child: Opacity(
              opacity: opacity,
              child: Text(sparkle.emoji, style: const TextStyle(fontSize: 26)),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MINI EQUALIZER BARS
  // ---------------------------------------------------------------------------
  Widget _buildMiniEqualizer() {
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, _) {
        final v1 = 5.0 + math.sin(_idleController.value * math.pi * 3).abs() * 9.0;
        final v2 = 5.0 + math.cos(_idleController.value * math.pi * 4).abs() * 11.0;
        final v3 = 5.0 + math.sin(_idleController.value * math.pi * 5).abs() * 8.0;

        return Row(
          children: [
            _eqBar(v1),
            const SizedBox(width: 2),
            _eqBar(v2),
            const SizedBox(width: 2),
            _eqBar(v3),
          ],
        );
      },
    );
  }

  Widget _eqBar(double height) {
    return Container(
      width: 2.5,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  LinearGradient _getSceneGradient(String storyId, int sceneIndex, Color themeColor) {
    // Return pleasant morning / nature / adventure gradients
    return LinearGradient(
      colors: [
        themeColor.withValues(alpha: 0.18),
        themeColor.withValues(alpha: 0.06),
        Colors.white,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  String _getSceneName(String storyId, int index, bool isHindi) {
    final names = {
      'thirsty_crow': isHindi
          ? ['प्यासा कौआ', 'घड़ा मिला', 'कौए की तरकीब', 'कंकड़ डाले', 'पानी पिया']
          : ['Hot Day', 'The Pitcher', 'Clever Idea', 'Dropping Pebbles', 'Water Rises!'],
      'hare_and_tortoise': isHindi
          ? ['दौड़ की चुनौती', 'तेज शुरुआत', 'पेड़ के नीचे नींद', 'कछुए की चाल', 'कछुआ जीता']
          : ['The Challenge', 'Fast Sprint', 'Shady Nap', 'Steady Steps', 'Finish Line!'],
      'lion_and_mouse': isHindi
          ? ['सोता हुआ शेर', 'शेर की दया', 'आजाद चूहा', 'जाल में फँसा', 'सच्चे दोस्त']
          : ['Sleeping King', 'Mercy Asked', 'Mouse Freed', 'Trapped in Net', 'Best Friends!'],
      'boy_cried_wolf': isHindi
          ? ['पहाड़ी पर चरवाहा', 'झूठी पुकार', 'गाँव वाले आए', 'सचमुच का भेड़िया', 'सच्चाई की सीख']
          : ['Shepherd Hill', 'False Alarm', 'Villagers Rush', 'Real Wolf', 'Always Tell Truth'],
      'ant_and_dove': isHindi
          ? ['नदी में चींटी', 'कबूतर का पत्ता', 'सुरक्षित किनारा', 'शिकारी का तीर', 'चींटी ने बचाया']
          : ['River Rescue', 'The Green Leaf', 'Safe Shore', 'Hunter\'s Arrow', 'Good Deed!'],
    };

    final list = names[storyId];
    if (list != null && index >= 0 && index < list.length) {
      return list[index];
    }
    return isHindi ? 'दृश्य ${index + 1}' : 'Scene ${index + 1}';
  }
}

class _TapSparkle {
  final int id;
  final Offset position;
  final String emoji;

  _TapSparkle({
    required this.id,
    required this.position,
    required this.emoji,
  });
}
