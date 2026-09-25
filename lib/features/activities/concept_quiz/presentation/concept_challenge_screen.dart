import 'package:flutter/material.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../data/local/local_storage_service.dart';
import '../../../../data/models/activity_model.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/models/student_attempt_model.dart';
import '../../../../data/models/student_profile.dart';
import '../../../../data/services/concept_solution_helper.dart';
import '../../../../data/services/procedural_question_generator.dart';
import '../../../../shared/components/gamified_card.dart';
import '../../../../shared/components/scratchpad_drawer.dart';
import '../../../../shared/dialogs/reward_dialog.dart';
import '../../bubble_pop/presentation/bubble_pop_screen.dart';
import 'question_solution_sheet.dart';

class ConceptChallengeScreen extends StatefulWidget {
  final Activity? activity;
  final Chapter? chapter;
  final List<Activity>? activities;
  final int initialIndex;
  final StudentClass studentClass;
  final ValueChanged<List<Activity>>? onActivitiesUpdated;

  const ConceptChallengeScreen({
    super.key,
    this.activity,
    this.chapter,
    this.activities,
    this.initialIndex = 0,
    this.studentClass = StudentClass.class1,
    this.onActivitiesUpdated,
  });

  @override
  State<ConceptChallengeScreen> createState() => _ConceptChallengeScreenState();
}

class _ConceptChallengeScreenState extends State<ConceptChallengeScreen> {
  late List<Activity> _activitiesList;
  late int _currentIndex;
  late Activity _currentActivity;
  int _answersGiven = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _wasPreviouslyAnswered = false;
  bool _showHint = false;
  int _currentQuestionMistakes = 0;
  bool _usedHintOnCurrentQuestion = false;

  @override
  void initState() {
    super.initState();
    _score = LocalStorageService.instance.totalStars;
    if (widget.activities != null && widget.activities!.isNotEmpty) {
      _activitiesList = List<Activity>.from(widget.activities!);
    } else if (widget.activity != null) {
      _activitiesList = [widget.activity!];
    } else {
      _activitiesList = [];
    }

    _currentIndex = _activitiesList.isNotEmpty
        ? widget.initialIndex.clamp(0, _activitiesList.length - 1)
        : 0;

    if (_activitiesList.isNotEmpty) {
      _loadActivity(_activitiesList[_currentIndex]);
    }
  }

  void _loadActivity(Activity act) {
    final prevAttempt = LocalStorageService.instance.getQuestionAttempt(act.activityId);
    setState(() {
      _currentActivity = act;
      _score = LocalStorageService.instance.totalStars;
      if (prevAttempt != null) {
        _selectedIndex = prevAttempt.selectedOptionIndex;
        _isAnswered = true;
        _isCorrect = prevAttempt.isCorrect;
        _wasPreviouslyAnswered = true;
      } else {
        _selectedIndex = null;
        _isAnswered = false;
        _isCorrect = false;
        _wasPreviouslyAnswered = false;
      }
      _showHint = false;
      _currentQuestionMistakes = 0;
      _usedHintOnCurrentQuestion = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (act.activityType != ActivityType.bubblePop) {
        AudioService.instance.speakPrompt(act.promptData.ttsFallback ?? act.promptData.text);
      }
    });
  }

  void _retryQuestion() {
    AudioService.instance.playSfx(CurioSfx.click);
    setState(() {
      _selectedIndex = null;
      _isAnswered = false;
      _isCorrect = false;
      _wasPreviouslyAnswered = false;
      _showHint = false;
    });
  }

