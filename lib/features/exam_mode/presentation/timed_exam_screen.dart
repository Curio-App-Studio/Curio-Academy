import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/student_attempt_model.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../models/exam_model.dart';
import 'exam_report_card_dialog.dart';

class TimedExamScreen extends ConsumerStatefulWidget {
  final Chapter? chapter;
  final List<Chapter>? chapters;
  final String subjectId;
  final String subjectName;
  final Color primaryColor;
  final int durationSeconds;

  const TimedExamScreen({
    super.key,
    this.chapter,
    this.chapters,
    required this.subjectId,
    required this.subjectName,
    required this.primaryColor,
    this.durationSeconds = 300, // 5 minutes default
  });

  @override
  ConsumerState<TimedExamScreen> createState() => _TimedExamScreenState();
}

class _TimedExamScreenState extends ConsumerState<TimedExamScreen> {
  final CurriculumRepository _repository = CurriculumRepository();
  List<ExamQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitted = false;

  late int _remainingSeconds;
  Timer? _timer;
  int _timeSpentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _prepareQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isSubmitted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _timeSpentSeconds++;
        } else {
          timer.cancel();
          _submitExam(autoSubmit: true);
        }
      });
    });
  }

  Future<void> _prepareQuestions() async {
    final activeProfile = ref.read(studentProfileProvider);
    final rawActivities = <Activity>[];

    if (widget.chapter != null) {
      final ch = widget.chapter!;
      if (ch.activities.isNotEmpty) {
        rawActivities.addAll(ch.activities);
      } else {
        final generated = _repository.generateActivitiesForChapter(
          ch.chapterId,
          activeProfile.studentClass,
          count: 5,
          chapter: ch,
        );
        rawActivities.addAll(generated);
      }
    } else if (widget.chapters != null && widget.chapters!.isNotEmpty) {
      for (final ch in widget.chapters!.take(5)) {
        final generated = _repository.generateActivitiesForChapter(
          ch.chapterId,
          activeProfile.studentClass,
          count: 2,
          chapter: ch,
        );
        rawActivities.addAll(generated);
        if (rawActivities.length >= 8) break;
      }
    }

    if (rawActivities.isEmpty) {
      final fallback = _repository.generateExtraActivities(activeProfile.studentClass, count: 5);
      rawActivities.addAll(fallback);
    }

    final parsedQuestions = <ExamQuestion>[];
    for (int i = 0; i < rawActivities.length; i++) {
      final act = rawActivities[i];
      String prompt = act.promptData.text;
      String tts = act.promptData.ttsFallback ?? prompt;
      String answer = '';
      List<String> options = [];
      String explanation = '';
      String? visualIcon;

      if (act.interactionPayload.containsKey('options')) {
        options = List<String>.from(act.interactionPayload['options'] as List);
      }
      if (act.interactionPayload.containsKey('explanation')) {
        explanation = act.interactionPayload['explanation'] as String;
      }
      if (act.interactionPayload.containsKey('visualIcon')) {
        visualIcon = act.interactionPayload['visualIcon'] as String;
      }

      // 1. Handle Bubble Pop activities: extract target and distractor bubbles as options
      if (act.activityType == ActivityType.bubblePop || options.isEmpty) {
        if (act.interactionPayload.containsKey('bubbles')) {
          final bubbles = act.interactionPayload['bubbles'] as List;
          final targetVal = act.interactionPayload['targetValue'];
          final correctLabels = <String>[];
          final wrongLabels = <String>[];

          for (final b in bubbles) {
            if (b is Map) {
              final label = b['label']?.toString() ?? b['value']?.toString() ?? '';
              if (label.isEmpty) continue;
              final isTarget = b['isTarget'] == true ||
                  (targetVal != null && (b['value'] == targetVal || b['label'] == targetVal.toString()));
              if (isTarget) {
                if (!correctLabels.contains(label)) correctLabels.add(label);
              } else {
                if (!wrongLabels.contains(label)) wrongLabels.add(label);
              }
            }
          }

          if (correctLabels.isNotEmpty) {
            answer = correctLabels.first;
            options = [answer, ...wrongLabels.take(3)]..shuffle();
          }
        }
      }

      // 2. Handle Card Match activities: extract pairs
      if (act.activityType == ActivityType.cardMatch || options.isEmpty) {
        if (act.interactionPayload.containsKey('pairs')) {
          final pairs = act.interactionPayload['pairs'] as List;
          if (pairs.isNotEmpty && pairs.first is Map) {
            final firstPair = pairs.first as Map;
            final left = firstPair['left']?.toString() ?? '';
            final right = firstPair['right']?.toString() ?? '';
            if (left.isNotEmpty && right.isNotEmpty) {
              answer = right;
              final otherRights = pairs.skip(1).map((p) => (p as Map)['right']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
              options = [answer, ...otherRights.take(3)]..shuffle();
              prompt = 'Which one matches with "$left"?';
              tts = 'Which one matches with $left?';
            }
          }
        }
      }

      if (answer.isEmpty) {
        answer = act.validationRule.expectedAnswer?.toString() ?? (options.isNotEmpty ? options.first : '');
      }

      // Always sanitize prompts so they never say "Pop..." or "बुलबुले फोड़ें" in exam mode
      prompt = _sanitizeExamPrompt(prompt, answer);
      tts = _sanitizeExamPrompt(tts, answer);

      if (options.isEmpty) {
        options = [answer, 'Not this one', 'Something else'];
      }

      // Kindergarten optimization: limit to 2 or 3 choices max
      if (activeProfile.studentClass.isKindergarten && options.length > 3) {
        final wrong = options.where((o) => o != answer).take(2).toList();
        options = [answer, ...wrong]..shuffle();
      }

      parsedQuestions.add(
        ExamQuestion(
          questionNumber: i + 1,
          activity: act,
          prompt: prompt,
          ttsFallback: tts,
          options: options,
          correctAnswer: answer,
          explanation: explanation,
          visualIcon: visualIcon,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _questions = parsedQuestions;
        _isLoading = false;
      });
      _startTimer();
      if (_questions.isNotEmpty) {
        AudioService.instance.speakPrompt(_questions.first.ttsFallback);
      }
    }
  }

  String _sanitizeExamPrompt(String text, String answer) {
    var p = text.trim();

    // Hindi Pop prompts:
    if (p.contains('बुलबुले फोड़ें') || p.contains('बुलबुलों को फोड़ें') || p.contains('फोड़ें')) {
      final quoteMatch = RegExp(r"['\u2018\u201c](.*?)['\u2019\u201d]").firstMatch(p);
      if (quoteMatch != null) {
        return 'इनमें से कौन सा "${quoteMatch.group(1)}" अक्षर है?';
      }
      final clean = p.replaceAll(RegExp(r'(वाले )?बुलबुले फोड़ें!?', caseSensitive: false), '').trim();
      if (clean.isNotEmpty) {
        return 'इनमें से सही विकल्प चुनें: $clean';
      }
      return 'सही विकल्प चुनें';
    }

    // English Pop prompts:
    if (RegExp(r'Pop (all )?bubbles that equal (.*?)!?', caseSensitive: false).hasMatch(p)) {
      return p.replaceAllMapped(
        RegExp(r'Pop (all )?bubbles that equal (.*?)!?', caseSensitive: false),
        (m) => 'Which one equals ${m.group(2)}?',
      );
    }

    if (RegExp(r'Pop the opposite of (.*?)!?', caseSensitive: false).hasMatch(p)) {
      return p.replaceAllMapped(
        RegExp(r'Pop the opposite of (.*?)!?', caseSensitive: false),
        (m) => 'What is the opposite of ${m.group(1)}?',
      );
    }

    if (RegExp(r'Pop the rhyming word (for|with) (.*?)!?', caseSensitive: false).hasMatch(p)) {
      return p.replaceAllMapped(
        RegExp(r'Pop the rhyming word (for|with) (.*?)!?', caseSensitive: false),
        (m) => 'Which word rhymes with ${m.group(2)}?',
      );
    }

    if (RegExp(r'Pop all (the )?(.*?) bubbles!?', caseSensitive: false).hasMatch(p)) {
      return p.replaceAllMapped(
        RegExp(r'Pop all (the )?(.*?) bubbles!?', caseSensitive: false),
        (m) => 'Which of these is ${m.group(2)}?',
      );
    }

    if (RegExp(r'Pop the bubbles with (.*?)!?', caseSensitive: false).hasMatch(p)) {
      return p.replaceAllMapped(
        RegExp(r'Pop the bubbles with (.*?)!?', caseSensitive: false),
        (m) => 'Which of these is ${m.group(1)}?',
      );
    }

    if (p.toLowerCase().startsWith('pop ')) {
      final clean = p.substring(4).replaceAll(RegExp(r'\s*bubbles!?$', caseSensitive: false), '').trim();
      return 'Which one is $clean?';
    }

    return p;
  }

  void _selectOption(int optionIndex) {
    if (_isSubmitted || _currentQuestionIndex >= _questions.length) return;
    final currentQ = _questions[_currentQuestionIndex];
    setState(() {
      currentQ.selectedOptionIndex = optionIndex;
      currentQ.selectedOptionText = currentQ.options[optionIndex];
    });
    AudioService.instance.playSfx(CurioSfx.click);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
      AudioService.instance.speakPrompt(_questions[_currentQuestionIndex].ttsFallback);
    }
  }

  void _prevQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
      AudioService.instance.speakPrompt(_questions[_currentQuestionIndex].ttsFallback);
    }
  }

  Future<void> _submitExam({bool autoSubmit = false}) async {
    if (_isSubmitted) return;
    _timer?.cancel();
    setState(() => _isSubmitted = true);

    int correct = 0;
    int incorrect = 0;
    int unattempted = 0;

    for (final q in _questions) {
      final isCorr = q.isCorrect;
      if (!q.isAttempted) {
        unattempted++;
        // Unattempted counts as a missed question in exam
        LocalStorageService.instance.saveQuestionAttempt(
          StudentQuestionAttempt(
            activityId: q.activity.activityId,
            chapterId: q.activity.chapterId ?? widget.chapter?.chapterId ?? 'exam_${widget.subjectId}',
            selectedOptionIndex: -1,
            selectedOptionText: 'Skipped',
            isCorrect: false,
            starsEarned: 0,
            timestamp: DateTime.now(),
          ),
        );
      } else if (isCorr) {
        correct++;
        LocalStorageService.instance.saveQuestionAttempt(
          StudentQuestionAttempt(
            activityId: q.activity.activityId,
            chapterId: q.activity.chapterId ?? widget.chapter?.chapterId ?? 'exam_${widget.subjectId}',
            selectedOptionIndex: q.selectedOptionIndex!,
            selectedOptionText: q.selectedOptionText!,
            isCorrect: true,
            starsEarned: 1,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        incorrect++;
        LocalStorageService.instance.saveQuestionAttempt(
          StudentQuestionAttempt(
            activityId: q.activity.activityId,
            chapterId: q.activity.chapterId ?? widget.chapter?.chapterId ?? 'exam_${widget.subjectId}',
            selectedOptionIndex: q.selectedOptionIndex!,
            selectedOptionText: q.selectedOptionText!,
            isCorrect: false,
            starsEarned: 0,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // Rule: Completing a unit test or chapter exam marks the chapter complete!
    if (widget.chapter != null) {
      await LocalStorageService.instance.markChapterCompleted(widget.chapter!.chapterId);
    } else if (widget.chapters != null) {
      for (final ch in widget.chapters!) {
        await LocalStorageService.instance.markChapterCompleted(ch.chapterId);
      }
    }

    final examTitle = widget.chapter != null
        ? '${widget.chapter!.title} (Unit Test)'
        : '${widget.subjectName} (Mock Test)';

    final result = ExamResult(
      examTitle: examTitle,
      subjectId: widget.subjectId,
      totalQuestions: _questions.length,
      correctCount: correct,
      incorrectCount: incorrect + unattempted,
      unattemptedCount: unattempted,
      timeSpentSeconds: _timeSpentSeconds,
      totalTimeSeconds: widget.durationSeconds,
      questions: _questions,
    );

    AudioService.instance.playSfx(CurioSfx.applause);

    if (mounted) {
      ExamReportCardDialog.show(
        context,
        result: result,
        onRetake: () {
          setState(() {
            _currentQuestionIndex = 0;
            _isLoading = true;
            _isSubmitted = false;
            _remainingSeconds = widget.durationSeconds;
            _timeSpentSeconds = 0;
          });
          _prepareQuestions();
        },
        onDismiss: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  String _formatTimerDisplay(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: widget.primaryColor),
              const SizedBox(height: 16),
              Text(
                strings.isHindi ? 'परीक्षा पत्र तैयार हो रहा है... 📝' : 'Preparing Exam Paper... 📝',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final isLowTime = _remainingSeconds <= 60;
    final timerColor = isLowTime ? const Color(0xFFDC2626) : (_remainingSeconds <= 120 ? const Color(0xFFD97706) : const Color(0xFF059669));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF334155)),
          onPressed: () => _confirmExit(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.chapter != null ? widget.chapter!.title : '${widget.subjectName} Unit Test',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              ref.watch(studentProfileProvider).studentClass.isKindergarten
                  ? (strings.isHindi ? 'मज़ेदार अभ्यास क्विज़ 🎒🌟' : 'Fun Practice Quiz 🎒🌟')
                  : strings.examMode,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: widget.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          // Timer Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: timerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: timerColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: timerColor),
                const SizedBox(width: 4),
                Text(
                  _formatTimerDisplay(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: timerColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF475569)),
            tooltip: 'Audio Prompt',
            onPressed: () {
              AudioService.instance.playSfx(CurioSfx.click);
              AudioService.instance.speakPrompt(currentQuestion.ttsFallback);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer progress bar
            LinearProgressIndicator(
              value: widget.durationSeconds > 0 ? (_remainingSeconds / widget.durationSeconds) : 0,
              backgroundColor: const Color(0xFFE2E8F0),
              color: timerColor,
              minHeight: 4,
            ),

            // Stepper pills
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${strings.question} ${_currentQuestionIndex + 1} ${strings.ofWord} ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Row(
                    children: List.generate(_questions.length, (idx) {
                      final q = _questions[idx];
                      final isCurrent = idx == _currentQuestionIndex;
                      final isAnswered = q.isAttempted;
                      return GestureDetector(
                        onTap: () {
                          AudioService.instance.playSfx(CurioSfx.click);
                          setState(() => _currentQuestionIndex = idx);
                          AudioService.instance.speakPrompt(_questions[idx].ttsFallback);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? widget.primaryColor
                                : (isAnswered ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent
                                  ? widget.primaryColor
                                  : (isAnswered ? const Color(0xFF059669) : const Color(0xFFCBD5E1)),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isCurrent
                                    ? Colors.white
                                    : (isAnswered ? const Color(0xFF065F46) : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Question and choices
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Prompt Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentQuestion.visualIcon != null) ...[
                            Text(currentQuestion.visualIcon!, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 10),
                          ],
                          Text(
                            currentQuestion.prompt,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      strings.selectAnswerPrompt,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Options List
                    ...List.generate(currentQuestion.options.length, (optIdx) {
                      final optionText = currentQuestion.options[optIdx];
                      final isSelected = currentQuestion.selectedOptionIndex == optIdx;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _selectOption(optIdx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? widget.primaryColor.withValues(alpha: 0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? widget.primaryColor : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1.2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: widget.primaryColor.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected ? widget.primaryColor : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? widget.primaryColor : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + optIdx), // A, B, C, D
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isSelected ? Colors.white : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? widget.primaryColor : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: widget.primaryColor, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    OutlinedButton(
                      onPressed: _prevQuestion,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text(strings.prevQuestion),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (_currentQuestionIndex < _questions.length - 1)
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: Row(
                        children: [
                          Text(strings.nextQuestion),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _submitExam(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            strings.submitExam,
                            style: const TextStyle(fontWeight: FontWeight.w900),
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

  void _confirmExit(BuildContext context) {
    final strings = ref.strings;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.isHindi ? 'परीक्षा छोड़ें?' : 'Leave Exam?'),
        content: Text(
          strings.isHindi
              ? 'क्या आप वास्तव में टेस्ट छोड़ना चाहते हैं? आपकी प्रगति सहेजी नहीं जाएगी।'
              : 'Are you sure you want to quit the exam? Your current progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.isHindi ? 'जारी रखें' : 'Keep Going'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              strings.isHindi ? 'छोड़ें' : 'Quit Exam',
              style: const TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}
