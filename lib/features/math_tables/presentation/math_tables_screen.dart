import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../../services/ad_service.dart';
import '../domain/math_table_model.dart';

/// Full Interactive Math Multiplication Tables Explorer & Mastery Screen
class MathTablesScreen extends ConsumerStatefulWidget {
  final int initialTable;

  const MathTablesScreen({
    super.key,
    this.initialTable = 2,
  });

  static Future<void> push(BuildContext context, {int initialTable = 2}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MathTablesScreen(initialTable: initialTable),
      ),
    );
  }

  @override
  ConsumerState<MathTablesScreen> createState() => _MathTablesScreenState();
}

class _MathTablesScreenState extends ConsumerState<MathTablesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedTable;
  late MathTableData _currentTableData;
  int _maxMultiplier = 10; // 10 or 12

  // Auto-Chant State
  bool _isChanting = false;
  int _activeChantRowIndex = -1;
  Timer? _chantTimer;

  // Flashcard State
  int _flashcardIndex = 0;
  bool _flashcardFlipped = false;

  // Fill in blanks / Practice State
  List<TableQuestion> _practiceQuestions = [];
  int _practiceIndex = 0;
  int? _practiceSelectedAnswer;
  bool _practiceAnswered = false;
  int _practiceScore = 0;
  int _practiceStreak = 0;

  // Speed Quiz State
  List<TableQuestion> _quizQuestions = [];
  int _quizIndex = 0;
  int? _quizSelectedAnswer;
  bool _quizAnswered = false;
  int _quizScore = 0;
  int _quizTimerSeconds = 0;
  Timer? _quizTimer;
  int _tableSwitchCount = 0;

  void _onTableSelected(int num) {
    if (num == _selectedTable) return;
    _tableSwitchCount++;
    if (_tableSwitchCount >= 2) {
      _tableSwitchCount = 0;
      AdService().showInterstitialAdIfReady();
    }
    _loadTable(num);
  }

  @override
  void initState() {
    super.initState();
    _selectedTable = widget.initialTable;
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _stopChant();
      }
    });
    _loadTable(_selectedTable);
  }

  @override
  void dispose() {
    _stopChant();
    _quizTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _loadTable(int n) {
    _stopChant();
    setState(() {
      _selectedTable = n;
      _currentTableData = MathTableData.generate(n, maxMultiplier: _maxMultiplier);
      _flashcardIndex = 0;
      _flashcardFlipped = false;
      _initPractice();
      _initQuiz();
    });
  }

  void _initPractice() {
    _practiceQuestions = TableQuestion.generateQuiz(_selectedTable, count: 10, maxMultiplier: _maxMultiplier);
    _practiceIndex = 0;
    _practiceSelectedAnswer = null;
    _practiceAnswered = false;
    _practiceScore = 0;
    _practiceStreak = 0;
  }

  void _initQuiz() {
    _quizTimer?.cancel();
    _quizQuestions = TableQuestion.generateQuiz(_selectedTable, count: 10, maxMultiplier: _maxMultiplier);
    _quizIndex = 0;
    _quizSelectedAnswer = null;
    _quizAnswered = false;
    _quizScore = 0;
    _quizTimerSeconds = 0;
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _quizTimerSeconds++);
      }
    });
  }

  void _stopChant() {
    _chantTimer?.cancel();
    _chantTimer = null;
    if (_isChanting) {
      setState(() {
        _isChanting = false;
        _activeChantRowIndex = -1;
      });
    }
  }

  void _startChant() {
    if (_isChanting) {
      _stopChant();
      return;
    }

    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';
    setState(() {
      _isChanting = true;
      _activeChantRowIndex = 0;
    });

    _speakCurrentChantRow(isHindi);

    _chantTimer = Timer.periodic(const Duration(milliseconds: 2700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_activeChantRowIndex + 1 < _currentTableData.rows.length) {
        setState(() => _activeChantRowIndex++);
        _speakCurrentChantRow(isHindi);
      } else {
        _stopChant();
        AudioService.instance.playSfx(CurioSfx.applause);
      }
    });
  }

  void _speakCurrentChantRow(bool isHindi) {
    if (_activeChantRowIndex < 0 || _activeChantRowIndex >= _currentTableData.rows.length) return;
    final row = _currentTableData.rows[_activeChantRowIndex];
    final text = isHindi ? row.chantHi : row.chantEn;
    AudioService.instance.speakPrompt(text);
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF065F46)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isHindi ? 'पहाड़े सीखें (Tables 1-20)' : 'Learn Tables (1 to 20)',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF065F46)),
        ),
        actions: [
          // Range toggle (up to 10 or 12)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                setState(() {
                  _maxMultiplier = _maxMultiplier == 10 ? 12 : 10;
                  _loadTable(_selectedTable);
                });
              },
              child: Text(
                '×$_maxMultiplier',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857), fontSize: 13),
              ),
            ),
          ),
          // Speaker mute toggle
          IconButton(
            icon: Icon(
              AudioService.instance.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: const Color(0xFF065F46),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                AudioService.instance.toggleMute();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              // Horizontal Table Number Picker (1 to 20)
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    final num = index + 1;
                    final isSelected = num == _selectedTable;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          '$num',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: isSelected ? Colors.white : const Color(0xFF065F46),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF059669),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
                            width: 1.5,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (_) => _onTableSelected(num),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // 4 Learning Mode Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF059669),
                indicatorWeight: 3.5,
                labelColor: const Color(0xFF065F46),
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                tabs: [
                  Tab(text: isHindi ? '📖 चार्ट' : '📖 Chart'),
                  Tab(text: isHindi ? '🃏 कार्ड्स' : '🃏 Cards'),
                  Tab(text: isHindi ? '🧩 अभ्यास' : '🧩 Fill In'),
                  Tab(text: isHindi ? '⚡ टेस्ट' : '⚡ Test'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChartAndChantTab(isHindi),
          _buildFlashcardTab(isHindi),
          _buildFillInBlanksTab(isHindi),
          _buildSpeedQuizTab(isHindi),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: CHART, CHANT & VISUAL CONCEPT EXPLORER
  // -------------------------------------------------------------
  Widget _buildChartAndChantTab(bool isHindi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Magic Trick / Mnemonic Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? _currentTableData.trickTitleHi : _currentTableData.trickTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isHindi ? _currentTableData.trickDescriptionHi : _currentTableData.trickDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78350F),
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Auto-Recite / Chant Controller Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isChanting ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isChanting ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: _startChant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isChanting
                            ? (isHindi ? 'पहाड़ा बोलकर सुना रहे हैं...' : 'Chanting Table Along...')
                            : (isHindi ? 'बोलकर सीखें (Auto-Recite)' : 'Sing & Chant Along (Auto-Recite)'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF065F46)),
                      ),
                      Text(
                        isHindi ? 'किसी भी लाइन पर टैप करके अर्थ समझें' : 'Tap any row below for visual dots',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                if (_isChanting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Text('🎵 LIVE', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Table Rows List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentTableData.rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final row = _currentTableData.rows[idx];
              final isCurrentChanting = _isChanting && _activeChantRowIndex == idx;

              return InkWell(
                onTap: () => _showRowConceptModal(row, isHindi),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrentChanting ? const Color(0xFFECFDF5) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrentChanting ? const Color(0xFF059669) : const Color(0xFFE5E7EB),
                      width: isCurrentChanting ? 2.2 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrentChanting
                            ? const Color(0xFF059669).withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: isCurrentChanting ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Multiplier Badge
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${row.multiplier}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF065F46), fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Equation
                      Expanded(
                        child: Text(
                          row.formula,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: isCurrentChanting ? const Color(0xFF047857) : const Color(0xFF1F2937),
                          ),
                        ),
                      ),

                      // Speak Single Row Button
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF059669), size: 22),
                        onPressed: () {
                          final text = isHindi ? row.chantHi : row.chantEn;
                          AudioService.instance.speakPrompt(text);
                        },
                      ),

                      // Visual Concept Icon
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF9CA3AF), size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Visual Concept Bottom Sheet (Repeated Addition + Dot Grid)
  void _showRowConceptModal(MathTableRow row, bool isHindi) {
    AudioService.instance.playSfx(CurioSfx.click);
    final speakText = isHindi ? row.chantHi : row.chantEn;
    AudioService.instance.speakPrompt(speakText);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),

              // Title formula
              Text(
                row.formula,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
              ),
              const SizedBox(height: 4),
              Text(
                isHindi ? row.chantHi : row.chantEn,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
              ),
              const SizedBox(height: 16),

              // Repeated Addition Explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  children: [
                    Text(
                      isHindi ? 'बार-बार जोड़ना (Repeated Addition):' : 'Repeated Addition Meaning:',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${row.repeatedAddition} = ${row.product}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dot Grid Visualizer (capped at reasonable display size)
              Text(
                isHindi
                    ? '${row.multiplier} समूह, प्रत्येक में ${row.tableNumber} बिंदु:'
                    : '${row.multiplier} groups of ${row.tableNumber} dots:',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 10),

              // Dot Rows
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: List.generate(
                  row.multiplier,
                  (groupIndex) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      '• ' * row.tableNumber,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  isHindi ? 'समझ गया! 👍' : 'Got It! 👍',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  // -------------------------------------------------------------
  // TAB 2: INTERACTIVE FLIP FLASHCARDS
  // -------------------------------------------------------------
  Widget _buildFlashcardTab(bool isHindi) {
    final row = _currentTableData.rows[_flashcardIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        children: [
          // Indicator & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isHindi ? "कार्ड" : "Card"} ${_flashcardIndex + 1}/${_currentTableData.rows.length}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF047857), fontSize: 14),
              ),
              Text(
                isHindi ? 'कार्ड पर टैप करें उत्तर देखने के लिए' : 'Tap card to flip answer',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3D Flip Card
          GestureDetector(
            onTap: () {
              setState(() => _flashcardFlipped = !_flashcardFlipped);
              AudioService.instance.playSfx(CurioSfx.click);
              if (_flashcardFlipped) {
                AudioService.instance.speakPrompt('${row.product}');
              } else {
                AudioService.instance.speakPrompt('${row.tableNumber} times ${row.multiplier}');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 240,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _flashcardFlipped
                    ? const LinearGradient(colors: [Color(0xFF059669), Color(0xFF047857)])
                    : const LinearGradient(colors: [Colors.white, Color(0xFFF9FAFB)]),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _flashcardFlipped ? const Color(0xFF047857) : const Color(0xFFA7F3D0),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _flashcardFlipped ? '🎉 ANSWER' : '❓ QUESTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: _flashcardFlipped ? const Color(0xFFA7F3D0) : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _flashcardFlipped ? '${row.product}' : '${row.tableNumber} × ${row.multiplier} = ?',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: _flashcardFlipped ? Colors.white : const Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _flashcardFlipped ? (isHindi ? row.chantHi : row.chantEn) : (isHindi ? 'टैप करके उत्तर देखें 🔄' : 'Tap to reveal answer 🔄'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _flashcardFlipped ? const Color(0xFFD1FAE5) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Previous & Next Flashcard Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF065F46),
                  side: const BorderSide(color: Color(0xFF059669), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _flashcardIndex > 0
                    ? () {
                        setState(() {
                          _flashcardIndex--;
                          _flashcardFlipped = false;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: Text(isHindi ? 'पिछला' : 'Previous', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _flashcardIndex + 1 < _currentTableData.rows.length
                    ? () {
                        setState(() {
                          _flashcardIndex++;
                          _flashcardFlipped = false;
                        });
                      }
                    : () {
                        // Loop back to start
                        setState(() {
                          _flashcardIndex = 0;
                          _flashcardFlipped = false;
                        });
                      },
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                label: Text(
                  _flashcardIndex + 1 < _currentTableData.rows.length
                      ? (isHindi ? 'अगला' : 'Next')
                      : (isHindi ? 'शुरू से देखें' : 'Restart'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: FILL IN THE BLANKS / MISSING NUMBER GAME
  // -------------------------------------------------------------
  Widget _buildFillInBlanksTab(bool isHindi) {
    if (_practiceQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF059669)));
    }

    final q = _practiceQuestions[_practiceIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isHindi ? "प्रश्न" : "Question"} ${_practiceIndex + 1}/${_practiceQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF047857), fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Text('⭐ $_practiceScore  •  🔥 $_practiceStreak', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Equation Prompt Box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  isHindi ? 'खाली स्थान में सही संख्या भरें:' : 'Find the missing number:',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 14),
                Text(
                  q.promptEquation,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4 Option Buttons (Grid)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: q.options.map((opt) {
              final isCorrect = opt == q.correctAnswer;
              final isSelected = opt == _practiceSelectedAnswer;

              Color bg = Colors.white;
              Color border = const Color(0xFFA7F3D0);
              Color text = const Color(0xFF065F46);

              if (_practiceAnswered) {
                if (isCorrect) {
                  bg = const Color(0xFFD1FAE5);
                  border = const Color(0xFF10B981);
                  text = const Color(0xFF065F46);
                } else if (isSelected) {
                  bg = const Color(0xFFFEE2E2);
                  border = const Color(0xFFEF4444);
                  text = const Color(0xFF991B1B);
                }
              }

              return InkWell(
                onTap: _practiceAnswered
                    ? null
                    : () {
                        setState(() {
                          _practiceSelectedAnswer = opt;
                          _practiceAnswered = true;
                          if (isCorrect) {
                            _practiceScore++;
                            _practiceStreak++;
                            AudioService.instance.playSfx(CurioSfx.correctCheer);
                          } else {
                            _practiceStreak = 0;
                            AudioService.instance.playSfx(CurioSfx.gentleWobble);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$opt',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: text,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Next Question Button
          if (_practiceAnswered)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (_practiceIndex + 1 < _practiceQuestions.length) {
                  setState(() {
                    _practiceIndex++;
                    _practiceAnswered = false;
                    _practiceSelectedAnswer = null;
                  });
                } else {
                  AdService().showInterstitialAdIfReady();
                  _initPractice();
                }
              },
              child: Text(
                _practiceIndex + 1 < _practiceQuestions.length
                    ? (isHindi ? 'अगला प्रश्न ➔' : 'Next Question ➔')
                    : (isHindi ? 'नया अभ्यास शुरू करें 🔄' : 'Practice More 🔄'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: SPEED TABLE QUIZ
  // -------------------------------------------------------------
  Widget _buildSpeedQuizTab(bool isHindi) {
    if (_quizQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF059669)));
    }

    final q = _quizQuestions[_quizIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timer & Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isHindi ? "प्रश्न" : "Q"}: ${_quizIndex + 1}/${_quizQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF047857), fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, size: 16, color: Color(0xFF1E40AF)),
                    const SizedBox(width: 4),
                    Text(
                      '${_quizTimerSeconds}s',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${q.tableNumber} × ${q.multiplier} = ?',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Options Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: q.options.map((opt) {
              final isCorrect = opt == q.correctAnswer;
              final isSelected = opt == _quizSelectedAnswer;

              Color bg = Colors.white;
              Color border = const Color(0xFFA7F3D0);
              Color text = const Color(0xFF065F46);

              if (_quizAnswered) {
                if (isCorrect) {
                  bg = const Color(0xFFD1FAE5);
                  border = const Color(0xFF10B981);
                  text = const Color(0xFF065F46);
                } else if (isSelected) {
                  bg = const Color(0xFFFEE2E2);
                  border = const Color(0xFFEF4444);
                  text = const Color(0xFF991B1B);
                }
              }

              return InkWell(
                onTap: _quizAnswered
                    ? null
                    : () {
                        setState(() {
                          _quizSelectedAnswer = opt;
                          _quizAnswered = true;
                          if (isCorrect) {
                            _quizScore++;
                            AudioService.instance.playSfx(CurioSfx.correctCheer);
                          } else {
                            AudioService.instance.playSfx(CurioSfx.gentleWobble);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$opt',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: text),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          if (_quizAnswered)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047857),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (_quizIndex + 1 < _quizQuestions.length) {
                  setState(() {
                    _quizIndex++;
                    _quizAnswered = false;
                    _quizSelectedAnswer = null;
                  });
                } else {
                  _showQuizResultDialog(isHindi);
                }
              },
              child: Text(
                _quizIndex + 1 < _quizQuestions.length
                    ? (isHindi ? 'अगला प्रश्न ➔' : 'Next Question ➔')
                    : (isHindi ? 'रिजल्ट देखें 🏆' : 'View Results 🏆'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }

  void _showQuizResultDialog(bool isHindi) {
    _quizTimer?.cancel();
    AdService().showInterstitialAdIfReady();
    final total = _quizQuestions.length;
    final pct = total > 0 ? ((_quizScore / total) * 100).round() : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Text(
                pct >= 80 ? '🏆' : (pct >= 50 ? '🌟' : '💪'),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                pct >= 80
                    ? (isHindi ? 'शाबाश! टेबल मास्टर!' : 'Table Master!')
                    : (isHindi ? 'अच्छा प्रयास!' : 'Good Effort!'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF065F46)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isHindi
                    ? 'आपने $total में से $_quizScore सही उत्तर दिए ($pct%)।'
                    : 'You answered $_quizScore out of $total correctly ($pct%) in ${_quizTimerSeconds}s.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _tabController.animateTo(0); // Go back to chart
              },
              child: Text(isHindi ? 'चार्ट देखें' : 'Study Chart'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _initQuiz();
              },
              child: Text(
                isHindi ? 'फिर से टेस्ट दें' : 'Retake Test',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
