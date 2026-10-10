import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/activity_model.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/services/concept_solution_helper.dart';

/// Modal bottom sheet displaying complete step-by-step solution,
/// underlying mathematical concept, formulas, rules, and exam pro-tips
/// with full English & Hindi bilingual localization.
class QuestionSolutionSheet extends ConsumerStatefulWidget {
  final Activity activity;
  final Chapter? chapter;

  const QuestionSolutionSheet({
    super.key,
    required this.activity,
    this.chapter,
  });

  static Future<void> show(BuildContext context, {required Activity activity, Chapter? chapter}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuestionSolutionSheet(activity: activity, chapter: chapter),
    );
  }

  @override
  ConsumerState<QuestionSolutionSheet> createState() => _QuestionSolutionSheetState();
}

class _QuestionSolutionSheetState extends ConsumerState<QuestionSolutionSheet> {
  bool _isSpeaking = false;

  void _toggleReadAloud(ConceptSolutionDetails details) {
    if (_isSpeaking) {
      AudioService.instance.stopAudio();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      AudioService.instance.playSfx(CurioSfx.click);
      AudioService.instance.speakPrompt(details.speechNarration);
    }
  }

  @override
  void dispose() {
    if (_isSpeaking) {
      AudioService.instance.stopAudio();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    final details = ConceptSolutionHelper.instance.getDetails(
      widget.activity,
      chapter: widget.chapter,
      isHindi: isHindi,
    );

    return Container(
      height: mediaQuery.size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    details.visualIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.fullExplanation,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        details.conceptTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: Icon(_isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded),
                  tooltip: _isSpeaking ? 'Stop Audio' : strings.readConceptAloud,
                  onPressed: () => _toggleReadAloud(details),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Question Recap
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'प्रश्न (QUESTION)' : 'QUESTION',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          details.questionText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Correct Answer Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi ? 'सही उत्तर (CORRECT ANSWER)' : 'CORRECT ANSWER',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                details.correctAnswer,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14532D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Step-by-Step Mathematical Working
                  if (details.steps.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.format_list_numbered_rounded, size: 20, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Text(
                          strings.stepByStepWorking,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: List.generate(details.steps.length, (idx) {
                          final stepText = details.steps[idx];
                          final isLast = idx == details.steps.length - 1;

                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF93C5FD)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${idx + 1}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    stepText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                                      color: isLast ? const Color(0xFF15803D) : const Color(0xFF334155),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // 4. Concept Detail Card
                  Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, size: 20, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 8),
                      Text(
                        strings.coreConcept,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.conceptTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5B21B6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          details.conceptDetail,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4C1D95),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. Golden Rules & Formulas
                  if (details.formulasAndRules.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.rule_rounded, size: 20, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Text(
                          strings.goldenRules,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        children: details.formulasAndRules.map((rule) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('⭐ ', style: TextStyle(fontSize: 14)),
                                Expanded(
                                  child: Text(
                                    rule,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // 6. Pro Tip / Pitfall
                  if (details.proTip.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🎯 ', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              details.proTip,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E40AF),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Got it button
                  ElevatedButton(
                    onPressed: () {
                      AudioService.instance.playSfx(CurioSfx.click);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      strings.understoodClose,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
