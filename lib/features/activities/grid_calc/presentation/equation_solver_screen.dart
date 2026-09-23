import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../data/models/activity_model.dart';
import '../../../../data/services/procedural_question_generator.dart';
import '../../../../shared/components/curio_button.dart';
import '../../../../shared/components/gamified_card.dart';
import '../../../../shared/components/scratchpad_drawer.dart';
import '../../../../shared/dialogs/reward_dialog.dart';

class EquationStep {
  final int stepNumber;
  final String question;
  final String correctExplanation;
  final List<String> options;
  final int correctOptionIndex;
  final String resultingEquation;

  const EquationStep({
    required this.stepNumber,
    required this.question,
    required this.correctExplanation,
    required this.options,
    required this.correctOptionIndex,
    required this.resultingEquation,
  });
}

class EquationSolverScreen extends StatefulWidget {
  final Activity? activity;

  const EquationSolverScreen({super.key, this.activity});

  @override
  State<EquationSolverScreen> createState() => _EquationSolverScreenState();
}

class _EquationSolverScreenState extends State<EquationSolverScreen> {
  int _currentStepIndex = 0;
  late String _currentEquation;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _score = 0;
  int _equationCount = 1;

  // Timer Challenge
  int _secondsRemaining = 90;
  Timer? _timer;

  late List<EquationStep> _steps;

  @override
  void initState() {
    super.initState();
    _loadEquation(widget.activity);
    _startTimer();
  }

  void _loadEquation(Activity? act) {
    _currentStepIndex = 0;
    _selectedOptionIndex = null;
    _isAnswered = false;
    _isCorrect = false;

    final payload = act?.interactionPayload;
    if (payload != null && payload.containsKey('equation') && payload.containsKey('stepsRequired')) {
      _currentEquation = payload['equation'] as String? ?? '3x - 7 = 14';
      final rawSteps = payload['stepsRequired'] as List<dynamic>;

      _steps = List.generate(rawSteps.length, (idx) {
        final stepMap = rawSteps[idx] as Map<String, dynamic>;
        final action = stepMap['action'] as String? ?? 'add_both_sides';
        final op = stepMap['operand'] ?? 7;
        final res = stepMap['resultPrompt'] as String? ?? '3x = 21';

        if (idx == 0) {
          final isAdd = action.contains('add');
          return EquationStep(
            stepNumber: 1,
            question: 'Step 1: Isolate the variable term. What operation should you apply to both sides?',
            correctExplanation: isAdd
                ? 'Correct! Adding $op to both sides cancels the subtraction: resulting in $res.'
                : 'Correct! Subtracting $op from both sides balances the equation: resulting in $res.',
            options: isAdd
                ? [
                    'Add $op to both sides (+ $op)',
                    'Subtract $op from both sides (- $op)',
                    'Multiply both sides by $op',
                    'Divide both sides by 2',
                  ]
                : [
                    'Subtract $op from both sides (- $op)',
                    'Add $op to both sides (+ $op)',
                    'Multiply both sides by $op',
                    'Divide both sides by 2',
                  ],
            correctOptionIndex: 0,
            resultingEquation: res,
          );
        } else {
          return EquationStep(
            stepNumber: 2,
            question: 'Step 2: Solve for x. What inverse operation isolates x?',
            correctExplanation: 'Bravo! Dividing both sides by $op isolates x: resulting in $res.',
            options: [
              'Subtract $op from both sides (- $op)',
              'Divide both sides by $op (÷ $op)',
              'Multiply both sides by $op (× $op)',
              'Add $op to both sides (+ $op)',
            ],
            correctOptionIndex: 1,
            resultingEquation: res,
          );
        }
      });
    } else {
      // Default equation
      _currentEquation = '3x - 7 = 14';
      _steps = const [
        EquationStep(
          stepNumber: 1,
          question: 'Step 1: Isolate the variable term (3x). What operation should you apply to both sides?',
          correctExplanation: 'Correct! Adding 7 to both sides cancels the -7 on the left: 14 + 7 = 21.',
          options: [
            'Add 7 to both sides (+ 7)',
            'Subtract 7 from both sides (- 7)',
            'Multiply both sides by 3 (× 3)',
            'Divide both sides by 14 (÷ 14)',
          ],
          correctOptionIndex: 0,
          resultingEquation: '3x = 21',
        ),
        EquationStep(
          stepNumber: 2,
          question: 'Step 2: Solve for x. What inverse operation undoes multiplication by 3?',
          correctExplanation: 'Bravo! Dividing both sides by 3 gives x = 21 ÷ 3 = 7.',
          options: [
            'Subtract 3 from both sides (- 3)',
            'Divide both sides by 3 (÷ 3)',
            'Multiply both sides by 3 (× 3)',
            'Add 21 to both sides (+ 21)',
          ],
          correctOptionIndex: 1,
          resultingEquation: 'x = 7',
        ),
      ];
    }
  }

