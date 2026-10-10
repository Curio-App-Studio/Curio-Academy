import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/models/student_profile.dart';
import '../../../../data/services/concept_reading_service.dart';
import 'textbook_reader_screen.dart';

/// Kid-friendly Interactive Detailed Concept Lesson & Study Guide Sheet
/// Provides exhaustive, syllabus-aligned concept definitions, formulas,
/// worked examples, common exam traps, and audio read-aloud across all grades.
class ConceptLessonSheet extends ConsumerStatefulWidget {
  final Chapter chapter;
  final StudentProfile profile;
  final VoidCallback onStartPractice;

  const ConceptLessonSheet({
    super.key,
    required this.chapter,
    required this.profile,
    required this.onStartPractice,
  });

  static void show(
    BuildContext context, {
    required Chapter chapter,
    required StudentProfile profile,
    required VoidCallback onStartPractice,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConceptLessonSheet(
        chapter: chapter,
        profile: profile,
        onStartPractice: onStartPractice,
      ),
    );
  }

  @override
  ConsumerState<ConceptLessonSheet> createState() => _ConceptLessonSheetState();
}

class _ConceptLessonSheetState extends ConsumerState<ConceptLessonSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChapterStudyMaterial _studyMaterial;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _studyMaterial = ConceptReadingService.instance.getStudyMaterial(widget.chapter);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _speakText(String text, {bool? isHindi}) {
    AudioService.instance.playSfx(CurioSfx.click);
    final hindi = isHindi ?? (ref.read(appLanguageProvider) == AppLanguage.hindi);
    AudioService.instance.speakPrompt(text, isHindi: hindi);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    final title = isHindi ? _studyMaterial.hindiTitle : _studyMaterial.title;
    final overview = isHindi ? _studyMaterial.hindiOverview : _studyMaterial.overview;

