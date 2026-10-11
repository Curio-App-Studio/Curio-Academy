import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/local/local_storage_service.dart';
import '../domain/tracing_character.dart';
import '../domain/tracing_repository.dart';

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

  // Drawing strokes: list of continuous stroke lines
  final List<List<Offset>> _strokes = [];
  final List<Color> _strokeColors = [];
  List<Offset> _currentStroke = [];

  // Sparkle particle trail
  final List<_SparkleParticle> _particles = [];

  // Color Palette
  static const List<Color> _crayonColors = [
    Color(0xFFFF3B30), // Red
    Color(0xFFFF9500), // Orange
    Color(0xFFFFCC00), // Yellow
    Color(0xFF34C759), // Green
    Color(0xFF007AFF), // Blue
    Color(0xFFAF52DE), // Purple
    Color(0xFFFF2D55), // Pink
  ];
  Color _selectedColor = const Color(0xFF007AFF);
  bool _rainbowMode = false;
  int _rainbowColorIndex = 0;

  // Star Celebration Controller
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  bool _showCelebration = false;

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

    // Speak initial character after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentCharacter();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  TracingCharacter get _currentChar => _characterList[_currentIndex];

  void _onCategorySelected(TracingCategory category) {
    if (_currentCategory == category) return;
    AudioService.instance.playSfx(CurioSfx.click);
    setState(() {
      _currentCategory = category;
      _characterList = TracingRepository.instance.getCharactersByCategory(category);
      _currentIndex = 0;
      _clearCanvas();
    });
    _speakCurrentCharacter();
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _strokeColors.clear();
      _currentStroke = [];
      _particles.clear();
      _showCelebration = false;
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
      setState(() {
        _currentIndex--;
        _clearCanvas();
      });
      _speakCurrentCharacter();
    }
  }

  void _goToNext() {
    if (_currentIndex < _characterList.length - 1) {
      AudioService.instance.playSfx(CurioSfx.click);
      setState(() {
        _currentIndex++;
        _clearCanvas();
      });
      _speakCurrentCharacter();
    }
  }

  void _onPanStart(DragStartDetails details) {
    Color strokeColor = _selectedColor;
    if (_rainbowMode) {
      strokeColor = _crayonColors[_rainbowColorIndex % _crayonColors.length];
      _rainbowColorIndex++;
    }

    setState(() {
      _currentStroke = [details.localPosition];
      _strokes.add(_currentStroke);
      _strokeColors.add(strokeColor);
      _addSparkle(details.localPosition, strokeColor);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
      _addSparkle(details.localPosition, _strokeColors.isNotEmpty ? _strokeColors.last : _selectedColor);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _currentStroke = [];
  }

  void _addSparkle(Offset position, Color color) {
    if (_particles.length > 25) {
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

  Future<void> _checkAndCelebrate() async {
    if (_strokes.isEmpty) {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? 'अपनी उंगली से अक्षर पर ट्रेस करें! ✍️' : 'Trace the letter with your finger first! ✍️',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF6366F1),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Mark completed in LocalStorage
    await LocalStorageService.instance.markCharacterTraced(_currentChar.id);

    AudioService.instance.playSfx(CurioSfx.applause);
    setState(() {
      _showCelebration = true;
    });
    _celebrationController.forward(from: 0.0);

    final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
    final cheerText = isHindi
        ? 'शाबाश! आपने ${_currentChar.titleHi} बहुत सुंदर लिखा! 🌟'
        : 'Awesome! You traced ${_currentChar.titleEn}! 🌟';
    AudioService.instance.speakPrompt(cheerText, isHindi: isHindi);

    // Auto advance after short celebration
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _currentIndex < _characterList.length - 1) {
        _goToNext();
      }
    });
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
                        setState(() {
                          _currentIndex = idx;
                          _clearCanvas();
                        });
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
                    child: _buildTracingCanvasArea(),
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

  Widget _buildTracingCanvasArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Notebook Guided Ruled Lines
            CustomPaint(
              size: Size.infinite,
              painter: _NotebookLinesPainter(),
            ),

            // Large Dotted Outline of Target Character
            Center(
              child: Text(
                _currentChar.character,
                style: TextStyle(
                  fontSize: 220,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.75),
                  fontFamily: 'Roboto',
                ),
              ),
            ),

            // Guided Start Hint Star ⭐
            Align(
              alignment: Alignment(
                (_currentChar.startHint.dx * 2) - 1,
                (_currentChar.startHint.dy * 2) - 1,
              ),
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF08A).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                  child: const Text('⭐', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),

            // Interactive Finger Drawing Gesture Area
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                size: Size.infinite,
                painter: _TracingStrokesPainter(
                  strokes: _strokes,
                  colors: _strokeColors,
                  particles: _particles,
                ),
              ),
            ),
          ],
        ),
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
    return Positioned.fill(
      child: IgnorePointer(
        child: ScaleTransition(
          scale: _celebrationScale,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
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
                  const Text('🌟 🏆 🌟', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(
                    isHindi ? 'अद्भुत काम!' : 'Super Tracing!',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isHindi
                        ? 'आपने ${_currentChar.titleHi} सीख लिया! (+10 अंक)'
                        : 'You mastered ${_currentChar.titleEn}! (+10 Points)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
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

// Painter for child's finger tracing strokes and sparkling particles
class _TracingStrokesPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Color> colors;
  final List<_SparkleParticle> particles;

  _TracingStrokesPainter({
    required this.strokes,
    required this.colors,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw glowing particles
    for (final p in particles) {
      final particlePaint = Paint()
        ..color = p.color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size / 2, particlePaint);
    }

    // 2. Draw user finger strokes
    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      if (stroke.isEmpty) continue;

      final color = i < colors.length ? colors[i] : const Color(0xFF007AFF);
      final paint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 22.0
        ..style = PaintingStyle.stroke;

      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 11.0, Paint()..color = color..style = PaintingStyle.fill);
      } else {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int j = 1; j < stroke.length; j++) {
          path.lineTo(stroke[j].dx, stroke[j].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracingStrokesPainter oldDelegate) => true;
}
