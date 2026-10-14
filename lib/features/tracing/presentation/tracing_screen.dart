import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/local/local_storage_service.dart';
import '../domain/tracing_character.dart';
import '../domain/tracing_checkpoint.dart';
import '../domain/tracing_evaluator.dart';
import '../domain/tracing_repository.dart';
import '../domain/tracing_stroke_data.dart';
import 'widgets/cartoon_background_painter.dart';
import 'widgets/cartoon_letter_painter.dart';

class TracingScreen extends ConsumerStatefulWidget {
  final TracingCategory initialCategory;

  const TracingScreen({
    super.key,
    this.initialCategory = TracingCategory.englishUpper,
  });

  static Future<void> push(
    BuildContext context, {
    TracingCategory initialCategory = TracingCategory.englishUpper,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TracingScreen(initialCategory: initialCategory),
      ),
    );
  }

  @override
  ConsumerState<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends ConsumerState<TracingScreen> with TickerProviderStateMixin {
  late TracingCategory _currentCategory;
  late List<TracingCharacter> _characterList;
  int _currentIndex = 0;

  // Active Drawing & Completed Strokes
  final List<List<Offset>> _strokes = [];
  final List<Color> _strokeColors = [];
  List<Offset> _currentStroke = [];
  final List<List<Offset>> _completedStrokePaths = [];
  final List<Color> _completedStrokeColors = [];

  // Sequential Stroke Progression
  List<TracingStrokeGuide> _strokeGuides = [];
  int _activeStrokeIndex = 0;
  int _activeDotIndex = 0;

  // Sparkle particle trail
  final List<_SparkleParticle> _particles = [];

  // Color Palette (Red default from reference image 2)
  static const List<Color> _crayonColors = [
    Color(0xFFE11D48), // Vibrant Red
    Color(0xFFFF9500), // Orange
    Color(0xFFFFCC00), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF0EA5E9), // Blue
    Color(0xFFA855F7), // Purple
    Color(0xFFEC4899), // Pink
  ];
  Color _selectedColor = const Color(0xFFE11D48);
  bool _rainbowMode = false;
  int _rainbowColorIndex = 0;

  // Star Celebration Controller
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  bool _showCelebration = false;

  // Animated Hand Pointer Bouncing Controller
  late AnimationController _handBounceController;
  late Animation<double> _handBounceAnimation;

  // Real-time tracking accuracy & auto-check state
  double _liveAccuracy = 0.0;
  int _liveStars = 0;
  Size _canvasSize = const Size(360, 400);
  TracingEvaluationResult? _lastResult;
  Timer? _celebrationAutoAdvanceTimer;

  // Checkpoints fallback list
  List<TracingCheckpoint> _checkpoints = [];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.initialCategory;
    _characterList = TracingRepository.instance.getCharactersByCategory(_currentCategory);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _celebrationScale = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );

    _handBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
    _handBounceAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _handBounceController, curve: Curves.easeInOut),
    );

    // Speak initial character and load stroke guides after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentCharacter();
      _loadCharacterGuides();
    });
  }

  @override
  void dispose() {
    _celebrationAutoAdvanceTimer?.cancel();
    _celebrationController.dispose();
    _handBounceController.dispose();
    super.dispose();
  }

  TracingCharacter get _currentChar => _characterList[_currentIndex];

  void _loadCharacterGuides() {
    setState(() {
      _strokeGuides = TracingStrokeCatalog.getStrokes(_currentChar.character);
      _clearCanvas();
    });
  }

  void _onCategorySelected(TracingCategory category) {
    if (_currentCategory == category) return;
    AudioService.instance.playSfx(CurioSfx.click);
    TracingEvaluator.clearCache();
    setState(() {
      _currentCategory = category;
      _characterList = TracingRepository.instance.getCharactersByCategory(category);
      _currentIndex = 0;
      _clearCanvas();
    });
    _loadCharacterGuides();
    _speakCurrentCharacter();
  }

  void _clearCanvas() {
    _celebrationAutoAdvanceTimer?.cancel();
    setState(() {
      _strokes.clear();
      _strokeColors.clear();
      _currentStroke = [];
      _completedStrokePaths.clear();
      _completedStrokeColors.clear();
      _activeStrokeIndex = 0;
      _activeDotIndex = 0;
      _particles.clear();
      _showCelebration = false;
      _liveAccuracy = 0.0;
      _liveStars = 0;
      _lastResult = null;
    });
  }

  void _speakCurrentCharacter() {
    final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
    final text = isHindi ? _currentChar.soundPromptHi : _currentChar.soundPromptEn;
    AudioService.instance.speakPrompt(text, isHindi: isHindi || _currentChar.category == TracingCategory.hindiSwar || _currentChar.category == TracingCategory.hindiVyanjan);
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      AudioService.instance.playSfx(CurioSfx.click);
      TracingEvaluator.clearCache();
      setState(() {
        _currentIndex--;
      });
      _loadCharacterGuides();
      _speakCurrentCharacter();
    }
  }

  void _goToNext() {
    if (_currentIndex < _characterList.length - 1) {
      AudioService.instance.playSfx(CurioSfx.click);
      TracingEvaluator.clearCache();
      setState(() {
        _currentIndex++;
      });
      _loadCharacterGuides();
      _speakCurrentCharacter();
    }
  }

  static double _distToSegment(Offset p, Offset v, Offset w) {
    final l2 = (v - w).distanceSquared;
    if (l2 == 0.0) return (p - v).distance;
    final t = math.max(0.0, math.min(1.0, ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2));
    final projection = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p - projection).distance;
  }

  void _handlePanStart(DragStartDetails details, Rect letterBounds) {
    if (_showCelebration) return;
    Color strokeColor = _selectedColor;
    if (_rainbowMode) {
      strokeColor = _crayonColors[_rainbowColorIndex % _crayonColors.length];
      _rainbowColorIndex++;
      _selectedColor = strokeColor;
    }

    setState(() {
      _currentStroke = [details.localPosition];
      _addSparkle(details.localPosition, strokeColor);
      _checkPointHit(details.localPosition, letterBounds);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, Rect letterBounds) {
    if (_showCelebration) return;
    setState(() {
      _currentStroke.add(details.localPosition);
      _addSparkle(details.localPosition, _selectedColor);
      _checkPointHit(details.localPosition, letterBounds);
    });
  }

  void _handlePanEnd(DragEndDetails details, Rect letterBounds) {
    // Keep stroke progress intact for child
  }

  void _checkPointHit(Offset pos, Rect letterBounds) {
    if (_activeStrokeIndex >= _strokeGuides.length) return;
    final strokeGuide = _strokeGuides[_activeStrokeIndex];
    final screenPoints = strokeGuide.toScreenCoordinates(letterBounds);
    if (_activeDotIndex >= screenPoints.length) return;

    final targetPoint = screenPoints[_activeDotIndex];
    bool hit = (pos - targetPoint).distance <= 48.0;
    if (!hit && _currentStroke.length >= 2) {
      final prevPos = _currentStroke[_currentStroke.length - 2];
      hit = _distToSegment(targetPoint, prevPos, pos) <= 48.0;
    }

    if (hit) {
      AudioService.instance.playSfx(CurioSfx.bubblePop);
      _addSparkle(targetPoint, const Color(0xFFFFD700));
      _addSparkle(targetPoint, Colors.white);

      _activeDotIndex++;

      // In fast dragging, collect any dots already passed
      while (_activeDotIndex < screenPoints.length) {
        final nextPt = screenPoints[_activeDotIndex];
        if ((pos - nextPt).distance <= 48.0) {
          _activeDotIndex++;
          _addSparkle(nextPt, const Color(0xFFFFD700));
        } else {
          break;
        }
      }

      // Compute total dots progress
      final totalDots = _strokeGuides.fold<int>(0, (sum, g) => sum + g.normalizedPoints.length);
      int collectedDots = 0;
      for (int i = 0; i < _activeStrokeIndex && i < _strokeGuides.length; i++) {
        collectedDots += _strokeGuides[i].normalizedPoints.length;
      }
      collectedDots += _activeDotIndex;

      final ratio = totalDots > 0 ? (collectedDots / totalDots).clamp(0.0, 1.0) : 0.0;
      _liveAccuracy = ratio;
      if (ratio >= 0.85) {
        _liveStars = 3;
      } else if (ratio >= 0.55) {
        _liveStars = 2;
      } else if (ratio >= 0.25) {
        _liveStars = 1;
      }

      // Check if current stroke finished
      if (_activeDotIndex >= screenPoints.length) {
        AudioService.instance.playSfx(CurioSfx.starAward);
        _completedStrokePaths.add(List.from(_currentStroke));
        _completedStrokeColors.add(_selectedColor);
        _currentStroke = [];
        _activeStrokeIndex++;
        _activeDotIndex = 0;

        // Check if all strokes of the character are completed
        if (_activeStrokeIndex >= _strokeGuides.length) {
          _triggerFullCelebration();
        }
      }
    }
  }

  void _addSparkle(Offset position, Color color) {
    if (_particles.length > 30) {
      _particles.removeAt(0);
    }
    _particles.add(
      _SparkleParticle(
        position: position + Offset((math.Random().nextDouble() - 0.5) * 20, (math.Random().nextDouble() - 0.5) * 20),
        color: color,
        size: math.Random().nextDouble() * 12 + 6,
        life: 1.0,
      ),
    );
  }

  Future<void> _triggerFullCelebration() async {
    if (_showCelebration) return;
    await LocalStorageService.instance.markCharacterTraced(_currentChar.id);

    AudioService.instance.playSfx(CurioSfx.starAward);
    AudioService.instance.playSfx(CurioSfx.applause);

    final evalResult = const TracingEvaluationResult(
      isCompleted: true,
      coverage: 1.0,
      accuracy: 1.0,
      stars: 3,
      feedbackEn: 'Superb handwriting! Perfect trace! 🌟🌟🌟',
      feedbackHi: 'अद्भुत सुलेख! बहुत सुंदर लिखा! 🌟🌟🌟',
    );

    setState(() {
      _showCelebration = true;
      _lastResult = evalResult;
      _liveAccuracy = 1.0;
      _liveStars = 3;
    });
    _celebrationController.forward(from: 0.0);

    final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
    final cheerText = isHindi ? evalResult.feedbackHi : evalResult.feedbackEn;
    AudioService.instance.speakPrompt(cheerText, isHindi: isHindi);

    _celebrationAutoAdvanceTimer?.cancel();
    _celebrationAutoAdvanceTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted && _showCelebration && _currentIndex < _characterList.length - 1) {
        _goToNext();
      }
    });
  }

  Future<void> _checkAndCelebrate() async {
    if (_showCelebration) return;
    if (_activeStrokeIndex < _strokeGuides.length) {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
      final totalDots = _strokeGuides.fold<int>(0, (sum, g) => sum + g.normalizedPoints.length);
      int collectedDots = 0;
      for (int i = 0; i < _activeStrokeIndex && i < _strokeGuides.length; i++) {
        collectedDots += _strokeGuides[i].normalizedPoints.length;
      }
      collectedDots += _activeDotIndex;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi
                ? 'उंगली से सभी मोतियों पर ट्रेस करें! ($collectedDots/$totalDots) ✍️'
                : 'Trace through all the dots on the letter! ($collectedDots/$totalDots) ✍️',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFEA580C),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    _triggerFullCelebration();
  }

  void _showCharacterSelectionSheet() {
    AudioService.instance.playSfx(CurioSfx.click);
    final completedSet = LocalStorageService.instance.getTracedCharacters();
    final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHindi ? 'अक्षर चुनें (${_characterList.length})' : 'Pick a Character (${_characterList.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _characterList.length,
                  itemBuilder: (context, idx) {
                    final char = _characterList[idx];
                    final isCurrent = idx == _currentIndex;
                    final isDone = completedSet.contains(char.id);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        AudioService.instance.playSfx(CurioSfx.click);
                        Navigator.pop(ctx);
                        TracingEvaluator.clearCache();
                        setState(() {
                          _currentIndex = idx;
                          _clearCanvas();
                        });
                        _loadCharacterGuides();
                        _speakCurrentCharacter();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFF6366F1) : (isDone ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF4338CA)
                                : (isDone ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                            width: isCurrent ? 2.5 : 1.5,
                          ),
                          boxShadow: isCurrent
                              ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                char.character,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isCurrent ? Colors.white : (isDone ? const Color(0xFF047857) : const Color(0xFF334155)),
                                ),
                              ),
                            ),
                            if (isDone)
                              const Positioned(
                                top: 4,
                                right: 4,
                                child: Text('⭐', style: TextStyle(fontSize: 10)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
    final completedSet = LocalStorageService.instance.getTracedCharacters();
    final isCurrentDone = completedSet.contains(_currentChar.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header Bar
                _buildTopAppBar(isHindi, completedSet),

                // Category Selector Tabs
                _buildCategoryTabs(isHindi),

                const SizedBox(height: 8),

                // Current Character Banner Card with Sound Button
                _buildCharacterInfoBar(isHindi, isCurrentDone),

                const SizedBox(height: 6),

                // Tracing Blackboard/Canvas
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _buildTracingCanvasArea(isHindi),
                  ),
                ),

                const SizedBox(height: 8),

                // Crayon Color Palette & Action Buttons
                _buildBottomControlsBar(isHindi),
                const SizedBox(height: 8),
              ],
            ),

            // Star Burst Celebration Overlay
            if (_showCelebration) _buildCelebrationOverlay(isHindi),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(bool isHindi, Set<String> completedSet) {
    final totalCompleted = _characterList.where((c) => completedSet.contains(c.id)).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Material(
            color: const Color(0xFFF8FAFC),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                AudioService.instance.playSfx(CurioSfx.click);
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B), size: 24),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? '✏️ सुलेख और ट्रेसिंग' : '✏️ Letter & Number Tracing',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isHindi ? 'उंगली से बनाएं और सीखें' : 'Draw with your finger to learn',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          // Progress Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$totalCompleted/${_characterList.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(bool isHindi) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: TracingCategory.values.length,
        itemBuilder: (context, idx) {
          final cat = TracingCategory.values[idx];
          final isSelected = cat == _currentCategory;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onCategorySelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharacterInfoBar(bool isHindi, bool isDone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            color: _currentIndex > 0 ? const Color(0xFF6366F1) : Colors.grey.shade300,
            onPressed: _currentIndex > 0 ? _goToPrevious : null,
          ),

          // Character Emblem & Title
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showCharacterSelectionSheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentChar.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isHindi ? _currentChar.titleHi : _currentChar.titleEn,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_currentIndex + 1}/${_characterList.length}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                            if (isDone) ...[
                              const SizedBox(width: 4),
                              const Text('⭐', style: TextStyle(fontSize: 11)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Speaker Button
          Material(
            color: const Color(0xFFEEF2FF),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                AudioService.instance.playSfx(CurioSfx.click);
                _speakCurrentCharacter();
              },
              child: const Padding(
                padding: EdgeInsets.all(9.0),
                child: Icon(Icons.volume_up_rounded, color: Color(0xFF6366F1), size: 22),
              ),
            ),
          ),

          // Next Button
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            color: _currentIndex < _characterList.length - 1 ? const Color(0xFF6366F1) : Colors.grey.shade300,
            onPressed: _currentIndex < _characterList.length - 1 ? _goToNext : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTracingCanvasArea(bool isHindi) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final newSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_canvasSize != newSize) {
          _canvasSize = newSize;
        }

        final fontSize = math.min(_canvasSize.width * 0.78, _canvasSize.height * 0.72).clamp(180.0, 320.0);
        final tp = TextPainter(
          text: TextSpan(
            text: _currentChar.character,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: 'Roboto',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final letterBounds = Rect.fromLTWH(
          (_canvasSize.width - tp.width) / 2,
          (_canvasSize.height - tp.height) / 2 - 12,
          tp.width,
          tp.height,
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF0F172A), width: 3.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // 1. Scenic Cartoon Preschool Background (Sky, Rainbow, Tree Canopies, Meadow)
                const Positioned.fill(
                  child: CustomPaint(
                    painter: CartoonBackgroundPainter(),
                  ),
                ),

                // 2. Chunky Double-Bordered Cartoon Letter Track, Progressive Color Fill & Active Stroke Dots
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _handBounceAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: CartoonLetterPainter(
                          character: _currentChar.character,
                          letterBounds: letterBounds,
                          fontSize: fontSize,
                          allStrokes: _strokeGuides,
                          activeStrokeIndex: _activeStrokeIndex,
                          activeDotIndex: _activeDotIndex,
                          completedStrokes: _completedStrokePaths,
                          strokeColors: _completedStrokeColors,
                          liveCurrentStroke: _currentStroke,
                          currentCrayonColor: _selectedColor,
                          handBounceOffset: _handBounceAnimation.value,
                        ),
                      );
                    },
                  ),
                ),

                // 3. Popping Sparkle Particles Trail
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SparklesPainter(particles: _particles),
                  ),
                ),

                // 4. Interactive Finger Gesture Detector
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) => _handlePanStart(details, letterBounds),
                    onPanUpdate: (details) => _handlePanUpdate(details, letterBounds),
                    onPanEnd: (details) => _handlePanEnd(details, letterBounds),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // 5. Floating Real-Time Tracking Accuracy HUD 🎯
                Positioned(
                  top: 14,
                  right: 14,
                  child: _buildTrackingAccuracyBadge(isHindi),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackingAccuracyBadge(bool isHindi) {
    final totalDots = _strokeGuides.fold<int>(0, (sum, g) => sum + g.normalizedPoints.length);
    int collectedDots = 0;
    for (int i = 0; i < _activeStrokeIndex && i < _strokeGuides.length; i++) {
      collectedDots += _strokeGuides[i].normalizedPoints.length;
    }
    collectedDots += _activeDotIndex;

    Color bgColor = Colors.white.withValues(alpha: 0.95);
    Color borderColor = const Color(0xFFE2E8F0);
    Color textColor = const Color(0xFF1E293B);

    if (_liveStars == 3) {
      bgColor = const Color(0xFFECFDF5);
      borderColor = const Color(0xFF10B981);
      textColor = const Color(0xFF047857);
    } else if (_liveStars >= 1) {
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFB45309);
    }

    String starsDisplay = '☆☆☆';
    if (_liveStars == 3) {
      starsDisplay = '⭐⭐⭐';
    } else if (_liveStars == 2) {
      starsDisplay = '⭐⭐☆';
    } else if (_liveStars == 1) {
      starsDisplay = '⭐☆☆';
    }

    final displayText = totalDots > 0
        ? (isHindi ? 'मोती: $collectedDots/$totalDots' : 'Dots: $collectedDots/$totalDots')
        : (isHindi ? 'सुलेख' : 'Trace');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            starsDisplay,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControlsBar(bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crayon Colors Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rainbow crayon button
                _buildColorCrayon(
                  isRainbow: true,
                  isSelected: _rainbowMode,
                  onTap: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    setState(() => _rainbowMode = true);
                  },
                ),
                const SizedBox(width: 10),
                ..._crayonColors.map((color) {
                  final isSelected = !_rainbowMode && _selectedColor == color;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildColorCrayon(
                      color: color,
                      isSelected: isSelected,
                      onTap: () {
                        AudioService.instance.playSfx(CurioSfx.click);
                        setState(() {
                          _rainbowMode = false;
                          _selectedColor = color;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Action Buttons: Clear 🧹 & Done/Check 🌟
          Row(
            children: [
              // Clear Canvas Button
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    _clearCanvas();
                  },
                  icon: const Icon(Icons.cleaning_services_rounded, color: Color(0xFF64748B), size: 20),
                  label: Text(
                    isHindi ? 'मिटाएं' : 'Clear',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Check / Submit Celebration Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _checkAndCelebrate,
                  icon: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
                  label: Text(
                    isHindi ? 'शाबाश! पूरा हुआ ⭐' : 'Done! Check ⭐',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 3,
                    shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCrayon({
    Color? color,
    bool isRainbow = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 38 : 32,
        height: isSelected ? 38 : 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isRainbow
              ? const SweepGradient(
                  colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
                )
              : null,
          color: isRainbow ? null : color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: isRainbow
            ? const Center(child: Text('🌈', style: TextStyle(fontSize: 14)))
            : (isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null),
      ),
    );
  }

  Widget _buildCelebrationOverlay(bool isHindi) {
    final accuracyPercent = ((_lastResult?.accuracy ?? _liveAccuracy) * 100).toInt();
    final stars = _lastResult?.stars ?? _liveStars;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: ScaleTransition(
            scale: _celebrationScale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 26),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stars >= 3 ? '🌟 🏆 🌟' : (stars == 2 ? '⭐⭐' : '⭐'),
                    style: const TextStyle(fontSize: 44),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi ? 'अद्भुत काम!' : 'Super Tracing!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  // Accuracy Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      isHindi ? 'सटीकता: $accuracyPercent% • +10 अंक' : 'Accuracy: $accuracyPercent% • +10 Points',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857), fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isHindi
                        ? 'आपने ${_currentChar.titleHi} बहुत सुंदर लिखा!'
                        : 'You mastered ${_currentChar.titleEn}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AudioService.instance.playSfx(CurioSfx.click);
                            _clearCanvas();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(isHindi ? 'पुनः अभ्यास' : 'Practice Again'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AudioService.instance.playSfx(CurioSfx.click);
                            _goToNext();
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: Text(isHindi ? 'अगला अक्षर' : 'Next Letter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Particle for glittering sparkle trail
class _SparkleParticle {
  final Offset position;
  final Color color;
  final double size;
  final double life;

  _SparkleParticle({
    required this.position,
    required this.color,
    required this.size,
    required this.life,
  });
}

// Painter for drawing notebook horizontal guide ruled lines
class _NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    final dashPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.5)
      ..strokeWidth = 1.2;

    // Top Headline line (at 25% height)
    canvas.drawLine(Offset(20, size.height * 0.22), Offset(size.width - 20, size.height * 0.22), linePaint);

    // Midline dashed (at 50% height)
    double x = 20;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    while (x < size.width - 20) {
      canvas.drawLine(Offset(x, size.height * 0.5), Offset(x + dashWidth, size.height * 0.5), dashPaint);
      x += dashWidth + dashSpace;
    }

    // Baseline line (at 78% height)
    canvas.drawLine(Offset(20, size.height * 0.78), Offset(size.width - 20, size.height * 0.78), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter for sparkling particles trailing finger and popping on dots
class _SparklesPainter extends CustomPainter {
  final List<_SparkleParticle> particles;

  const _SparklesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final particlePaint = Paint()
        ..color = p.color.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size / 2, particlePaint);

      final centerHighlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size / 4, centerHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) => true;
}
