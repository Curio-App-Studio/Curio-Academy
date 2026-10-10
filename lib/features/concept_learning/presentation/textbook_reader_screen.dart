import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/services/concept_reading_service.dart';
import '../../../data/services/literature_reading_service.dart';
import '../../../services/ad_service.dart';
import '../../../shared/components/language_switch_button.dart';

/// Full-Screen Interactive Digital Textbook Reader
/// Comprehensive, syllabus-aligned pedagogical textbook experience
/// designed to replace physical textbooks from LKG to Class 8.
class TextbookReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  final StudentProfile profile;
  final VoidCallback onStartPractice;

  const TextbookReaderScreen({
    super.key,
    required this.chapter,
    required this.profile,
    required this.onStartPractice,
  });

  @override
  ConsumerState<TextbookReaderScreen> createState() => _TextbookReaderScreenState();
}

class _TextbookReaderScreenState extends ConsumerState<TextbookReaderScreen> {
  late ChapterStudyMaterial _studyMaterial;
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _revealedAnswers = {};
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _studyMaterial = ConceptReadingService.instance.getStudyMaterial(widget.chapter);
  }

  @override
  void dispose() {
    AudioService.instance.stopAudio();
    _scrollController.dispose();
    super.dispose();
  }

  void _speakText(String text) {
    AudioService.instance.speakPrompt(text);
  }

  void _toggleAnswer(int sectionIndex) {
    setState(() {
      _revealedAnswers[sectionIndex] = !(_revealedAnswers[sectionIndex] ?? false);
    });
    if (_revealedAnswers[sectionIndex] == true) {
      AudioService.instance.playSfx(CurioSfx.starAward);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final isHindi = strings.isHindi;
    final isLiterature = LiteratureReadingService.instance.isLiteratureChapter(widget.chapter);
    final litData = isLiterature ? LiteratureReadingService.instance.getReadingData(widget.chapter.chapterId) : null;
    final isPoem = litData?['isPoem'] as bool? ?? (_studyMaterial.icon == '📜');
    final author = litData?['author'] as String? ?? widget.chapter.author;
    final bookTitle = litData?['bookTitle'] as String? ?? widget.chapter.bookTitle;

    final displayTitle = isHindi ? _studyMaterial.hindiTitle : _studyMaterial.title;
    final displayOverview = isHindi ? _studyMaterial.hindiOverview : _studyMaterial.overview;
    final points = isHindi ? _studyMaterial.hindiPointsToRemember : _studyMaterial.pointsToRemember;
    final facts = isHindi ? _studyMaterial.hindiDidYouKnowFacts : _studyMaterial.didYouKnowFacts;
    final rules = isHindi ? _studyMaterial.hindiQuickRulesAndFormulas : _studyMaterial.quickRulesAndFormulas;
    final solvedList = _studyMaterial.solvedExamples;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5), // Warm pleasant reading paper tone
      appBar: AppBar(
        title: Text(
          isLiterature
              ? (isHindi ? '📖 संपूर्ण कहानी / कविता पठन' : '📖 Story & Literature Reader')
              : strings.textbookTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        actions: [
          // Font size decrement
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded, size: 20),
            tooltip: 'Smaller text',
            onPressed: () {
              if (_fontScale > 0.85) {
                setState(() => _fontScale -= 0.1);
              }
            },
          ),
          // Font size increment
          IconButton(
            icon: const Icon(Icons.text_increase_rounded, size: 22),
            tooltip: 'Larger text',
            onPressed: () {
              if (_fontScale < 1.35) {
                setState(() => _fontScale += 0.1);
              }
            },
          ),
          const LanguageSwitchButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Chapter Navigation Pill Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7B25).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.profile.board.shortCode} • ${widget.chapter.grade}${bookTitle != null ? ' • $bookTitle' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHindi ? 'अध्याय ${widget.chapter.chapterNumber}: $displayTitle' : 'Ch ${widget.chapter.chapterNumber}: $displayTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B)),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFF7B25), size: 22),
                    tooltip: strings.readConceptAloud,
                    onPressed: () {
                      final narration = isHindi
                          ? 'अध्याय ${widget.chapter.chapterNumber}: $displayTitle। $displayOverview'
                          : 'Chapter ${widget.chapter.chapterNumber}: $displayTitle. $displayOverview';
                      _speakText(narration);
                    },
                  ),
                ],
              ),
            ),

            // Main Reader Content
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                children: [
                  // 1. Chapter Title Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFEDD5)),
                              ),
                              child: Center(
                                child: Text(_studyMaterial.icon, style: const TextStyle(fontSize: 32)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLiterature
                                        ? (isPoem
                                            ? (isHindi ? 'कविता • अध्याय ${widget.chapter.chapterNumber}' : 'POEM • CHAPTER ${widget.chapter.chapterNumber}')
                                            : (isHindi ? 'कहानी • अध्याय ${widget.chapter.chapterNumber}' : 'STORY • CHAPTER ${widget.chapter.chapterNumber}'))
                                        : (isHindi ? 'अध्याय ${widget.chapter.chapterNumber}' : 'CHAPTER ${widget.chapter.chapterNumber}'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.orange.shade800,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayTitle,
                                    style: TextStyle(
                                      fontSize: 20 * _fontScale,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0F172A),
                                      height: 1.25,
                                    ),
                                  ),
                                  if (author != null && author.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      isHindi ? 'रचयिता: $author' : 'By $author',
                                      style: TextStyle(
                                        fontSize: 12.5 * _fontScale,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFC2410C),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Overview Text
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            displayOverview,
                            style: TextStyle(
                              fontSize: 14 * _fontScale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Structured Textbook Sections (1.1, 1.2, 1.3, 1.4)
                  if (_studyMaterial.textbookSections.isNotEmpty) ...[
                    ..._studyMaterial.textbookSections.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final section = entry.value;
                      final secTitle = isHindi ? section.hindiTitle : section.title;
                      final secContent = isHindi ? section.hindiContent : section.content;
                      final secTip = isHindi ? section.hindiCalloutTip : section.calloutTip;
                      final secQuestion = isHindi ? section.hindiQuickCheckQuestion : section.quickCheckQuestion;
                      final secAnswer = isHindi ? section.hindiQuickCheckAnswer : section.quickCheckAnswer;
                      final isAnswerRevealed = _revealedAnswers[idx] ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLiterature
                                        ? const Color(0xFFEA580C).withValues(alpha: 0.12)
                                        : const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isLiterature
                                        ? (isPoem
                                            ? (isHindi ? 'छंद ${section.sectionNumber}' : 'Stanza ${section.sectionNumber}')
                                            : (isHindi ? 'दृश्य ${section.sectionNumber}' : 'Scene ${section.sectionNumber}'))
                                        : '§ ${section.sectionNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isLiterature ? const Color(0xFFC2410C) : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    secTitle,
                                    style: TextStyle(
                                      fontSize: 16 * _fontScale,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB), size: 20),
                                  tooltip: 'Listen to section',
                                  onPressed: () => _speakText('$secTitle. $secContent'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Main Explanatory Content
                            Text(
                              secContent,
                              style: TextStyle(
                                fontSize: 14.5 * _fontScale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                                height: 1.55,
                              ),
                            ),

                            // Key Formula Callout if available
                            if (section.keyFormula != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('📐', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        section.keyFormula!,
                                        style: TextStyle(
                                          fontSize: 13.5 * _fontScale,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF92400E),
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Callout Tip if available
                            if (secTip != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('💡', style: TextStyle(fontSize: 15)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        secTip,
                                        style: TextStyle(
                                          fontSize: 13 * _fontScale,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF166534),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Interactive Quick Check Question
                            if (secQuestion != null && secAnswer != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('⚡', style: TextStyle(fontSize: 15)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            strings.quickCheckTitle,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF475569),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      secQuestion,
                                      style: TextStyle(
                                        fontSize: 13.5 * _fontScale,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (isAnswerRevealed) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFF86EFAC)),
                                        ),
                                        child: Text(
                                          '✅ $secAnswer',
                                          style: TextStyle(
                                            fontSize: 13 * _fontScale,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () => _toggleAnswer(idx),
                                        icon: Icon(
                                          isAnswerRevealed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                          size: 16,
                                          color: const Color(0xFF2563EB),
                                        ),
                                        label: Text(
                                          isAnswerRevealed ? strings.hideAnswer : strings.showAnswer,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],

                  // 2.5 Vocabulary & Glossary Section (Word Meanings / शब्दार्थ)
                  if (_studyMaterial.definitions.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🔤', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isLiterature
                                      ? (isHindi ? 'कठिन शब्दार्थ एवं शब्दावली' : 'Vocabulary & Word Meanings')
                                      : (isHindi ? 'प्रमुख शब्दावली एवं परिभाषाएं' : 'Key Concepts & Definitions'),
                                  style: TextStyle(
                                    fontSize: 16 * _fontScale,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._studyMaterial.definitions.map((def) {
                            final term = isHindi ? def.hindiTerm : def.term;
                            final meaning = isHindi ? def.hindiDefinition : def.definition;
                            final example = isHindi ? def.hindiExample : def.example;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          term,
                                          style: TextStyle(
                                            fontSize: 14.5 * _fontScale,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF3B82F6), size: 18),
                                        tooltip: 'Listen',
                                        onPressed: () => _speakText('$term: $meaning'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meaning,
                                    style: TextStyle(
                                      fontSize: 13.5 * _fontScale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569),
                                      height: 1.35,
                                    ),
                                  ),
                                  if (example != null && example.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      example,
                                      style: TextStyle(
                                        fontSize: 12.5 * _fontScale,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // 3. Points to Remember (NCERT/ICSE Summary Box)
                  if (points.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('📌', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isLiterature
                                      ? (isHindi ? 'कहानी का सार व नैतिक सीख' : 'Central Theme & Moral')
                                      : strings.pointsToRememberTitle,
                                  style: TextStyle(
                                    fontSize: 16 * _fontScale,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...points.map((pt) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('✓ ', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                                    Expanded(
                                      child: Text(
                                        pt,
                                        style: TextStyle(
                                          fontSize: 13.5 * _fontScale,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E40AF),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],

                  // 4. Did You Know? Facts Box
                  if (facts.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isLiterature
                                      ? (isHindi ? 'रचयिता परिचय व रोचक तथ्य' : 'Author Profile & Story Facts')
                                      : strings.didYouKnowTitle,
                                  style: TextStyle(
                                    fontSize: 16 * _fontScale,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...facts.map((fact) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('★ ', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w900)),
                                    Expanded(
                                      child: Text(
                                        fact,
                                        style: TextStyle(
                                          fontSize: 13.5 * _fontScale,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF78350F),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],

                  // 5. Formulas & Laws Cheat Sheet
                  if (rules.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('📐', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.formulasReference,
                                  style: TextStyle(
                                    fontSize: 16 * _fontScale,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...rules.asMap().entries.map((e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${e.key + 1}. ',
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: TextStyle(
                                          fontSize: 13 * _fontScale,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],

                  // 6. Solved Step-by-Step Textbook Problems
                  if (solvedList.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.stepByStepExample,
                                  style: TextStyle(
                                    fontSize: 16 * _fontScale,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...solvedList.map((ex) {
                            final q = isHindi ? ex.hindiQuestion : ex.question;
                            final st = isHindi ? ex.hindiSteps : ex.steps;
                            final ans = isHindi ? ex.hindiFinalAnswer : ex.finalAnswer;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${isHindi ? 'प्रश्न: ' : 'Q: '}$q',
                                    style: TextStyle(
                                      fontSize: 14 * _fontScale,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF166534),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...st.map((s) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Text(
                                          '• $s',
                                          style: TextStyle(
                                            fontSize: 13 * _fontScale,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF15803D),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: Text(
                                      '${isHindi ? 'अंतिम उत्तर: ' : 'Answer: '}$ans',
                                      style: TextStyle(
                                        fontSize: 13 * _fontScale,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF14532D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Bottom Action Bar to launch exercises
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isLiterature) {
                      AdService().recordStoryCompleted();
                    }
                    Navigator.of(context).pop();
                    widget.onStartPractice();
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
                  label: Text(
                    isLiterature
                        ? (isHindi ? 'अभ्यास व प्रश्नोत्तरी शुरू करें 🚀' : 'Start Story Quiz & Practice 🚀')
                        : strings.startPracticeNow,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7B25),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
