import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/hindi_curriculum_translator.dart';
import '../../../../data/local/local_storage_service.dart';
import '../../../../data/models/activity_model.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/models/student_attempt_model.dart';
import '../../../../data/models/student_profile.dart';
import '../../../../data/repositories/curriculum_repository.dart';
import '../../../../data/services/concept_solution_helper.dart';
import '../../../../shared/components/gamified_card.dart';
import '../../../../shared/components/scratchpad_drawer.dart';
import '../../../../shared/dialogs/reward_dialog.dart';
import '../../../../shared/components/language_switch_button.dart';
import 'question_solution_sheet.dart';
import '../../../../services/ad_service.dart';

class ConceptChallengeScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ConceptChallengeScreen> createState() => _ConceptChallengeScreenState();
}

class _ConceptChallengeScreenState extends ConsumerState<ConceptChallengeScreen> {
  late List<Activity> _activitiesList;
  late int _currentIndex;
  late Activity _currentActivity;
  int _answersGiven = 0;
  int? _selectedIndex;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _wasPreviouslyAnswered = false;
  bool _showHint = false;
  int _currentQuestionMistakes = 0;
  bool _usedHintOnCurrentQuestion = false;
  final Set<int> _eliminatedIndices = {};
  Timer? _rewardTimer;

  @override
  void dispose() {
    _rewardTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
      _eliminatedIndices.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (act.activityType != ActivityType.bubblePop) {
        final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
        final promptToSpeak = isHindi
            ? HindiCurriculumTranslator.translatePrompt(act.promptData.text)
            : (act.promptData.ttsFallback ?? act.promptData.text);
        AudioService.instance.speakPrompt(promptToSpeak, isHindi: isHindi);
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
    if (isCorrect && pointsEarned > 0) {
      LocalStorageService.instance.addDiscoveryPoints(pointsEarned);
    }

    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
      _isCorrect = isCorrect;
      _wasPreviouslyAnswered = false;
      _answersGiven++;
    });

    // Seamless auto-flow: pre-generate next question if currently at or near the last question
    if (_currentIndex + 1 >= _activitiesList.length) {
      _generateAndAppendNextQuestion();
    }

