import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../domain/rhyme_story_model.dart';

/// Dynamic, interactive picture-book diorama canvas for children's moral stories
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
  late AnimationController _actionController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final List<_TapSparkle> _sparkles = [];
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    // Ambient breathing / floating / cloud drifting
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // Fast action controller (wing flap, running, chewing, sound waves)
    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    // Touch tap bounce reaction
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
    _actionController.dispose();
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
          : const Offset(160, 100);

      final stars = ['⭐', '✨', '🎈', '💖', '🌟', '🎶', '🌸', '💫'];
      final chosenEmoji = stars[_tapCount % stars.length];

      _sparkles.add(_TapSparkle(
        id: DateTime.now().millisecondsSinceEpoch,
        position: localPos,
        emoji: chosenEmoji,
      ));

      if (_sparkles.length > 7) {
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
        height: 220,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: _getSceneGradient(widget.story.id, sceneIndex, themeColor),
          border: Border.all(
            color: widget.isSpeaking
                ? themeColor
                : themeColor.withValues(alpha: 0.4),
            width: widget.isSpeaking ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: widget.isSpeaking ? 0.25 : 0.09),
              blurRadius: widget.isSpeaking ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Layered Scenic Landscape Backdrop
            _buildScenicBackdrop(widget.story.id, sceneIndex, themeColor),

            // 2. Animated Character Stage
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.90, end: 1.0).animate(
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

            // 4. Top Status Header (Scene Badge + Reading Equalizer)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
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
                        const SizedBox(width: 5),
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

                  if (widget.isSpeaking)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                            widget.isHindi ? 'पढ़ा जा रहा है 🗣️' : 'Reading 🗣️',
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
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(
                            widget.isHindi ? 'टच करें ✨' : 'Tap Scene ✨',
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
  // SCENIC BACKDROPS PER STORY
  // ---------------------------------------------------------------------------
  Widget _buildScenicBackdrop(String storyId, int sceneIndex, Color themeColor) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 1. Drifting Sky Clouds
          Positioned(
            top: 20,
            left: 20,
            child: AnimatedBuilder(
              animation: _idleController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_idleController.value * 18, 0),
                  child: Opacity(
                    opacity: 0.4,
                    child: const Text('☁️', style: TextStyle(fontSize: 28)),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 32,
            right: 35,
            child: AnimatedBuilder(
              animation: _idleController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(-_idleController.value * 14, 0),
                  child: Opacity(
                    opacity: 0.35,
                    child: const Text('☁️', style: TextStyle(fontSize: 22)),
                  ),
                );
              },
            ),
          ),

          // 2. Rolling Hills / Ground Curve at Bottom
          Positioned(
            bottom: -35,
            left: -20,
            right: -20,
            height: 95,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGroundGradient(storyId, sceneIndex),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(110)),
              ),
            ),
          ),

          // 3. Ground Details (Flowers, grass, pebbles)
          Positioned(
            bottom: 6,
            left: 25,
            child: Opacity(
              opacity: 0.6,
              child: Text(_getGroundFlora(storyId, sceneIndex), style: const TextStyle(fontSize: 14)),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 25,
            child: Opacity(
              opacity: 0.6,
              child: Text(_getGroundFlora(storyId, sceneIndex), style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGroundGradient(String storyId, int sceneIndex) {
    switch (storyId) {
      case 'thirsty_crow':
        return [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)];
      case 'hare_and_tortoise':
        return [const Color(0xFFBBF7D0), const Color(0xFF86EFAC)];
      case 'lion_and_mouse':
        return [const Color(0xFFFED7AA), const Color(0xFFFDBA74)];
      case 'boy_cried_wolf':
        return [const Color(0xFFDCFCE7), const Color(0xFFA7F3D0)];
      case 'ant_and_dove':
        return [const Color(0xFFBAE6FD), const Color(0xFF7DD3FC)];
      default:
        return [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.8)];
    }
  }

  String _getGroundFlora(String storyId, int sceneIndex) {
    switch (storyId) {
      case 'thirsty_crow':
        return '🌾 🪨';
      case 'hare_and_tortoise':
        return '🌸 🌿 🌼';
      case 'lion_and_mouse':
        return '🌾 🌿';
      case 'boy_cried_wolf':
        return '🌲 🌼';
      case 'ant_and_dove':
        return '🌊 🍃 🌾';
      default:
        return '🌿 🌸';
    }
  }

  // ---------------------------------------------------------------------------
  // ACTOR LAYOUT TAILORED PER STORY SCENE
  // ---------------------------------------------------------------------------
  Widget _buildSceneActorLayout(
      String storyId, int sceneIndex, StoryScene scene, Color themeColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleController, _actionController]),
      builder: (context, _) {
        final idleFloat = math.sin(_idleController.value * math.pi * 2) * 6.0;
        final idleSway = math.cos(_idleController.value * math.pi * 2) * 0.05;
        final actionFloat = math.sin(_actionController.value * math.pi * 2) * 8.0;

        return ScaleTransition(
          scale: _bounceAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 28, bottom: 8),
              child: _buildStorySpecificStage(
                storyId,
                sceneIndex,
                scene,
                idleFloat,
                idleSway,
                actionFloat,
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
    double actionFloat,
    Color themeColor,
  ) {
    switch (storyId) {
      case 'thirsty_crow':
        return _buildThirstyCrowStage(sceneIndex, idleFloat, idleSway, actionFloat);
      case 'hare_and_tortoise':
        return _buildHareAndTortoiseStage(sceneIndex, idleFloat, idleSway, actionFloat);
      case 'lion_and_mouse':
        return _buildLionAndMouseStage(sceneIndex, idleFloat, idleSway, actionFloat);
      case 'boy_cried_wolf':
        return _buildBoyCriedWolfStage(sceneIndex, idleFloat, idleSway, actionFloat);
      case 'ant_and_dove':
        return _buildAntAndDoveStage(sceneIndex, idleFloat, idleSway, actionFloat);
      default:
        return _buildDefaultActorStage(scene, idleFloat, idleSway, themeColor);
    }
  }

  // ---------------------------------------------------------------------------
  // 1. THE THIRSTY CROW (🦅)
  // ---------------------------------------------------------------------------
  Widget _buildThirstyCrowStage(
      int sceneIndex, double idleFloat, double idleSway, double actionFloat) {
    switch (sceneIndex) {
      case 0: // Flying under hot burning sun (facing forward to the right)
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Soaring crow flapping across the sky (facing forward to the right)
            Transform.translate(
              offset: Offset(actionFloat * 1.5, idleFloat),
              child: Transform.rotate(
                angle: -idleSway * 1.5,
                child: Transform.flip(
                  flipX: true,
                  child: const Text('🦅', style: TextStyle(fontSize: 58)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.9 + (_actionController.value * 0.25),
              child: const Text('💦', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 28),
            // Rotating burning sun
            Transform.rotate(
              angle: _idleController.value * math.pi * 0.2,
              child: const Text('☀️', style: TextStyle(fontSize: 52)),
            ),
          ],
        );

      case 1: // Spotting pitcher with little water
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Transform.rotate(
                angle: 0.15, // peeking down curiously into the pitcher
                child: Transform.flip(
                  flipX: true,
                  child: const Text('🦅', style: TextStyle(fontSize: 54)),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                const Text('🏺', style: TextStyle(fontSize: 60)),
                Positioned(
                  bottom: 8,
                  child: Transform.scale(
                    scale: 0.85 + (_idleController.value * 0.2),
                    child: const Text('💧', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            const Text('🔍', style: TextStyle(fontSize: 26)),
          ],
        );

      case 2: // Looking at smooth pebbles with glowing idea!
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: Offset(0, idleFloat),
                  child: Transform.rotate(
                    angle: 0.1, // looking down at ground pebbles
                    child: Transform.flip(
                      flipX: true,
                      child: const Text('🦅', style: TextStyle(fontSize: 54)),
                    ),
                  ),
                ),
                Positioned(
                  top: -20,
                  right: -8,
                  child: Transform.scale(
                    scale: 1.0 + (_actionController.value * 0.3),
                    child: const Text('💡', style: TextStyle(fontSize: 28)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Transform.translate(
                  offset: Offset(0, -idleFloat.abs() * 0.5),
                  child: const Text('🪨', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 4),
                const Text('🪨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 4),
                const Text('🪨', style: TextStyle(fontSize: 28)),
              ],
            ),
          ],
        );

      case 3: // Dropping pebbles one by one into pitcher
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Transform.rotate(
                angle: 0.12, // tilted forward dropping pebble into pitcher mouth
                child: Transform.flip(
                  flipX: true,
                  child: const Text('🦅', style: TextStyle(fontSize: 52)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Dropping pebble animation falling into jug
            Transform.translate(
              offset: Offset(0, -8 + (_actionController.value * 24)),
              child: const Text('🪨', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                const Text('🏺', style: TextStyle(fontSize: 58)),
                Positioned(
                  top: -6,
                  child: Transform.scale(
                    scale: 0.8 + (_actionController.value * 0.4),
                    child: const Text('💦', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ],
        );

      case 4: // Water risen! Happy drinking celebration
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Transform.rotate(
                angle: 0.22, // dipping beak right into the jug opening!
                child: Transform.flip(
                  flipX: true,
                  child: const Text('🦅', style: TextStyle(fontSize: 56)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                const Text('🏺', style: TextStyle(fontSize: 58)),
                Positioned(
                  top: -8,
                  child: Transform.scale(
                    scale: 1.0 + (_actionController.value * 0.25),
                    child: const Text('🌊', style: TextStyle(fontSize: 26)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.0 + (_actionController.value * 0.3),
                  child: const Text('✨', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(height: 4),
                const Text('🎉', style: TextStyle(fontSize: 24)),
              ],
            ),
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 2. THE HARE & THE TORTOISE (🐰 🐢)
  // ---------------------------------------------------------------------------
  Widget _buildHareAndTortoiseStage(
      int sceneIndex, double idleFloat, double idleSway, double actionFloat) {
    switch (sceneIndex) {
      case 0: // Challenge at the start line (facing each other across flag)
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Proud boasting hare on left, facing right towards tortoise
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Transform.flip(
                flipX: true,
                child: const Text('🐇', style: TextStyle(fontSize: 54)),
              ),
            ),
            const SizedBox(width: 14),
            const Text('🚩', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            // Steady determined tortoise on right, naturally facing left towards hare
            Transform.translate(
              offset: Offset(0, -idleFloat * 0.5),
              child: const Text('🐢', style: TextStyle(fontSize: 48)),
            ),
          ],
        );

      case 1: // Hare zooming far ahead, Tortoise marching forward
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Steady tortoise with footsteps, marching forward to the right
            Transform.translate(
              offset: Offset(idleFloat * 0.5, 0),
              child: Transform.flip(
                flipX: true,
                child: const Text('🐢', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(width: 16),
            const Text('🐾', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 24),
            // Fast hare zooming away to the right, dust blowing behind
            Transform.translate(
              offset: Offset(actionFloat * 2, 0),
              child: Row(
                children: [
                  const Text('💨', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 4),
                  Transform.flip(
                    flipX: true,
                    child: const Text('🐇', style: TextStyle(fontSize: 50)),
                  ),
                ],
              ),
            ),
          ],
        );

      case 2: // Hare sleeping soundly under big tree, Tortoise plodding past
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Big shady tree
            const Text('🌳', style: TextStyle(fontSize: 66)),
            const SizedBox(width: 10),
            // Asleep hare with rising Zzz
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Text('🐇', style: TextStyle(fontSize: 46)),
                Positioned(
                  top: -18,
                  right: -8,
                  child: Transform.translate(
                    offset: Offset(0, -_actionController.value * 8),
                    child: Opacity(
                      opacity: 0.85,
                      child: const Text('💤', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Tortoise walking steadily forward to the right
            Transform.translate(
              offset: Offset(-idleFloat, 0),
              child: Transform.flip(
                flipX: true,
                child: const Text('🐢', style: TextStyle(fontSize: 40)),
              ),
            ),
          ],
        );

      case 3: // Tortoise passing the sleeping hare
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Sleeping hare under tree on left
            Opacity(
              opacity: 0.65,
              child: Row(
                children: const [
                  Text('🌳', style: TextStyle(fontSize: 50)),
                  Text('🐇💤', style: TextStyle(fontSize: 34)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Smiling tortoise walking proudly forward to the right
            Transform.translate(
              offset: Offset(idleFloat, 0),
              child: Transform.rotate(
                angle: idleSway,
                child: Transform.flip(
                  flipX: true,
                  child: const Text('🐢', style: TextStyle(fontSize: 54)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('✨', style: TextStyle(fontSize: 24)),
          ],
        );

      case 4: // Tortoise crosses finish line! Winner trophy
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Crowned tortoise on left facing right towards trophy
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Transform.translate(
                  offset: Offset(0, idleFloat),
                  child: Transform.flip(
                    flipX: true,
                    child: const Text('🐢', style: TextStyle(fontSize: 58)),
                  ),
                ),
                Positioned(
                  top: -14,
                  child: Transform.scale(
                    scale: 1.0 + (_actionController.value * 0.2),
                    child: const Text('👑', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Finish line & Gold Trophy
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.05 + (_actionController.value * 0.15),
                  child: const Text('🏆', style: TextStyle(fontSize: 38)),
                ),
                const SizedBox(height: 2),
                const Text('🏁', style: TextStyle(fontSize: 28)),
              ],
            ),
            const SizedBox(width: 16),
            // Shocked hare rubbing eyes, facing left towards victorious tortoise
            Transform.translate(
              offset: Offset(0, -idleFloat * 0.5),
              child: const Text('🐇😲', style: TextStyle(fontSize: 42)),
            ),
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 3. THE LION & THE MOUSE (🦁 🐭)
  // ---------------------------------------------------------------------------
  Widget _buildLionAndMouseStage(
      int sceneIndex, double idleFloat, double idleSway, double actionFloat) {
    switch (sceneIndex) {
      case 0: // Giant sleeping lion and little playful mouse
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Sleeping lion breathing on left
            Transform.scale(
              scale: 0.96 + (_idleController.value * 0.08),
              child: const Text('🦁', style: TextStyle(fontSize: 66)),
            ),
            const SizedBox(width: 18),
            // Little hopping mouse on right facing left towards lion
            Transform.translate(
              offset: Offset(0, actionFloat),
              child: const Text('🐭', style: TextStyle(fontSize: 40)),
            ),
          ],
        );

      case 1: // Lion wakes up and grabs mouse in paw
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Roaring lion on left
            Transform.rotate(
              angle: idleSway,
              child: const Text('🦁', style: TextStyle(fontSize: 62)),
            ),
            const SizedBox(width: 6),
            Transform.scale(
              scale: 0.9 + (_actionController.value * 0.3),
              child: const Text('🔊', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            // Pleading scared mouse facing lion
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🐭🥺', style: TextStyle(fontSize: 42)),
            ),
          ],
        );

      case 2: // Kind lion lets mouse free, mouse scurrying away to freedom!
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦁', style: TextStyle(fontSize: 58)),
            ),
            const SizedBox(width: 18),
            Transform.scale(
              scale: 1.0 + (_actionController.value * 0.3),
              child: const Text('💖', style: TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 18),
            // Happy mouse scampering away to the right
            Transform.translate(
              offset: Offset(actionFloat * 1.5, 0),
              child: Transform.flip(
                flipX: true,
                child: const Text('🐭✨', style: TextStyle(fontSize: 42)),
              ),
            ),
          ],
        );

      case 3: // Lion caught in heavy hunter's net!
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lion trapped inside net
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: idleSway * 2,
                  child: const Text('🦁', style: TextStyle(fontSize: 60)),
                ),
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.15,
                    child: const Text('🕸️', style: TextStyle(fontSize: 66)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🪢', style: TextStyle(fontSize: 28)),
                SizedBox(height: 4),
                Text('⚡', style: TextStyle(fontSize: 22)),
              ],
            ),
          ],
        );

      case 4: // Brave mouse chews the ropes, lifelong friends!
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Grateful lion on left
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('🦁', style: TextStyle(fontSize: 60)),
            ),
            const SizedBox(width: 14),
            // Chewing sparkles
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.0 + (_actionController.value * 0.3),
                  child: const Text('✨', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(height: 2),
                const Text('🪢✂️', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(width: 14),
            // Brave little mouse facing left towards ropes and lion
            Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: Offset(0, -idleFloat),
                  child: const Text('🐭', style: TextStyle(fontSize: 48)),
                ),
                Positioned(
                  top: -14,
                  right: -4,
                  child: const Text('⭐', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 4. THE BOY WHO CRIED WOLF (👦 🐺)
  // ---------------------------------------------------------------------------
  Widget _buildBoyCriedWolfStage(
      int sceneIndex, double idleFloat, double idleSway, double actionFloat) {
    switch (sceneIndex) {
      case 0: // Bored boy watching sheep graze on pasture
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('👦', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 20),
            // Grazing sheep facing left towards hill and boy
            Transform.translate(
              offset: Offset(idleFloat * 0.5, 0),
              child: const Text('🐑', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(width: 10),
            const Text('🐑', style: TextStyle(fontSize: 36)),
          ],
        );

      case 1: // Boy shouting false alarm into megaphone! Villagers running to help
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: Offset(0, idleFloat),
                  child: const Text('👦📢', style: TextStyle(fontSize: 54)),
                ),
                Positioned(
                  top: -16,
                  right: -10,
                  child: Transform.scale(
                    scale: 1.0 + (_actionController.value * 0.3),
                    child: const Text('🚨', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Running villagers coming from right towards boy
            Transform.translate(
              offset: Offset(actionFloat, 0),
              child: const Text('👨‍🌾👩‍🌾', style: TextStyle(fontSize: 42)),
            ),
          ],
        );

      case 2: // Boy laughing as villagers walk away disappointed
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Laughing boy on left
            Transform.translate(
              offset: Offset(0, actionFloat),
              child: const Text('👦🤣', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 24),
            // Villagers walking away to the right (flipped so they walk away)
            Opacity(
              opacity: 0.75,
              child: Transform.flip(
                flipX: true,
                child: const Text('🚶‍♂️👨‍🌾', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(width: 14),
            const Text('🐑', style: TextStyle(fontSize: 38)),
          ],
        );

      case 3: // Real grey wolf appears from the dark woods!
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ferocious wolf stalking from the woods on left
            Transform.translate(
              offset: Offset(actionFloat * 1.2, 0),
              child: Row(
                children: const [
                  Text('🌲', style: TextStyle(fontSize: 44)),
                  Text('🐺', style: TextStyle(fontSize: 58)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Panicking boy screaming for help in middle
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('👦😱', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 14),
            // Scared sheep fleeing to the right away from wolf
            Transform.translate(
              offset: Offset(actionFloat * 1.5, 0),
              child: Row(
                children: [
                  const Text('💨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 2),
                  Transform.flip(
                    flipX: true,
                    child: const Text('🐑', style: TextStyle(fontSize: 34)),
                  ),
                ],
              ),
            ),
          ],
        );

      case 4: // Lesson learned, sunset wisdom
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: const Text('👦😔', style: TextStyle(fontSize: 54)),
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.0 + (_actionController.value * 0.25),
                  child: const Text('💡', style: TextStyle(fontSize: 34)),
                ),
                const SizedBox(height: 4),
                const Text('⭐', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(width: 20),
            const Text('🐑', style: TextStyle(fontSize: 42)),
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 5. THE ANT & THE DOVE (🐜 🕊️)
  // ---------------------------------------------------------------------------
  Widget _buildAntAndDoveStage(
      int sceneIndex, double idleFloat, double idleSway, double actionFloat) {
    switch (sceneIndex) {
      case 0: // Tiny ant falls into flowing river waves
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Slipping ant
            Transform.translate(
              offset: Offset(actionFloat * 0.5, 6),
              child: const Text('🐜💦', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(width: 16),
            // Rushing blue river
            Transform.scale(
              scale: 0.95 + (_idleController.value * 0.1),
              child: const Text('🌊🌊', style: TextStyle(fontSize: 46)),
            ),
          ],
        );

      case 1: // White dove in tree drops a fresh green leaf towards the river
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dove flapping wings on left, facing right towards river
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Transform.rotate(
                angle: -idleSway,
                child: Transform.flip(
                  flipX: true,
                  child: const Text('🕊️', style: TextStyle(fontSize: 56)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Leaf fluttering down
            Transform.translate(
              offset: Offset(idleFloat * 0.8, actionFloat * 1.5),
              child: Transform.rotate(
                angle: actionFloat * 0.1,
                child: const Text('🍃', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            const Text('🌊', style: TextStyle(fontSize: 42)),
          ],
        );

      case 2: // Ant climbs safely on the floating leaf boat sailing forward
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Leaf boat sailing forward to the right
            Transform.translate(
              offset: Offset(actionFloat * 1.2, idleFloat * 0.5),
              child: Transform.rotate(
                angle: idleSway * 1.5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.flip(
                      flipX: true,
                      child: const Text('🐜', style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 2),
                    const Text('🍃', style: TextStyle(fontSize: 46)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('🌊', style: TextStyle(fontSize: 44)),
            const SizedBox(width: 10),
            const Text('✨', style: TextStyle(fontSize: 24)),
          ],
        );

      case 3: // Hunter with bow sneaks up on unaware dove
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hunter on left aiming arrow to the right
            Transform.translate(
              offset: Offset(actionFloat * 0.8, 0),
              child: Transform.flip(
                flipX: true,
                child: const Text('👨‍🌾🏹', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(width: 14),
            const Text('⚠️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            // Unaware dove resting in tree, facing away to the right
            Transform.translate(
              offset: Offset(0, idleFloat),
              child: Transform.flip(
                flipX: true,
                child: const Text('🕊️🌿', style: TextStyle(fontSize: 52)),
              ),
            ),
          ],
        );

      case 4: // Ant bites hunter's foot! Dove flies away safe into open sky
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Ant biting hunter with shock zaps
            Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: Offset(0, actionFloat * 0.5),
                  child: const Text('🐜⚡', style: TextStyle(fontSize: 38)),
                ),
                Positioned(
                  top: -16,
                  right: -8,
                  child: const Text('💥', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            const SizedBox(width: 14),
            const Text('😵🦶', style: TextStyle(fontSize: 44)),
            const SizedBox(width: 20),
            // Dove soaring freely into the sky to the right
            Transform.translate(
              offset: Offset(0, -actionFloat),
              child: Transform.rotate(
                angle: 0.15,
                child: Transform.flip(
                  flipX: true,
                  child: const Text('🕊️✨', style: TextStyle(fontSize: 52)),
                ),
              ),
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
          child: Text(scene.emoji, style: const TextStyle(fontSize: 56)),
        ),
        const SizedBox(width: 22),
        Transform.scale(
          scale: 1.0 + (_idleController.value * 0.2),
          child: Text(widget.story.emoji, style: const TextStyle(fontSize: 48)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SCENE GRADIENTS
  // ---------------------------------------------------------------------------
  LinearGradient _getSceneGradient(String storyId, int sceneIndex, Color themeColor) {
    switch (storyId) {
      case 'thirsty_crow':
        if (sceneIndex == 0) {
          // Sunny blazing desert sky
          return const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A), Color(0xFFF59E0B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else if (sceneIndex >= 3) {
          // Refreshing oasis blue
          return const LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD), Color(0xFF38BDF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        }
        return const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFCD34D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

      case 'hare_and_tortoise':
        if (sceneIndex == 4) {
          // Victory gold
          return const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A), Color(0xFFF59E0B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        }
        // Sunny green racetrack
        return const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFF86EFAC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

      case 'lion_and_mouse':
        if (sceneIndex == 3) {
          // Dangerous net trap dusky
          return const LinearGradient(
            colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        }
        // Warm savannah amber
        return const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5), Color(0xFFFB923C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

      case 'boy_cried_wolf':
        if (sceneIndex == 3) {
          // Dark menacing forest
          return const LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else if (sceneIndex == 4) {
          // Sunset twilight
          return const LinearGradient(
            colors: [Color(0xFFFFEDD5), Color(0xFFFCA5A5), Color(0xFFC084FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        }
        // Alpine meadow green
        return const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFF4ADE80)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

      case 'ant_and_dove':
        // River azure & sky blue
        return const LinearGradient(
          colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE), Color(0xFF38BDF8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

      default:
        return LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.15),
            Colors.white,
            themeColor.withValues(alpha: 0.35),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // SCENE TITLES
  // ---------------------------------------------------------------------------
  String _getSceneName(String storyId, int index, bool isHindi) {
    final titles = {
      'thirsty_crow': isHindi
          ? ['तपती धूप', 'सुराही मिली', 'अनोखा उपाय', 'कंकड़ डाले', 'पानी पीया']
          : ['Hot Day', 'Found Pitcher', 'Clever Idea', 'Drop Pebbles', 'Water Rises'],
      'hare_and_tortoise': isHindi
          ? ['घमंडी खरगोश', 'दौड़ शुरू', 'खरगोश सोया', 'कछुआ आगे', 'कछुआ जीता']
          : ['The Challenge', 'Race Begins', 'Hare Naps', 'Tortoise Passes', 'Champion'],
      'lion_and_mouse': isHindi
          ? ['सोता शेर', 'शेर ने पकड़ा', 'चूहे की मदद', 'जाल में फंसा', 'सच्चे दोस्त']
          : ['Sleeping Lion', 'Caught Mouse', 'Set Free', 'Trapped in Net', 'Best Friends'],
      'boy_cried_wolf': isHindi
          ? ['उबाऊ चरवाहा', 'झूठा शोर', 'गाँव वाले आए', 'असली भेड़िया', 'सच्चा सबक']
          : ['Bored Boy', 'False Alarm', 'Laughed Again', 'Real Wolf!', 'Lesson Learned'],
      'ant_and_dove': isHindi
          ? ['नदी में चींटी', 'पत्ता गिराया', 'चींटी बची', 'शिकारी आया', 'पैर पर काटा']
          : ['River Danger', 'Leaf Dropped', 'Safe & Sound', 'Hunter Aims', 'Hero Ant'],
    };

    final list = titles[storyId];
    if (list != null && index < list.length) {
      return list[index];
    }
    return isHindi ? 'दृश्य ${index + 1}' : 'Scene ${index + 1}';
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