  void _handleOptionTap(int index, String optionValue) {
    if (_isAnswered) return;

    final expected = _currentActivity.validationRule.expectedAnswer?.toString() ?? '';
    final isCorrect = (optionValue.trim().toLowerCase() == expected.trim().toLowerCase());

    if (!isCorrect) {
      _currentQuestionMistakes++;
    }

    final int starsAwarded;
    if (_currentQuestionMistakes == 0 && !_usedHintOnCurrentQuestion) {
      starsAwarded = 3;
    } else if (_currentQuestionMistakes == 1 || _usedHintOnCurrentQuestion) {
      starsAwarded = 2;
    } else {
      starsAwarded = 1;
    }

    final pointsEarned = isCorrect
        ? ((_currentActivity.pointsReward * starsAwarded) ~/ 3).clamp(5, _currentActivity.pointsReward)
        : 0;

    // Persist response attempt with stars to local storage
    final chapterId = widget.chapter?.chapterId ?? _currentActivity.chapterId ?? 'ch_1';
    final attempt = StudentQuestionAttempt(
      activityId: _currentActivity.activityId,
      chapterId: chapterId,
      selectedOptionIndex: index,
      selectedOptionText: optionValue,
      isCorrect: isCorrect,
      starsEarned: isCorrect ? starsAwarded : 0,
      timestamp: DateTime.now(),
    );
    LocalStorageService.instance.saveQuestionAttempt(attempt);

    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
      _isCorrect = isCorrect;
      _wasPreviouslyAnswered = false;
      _answersGiven++;
      _score = LocalStorageService.instance.totalStars;
    });

    if (isCorrect) {
      AudioService.instance.playSfx(CurioSfx.correctCheer);
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        final congratMessage = starsAwarded == 3
            ? 'Awesome! Perfect answer on your first try! 🌟'
            : starsAwarded == 2
                ? 'Great effort! You worked through and got it! ⭐'
                : 'Good perseverance! Practice makes perfect! ✨';

        RewardDialog.show(
          context,
          starsAwarded: starsAwarded,
          totalPoints: pointsEarned,
          message: congratMessage,
          onContinue: () {
            _goToNextQuestion();
          },
          onReplay: () {
            _retryQuestion();
          },
        );
      });
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
    }
  }

  void _goToPreviousQuestion() {
    if (_currentIndex > 0) {
      AudioService.instance.playSfx(CurioSfx.click);
      setState(() {
        _currentIndex--;
        _loadActivity(_activitiesList[_currentIndex]);
      });
    }
  }

  void _skipQuestion() {
    AudioService.instance.playSfx(CurioSfx.click);
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    AudioService.instance.playSfx(CurioSfx.click);

    final isAtLastQuestion = _currentIndex + 1 >= _activitiesList.length;
    final hasGivenTwoOrMoreAnswers = _answersGiven >= 2;

    // After giving 2 answers, or whenever reaching the end of the question list:
    // Automatically generate and add the next authentic chapter question!
    if (isAtLastQuestion || hasGivenTwoOrMoreAnswers) {
      if (isAtLastQuestion) {
        _generateAndAppendNextQuestion();
      }
    }

    if (_currentIndex + 1 < _activitiesList.length) {
      setState(() {
        _currentIndex++;
        _loadActivity(_activitiesList[_currentIndex]);
      });
    }
  }

  void _generateAndAppendNextQuestion() {
    final chapter = widget.chapter ??
        Chapter(
          chapterId: _currentActivity.chapterId ?? 'ch_default',
          chapterNumber: 1,
          title: _currentActivity.chapterName ?? 'Concept Practice',
          grade: widget.studentClass.label,
          icon: '✨',
        );

    final existingPrompts = _activitiesList.map((a) => a.promptData.text).toSet();
    final newActs = ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
      chapter,
      widget.studentClass,
      count: 1,
      existingPromptTexts: existingPrompts,
    );

    if (newActs.isNotEmpty) {
      _activitiesList.add(newActs.first);
      widget.onActivitiesUpdated?.call(_activitiesList);
      // Persist updated question list to local storage immediately
      LocalStorageService.instance.saveChapterActivities(chapter.chapterId, _activitiesList);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Question ${_activitiesList.length} automatically added and saved!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
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
    if (_currentActivity.activityType == ActivityType.bubblePop) {
      return BubblePopScreen(
        activity: _currentActivity,
        activities: _activitiesList,
        initialLevelIndex: _currentIndex,
      );
    }

    final payload = _currentActivity.interactionPayload;
    final options = (payload['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ['Option A', 'Option B', 'Option C', 'Option D'];
    final explanation = payload['explanation'] as String? ?? 'Review the concept and try again!';
    final visualIcon = payload['visualIcon'] as String? ?? '📐';
    final topicTitle = payload['topicTitle'] as String? ??
        _currentActivity.chapterName ??
        _currentActivity.topicId;

    final bool isLastOrAutoAdding = (_currentIndex + 1 >= _activitiesList.length) || (_answersGiven >= 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: _buildBottomActionBar(isLastOrAutoAdding),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_activitiesList.length}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              widget.chapter?.title ?? _currentActivity.chapterName ?? _currentActivity.targetGrade,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AudioService.instance.muteNotifier,
            builder: (context, isMuted, child) {
              return IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF4F46E5),
                ),
                tooltip: isMuted ? 'Unmute Speaker' : 'Mute Speaker',
                onPressed: () {
                  AudioService.instance.toggleMute();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_rounded, color: Color(0xFFD97706)),
            tooltip: 'View Solution & Concept Details',
            onPressed: () {
              setState(() {
                _usedHintOnCurrentQuestion = true;
              });
              QuestionSolutionSheet.show(
                context,
                activity: _currentActivity,
                chapter: widget.chapter,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB)),
            tooltip: 'Scratchpad',
            onPressed: _openScratchpad,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _activitiesList.isEmpty
                ? 0
                : (_currentIndex + 1) / _activitiesList.length,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF7B25)),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Problem Card with Visual Icon and Topic Badge
              GamifiedCard(
                backgroundColor: Colors.white,
                borderColor: const Color(0xFFE2E8F0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                topicTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            if (_isAnswered && _isCorrect) ...[
                              const SizedBox(width: 8),
                              Builder(
                                builder: (_) {
                                  final earned = LocalStorageService.instance.getStarsForActivity(_currentActivity.activityId);
                                  final starsToShow = earned > 0 ? earned : 3;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFDE68A)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(3, (i) => Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: i < starsToShow ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                                      )),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB), size: 22),
                              tooltip: 'Read Question Aloud',
                              onPressed: () {
                                AudioService.instance.playSfx(CurioSfx.click);
                                AudioService.instance.speakPrompt(
                                  _currentActivity.promptData.ttsFallback ??
                                  _currentActivity.promptData.text,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      visualIcon,
                      style: const TextStyle(fontSize: 54),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentActivity.promptData.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Options Grid/List
              ...List.generate(options.length, (idx) {
                final optionValue = options[idx];
                final isSelected = _selectedIndex == idx;
                final isExpected = (optionValue.trim().toLowerCase() ==
                    _currentActivity.validationRule.expectedAnswer?.toString().trim().toLowerCase());

                Color cardBg = Colors.white;
                Color border = const Color(0xFFE2E8F0);
                Color textCol = const Color(0xFF1E293B);

                if (_isAnswered) {
                  if (isExpected) {
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
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _handleOptionTap(idx, optionValue),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: border,
                          width: (isSelected || (_isAnswered && isExpected)) ? 2.5 : 1.2,
                        ),
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
                              color: border.withValues(alpha: 0.25),
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
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              optionValue,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textCol,
                              ),
                            ),
                          ),
                          if (_isAnswered && isExpected)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                          if (_isAnswered && isSelected && !isExpected)
                            const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626)),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              // 3. Feedback Banner & Previous Response Notice
              if (_isAnswered) ...[
                if (_wasPreviouslyAnswered) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 20, color: Color(0xFF2563EB)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Showing your previous response: ${options[_selectedIndex ?? 0]} (${_isCorrect ? "Correct ✓" : "Needs Review"}).',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

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
                        _isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        color: _isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isCorrect ? 'Excellent job! $explanation' : explanation,
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
                const SizedBox(height: 10),

                // View Solution & Concept Details Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _usedHintOnCurrentQuestion = true;
                    });
                    QuestionSolutionSheet.show(
                      context,
                      activity: _currentActivity,
                      chapter: widget.chapter,
                    );
                  },
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: const Text(
                    'View Full Solution & Concept Details 💡',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4338CA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Action: Retry Question
                OutlinedButton.icon(
                  onPressed: _retryQuestion,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Retry This Question',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 5. Scratchpad Callout Button
              OutlinedButton.icon(
                icon: const Icon(Icons.draw_rounded, size: 20),
                label: const Text('Open Scratchpad for Calculations ✏️'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _openScratchpad,
              ),

              const SizedBox(height: 12),

              // 6. Hint & Concept Assistance (Available for every question)
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(
                        _showHint ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: const Color(0xFFD97706),
                      ),
                      label: Text(
                        _showHint ? 'Hide Hint' : 'Need a Hint? 💡',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _showHint = !_showHint);
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.auto_stories_rounded,
                        size: 20,
                        color: Color(0xFF4F46E5),
                      ),
                      label: const Text(
                        'Full Solution 🔍',
                        style: TextStyle(
                          color: Color(0xFF4338CA),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        QuestionSolutionSheet.show(
                          context,
                          activity: _currentActivity,
                          chapter: widget.chapter,
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (_showHint) ...[
                Builder(
                  builder: (context) {
                    final details = ConceptSolutionHelper.instance.getDetails(
                      _currentActivity,
                      chapter: widget.chapter,
                    );
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Text('💡', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pedagogical Hint & Clue',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFFB45309)),
                                tooltip: 'Listen to Hint',
                                onPressed: () {
                                  AudioService.instance.speakPrompt(details.hint);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details.hint,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF78350F),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              QuestionSolutionSheet.show(
                                context,
                                activity: _currentActivity,
                                chapter: widget.chapter,
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Still stuck? View step-by-step solution',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4338CA),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF4338CA)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(bool isLast) {
    final canGoPrev = _currentIndex > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
        ),
        child: Row(
          children: [
            // 1. Previous Question Button
            OutlinedButton.icon(
              onPressed: canGoPrev ? _goToPreviousQuestion : null,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: canGoPrev ? const Color(0xFF334155) : const Color(0xFF94A3B8),
              ),
              label: Text(
                'Prev',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: canGoPrev ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                backgroundColor: canGoPrev ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
                side: BorderSide(
                  color: canGoPrev ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 2. Skip Question Button (Visible when question is not yet answered)
            if (!_isAnswered) ...[
              OutlinedButton.icon(
                onPressed: _skipQuestion,
                icon: const Icon(
                  Icons.skip_next_rounded,
                  size: 19,
                  color: Color(0xFFB45309),
                ),
                label: const Text(
                  'Skip',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFFB45309),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  backgroundColor: const Color(0xFFFFFBEB),
                  side: const BorderSide(color: Color(0xFFFDE68A), width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // 3. Next Question Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _goToNextQuestion,
                icon: Icon(
                  _isAnswered ? Icons.arrow_forward_rounded : Icons.arrow_forward_ios_rounded,
                  size: _isAnswered ? 20 : 16,
                  color: Colors.white,
                ),
                label: Text(
                  _isAnswered
                      ? (isLast ? 'Next Question (New ✨)' : 'Next Question ➡️')
                      : 'Next ➔',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: _isAnswered ? 3 : 0.5,
                  shadowColor: const Color(0xFFFF7B25).withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: _isAnswered
                      ? const Color(0xFFFF7B25)
                      : const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