    if (isCorrect) {
      AudioService.instance.playSfx(CurioSfx.correctCheer);
      _rewardTimer?.cancel();
      _rewardTimer = Timer(const Duration(milliseconds: 650), () {
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
          onBackToQuestions: () {
            Navigator.of(context).pop();
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
    if (_currentIndex + 1 >= _activitiesList.length) {
      _generateAndAppendNextQuestion();
    }
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    AudioService.instance.playSfx(CurioSfx.click);

    if (_currentIndex + 1 >= _activitiesList.length) {
      _generateAndAppendNextQuestion();
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
          subjectId: _currentActivity.subjectId,
          icon: '✨',
        );

    final existingPrompts = _activitiesList.map((a) => a.promptData.text).toSet();
    final newActs = CurriculumRepository.instance.generateActivitiesForChapter(
      chapter.chapterId,
      widget.studentClass,
      count: 1,
      chapter: chapter,
      existingPromptTexts: existingPrompts,
    );

    if (newActs.isNotEmpty) {
      _activitiesList.add(newActs.first);
      widget.onActivitiesUpdated?.call(_activitiesList);
      // Persist updated question list to local storage immediately
      LocalStorageService.instance.saveChapterActivities(chapter.chapterId, _activitiesList);
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
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    final payload = _currentActivity.interactionPayload;
    List<String>? candidateOptions = (payload['options'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    if (candidateOptions == null || candidateOptions.isEmpty) {
      if (payload.containsKey('bubbles') && (payload['bubbles'] as List).isNotEmpty) {
        candidateOptions = (payload['bubbles'] as List)
            .map((b) => b['label']?.toString() ?? b['value']?.toString() ?? '')
            .toSet()
            .where((s) => s.isNotEmpty)
            .take(4)
            .toList();
      }
    }
    final rawOptions = candidateOptions ?? ['Option A', 'Option B', 'Option C', 'Option D'];
    final options = isHindi
        ? rawOptions.map(HindiCurriculumTranslator.translateOption).toList()
        : rawOptions;
    final rawExplanation = payload['explanation'] as String? ?? 'Review the concept and try again!';
    final explanation = isHindi
        ? (rawExplanation.contains('Correct') || rawExplanation.contains('Great') || rawExplanation.contains('Awesome')
            ? 'बहुत बढ़िया! अवधारणा को याद रखें और अभ्यास करते रहें!'
            : rawExplanation)
        : rawExplanation;
    final visualIcon = payload['visualIcon'] as String? ?? '📐';
    final rawTopicTitle = payload['topicTitle'] as String? ??
        _currentActivity.chapterName ??
        _currentActivity.topicId;
    final topicTitle = isHindi
        ? HindiCurriculumTranslator.translateChapterTitle(rawTopicTitle)
        : rawTopicTitle;

    final displayedPrompt = isHindi
        ? HindiCurriculumTranslator.translatePrompt(_currentActivity.promptData.text)
        : _currentActivity.promptData.text;

    final bool isLastOrAutoAdding = (_currentIndex + 1 >= _activitiesList.length) || (_answersGiven >= 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: _buildBottomActionBar(isLastOrAutoAdding, strings, isHindi),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHindi
                  ? 'प्रश्न ${_currentIndex + 1} / ${_activitiesList.length}'
                  : 'Question ${_currentIndex + 1} of ${_activitiesList.length}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            Text(
              isHindi
                  ? HindiCurriculumTranslator.translateChapterTitle(widget.chapter?.title ?? _currentActivity.chapterName ?? _currentActivity.targetGrade)
                  : (widget.chapter?.title ?? _currentActivity.chapterName ?? _currentActivity.targetGrade),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
        leading: IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          const LanguageSwitchButton(),
          const SizedBox(width: 2),
          ValueListenableBuilder<int>(
            valueListenable: LocalStorageService.instance.totalStarsNotifier,
            builder: (context, totalStars, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                    const SizedBox(width: 3),
                    Text(
                      '$totalStars',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AudioService.instance.muteNotifier,
            builder: (context, isMuted, child) {
              return IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: isMuted ? const Color(0xFFEF4444) : const Color(0xFF4F46E5),
                  size: 21,
                ),
                tooltip: isMuted ? 'Unmute Speaker' : 'Mute Speaker',
                onPressed: () {
                  AudioService.instance.toggleMute();
                },
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF475569), size: 21),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'hint') {
                setState(() {
                  _usedHintOnCurrentQuestion = true;
                });
                QuestionSolutionSheet.show(
                  context,
                  activity: _currentActivity,
                  chapter: widget.chapter,
                );
              } else if (value == 'scratchpad') {
                _openScratchpad();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'hint',
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Color(0xFFD97706), size: 20),
                    SizedBox(width: 10),
                    Text('Hint & Solution', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'scratchpad',
                child: Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 10),
                    Text('Scratchpad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
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
                                final isHindi = ref.read(appLanguageProvider) == AppLanguage.hindi;
                                AudioService.instance.speakPrompt(displayedPrompt, isHindi: isHindi);
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
                      displayedPrompt,
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
                final displayedOption = options[idx];
                final rawOption = rawOptions[idx];
                final isSelected = _selectedIndex == idx;
                final isExpected = (rawOption.trim().toLowerCase() ==
                    _currentActivity.validationRule.expectedAnswer?.toString().trim().toLowerCase());

                final isEliminated = _eliminatedIndices.contains(idx);
                if (isEliminated) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                displayedOption,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF94A3B8),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

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
                    onTap: () => _handleOptionTap(idx, rawOption),
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
                              displayedOption,
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
                            isHindi
                                ? 'आपका पिछला उत्तर: ${options[_selectedIndex ?? 0]} (${_isCorrect ? "सही ✓" : "समीक्षा आवश्यक"}).'
                                : 'Showing your previous response: ${options[_selectedIndex ?? 0]} (${_isCorrect ? "Correct ✓" : "Needs Review"}).',
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
                          _isCorrect
                              ? (isHindi ? 'शानदार कार्य! बिल्कुल सही उत्तर 🌟' : 'Excellent job! $explanation')
                              : (isHindi ? 'कोई बात नहीं! एक बार फिर प्रयास करें या संकेत देखें! 💡' : explanation),
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
                  label: Text(
                    isHindi ? 'पूर्ण हल और अवधारणा विवरण देखें 💡' : 'View Full Solution & Concept Details 💡',
                    style: const TextStyle(
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
                  label: Text(
                    strings.retryQuestion,
                    style: const TextStyle(
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
                const SizedBox(height: 10),

                // 4b. Action: Back to Question List
                ElevatedButton.icon(
                  onPressed: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: Text(
                    isHindi ? 'प्रश्नावली पर वापस जाएं 📋' : 'Back to Question List 📋',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 5. Scratchpad Callout Button
              OutlinedButton.icon(
                icon: const Icon(Icons.draw_rounded, size: 20),
                label: Text(strings.openScratchpad),
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
                        size: 19,
                        color: const Color(0xFFD97706),
                      ),
                      label: Text(
                        _showHint ? strings.hideHint : strings.needAHint,
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _showHint = !_showHint);
                      },
                    ),
                  ),
                  if (options.length >= 3)
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(
                          _eliminatedIndices.isNotEmpty ? Icons.check_circle_rounded : Icons.highlight_off_rounded,
                          size: 19,
                          color: _eliminatedIndices.isNotEmpty ? const Color(0xFF10B981) : const Color(0xFF0D9488),
                        ),
                        label: Text(
                          _eliminatedIndices.isNotEmpty ? '50:50 Used' : '50:50 Clue 🎯',
                          style: TextStyle(
                            color: _eliminatedIndices.isNotEmpty ? const Color(0xFF059669) : const Color(0xFF0F766E),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: (_isAnswered || _eliminatedIndices.isNotEmpty)
                            ? null
                            : () {
                                AdService().showRewardedAd(
                                  onUserEarnedReward: (reward) {
                                    final expected = _currentActivity.validationRule.expectedAnswer?.toString().trim().toLowerCase();
                                    final wrongIndices = <int>[];
                                    for (int i = 0; i < rawOptions.length; i++) {
                                      if (rawOptions[i].trim().toLowerCase() != expected) {
                                        wrongIndices.add(i);
                                      }
                                    }
                                    wrongIndices.shuffle();
                                    setState(() {
                                      _eliminatedIndices.addAll(wrongIndices.take(2));
                                    });
                                    AudioService.instance.playSfx(CurioSfx.starAward);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          LocalStorageService.instance.isClosedTester || LocalStorageService.instance.isPremiumUser
                                              ? '⭐ VIP Lifeline: 2 incorrect options eliminated for free!'
                                              : '🎯 50:50 Lifeline: 2 incorrect options eliminated!',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                );
                              },
                      ),
                    ),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.auto_stories_rounded,
                        size: 19,
                        color: Color(0xFF4F46E5),
                      ),
                      label: Text(
                        strings.fullExplanation,
                        style: const TextStyle(
                          color: Color(0xFF4338CA),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
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
                      isHindi: isHindi,
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
                                children: [
                                  const Text('💡', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    strings.pedagogicalHint,
                                    style: const TextStyle(
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
                              children: [
                                Text(
                                  isHindi
                                      ? 'अटक गए हैं? चरणबद्ध समाधान देखें'
                                      : 'Still stuck? View step-by-step solution',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4338CA),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF4338CA)),
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

  Widget _buildBottomActionBar(bool isLast, AppLocalizations strings, bool isHindi) {
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
            // 1. Previous Question OR Back to Questions Button
            OutlinedButton.icon(
              onPressed: (_isAnswered || canGoPrev)
                  ? () {
                      AudioService.instance.playSfx(CurioSfx.click);
                      if (_isAnswered) {
                        Navigator.of(context).pop();
                      } else if (canGoPrev) {
                        _goToPreviousQuestion();
                      }
                    }
                  : null,
              icon: Icon(
                _isAnswered ? Icons.list_alt_rounded : Icons.arrow_back_rounded,
                size: 18,
                color: (_isAnswered || canGoPrev) ? const Color(0xFF334155) : const Color(0xFF94A3B8),
              ),
              label: Text(
                _isAnswered
                    ? (isHindi ? 'प्रश्नावली 📋' : 'Questions 📋')
                    : strings.prevQuestion,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: (_isAnswered || canGoPrev) ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                backgroundColor: (_isAnswered || canGoPrev) ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
                side: BorderSide(
                  color: (_isAnswered || canGoPrev) ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
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
                label: Text(
                  strings.skipQuestion,
                  style: const TextStyle(
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
                      ? (isLast ? strings.nextQuestionNew : strings.nextQuestion)
                      : (isHindi ? 'अगला ➔' : 'Next ➔'),
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