  void _startTimer() {
    _secondsRemaining = 90;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleOptionSelected(int index) {
    if (_isAnswered) return;

    final step = _steps[_currentStepIndex];
    final correct = (index == step.correctOptionIndex);

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      _isCorrect = correct;
      if (correct) {
        _score += 25;
        _currentEquation = step.resultingEquation;
      }
    });

    if (correct) {
      AudioService.instance.playSfx(CurioSfx.correctCheer);
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
    }
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
        _isCorrect = false;
      });
      AudioService.instance.playSfx(CurioSfx.click);
    } else {
      _timer?.cancel();
      AudioService.instance.playSfx(CurioSfx.starAward);

      RewardDialog.show(
        context,
        starsAwarded: 3,
        totalPoints: _score + (_secondsRemaining > 30 ? 20 : 10),
        message: 'You solved and balanced the equation step by step! 📐✨',
        onContinue: () {
          // Generate the next procedural equation infinitely!
          final nextActivity = ProceduralQuestionGenerator.instance
              .generateLinearEquation(targetGrade: widget.activity?.targetGrade ?? 'Class 7');
          setState(() {
            _equationCount++;
            _loadEquation(nextActivity);
            _startTimer();
          });
          AudioService.instance.playSfx(CurioSfx.starAward);
        },
        onReplay: () {
          setState(() {
            _loadEquation(widget.activity);
            _startTimer();
          });
        },
      );
    }
  }

  void _openScratchpad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScratchpadDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Equation Balancer #$_equationCount',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, color: Color(0xFF4F46E5), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_secondsRemaining}s',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4F46E5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF4F46E5)),
            tooltip: 'Scratchpad',
            onPressed: _openScratchpad,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GamifiedCard(
                backgroundColor: const Color(0xFFFFFFFF),
                borderColor: const Color(0xFFE2E8F0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.activity?.targetGrade ?? "Class 7"} • Simple Equations',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ),
                        Text(
                          'Step ${_currentStepIndex + 1} of ${_steps.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6366F1),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Container(
                        key: ValueKey(_currentEquation),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF818CF8), width: 2),
                        ),
                        child: Text(
                          _currentEquation,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '⚖️ Balanced Equation',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                step.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 14),

              ...List.generate(step.options.length, (idx) {
                final optionText = step.options[idx];
                final isSelected = _selectedOptionIndex == idx;
                final isCorrectOption = idx == step.correctOptionIndex;

                Color cardBg = Colors.white;
                Color border = const Color(0xFFE2E8F0);
                Color textCol = const Color(0xFF1E293B);

                if (_isAnswered) {
                  if (isCorrectOption) {
                    cardBg = const Color(0xFFF0FDF4);
                    border = const Color(0xFF22C55E);
                    textCol = const Color(0xFF15803D);
                  } else if (isSelected) {
                    cardBg = const Color(0xFFFEF2F2);
                    border = const Color(0xFFEF4444);
                    textCol = const Color(0xFFB91C1C);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _handleOptionSelected(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: isSelected || (_isAnswered && isCorrectOption) ? 2 : 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: border.withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + idx),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: textCol,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              optionText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textCol,
                              ),
                            ),
                          ),
                          if (_isAnswered && isCorrectOption)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                          if (_isAnswered && isSelected && !isCorrectOption)
                            const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626)),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              if (_isAnswered) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCorrect ? Icons.lightbulb_rounded : Icons.info_outline_rounded,
                        color: _isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isCorrect
                              ? step.correctExplanation
                              : 'Review inverse operations: Keep both sides balanced.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isCorrect ? const Color(0xFF15803D) : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CurioButton(
                  label: _currentStepIndex < _steps.length - 1 ? 'Next Step ➡️' : 'Next Equation 🚀',
                  backgroundColor: const Color(0xFF4F46E5),
                  onPressed: _nextStep,
                ),
              ],

              const SizedBox(height: 16),

              OutlinedButton.icon(
                icon: const Icon(Icons.brush_rounded, size: 20),
                label: const Text('Open Scratchpad for Calculations'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFFC7D2FE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _openScratchpad,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