    return Container(
      height: size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // 2. Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECE5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF7B25).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _studyMaterial.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.profile.board.shortCode} • ${widget.chapter.grade}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isHindi ? 'अध्याय ${widget.chapter.chapterNumber}' : 'Ch ${widget.chapter.chapterNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final fullNarration = isHindi
                        ? 'अध्याय ${widget.chapter.chapterNumber}: $title। $overview'
                        : 'Chapter ${widget.chapter.chapterNumber}: ${_studyMaterial.title}. $overview';
                    _speakText(fullNarration);
                  },
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFF7B25), size: 26),
                  tooltip: strings.readConceptAloud,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 2.5 Digital Textbook Reader Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                AudioService.instance.playSfx(CurioSfx.click);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TextbookReaderScreen(
                      chapter: widget.chapter,
                      profile: widget.profile,
                      onStartPractice: () {
                        Navigator.of(context).pop();
                        widget.onStartPractice();
                      },
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFFD97706), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? 'सम्पूर्ण डिजिटल पाठ्यपुस्तक (NCERT / ICSE)' : 'Complete Digital Textbook (NCERT / ICSE)',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          Text(
                            isHindi ? 'विस्तृत सिद्धांत, सूत्र, और त्वरित जांच प्रश्न' : 'In-depth theory, formulas & interactive checks',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFD97706)),
                  ],
                ),
              ),
            ),
          ),

          // 3. Tab Bar Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: const Color(0xFFFF7B25),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: strings.definitionsTab),
                Tab(text: strings.rulesTab),
                Tab(text: strings.examplesTab),
                Tab(text: strings.examTrapsTab),
              ],
            ),
          ),

          const Divider(height: 12, thickness: 1, color: Color(0xFFF1F5F9)),

          // 4. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDefinitionsTab(isHindi, strings, overview),
                _buildRulesAndFormulasTab(isHindi, strings),
                _buildSolvedExamplesTab(isHindi, strings),
                _buildExamTrapsTab(isHindi, strings),
              ],
            ),
          ),

          // 5. Bottom Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(18, 10, 18, MediaQuery.of(context).padding.bottom + 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onStartPractice();
                    },
                    icon: const Text('⚡', style: TextStyle(fontSize: 18)),
                    label: Text(
                      isHindi
                          ? 'अध्याय ${widget.chapter.chapterNumber} का अभ्यास करें ⚡'
                          : 'Practice Chapter ${widget.chapter.chapterNumber} Now!',
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7B25),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: DEFINITIONS & CONCEPTS
  // ==========================================
  Widget _buildDefinitionsTab(bool isHindi, AppLocalizations strings, String overview) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        // Mascot Chapter Overview Banner (Tap to Speak)
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _speakText('${strings.curioSays}: $overview', isHindi: isHindi),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFDBA74).withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🦊', style: TextStyle(fontSize: 34)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            strings.curioSays,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.volume_up_rounded, color: Color(0xFFEA580C), size: 16),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        overview,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C2D12),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            const Text('📌', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isHindi ? 'आप क्या सीखेंगे: विस्तृत अवधारणाएँ एवं परिभाषाएं' : 'What You Will Learn: Detailed Concepts & Definitions',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Concept Definition Cards
        ..._studyMaterial.definitions.map((def) {
          final term = isHindi ? def.hindiTerm : def.term;
          final definition = isHindi ? def.hindiDefinition : def.definition;
          final keyPoints = isHindi ? def.hindiKeyPoints : def.keyPoints;
          final example = isHindi ? def.hindiExample : def.example;
          final trap = isHindi ? def.hindiCommonTrap : def.commonTrap;
          final realWorld = isHindi ? def.hindiRealWorldUse : def.realWorldUse;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Term & Audio Read Button (Tap to Speak)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _speakText('$term: $definition', isHindi: isHindi),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEDD5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.menu_book_rounded, color: Color(0xFFFF7B25), size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            term,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _speakText('$term: $definition', isHindi: isHindi),
                          icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFF7B25), size: 20),
                          tooltip: strings.listenDefinition,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Main Definition (Tap to Speak)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _speakText(definition, isHindi: isHindi),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            definition,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.volume_up_rounded, color: Color(0xFF94A3B8), size: 16),
                      ],
                    ),
                  ),
                ),

                // Formula / Pattern Pill if present (Tap to Speak)
                if (def.formula != null) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _speakText('${isHindi ? 'सूत्र: ' : 'Formula: '} ${def.formula!}', isHindi: isHindi),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Text('📐', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              def.formula!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.volume_up_rounded, color: Color(0xFFD97706), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                // Key Properties (Tap to Speak)
                if (keyPoints.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...keyPoints.map((point) => InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _speakText(point, isHindi: isHindi),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7B25))),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.volume_up_rounded, color: Color(0xFFCBD5E1), size: 14),
                            ],
                          ),
                        ),
                      )),
                ],

                // Concrete Example (Tap to Speak)
                if (example != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _speakText('${isHindi ? 'उदाहरण: ' : 'Example: '} $example', isHindi: isHindi),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${isHindi ? 'उदाहरण: ' : 'Example: '}$example',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.volume_up_rounded, color: Color(0xFF16A34A), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                // Common Trap (Watch Out! - Tap to Speak)
                if (trap != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _speakText('${strings.watchOut}: $trap', isHindi: isHindi),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚠️', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${strings.watchOut}: $trap',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.volume_up_rounded, color: Color(0xFFDC2626), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                // Real World Connection (Tap to Speak)
                if (realWorld != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _speakText('${isHindi ? 'वास्तविक जीवन में उपयोग: ' : 'Real-world application: '} $realWorld', isHindi: isHindi),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🌍', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${strings.whyItMatters}: $realWorld',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.volume_up_rounded, color: Color(0xFF64748B), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 2: RULES & FORMULAS REFERENCE
  // ==========================================
  Widget _buildRulesAndFormulasTab(bool isHindi, AppLocalizations strings) {
    final rules = isHindi ? _studyMaterial.hindiQuickRulesAndFormulas : _studyMaterial.quickRulesAndFormulas;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        Row(
          children: [
            const Text('📐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.formulasReference,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...rules.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final rule = entry.value;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _speakText('${isHindi ? 'नियम ' : 'Rule '}$idx: $rule', isHindi: isHindi),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _speakText(rule, isHindi: isHindi),
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFD97706), size: 18),
                    tooltip: strings.listenDefinition,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 3: WORKED EXAMPLES
  // ==========================================
  Widget _buildSolvedExamplesTab(bool isHindi, AppLocalizations strings) {
    if (_studyMaterial.solvedExamples.isEmpty) {
      return Center(
        child: Text(
          isHindi ? 'कोई उदाहरण उपलब्ध नहीं है।' : 'No worked examples available.',
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.stepByStepExample,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._studyMaterial.solvedExamples.map((ex) {
          final question = isHindi ? ex.hindiQuestion : ex.question;
          final steps = isHindi ? ex.hindiSteps : ex.steps;
          final answer = isHindi ? ex.hindiFinalAnswer : ex.finalAnswer;
          final highlight = isHindi ? ex.hindiConceptHighlight : ex.conceptHighlight;

          final fullExampleSpeech =
              '${isHindi ? 'प्रश्न: ' : 'Question: '} $question। ${isHindi ? 'चरणबद्ध हल: ' : 'Steps: '} ${steps.join(". ")}। ${isHindi ? 'अंतिम उत्तर: ' : 'Final Answer: '} $answer';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Concept Tag & Read Aloud Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        highlight,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _speakText(fullExampleSpeech, isHindi: isHindi),
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB), size: 20),
                      tooltip: strings.readConceptAloud,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Question (Tap to Speak)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _speakText('${isHindi ? 'प्रश्न: ' : 'Question: '} $question', isHindi: isHindi),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${isHindi ? 'प्रश्न: ' : 'Question: '}$question',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.volume_up_rounded, color: Color(0xFF93C5FD), size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  isHindi ? 'चरणबद्ध हल:' : 'Step-by-Step Working:',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 6),

                // Steps (Tap to Speak each step)
                ...steps.map((st) => InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _speakText(st, isHindi: isHindi),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right_rounded, color: Color(0xFF2563EB), size: 20),
                            Expanded(
                              child: Text(
                                st,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E40AF),
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.volume_up_rounded, color: Color(0xFFBFDBFE), size: 14),
                          ],
                        ),
                      ),
                    )),

                const SizedBox(height: 10),

                // Verified Answer (Tap to Speak)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _speakText('${isHindi ? 'अंतिम उत्तर: ' : 'Final Answer: '} $answer', isHindi: isHindi),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isHindi ? '✅ अंतिम उत्तर: ' : '✅ Final Answer: ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            answer,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.volume_up_rounded, color: Color(0xFF16A34A), size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 4: EXAM TRAPS & TIPS
  // ==========================================
  Widget _buildExamTrapsTab(bool isHindi, AppLocalizations strings) {
    final traps = isHindi ? _studyMaterial.hindiExamTraps : _studyMaterial.examTraps;
    final proTip = isHindi ? _studyMaterial.hindiProTip : _studyMaterial.proTip;
    final realWorld = isHindi ? _studyMaterial.hindiRealWorldConnection : _studyMaterial.realWorldConnection;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.commonMistakesTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...traps.map((tr) => InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _speakText('${strings.watchOut}: $tr', isHindi: isHindi),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🚨', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF991B1B),
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.volume_up_rounded, color: Color(0xFFDC2626), size: 16),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 16),

        // Mascot Pro-Tip (Tap to Speak)
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _speakText('${strings.proTip}: $proTip', isHindi: isHindi),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        strings.proTip,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, color: Color(0xFF16A34A), size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  proTip,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Real-World Story (Tap to Speak)
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _speakText('${strings.whyItMatters}: $realWorld', isHindi: isHindi),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        strings.whyItMatters,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, color: Color(0xFF64748B), size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  realWorld,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
