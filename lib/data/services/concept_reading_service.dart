import '../models/chapter_model.dart';
import '../../core/localization/hindi_curriculum_translator.dart';
import 'literature_reading_service.dart';

/// Represents a detailed, textbook-quality definition of a curriculum concept
class ConceptDefinition {
  final String term;
  final String hindiTerm;
  final String definition;
  final String hindiDefinition;
  final String? formula;
  final List<String> keyPoints;
  final List<String> hindiKeyPoints;
  final String? example;
  final String? hindiExample;
  final String? commonTrap;
  final String? hindiCommonTrap;
  final String? realWorldUse;
  final String? hindiRealWorldUse;

  const ConceptDefinition({
    required this.term,
    required this.hindiTerm,
    required this.definition,
    required this.hindiDefinition,
    this.formula,
    this.keyPoints = const [],
    this.hindiKeyPoints = const [],
    this.example,
    this.hindiExample,
    this.commonTrap,
    this.hindiCommonTrap,
    this.realWorldUse,
    this.hindiRealWorldUse,
  });
}

/// Represents a worked, step-by-step textbook example for reading
class SolvedReadingExample {
  final String question;
  final String hindiQuestion;
  final List<String> steps;
  final List<String> hindiSteps;
  final String finalAnswer;
  final String hindiFinalAnswer;
  final String conceptHighlight;
  final String hindiConceptHighlight;

  const SolvedReadingExample({
    required this.question,
    required this.hindiQuestion,
    required this.steps,
    required this.hindiSteps,
    required this.finalAnswer,
    required this.hindiFinalAnswer,
    required this.conceptHighlight,
    required this.hindiConceptHighlight,
  });
}

/// Represents an authentic textbook section with exhaustive theory,
/// formulas, real-world examples, callouts, and interactive quick-check questions.
class ChapterSection {
  final String sectionNumber;
  final String title;
  final String hindiTitle;
  final String content;
  final String hindiContent;
  final String? keyFormula;
  final String? calloutTip;
  final String? hindiCalloutTip;
  final String? quickCheckQuestion;
  final String? hindiQuickCheckQuestion;
  final String? quickCheckAnswer;
  final String? hindiQuickCheckAnswer;

  const ChapterSection({
    required this.sectionNumber,
    required this.title,
    required this.hindiTitle,
    required this.content,
    required this.hindiContent,
    this.keyFormula,
    this.calloutTip,
    this.hindiCalloutTip,
    this.quickCheckQuestion,
    this.hindiQuickCheckQuestion,
    this.quickCheckAnswer,
    this.hindiQuickCheckAnswer,
  });
}

/// Comprehensive, detailed chapter study material for reading and concept mastery
class ChapterStudyMaterial {
  final String chapterId;
  final String title;
  final String hindiTitle;
  final String grade;
  final String subjectId;
  final String icon;
  final String overview;
  final String hindiOverview;
  final List<ConceptDefinition> definitions;
  final List<String> quickRulesAndFormulas;
  final List<String> hindiQuickRulesAndFormulas;
  final List<SolvedReadingExample> solvedExamples;
  final List<String> examTraps;
  final List<String> hindiExamTraps;
  final String realWorldConnection;
  final String hindiRealWorldConnection;
  final String proTip;
  final String hindiProTip;
  final List<ChapterSection> textbookSections;
  final List<String> pointsToRemember;
  final List<String> hindiPointsToRemember;
  final List<String> didYouKnowFacts;
  final List<String> hindiDidYouKnowFacts;

  const ChapterStudyMaterial({
    required this.chapterId,
    required this.title,
    required this.hindiTitle,
    required this.grade,
    required this.subjectId,
    required this.icon,
    required this.overview,
    required this.hindiOverview,
    required this.definitions,
    required this.quickRulesAndFormulas,
    required this.hindiQuickRulesAndFormulas,
    required this.solvedExamples,
    required this.examTraps,
    required this.hindiExamTraps,
    required this.realWorldConnection,
    required this.hindiRealWorldConnection,
    required this.proTip,
    required this.hindiProTip,
    this.textbookSections = const [],
    this.pointsToRemember = const [],
    this.hindiPointsToRemember = const [],
    this.didYouKnowFacts = const [],
    this.hindiDidYouKnowFacts = const [],
  });
}

/// Comprehensive Knowledge & Reading Service for all grades (LKG to Class 8)
/// and subjects (Math & English), strictly aligned with CBSE/ICSE curricula.
class ConceptReadingService {
  static final ConceptReadingService instance = ConceptReadingService._internal();
  ConceptReadingService._internal();

  /// Builds or retrieves comprehensive, syllabus-aligned reading material for a chapter
  ChapterStudyMaterial getStudyMaterial(Chapter chapter) {
    final titleLower = chapter.title.toLowerCase();
    final gradeLower = chapter.grade.toLowerCase();
    final isEnglish = chapter.subjectId.toLowerCase() == 'english';
    final isScience = chapter.subjectId.toLowerCase() == 'science';
    final isEvs = chapter.subjectId.toLowerCase() == 'evs';
    final isHindi = chapter.subjectId.toLowerCase() == 'hindi';

    final hindiTitle = HindiCurriculumTranslator.translateChapterTitle(chapter.title);

    // 0. Check for specialized complete literature reading story/poem
    final litMaterial = LiteratureReadingService.instance.buildStudyMaterial(chapter);
    if (litMaterial != null) {
      return litMaterial;
    }

    // 1. Check for specialized curriculum domain builders
    if (isEnglish) {
      return _buildEnglishStudyMaterial(chapter, titleLower, gradeLower, hindiTitle);
    } else if (isScience) {
      return _buildScienceStudyMaterial(chapter, titleLower, gradeLower, hindiTitle);
    } else if (isEvs) {
      return _buildEvsStudyMaterial(chapter, titleLower, gradeLower, hindiTitle);
    } else if (isHindi) {
      return _buildHindiStudyMaterial(chapter, titleLower, gradeLower, hindiTitle);
    } else {
      return _buildMathStudyMaterial(chapter, titleLower, gradeLower, hindiTitle);
    }
  }

  // ==========================================
  // MATHEMATICS DETAILED STUDY MATERIAL
  // ==========================================
  ChapterStudyMaterial _buildMathStudyMaterial(
    Chapter chapter,
    String titleLower,
    String gradeLower,
    String hindiTitle,
  ) {
    final definitions = <ConceptDefinition>[];
    final solvedExamples = <SolvedReadingExample>[];
    final quickRules = <String>[];
    final hindiQuickRules = <String>[];
    final examTraps = <String>[];
    final hindiExamTraps = <String>[];

    // 1. Chapter-Specific Definitions from chapter.keyConcepts FIRST
    _populateChapterSpecificDefinitions(definitions, chapter, isEnglish: false);

    // 2. Supplementary Domain Definitions and Rules
    if (titleLower.contains('shape') ||
        titleLower.contains('geometry') ||
        (titleLower.contains('line') && !titleLower.contains('linear')) ||
        titleLower.contains('angle') ||
        titleLower.contains('triangle') ||
        titleLower.contains('quadrilateral') ||
        titleLower.contains('circle') ||
        titleLower.contains('area') ||
        titleLower.contains('perimeter') ||
        titleLower.contains('volume') ||
        titleLower.contains('mensuration')) {
      if (definitions.length < 4) _populateGeometryDefinitions(definitions, gradeLower, titleLower);
      _populateGeometryRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps, gradeLower);
    }
    // --- Domain 2: Numbers, Integers, Fractions, Decimals, Rational Numbers ---
    else if (titleLower.contains('number') ||
        titleLower.contains('integer') ||
        titleLower.contains('fraction') ||
        titleLower.contains('decimal') ||
        titleLower.contains('rational') ||
        titleLower.contains('factor') ||
        titleLower.contains('multiple') ||
        titleLower.contains('place value') ||
        titleLower.contains('exponent') ||
        titleLower.contains('power') ||
        titleLower.contains('set')) {
      if (definitions.length < 4) _populateNumberSystemDefinitions(definitions, gradeLower, titleLower);
      _populateNumberSystemRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps, gradeLower);
    }
    // --- Domain 3: Algebra & Equations ---
    else if (titleLower.contains('algebra') ||
        titleLower.contains('equation') ||
        titleLower.contains('variable') ||
        titleLower.contains('expression')) {
      if (definitions.length < 4) _populateAlgebraDefinitions(definitions, gradeLower, titleLower);
      _populateAlgebraRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps, gradeLower);
    }
    // --- Domain 4: Commercial Math, Ratios, Percentages, Money, Time, Measurement ---
    else if (titleLower.contains('ratio') ||
        titleLower.contains('proportion') ||
        titleLower.contains('percentage') ||
        titleLower.contains('profit') ||
        titleLower.contains('loss') ||
        titleLower.contains('interest') ||
        titleLower.contains('money') ||
        titleLower.contains('time') ||
        titleLower.contains('measurement') ||
        titleLower.contains('unitary') ||
        titleLower.contains('clock')) {
      if (definitions.length < 4) _populateCommercialMathDefinitions(definitions, gradeLower, titleLower);
      _populateCommercialMathRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps, gradeLower);
    }
    // --- Domain 5: Operations, Addition, Subtraction, Multiplication, Division ---
    else {
      if (definitions.length < 4) _populateOperationsDefinitions(definitions, gradeLower, titleLower);
      _populateOperationsRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps, gradeLower);
    }

    // Ensure at least 3 detailed definitions exist
    _ensureMinimumDefinitions(definitions, chapter, isEnglish: false);

    // Build rich solved examples (Chapter example first)
    _populateMathSolvedExamples(solvedExamples, chapter, gradeLower);

    // Combine rules: Chapter's curated rules MUST ALWAYS be first!
    final finalRules = <String>[];
    final finalHindiRules = <String>[];
    for (final r in chapter.rules) {
      if (!finalRules.contains(r)) {
        finalRules.add(r);
        finalHindiRules.add(HindiCurriculumTranslator.translateRule(r));
      }
    }
    for (int i = 0; i < quickRules.length; i++) {
      if (!finalRules.contains(quickRules[i])) {
        finalRules.add(quickRules[i]);
        finalHindiRules.add(hindiQuickRules[i]);
      }
    }

    // Combine exam traps: Mascot advice and Chapter-specific traps first!
    final finalTraps = <String>[];
    final finalHindiTraps = <String>[];
    if (chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty) {
      final advice = chapter.mascotAdvice!.trim();
      finalTraps.add('💡 Pro-Tip: $advice');
      finalHindiTraps.add('💡 स्मार्ट टिप: ${HindiCurriculumTranslator.translateHint(advice)}');
    }
    if (chapter.keyConcepts.isNotEmpty) {
      final trap = 'Common Mistake in ${chapter.title}: Do not confuse "${chapter.keyConcepts.first}" with similar terms. Always check definitions and boundary conditions carefully.';
      if (!finalTraps.contains('⚠️ $trap')) {
        finalTraps.add('⚠️ $trap');
        finalHindiTraps.add('⚠️ ${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} में सामान्य त्रुटि: "${HindiCurriculumTranslator.translateConcept(chapter.keyConcepts.first)}" को अन्य अवधारणाओं के साथ भ्रमित न करें।');
      }
    }
    for (int i = 0; i < examTraps.length; i++) {
      if (!finalTraps.contains(examTraps[i])) {
        finalTraps.add(examTraps[i]);
        finalHindiTraps.add(hindiExamTraps[i]);
      }
    }

    final textbookSections = <ChapterSection>[];
    final pointsToRemember = <String>[];
    final hindiPointsToRemember = <String>[];
    final didYouKnowFacts = <String>[];
    final hindiDidYouKnowFacts = <String>[];

    _populateMathTextbookSections(
      textbookSections,
      pointsToRemember,
      hindiPointsToRemember,
      didYouKnowFacts,
      hindiDidYouKnowFacts,
      chapter,
      titleLower,
      gradeLower,
    );

    return ChapterStudyMaterial(
      chapterId: chapter.chapterId,
      title: chapter.title,
      hindiTitle: hindiTitle,
      grade: chapter.grade,
      subjectId: chapter.subjectId,
      icon: chapter.icon,
      overview: chapter.description.isNotEmpty
          ? chapter.description
          : 'Detailed syllabus-aligned study notes covering core concepts, formal definitions, standard formulas, and common pitfalls for ${chapter.title}.',
      hindiOverview: HindiCurriculumTranslator.translateChapterDescription(
        chapter.description.isNotEmpty ? chapter.description : chapter.title,
        chapter.title,
      ),
      definitions: definitions,
      quickRulesAndFormulas: finalRules.isNotEmpty ? finalRules : chapter.rules,
      hindiQuickRulesAndFormulas: finalHindiRules.isNotEmpty
          ? finalHindiRules
          : chapter.rules.map((r) => HindiCurriculumTranslator.translateRule(r)).toList(),
      solvedExamples: solvedExamples,
      examTraps: finalTraps.isNotEmpty
          ? finalTraps
          : [
              'Read the question units carefully before calculating.',
              'Always double check your calculations using the inverse operation.',
            ],
      hindiExamTraps: finalHindiTraps.isNotEmpty
          ? finalHindiTraps
          : [
              'गणना करने से पहले प्रश्न में दी गई इकाइयों (Units) को ध्यान से देखें।',
              'विपरीत संक्रिया (Inverse Operation) का उपयोग करके अपने उत्तर की पुनः जाँच करें।',
            ],
      realWorldConnection: chapter.funFact ??
          'Mathematical principles from this chapter are used every day by architects, game developers, space scientists, and financial planners around the world!',
      hindiRealWorldConnection: chapter.funFact != null
          ? HindiCurriculumTranslator.translateStep(chapter.funFact!)
          : 'इस अध्याय के गणितीय सिद्धांतों का उपयोग आर्किटेक्ट, वीडियो गेम डेवलपर्स, अंतरिक्ष वैज्ञानिकों और वित्तीय योजनाकारों द्वारा हर दिन किया जाता है!',
      proTip: chapter.mascotAdvice ??
          'Write down every known variable with its units before applying the formula to avoid careless mistakes!',
      hindiProTip: chapter.mascotAdvice != null
          ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
          : 'लापरवाही से होने वाली गलतियों से बचने के लिए सूत्र लागू करने से पहले सभी ज्ञात मानों को इकाइयों सहित लिखें!',
      textbookSections: textbookSections,
      pointsToRemember: pointsToRemember,
      hindiPointsToRemember: hindiPointsToRemember,
      didYouKnowFacts: didYouKnowFacts,
      hindiDidYouKnowFacts: hindiDidYouKnowFacts,
    );
  }

  // ==========================================
  // ENGLISH DETAILED STUDY MATERIAL
  // ==========================================
  ChapterStudyMaterial _buildEnglishStudyMaterial(
    Chapter chapter,
    String titleLower,
    String gradeLower,
    String hindiTitle,
  ) {
    final definitions = <ConceptDefinition>[];
    final solvedExamples = <SolvedReadingExample>[];
    final quickRules = <String>[];
    final hindiQuickRules = <String>[];
    final examTraps = <String>[];
    final hindiExamTraps = <String>[];

    // 1. Chapter-Specific Definitions from chapter.keyConcepts FIRST
    _populateChapterSpecificDefinitions(definitions, chapter, isEnglish: true);

    // 2. Supplementary Domain Definitions and Rules
    if (titleLower.contains('phonic') ||
        titleLower.contains('alphabet') ||
        titleLower.contains('rhym') ||
        titleLower.contains('letter') ||
        titleLower.contains('sound') ||
        titleLower.contains('sight')) {
      if (definitions.length < 4) _populatePhonicsDefinitions(definitions, gradeLower, titleLower);
      _populatePhonicsRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps);
    }
    // --- Domain 2: Nouns, Pronouns, Articles (Parts of Speech) ---
    else if (titleLower.contains('noun') ||
        titleLower.contains('pronoun') ||
        titleLower.contains('article')) {
      if (definitions.length < 4) _populateNounsDefinitions(definitions, gradeLower, titleLower);
      _populateNounsRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps);
    }
    // --- Domain 3: Verbs, Tenses, Subject-Verb Agreement, Active/Passive ---
    else if (titleLower.contains('verb') ||
        titleLower.contains('tense') ||
        titleLower.contains('voice') ||
        titleLower.contains('agreement') ||
        titleLower.contains('modal')) {
      if (definitions.length < 4) _populateVerbsAndTensesDefinitions(definitions, gradeLower, titleLower);
      _populateVerbsRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps);
    }
    // --- Domain 4: Adjectives, Adverbs, Prepositions, Conjunctions ---
    else if (titleLower.contains('adjective') ||
        titleLower.contains('adverb') ||
        titleLower.contains('preposition') ||
        titleLower.contains('conjunction') ||
        titleLower.contains('speech') ||
        titleLower.contains('clause') ||
        titleLower.contains('sentence')) {
      if (definitions.length < 4) _populateSyntaxDefinitions(definitions, gradeLower, titleLower);
      _populateSyntaxRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps);
    }
    // --- Domain 5: Vocabulary, Comprehension, Writing, Punctuation ---
    else {
      if (definitions.length < 4) _populateGeneralEnglishDefinitions(definitions, gradeLower, titleLower);
      _populateGeneralEnglishRules(quickRules, hindiQuickRules, examTraps, hindiExamTraps);
    }

    // Ensure at least 3 detailed definitions exist
    _ensureMinimumDefinitions(definitions, chapter, isEnglish: true);

    // Build rich English solved examples (Chapter example first)
    _populateEnglishSolvedExamples(solvedExamples, chapter, gradeLower);

    // Combine rules: Chapter's curated rules MUST ALWAYS be first!
    final finalRules = <String>[];
    final finalHindiRules = <String>[];
    for (final r in chapter.rules) {
      if (!finalRules.contains(r)) {
        finalRules.add(r);
        finalHindiRules.add(HindiCurriculumTranslator.translateRule(r));
      }
    }
    for (int i = 0; i < quickRules.length; i++) {
      if (!finalRules.contains(quickRules[i])) {
        finalRules.add(quickRules[i]);
        finalHindiRules.add(hindiQuickRules[i]);
      }
    }

    // Combine exam traps: Mascot advice and Chapter-specific traps first!
    final finalTraps = <String>[];
    final finalHindiTraps = <String>[];
    if (chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty) {
      final advice = chapter.mascotAdvice!.trim();
      finalTraps.add('💡 Pro-Tip: $advice');
      finalHindiTraps.add('💡 स्मार्ट टिप: ${HindiCurriculumTranslator.translateHint(advice)}');
    }
    if (chapter.keyConcepts.isNotEmpty) {
      final trap = 'Common Mistake in ${chapter.title}: Pay special attention to "${chapter.keyConcepts.first}" usage. Always re-read the sentence to ensure clarity and grammatical agreement.';
      if (!finalTraps.contains('⚠️ $trap')) {
        finalTraps.add('⚠️ $trap');
        finalHindiTraps.add('⚠️ ${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} में सामान्य त्रुटि: "${HindiCurriculumTranslator.translateConcept(chapter.keyConcepts.first)}" के प्रयोग पर विशेष ध्यान दें।');
      }
    }
    for (int i = 0; i < examTraps.length; i++) {
      if (!finalTraps.contains(examTraps[i])) {
        finalTraps.add(examTraps[i]);
        finalHindiTraps.add(hindiExamTraps[i]);
      }
    }

    final textbookSections = <ChapterSection>[];
    final pointsToRemember = <String>[];
    final hindiPointsToRemember = <String>[];
    final didYouKnowFacts = <String>[];
    final hindiDidYouKnowFacts = <String>[];

    _populateEnglishTextbookSections(
      textbookSections,
      pointsToRemember,
      hindiPointsToRemember,
      didYouKnowFacts,
      hindiDidYouKnowFacts,
      chapter,
      titleLower,
      gradeLower,
    );

    return ChapterStudyMaterial(
      chapterId: chapter.chapterId,
      title: chapter.title,
      hindiTitle: hindiTitle,
      grade: chapter.grade,
      subjectId: chapter.subjectId,
      icon: chapter.icon,
      overview: chapter.description.isNotEmpty
          ? chapter.description
          : 'Detailed English grammar and language guide covering definitions, structural rules, sentence examples, and writing mechanics for ${chapter.title}.',
      hindiOverview: HindiCurriculumTranslator.translateChapterDescription(
        chapter.description.isNotEmpty ? chapter.description : chapter.title,
        chapter.title,
      ),
      definitions: definitions,
      quickRulesAndFormulas: finalRules.isNotEmpty ? finalRules : chapter.rules,
      hindiQuickRulesAndFormulas: finalHindiRules.isNotEmpty
          ? finalHindiRules
          : chapter.rules.map((r) => HindiCurriculumTranslator.translateRule(r)).toList(),
      solvedExamples: solvedExamples,
      examTraps: finalTraps.isNotEmpty
          ? finalTraps
          : [
              'Always identify the subject and tense before selecting the correct verb form.',
              'Punctuation changes the entire meaning of a sentence: use commas and full stops accurately.',
            ],
      hindiExamTraps: finalHindiTraps.isNotEmpty
          ? finalHindiTraps
          : [
              'सही क्रिया रूप चुनने से पहले हमेशा वाक्य के कर्ता (Subject) और काल (Tense) की पहचान करें।',
              'विराम चिह्न पूरे वाक्य का अर्थ बदल सकते हैं: पूर्ण विराम और अल्पविराम का सटीक प्रयोग करें।',
            ],
      realWorldConnection: chapter.funFact ??
          'Mastering clear grammar and vocabulary allows writers, journalists, diplomats, and authors to move millions of minds with the power of words!',
      hindiRealWorldConnection: chapter.funFact != null
          ? HindiCurriculumTranslator.translateStep(chapter.funFact!)
          : 'सटीक व्याकरण और समृद्ध शब्दावली लेखकों, पत्रकारों और वैज्ञानिकों को अपनी बात स्पष्टता से कहने की असीम शक्ति देती है!',
      proTip: chapter.mascotAdvice ??
          'Read the complete sentence aloud: your natural ear for rhythm will often catch grammatical mismatches!',
      hindiProTip: chapter.mascotAdvice != null
          ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
          : 'पूरे वाक्य को बोलकर पढ़ें: कान की स्वाभाविक लय व्याकरण संबंधी गलतियों को तुरंत पकड़ लेती है!',
      textbookSections: textbookSections,
      pointsToRemember: pointsToRemember,
      hindiPointsToRemember: hindiPointsToRemember,
      didYouKnowFacts: didYouKnowFacts,
      hindiDidYouKnowFacts: hindiDidYouKnowFacts,
    );
  }

  // ==========================================
  // SCIENCE DETAILED STUDY MATERIAL
  // ==========================================
  ChapterStudyMaterial _buildScienceStudyMaterial(
    Chapter chapter,
    String titleLower,
    String gradeLower,
    String hindiTitle,
  ) {
    final definitions = <ConceptDefinition>[];
    final solvedExamples = <SolvedReadingExample>[];

    // 1. Chapter-Specific Definitions from chapter.keyConcepts FIRST
    _populateChapterSpecificDefinitions(definitions, chapter, isEnglish: false);
    _ensureMinimumDefinitions(definitions, chapter, isEnglish: false);

    // 2. Solved Example from chapter
    if (chapter.exampleQuestion != null && chapter.exampleQuestion!.isNotEmpty) {
      solvedExamples.add(
        SolvedReadingExample(
          question: chapter.exampleQuestion!,
          hindiQuestion: HindiCurriculumTranslator.translateStep(chapter.exampleQuestion!),
          steps: [
            chapter.exampleExplanation ?? 'Observe scientific evidence and apply core natural laws.',
            'Verify cause and effect relationships through scientific reasoning.',
            'Conclude with the verified scientific law or concept application.',
          ],
          hindiSteps: [
            'वैज्ञानिक प्रमाणों का अवलोकन करें और प्राकृतिक नियमों को लागू करें।',
            'वैज्ञानिक तर्क के माध्यम से कारण और प्रभाव की पुष्टि करें।',
            'सत्यापित सिद्धांत के साथ निष्कर्ष निकालें।',
          ],
          finalAnswer: chapter.exampleAnswer ?? 'Scientific Principle Demonstrated',
          hindiFinalAnswer: chapter.exampleAnswer != null
              ? HindiCurriculumTranslator.translateStep(chapter.exampleAnswer!)
              : 'वैज्ञानिक सिद्धांत सिद्ध हुआ',
          conceptHighlight: chapter.title,
          hindiConceptHighlight: HindiCurriculumTranslator.translateChapterTitle(chapter.title),
        ),
      );
    } else {
      final sampleConcept = chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts.first : chapter.title;
      solvedExamples.add(
        SolvedReadingExample(
          question: 'How do we observe and verify $sampleConcept in real life?',
          hindiQuestion: 'हम वास्तविक जीवन में ${HindiCurriculumTranslator.translateConcept(sampleConcept)} का अवलोकन और सत्यापन कैसे करते हैं?',
          steps: [
            'State the scientific observation related to $sampleConcept.',
            'Apply natural laws and logical cause-and-effect reasoning.',
            'Conclude with the verified scientific property.',
          ],
          hindiSteps: [
            '${HindiCurriculumTranslator.translateConcept(sampleConcept)} से संबंधित वैज्ञानिक अवलोकन को पहचानें।',
            'प्राकृतिक नियमों और वैज्ञानिक तर्क को लागू करें।',
            'सत्यापित गुणधर्म के साथ निष्कर्ष निकालें।',
          ],
          finalAnswer: 'Scientific Property Demonstrated: $sampleConcept',
          hindiFinalAnswer: 'वैज्ञानिक सिद्धांत सिद्ध हुआ: ${HindiCurriculumTranslator.translateConcept(sampleConcept)}',
          conceptHighlight: sampleConcept,
          hindiConceptHighlight: HindiCurriculumTranslator.translateConcept(sampleConcept),
        ),
      );
    }

    // 3. Rules: from chapter
    final finalRules = <String>[];
    final finalHindiRules = <String>[];
    for (final r in chapter.rules) {
      if (!finalRules.contains(r)) {
        finalRules.add(r);
        finalHindiRules.add(HindiCurriculumTranslator.translateRule(r));
      }
    }

    // 4. Exam Traps: Mascot advice and key concept warning
    final finalTraps = <String>[];
    final finalHindiTraps = <String>[];
    if (chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty) {
      final advice = chapter.mascotAdvice!.trim();
      finalTraps.add('💡 Pro-Tip: $advice');
      finalHindiTraps.add('💡 स्मार्ट टिप: ${HindiCurriculumTranslator.translateHint(advice)}');
    }
    if (chapter.keyConcepts.isNotEmpty) {
      final trap = 'Common Mistake in ${chapter.title}: Do not confuse "${chapter.keyConcepts.first}" with similar biological or physical terms. Always observe evidence carefully.';
      finalTraps.add('⚠️ $trap');
      finalHindiTraps.add('⚠️ ${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} में सामान्य त्रुटि: "${HindiCurriculumTranslator.translateConcept(chapter.keyConcepts.first)}" को अन्य वैज्ञानिक शब्दों के साथ भ्रमित न करें।');
    }

    final textbookSections = <ChapterSection>[];
    final pointsToRemember = <String>[];
    final hindiPointsToRemember = <String>[];
    final didYouKnowFacts = <String>[];
    final hindiDidYouKnowFacts = <String>[];

    _populateMathTextbookSections(
      textbookSections,
      pointsToRemember,
      hindiPointsToRemember,
      didYouKnowFacts,
      hindiDidYouKnowFacts,
      chapter,
      titleLower,
      gradeLower,
    );

    return ChapterStudyMaterial(
      chapterId: chapter.chapterId,
      title: chapter.title,
      hindiTitle: hindiTitle,
      grade: chapter.grade,
      subjectId: chapter.subjectId,
      icon: chapter.icon,
      overview: chapter.description.isNotEmpty
          ? chapter.description
          : 'Detailed syllabus-aligned study notes covering core principles, natural laws, and experimental observations for ${chapter.title}.',
      hindiOverview: HindiCurriculumTranslator.translateChapterDescription(
        chapter.description.isNotEmpty ? chapter.description : chapter.title,
        chapter.title,
      ),
      definitions: definitions,
      quickRulesAndFormulas: finalRules.isNotEmpty ? finalRules : chapter.rules,
      hindiQuickRulesAndFormulas: finalHindiRules.isNotEmpty
          ? finalHindiRules
          : chapter.rules.map((r) => HindiCurriculumTranslator.translateRule(r)).toList(),
      solvedExamples: solvedExamples,
      examTraps: finalTraps.isNotEmpty
          ? finalTraps
          : [
              'Always state units and verify scientific terminology before concluding answers!',
              'Observe cause and effect carefully in experiment questions.',
            ],
      hindiExamTraps: finalHindiTraps.isNotEmpty
          ? finalHindiTraps
          : [
              'वैज्ञानिक प्रश्नों का उत्तर देते समय हमेशा सटीक शब्दावली का प्रयोग करें!',
              'प्रयोग आधारित प्रश्नों में कारण और प्रभाव की सावधानीपूर्वक जाँच करें।',
            ],
      realWorldConnection: chapter.funFact ??
          'Scientific principles from this chapter shape modern medical breakthroughs, clean energy, space missions, and everyday technology.',
      hindiRealWorldConnection: chapter.funFact != null
          ? HindiCurriculumTranslator.translateStep(chapter.funFact!)
          : 'इस अध्याय के वैज्ञानिक सिद्धांत आधुनिक चिकित्सा, स्वच्छ ऊर्जा और अंतरिक्ष अनुसंधान को दिशा देते हैं।',
      proTip: chapter.mascotAdvice ??
          'Always draw clear, labeled diagrams and verify experimental observations!',
      hindiProTip: chapter.mascotAdvice != null
          ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
          : 'हमेशा स्वच्छ, नामांकित चित्र बनाएं और वैज्ञानिक प्रयोगों के चरणों की पुष्टि करें!',
      textbookSections: textbookSections,
      pointsToRemember: pointsToRemember,
      hindiPointsToRemember: hindiPointsToRemember,
      didYouKnowFacts: didYouKnowFacts,
      hindiDidYouKnowFacts: hindiDidYouKnowFacts,
    );
  }

  // ==========================================
  // EVS (ENVIRONMENTAL STUDIES) STUDY MATERIAL
  // ==========================================
  ChapterStudyMaterial _buildEvsStudyMaterial(
    Chapter chapter,
    String titleLower,
    String gradeLower,
    String hindiTitle,
  ) {
    final definitions = <ConceptDefinition>[];
    final solvedExamples = <SolvedReadingExample>[];

    // 1. Chapter-Specific Definitions from chapter.keyConcepts
    _populateChapterSpecificDefinitions(definitions, chapter, isEnglish: false);
    _ensureMinimumDefinitions(definitions, chapter, isEnglish: false);

    // 2. Solved Example from chapter
    if (chapter.exampleQuestion != null && chapter.exampleQuestion!.isNotEmpty) {
      solvedExamples.add(
        SolvedReadingExample(
          question: chapter.exampleQuestion!,
          hindiQuestion: HindiCurriculumTranslator.translateStep(chapter.exampleQuestion!),
          steps: [
            chapter.exampleExplanation ?? 'Observe your environment and apply core ecological principles.',
            'Connect cause and effect in the natural world.',
            'Conclude with the verified environmental takeaway.',
          ],
          hindiSteps: [
            'अपने पर्यावरण का अवलोकन करें और पारिस्थितिक नियमों को समझें।',
            'प्राकृतिक दुनिया में कारण और प्रभाव का संबंध देखें।',
            'सत्यापित पर्यावरण निष्कर्ष के साथ समाप्त करें।',
          ],
          finalAnswer: chapter.exampleAnswer ?? 'Environmental Observation Verified',
          hindiFinalAnswer: chapter.exampleAnswer != null
              ? HindiCurriculumTranslator.translateStep(chapter.exampleAnswer!)
              : 'पर्यावरणीय अवलोकन सत्यापित',
          conceptHighlight: chapter.title,
          hindiConceptHighlight: HindiCurriculumTranslator.translateChapterTitle(chapter.title),
        ),
      );
    } else {
      final sampleConcept = chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts.first : chapter.title;
      solvedExamples.add(
        SolvedReadingExample(
          question: 'How does $sampleConcept help us understand our living world?',
          hindiQuestion: 'हम वास्तविक जीवन में ${HindiCurriculumTranslator.translateConcept(sampleConcept)} का क्या महत्व देखते हैं?',
          steps: [
            'Identify how $sampleConcept connects living things with their surroundings.',
            'Observe real-world examples in nature, family, or neighbourhood.',
            'Conclude with sustainable environmental practices.',
          ],
          hindiSteps: [
            'पहचानें कि ${HindiCurriculumTranslator.translateConcept(sampleConcept)} किस प्रकार पर्यावरण से जुड़ता है।',
            'प्रकृति, परिवार या पड़ोस में इसके वास्तविक उदाहरण देखें।',
            'पर्यावरण संरक्षण के अच्छे व्यवहार के साथ निष्कर्ष निकालें।',
          ],
          finalAnswer: 'Living Connection: $sampleConcept',
          hindiFinalAnswer: 'पर्यावरणीय संबंध: ${HindiCurriculumTranslator.translateConcept(sampleConcept)}',
          conceptHighlight: sampleConcept,
          hindiConceptHighlight: HindiCurriculumTranslator.translateConcept(sampleConcept),
        ),
      );
    }

    // 3. Rules: from chapter
    final finalRules = <String>[];
    final finalHindiRules = <String>[];
    for (final r in chapter.rules) {
      if (!finalRules.contains(r)) {
        finalRules.add(r);
        finalHindiRules.add(HindiCurriculumTranslator.translateRule(r));
      }
    }

    // 4. Traps & Mascot Advice
    final finalTraps = <String>[];
    final finalHindiTraps = <String>[];
    if (chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty) {
      final advice = chapter.mascotAdvice!.trim();
      finalTraps.add('💡 Nature Tip: $advice');
      finalHindiTraps.add('💡 प्रकृति टिप: ${HindiCurriculumTranslator.translateHint(advice)}');
    }
    if (chapter.keyConcepts.isNotEmpty) {
      final trap = 'Remember for ${chapter.title}: Observe how "${chapter.keyConcepts.first}" interrelates with living habits and environmental harmony.';
      finalTraps.add('🌿 $trap');
      finalHindiTraps.add('🌿 ${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के लिए याद रखें: "${HindiCurriculumTranslator.translateConcept(chapter.keyConcepts.first)}" का पर्यावरण और जीवन से गहरा संबंध है।');
    }

    final textbookSections = <ChapterSection>[];
    final pointsToRemember = <String>[];
    final hindiPointsToRemember = <String>[];
    final didYouKnowFacts = <String>[];
    final hindiDidYouKnowFacts = <String>[];

    textbookSections.addAll([
      ChapterSection(
        sectionNumber: '1.1',
        title: 'Exploring ${chapter.title} in Nature and Society',
        hindiTitle: 'प्रकृति और समाज में ${chapter.title}',
        content: chapter.description.isNotEmpty
            ? '${chapter.description} Environmental Studies (EVS) encourages curiosity about our living surroundings, fostering respect for living beings, family bonds, and the natural resources that sustain our planet.'
            : 'In this chapter, we explore how ${chapter.title} connects us with the world around us. Observing living organisms, natural cycles, and community systems deepens our appreciation for our shared environment.',
        hindiContent: '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} हमें अपने आस-पास के सजीव जगत, परिवार और प्रकृति के प्रति संवेदनशील बनाता है। पर्यावरण का ध्यान रखना हमारी साझी जिम्मेदारी है।',
        calloutTip: 'Always be kind and observant: nature teaches us something new every day!',
        hindiCalloutTip: 'हमेशा प्रकृति का सम्मान करें और पशु-पक्षियों के प्रति दयालु रहें!',
        quickCheckQuestion: 'Why is it important to learn about ${chapter.title}?',
        hindiQuickCheckQuestion: '${chapter.title} के बारे में सीखना क्यों आवश्यक है?',
        quickCheckAnswer: 'It teaches us to live harmoniously with nature and our community.',
        hindiQuickCheckAnswer: 'यह हमें प्रकृति और समाज के साथ मिलकर रहना सिखाता है।',
      ),
      ChapterSection(
        sectionNumber: '1.2',
        title: 'Key Observations & Good Habits',
        hindiTitle: 'महत्वपूर्ण अवलोकन एवं अच्छी आदतें',
        content: chapter.rules.isNotEmpty
            ? chapter.rules.join(' ')
            : 'Living things thrive when they have clean air, pure water, healthy nutrition, and a peaceful environment. Practicing good hygiene and conserving natural resources keeps our community healthy.',
        hindiContent: 'स्वच्छ हवा, शुद्ध पानी और उचित पोषण सभी जीवों के लिए आवश्यक हैं। स्वच्छता और प्राकृतिक संसाधनों का संरक्षण ही स्वस्थ जीवन की कुंजी है।',
        keyFormula: chapter.rules.isNotEmpty ? chapter.rules.first : 'Care for Nature = Healthy Planet for All',
        calloutTip: 'Simple habits like turning off leaking taps and not littering make a huge positive difference!',
        hindiCalloutTip: 'नल बंद करना और कचरा कूड़ेदान में डालना जैसी छोटी आदतें बड़ा बदलाव लाती हैं!',
        quickCheckQuestion: 'What is one easy way you can protect your immediate environment?',
        hindiQuickCheckQuestion: 'आप अपने आस-पास के पर्यावरण की रक्षा कैसे कर सकते हैं?',
        quickCheckAnswer: 'By saving water, disposing of waste properly, and nurturing plants.',
        hindiQuickCheckAnswer: 'पानी बचाकर, कचरा सही जगह फेंककर और पेड़-पौधों की देखभाल करके।',
      ),
      ChapterSection(
        sectionNumber: '1.3',
        title: 'Real-World Connection & Wonder Fact',
        hindiTitle: 'वास्तविक जीवन और रोचक तथ्य',
        content: chapter.funFact != null && chapter.funFact!.isNotEmpty
            ? 'Did you know? ${chapter.funFact!} Every element of nature is interconnected in a delicate web of life, where plants, animals, and humans depend on each other.'
            : 'Nature is full of wondrous interconnections. From tiny ants and green leaves to giant rivers and blue skies, every part plays an essential role.',
        hindiContent: chapter.funFact != null
            ? '${HindiCurriculumTranslator.translateFact(chapter.funFact!)} प्रकृति में सभी जीव एक-दूसरे से जुड़े हुए हैं।'
            : 'प्रकृति में हर छोटे और बड़े जीव का अपना महत्वपूर्ण स्थान है।',
        calloutTip: chapter.mascotAdvice ?? 'Stay curious and explore your surroundings safely!',
        hindiCalloutTip: chapter.mascotAdvice != null
            ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
            : 'हमेशा जिज्ञासु रहें और सुरक्षित रूप से नया सीखें!',
        quickCheckQuestion: chapter.exampleQuestion ?? 'How are plants, animals, and humans connected?',
        hindiQuickCheckQuestion: chapter.exampleQuestion != null
            ? HindiCurriculumTranslator.translateStep(chapter.exampleQuestion!)
            : 'पौधे, जानवर और मनुष्य आपस में कैसे जुड़े हैं?',
        quickCheckAnswer: chapter.exampleAnswer ?? 'They depend on each other for food, oxygen, and shelter.',
        hindiQuickCheckAnswer: chapter.exampleAnswer != null
            ? HindiCurriculumTranslator.translateStep(chapter.exampleAnswer!)
            : 'वे भोजन, ऑक्सीजन और आश्रय के लिए एक-दूसरे पर निर्भर हैं।',
      ),
    ]);

    pointsToRemember.addAll([
      'All living organisms depend on fresh air, clean water, and fertile soil.',
      'Treat all animals and plants with empathy, kindness, and respect.',
      'Daily personal hygiene and regular exercise keep our body strong and energetic.',
      'Reduce, reuse, and recycle to keep our neighbourhood clean and beautiful.',
    ]);

    hindiPointsToRemember.addAll([
      'सभी सजीव शुद्ध हवा, स्वच्छ जल और उपजाऊ मिट्टी पर निर्भर हैं।',
      'सभी पशु-पक्षियों और पेड़-पौधों के साथ दया और आदर का व्यवहार करें।',
      'दैनिक स्वच्छता और व्यायाम हमारे शरीर को स्वस्थ और चुस्त रखते हैं।',
      'कचरा कम करें और पुनर्चक्रण द्वारा अपने आस-पास को सुंदर बनाए रखें।',
    ]);

    if (chapter.funFact != null && chapter.funFact!.isNotEmpty) {
      didYouKnowFacts.add(chapter.funFact!);
      hindiDidYouKnowFacts.add(HindiCurriculumTranslator.translateFact(chapter.funFact!));
    }
    didYouKnowFacts.add('Earth is the only known planet in our solar system that supports abundant, diverse living ecosystems!');
    hindiDidYouKnowFacts.add('पृथ्वी हमारे सौरमंडल का एकमात्र ज्ञात ग्रह है जहाँ जीवन और सजीव जगत पनपता है!');

    return ChapterStudyMaterial(
      chapterId: chapter.chapterId,
      title: chapter.title,
      hindiTitle: hindiTitle,
      grade: chapter.grade,
      subjectId: chapter.subjectId,
      icon: chapter.icon,
      overview: chapter.description.isNotEmpty
          ? chapter.description
          : 'Syllabus-aligned EVS study material covering nature, society, body awareness, and living world for ${chapter.title}.',
      hindiOverview: HindiCurriculumTranslator.translateChapterDescription(
        chapter.description.isNotEmpty ? chapter.description : chapter.title,
        chapter.title,
      ),
      definitions: definitions,
      quickRulesAndFormulas: finalRules.isNotEmpty ? finalRules : chapter.rules,
      hindiQuickRulesAndFormulas: finalHindiRules.isNotEmpty
          ? finalHindiRules
          : chapter.rules.map((r) => HindiCurriculumTranslator.translateRule(r)).toList(),
      solvedExamples: solvedExamples,
      examTraps: finalTraps.isNotEmpty
          ? finalTraps
          : [
              'Observe cause and effect carefully in environmental questions!',
              'Remember that all living beings need clean natural resources.',
            ],
      hindiExamTraps: finalHindiTraps.isNotEmpty
          ? finalHindiTraps
          : [
              'पर्यावरणीय प्रश्नों में कारण और प्रभाव को ध्यान से समझें!',
              'याद रखें कि सभी सजीवों को स्वच्छ प्राकृतिक संसाधनों की आवश्यकता होती है।',
            ],
      realWorldConnection: 'Everything we learn in EVS is directly visible in our daily home, school, parks, and seasonal changes!',
      hindiRealWorldConnection: 'ईवीएस में हम जो कुछ भी सीखते हैं, वह हमारे घर, स्कूल, बगीचों और बदलते मौसमों में साफ़ दिखाई देता है!',
      proTip: chapter.mascotAdvice ?? 'Share your love for nature with your family and friends!',
      hindiProTip: chapter.mascotAdvice != null
          ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
          : 'प्रकृति के प्रति अपना प्यार अपने परिवार और दोस्तों के साथ साझा करें!',
      textbookSections: textbookSections,
      pointsToRemember: pointsToRemember,
      hindiPointsToRemember: hindiPointsToRemember,
      didYouKnowFacts: didYouKnowFacts,
      hindiDidYouKnowFacts: hindiDidYouKnowFacts,
    );
  }

  // ==========================================
  // HINDI CURRICULUM STUDY MATERIAL
  // ==========================================
  ChapterStudyMaterial _buildHindiStudyMaterial(
    Chapter chapter,
    String titleLower,
    String gradeLower,
    String hindiTitle,
  ) {
    final definitions = <ConceptDefinition>[];
    final solvedExamples = <SolvedReadingExample>[];

    for (final concept in chapter.keyConcepts) {
      definitions.add(
        ConceptDefinition(
          term: concept,
          hindiTerm: concept,
          definition: '$concept - इस अध्याय की एक मुख्य अवधारणा एवं महत्वपूर्ण अध्ययन बिंदु है।',
          hindiDefinition: '$concept - इस अध्याय की एक मुख्य अवधारणा एवं महत्वपूर्ण अध्ययन बिंदु है।',
          keyPoints: const [
            'उच्चारण और लिखावट पर विशेष ध्यान दें।',
            'दैनिक बोलचाल एवं वाक्यों में इसका प्रयोग करें।',
          ],
          hindiKeyPoints: const [
            'उच्चारण और लिखावट पर विशेष ध्यान दें।',
            'दैनिक बोलचाल एवं वाक्यों में इसका प्रयोग करें।',
          ],
          example: chapter.rules.isNotEmpty ? chapter.rules.first : null,
          hindiExample: chapter.rules.isNotEmpty ? chapter.rules.first : null,
          realWorldUse: 'हिन्दी भाषा को शुद्ध, सुंदर और स्पष्ट रूप से लिखना व बोलना।',
          hindiRealWorldUse: 'हिन्दी भाषा को शुद्ध, सुंदर और स्पष्ट रूप से लिखना व बोलना।',
        ),
      );
    }

    if (definitions.isEmpty) {
      definitions.add(
        ConceptDefinition(
          term: chapter.title,
          hindiTerm: chapter.title,
          definition: chapter.description.isNotEmpty ? chapter.description : 'हिन्दी भाषा और व्याकरण की मूलभूत अवधारणा।',
          hindiDefinition: chapter.description.isNotEmpty ? chapter.description : 'हिन्दी भाषा और व्याकरण की मूलभूत अवधारणा।',
          keyPoints: const ['शुद्ध वाचन करें।', 'सही वर्तनी का ध्यान रखें।'],
          hindiKeyPoints: const ['शुद्ध वाचन करें।', 'सही वर्तनी का ध्यान रखें।'],
        ),
      );
    }

    if (chapter.exampleQuestion != null && chapter.exampleQuestion!.isNotEmpty) {
      solvedExamples.add(
        SolvedReadingExample(
          question: chapter.exampleQuestion!,
          hindiQuestion: chapter.exampleQuestion!,
          steps: [
            chapter.exampleExplanation ?? 'प्रश्न को ध्यानपूर्वक पढ़ें और सही उत्तर पहचानें।',
            'वर्ण, शब्द या व्याकरण के नियम का सही प्रयोग समझें।',
            'शुद्ध और सटीक उत्तर प्रस्तुत करें।',
          ],
          hindiSteps: [
            chapter.exampleExplanation ?? 'प्रश्न को ध्यानपूर्वक पढ़ें और सही उत्तर पहचानें।',
            'वर्ण, शब्द या व्याकरण के नियम का सही प्रयोग समझें।',
            'शुद्ध और सटीक उत्तर प्रस्तुत करें।',
          ],
          finalAnswer: chapter.exampleAnswer ?? 'सटीक उत्तर',
          hindiFinalAnswer: chapter.exampleAnswer ?? 'सटीक उत्तर',
          conceptHighlight: chapter.title,
          hindiConceptHighlight: chapter.title,
        ),
      );
    }

    final finalRules = <String>[...chapter.rules];
    if (finalRules.isEmpty) {
      finalRules.addAll([
        'प्रत्येक वर्ण और मात्रा का उच्चारण शुद्ध रखें।',
        'वाक्य रचना में व्याकरण के नियमों का पालन करें।',
      ]);
    }

    final textbookSections = <ChapterSection>[
      ChapterSection(
        sectionNumber: '1.1',
        title: 'अध्याय परिचय व अवधारणा (Introduction)',
        hindiTitle: 'अध्याय परिचय व अवधारणा',
        content: chapter.description.isNotEmpty
            ? chapter.description
            : 'इस अध्याय में हम ${chapter.title} के बारे में विस्तार से सीखेंगे और अभ्यास करेंगे।',
        hindiContent: chapter.description.isNotEmpty
            ? chapter.description
            : 'इस अध्याय में हम ${chapter.title} के बारे में विस्तार से सीखेंगे और अभ्यास करेंगे।',
        keyFormula: chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts.join(' • ') : null,
        calloutTip: 'प्रतिदिन शुद्ध उच्चारण के साथ हिन्दी पढ़ने का अभ्यास करें!',
        hindiCalloutTip: 'प्रतिदिन शुद्ध उच्चारण के साथ हिन्दी पढ़ने का अभ्यास करें!',
        quickCheckQuestion: chapter.exampleQuestion ?? 'इस अध्याय का मुख्य विषय क्या है?',
        hindiQuickCheckQuestion: chapter.exampleQuestion ?? 'इस अध्याय का मुख्य विषय क्या है?',
        quickCheckAnswer: chapter.exampleAnswer ?? chapter.title,
        hindiQuickCheckAnswer: chapter.exampleAnswer ?? chapter.title,
      ),
      ChapterSection(
        sectionNumber: '1.2',
        title: 'मुख्य नियम व भाषा-ज्ञान (Rules & Knowledge)',
        hindiTitle: 'मुख्य नियम व भाषा-ज्ञान',
        content: finalRules.join(' '),
        hindiContent: finalRules.join(' '),
        keyFormula: finalRules.first,
        calloutTip: 'मात्राओं और वर्णों के भेद को ध्यान से पहचानें!',
        hindiCalloutTip: 'मात्राओं और वर्णों के भेद को ध्यान से पहचानें!',
        quickCheckQuestion: 'सुंदर लिखावट के लिए क्या आवश्यक है?',
        hindiQuickCheckQuestion: 'सुंदर लिखावट के लिए क्या आवश्यक है?',
        quickCheckAnswer: 'नियमित अभ्यास और अक्षरों की सही बनावट।',
        hindiQuickCheckAnswer: 'नियमित अभ्यास और अक्षरों की सही बनावट।',
      ),
      ChapterSection(
        sectionNumber: '1.3',
        title: 'ज्ञानवर्धक तथ्य व गुरु मंत्र (Curio Wisdom)',
        hindiTitle: 'ज्ञानवर्धक तथ्य व गुरु मंत्र',
        content: chapter.funFact != null && chapter.funFact!.isNotEmpty
            ? chapter.funFact!
            : 'हिन्दी भारत की प्रमुख राजभाषा है और देवनागरी लिपि वैज्ञानिक दृष्टि से अत्यंत समृद्ध है।',
        hindiContent: chapter.funFact != null && chapter.funFact!.isNotEmpty
            ? chapter.funFact!
            : 'हिन्दी भारत की प्रमुख राजभाषा है और देवनागरी लिपि वैज्ञानिक दृष्टि से अत्यंत समृद्ध है।',
        calloutTip: chapter.mascotAdvice ?? 'हमेशा नया सीखने के लिए उत्साहित रहें!',
        hindiCalloutTip: chapter.mascotAdvice ?? 'हमेशा नया सीखने के लिए उत्साहित रहें!',
        quickCheckQuestion: 'हिन्दी किस लिपि में लिखी जाती है?',
        hindiQuickCheckQuestion: 'हिन्दी किस लिपि में लिखी जाती है?',
        quickCheckAnswer: 'देवनागरी लिपि में।',
        hindiQuickCheckAnswer: 'देवनागरी लिपि में।',
      ),
    ];

    final pointsToRemember = <String>[
      'हिन्दी भाषा में जैसा बोला जाता है, वैसा ही लिखा जाता है।',
      'मात्राओं के सही प्रयोग से शब्दों का अर्थ स्पष्ट रहता है।',
      'विराम चिह्नों का उचित प्रयोग भावों को सही रूप में व्यक्त करता है।',
      'नियमित पठन और लेखन से भाषा कौशल में निखार आता है।',
    ];

    final didYouKnowFacts = <String>[];
    if (chapter.funFact != null && chapter.funFact!.isNotEmpty) {
      didYouKnowFacts.add(chapter.funFact!);
    }
    didYouKnowFacts.add('हिन्दी विश्व में सबसे अधिक बोली जाने वाली प्रमुख भाषाओं में से एक है!');

    return ChapterStudyMaterial(
      chapterId: chapter.chapterId,
      title: chapter.title,
      hindiTitle: chapter.title,
      grade: chapter.grade,
      subjectId: chapter.subjectId,
      icon: chapter.icon,
      overview: chapter.description.isNotEmpty
          ? chapter.description
          : 'सीबीएसई व आईसीएसई पाठ्यक्रम पर आधारित ${chapter.title} का विस्तृत अध्ययन सामग्री।',
      hindiOverview: chapter.description.isNotEmpty
          ? chapter.description
          : 'सीबीएसई व आईसीएसई पाठ्यक्रम पर आधारित ${chapter.title} का विस्तृत अध्ययन सामग्री।',
      definitions: definitions,
      quickRulesAndFormulas: finalRules,
      hindiQuickRulesAndFormulas: finalRules,
      solvedExamples: solvedExamples,
      examTraps: const [
        'मात्राओं (ह्रस्व और दीर्घ) के अंतर को ध्यानपूर्वक समझें!',
        'समान उच्चारण वाले वर्णों (जैसे श, ष, स) में भ्रमित न हों!',
      ],
      hindiExamTraps: const [
        'मात्राओं (ह्रस्व और दीर्घ) के अंतर को ध्यानपूर्वक समझें!',
        'समान उच्चारण वाले वर्णों (जैसे श, ष, स) में भ्रमित न हों!',
      ],
      realWorldConnection: 'हिन्दी भाषा हमारी संस्कृति, साहित्य, समाचार और आपसी बातचीत की सुंदर अभिव्यक्ति है।',
      hindiRealWorldConnection: 'हिन्दी भाषा हमारी संस्कृति, साहित्य, समाचार और आपसी बातचीत की सुंदर अभिव्यक्ति है।',
      proTip: chapter.mascotAdvice ?? 'प्रतिदिन एक छोटा हिन्दी अनुच्छेद बोलकर पढ़ें!',
      hindiProTip: chapter.mascotAdvice ?? 'प्रतिदिन एक छोटा हिन्दी अनुच्छेद बोलकर पढ़ें!',
      textbookSections: textbookSections,
      pointsToRemember: pointsToRemember,
      hindiPointsToRemember: pointsToRemember,
      didYouKnowFacts: didYouKnowFacts,
      hindiDidYouKnowFacts: didYouKnowFacts,
    );
  }

  // ==========================================
  // GEOMETRY & MENSURATION POPULATION
  // ==========================================
  void _populateGeometryDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    if (gradeLower.contains('lkg') || gradeLower.contains('ukg')) {
      defs.add(
        const ConceptDefinition(
          term: 'Circle (वृत्त)',
          hindiTerm: 'वृत्त (Circle)',
          definition: 'A round shape that is perfectly curved all the way around with zero corners and zero straight sides.',
          hindiDefinition: 'एक गोल आकृति जो चारों तरफ से पूरी तरह से मुड़ी हुई होती है, जिसमें कोई कोना या सीधी भुजा नहीं होती।',
          formula: '0 Sides • 0 Corners',
          keyPoints: [
            'It can roll smoothly like a ball or a coin.',
            'Every point on the curved edge is the same distance from the center.',
          ],
          hindiKeyPoints: [
            'यह गेंद या सिक्के की तरह आसानी से लुढ़क सकता है।',
            'इसके घुमावदार किनारे का प्रत्येक बिंदु केंद्र से समान दूरी पर होता है।',
          ],
          example: 'A chapati, full moon, pizza, or bicycle wheel.',
          hindiExample: 'रोटी, पूर्णिमा का चाँद, पिज़्ज़ा या साइकिल का पहिया।',
          commonTrap: 'An oval or egg shape is NOT a circle because it is stretched!',
          hindiCommonTrap: 'अंडाकार आकृति वृत्त नहीं है क्योंकि वह खिंची हुई होती है!',
          realWorldUse: 'Bicycle and car wheels are made circular so vehicles glide smoothly without bumping.',
          hindiRealWorldUse: 'वाहनों के पहिए गोल बनाए जाते हैं ताकि वे बिना झटके के आसानी से चल सकें।',
        ),
      );
      defs.add(
        const ConceptDefinition(
          term: 'Square (वर्ग)',
          hindiTerm: 'वर्ग (Square)',
          definition: 'A flat flat shape with 4 straight sides that are all completely equal in length, and 4 matching corners.',
          hindiDefinition: 'एक समतल आकृति जिसकी 4 सीधी भुजाएँ होती हैं जो लंबाई में पूरी तरह बराबर होती हैं, और 4 कोने होते हैं।',
          formula: '4 Equal Sides • 4 Corners (90°)',
          keyPoints: [
            'All 4 sides must be exactly the same length.',
            'It will slide flat along a table instead of rolling.',
          ],
          hindiKeyPoints: [
            'चारों भुजाएँ लंबाई में बिल्कुल समान होनी चाहिए।',
            'यह लुढ़कने के बजाय मेज पर सपाट फिसलेगा।',
          ],
          example: 'A chessboard square, carrom board, or square picture frame.',
          hindiExample: 'शतरंज का खाना, कैरम बोर्ड या चौकोर फोटो फ्रेम।',
          commonTrap: 'A rectangle whose sides are not all equal is NOT a square!',
          hindiCommonTrap: 'जिस आयत की सभी भुजाएँ बराबर न हों, वह वर्ग नहीं कहलाता!',
          realWorldUse: 'Floor tiles and puzzle cubes are made square so they fit together perfectly without leaving gaps.',
          hindiRealWorldUse: 'फर्श की टाइलें चौकोर बनाई जाती हैं ताकि वे बिना खाली जगह छोड़े आपस में जुड़ सकें।',
        ),
      );
      defs.add(
        const ConceptDefinition(
          term: 'Triangle (त्रिभुज)',
          hindiTerm: 'त्रिभुज (Triangle)',
          definition: 'A sharp, stable flat shape created by connecting 3 straight sides that meet at 3 sharp corners (vertices).',
          hindiDefinition: '3 सीधी भुजाओं को जोड़कर बनाई गई एक मजबूत आकृति जो 3 कोनों पर मिलती है।',
          formula: '3 Sides • 3 Corners',
          keyPoints: [
            'Always has exactly 3 straight lines and 3 points.',
            'Cannot roll because of its flat sides and sharp corners.',
          ],
          hindiKeyPoints: [
            'हमेशा ठीक 3 सीधी रेखाएँ और 3 कोने होते हैं।',
            'सपाट भुजाओं और तीखे कोनों के कारण लुढ़क नहीं सकता।',
          ],
          example: 'A slice of pizza, a traffic yield sign, or a crispy samosa.',
          hindiExample: 'पिज़्ज़ा का टुकड़ा, सड़क का चेतावनी संकेत, या समोसा।',
          commonTrap: 'A curved shape with 3 rounded tips is NOT a true geometric triangle.',
          hindiCommonTrap: 'घुमावदार भुजाओं वाली आकृति वास्तविक त्रिभुज नहीं होती।',
          realWorldUse: 'Bridges and roof trusses use triangles because it is the strongest geometric shape that cannot be deformed.',
          hindiRealWorldUse: 'पुलों और छतों में त्रिभुज का उपयोग किया जाता है क्योंकि यह सबसे मजबूत ज्यामितीय आकृति है।',
        ),
      );
      return;
    }

    // Upper grades: Class 4 to 8
    defs.add(
      const ConceptDefinition(
        term: 'Perimeter (परिमाप)',
        hindiTerm: 'परिमाप (Perimeter)',
        definition: 'The total continuous boundary length enclosing any two-dimensional geometric region. It is calculated by adding the lengths of all outer boundary sides.',
        hindiDefinition: 'किसी द्विविमीय (2D) आकृति को घेरने वाली कुल बाहरी सीमा की लंबाई। यह सभी बाहरी भुजाओं के योग से प्राप्त होता है।',
        formula: 'Rectangle: P = 2(l + b) • Square: P = 4s • Circle: C = 2πr',
        keyPoints: [
          'Measured in linear units: cm, m, km, inches.',
          'Always represents a distance traveled around the outside edge.',
        ],
        hindiKeyPoints: [
          'रैखिक इकाइयों में मापा जाता है: सेमी, मीटर, किमी।',
          'हमेशा बाहरी किनारे के चारों ओर की दूरी दर्शाता है।',
        ],
        example: 'A garden measuring 10m long and 5m wide has a perimeter of 2(10 + 5) = 30 meters.',
        hindiExample: '10 मीटर लंबे और 5 मीटर चौड़े बगीचे का परिमाप 2(10 + 5) = 30 मीटर है।',
        commonTrap: 'Never write perimeter in square units (cm²). Perimeter is pure distance (cm, m)!',
        hindiCommonTrap: 'परिमाप को कभी भी वर्ग इकाई (वर्ग सेमी) में न लिखें। परिमाप केवल लंबाई है (सेमी, मीटर)!',
        realWorldUse: 'Fencing agricultural fields, putting lace around tablecloths, and framing photographs.',
        hindiRealWorldUse: 'खेतों के चारों ओर बाड़ लगाना, मेजपोश पर किनारी लगाना और फोटो फ्रेमिंग करना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Area (क्षेत्रफल)',
        hindiTerm: 'क्षेत्रफल (Area)',
        definition: 'The total two-dimensional surface space enclosed within the closed perimeter boundaries of a flat shape.',
        hindiDefinition: 'किसी बंद समतल आकृति की सीमाओं के भीतर आने वाले कुल सतह के स्थान का माप।',
        formula: 'Rectangle: A = l × b • Square: A = s² • Triangle: A = ½ × b × h • Circle: A = πr²',
        keyPoints: [
          'Expressed strictly in square units: cm², m², sq ft.',
          'Represents how many 1×1 unit squares fit inside the boundary.',
        ],
        hindiKeyPoints: [
          'हमेशा वर्ग इकाइयों में व्यक्त किया जाता है: सेमी², मीटर², वर्ग फीट।',
          'यह दर्शाता है कि सीमा के भीतर 1×1 इकाई के कितने वर्ग समा सकते हैं।',
        ],
        example: 'A rectangular room of 6m length and 4m breadth has an area of 6 × 4 = 24 m².',
        hindiExample: '6 मीटर लंबे और 4 मीटर चौड़े कमरे का क्षेत्रफल 6 × 4 = 24 वर्ग मीटर है।',
        commonTrap: 'Confusing height with slant height in triangles! Height must be perpendicular (90°) to the base.',
        hindiCommonTrap: 'त्रिभुज में तिरछी ऊंचाई को वास्तविक ऊंचाई न समझें! ऊंचाई हमेशा आधार पर लंबवत (90°) होनी चाहिए।',
        realWorldUse: 'Buying flooring tiles, painting walls, measuring land plots, and calculating carpet fabric.',
        hindiRealWorldUse: 'फर्श की टाइलें खरीदना, दीवारों पर पेंट कराना, जमीन नापना और कालीन बिछाना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Volume & Capacity (आयतन एवं धारिता)',
        hindiTerm: 'आयतन एवं धारिता (Volume & Capacity)',
        definition: 'Volume is the total three-dimensional space occupied by a solid object. Capacity is the volume of fluid or contents a hollow container can hold.',
        hindiDefinition: 'आयतन किसी ठोस वस्तु द्वारा घेरा गया कुल त्रिविमीय (3D) स्थान है। धारिता किसी खोखले बर्तन में भरे जा सकने वाले द्रव की मात्रा है।',
        formula: 'Cuboid: V = l × b × h • Cube: V = s³ • Cylinder: V = πr²h',
        keyPoints: [
          'Measured in cubic units (cm³, m³) or fluid units (liters, milliliters).',
          '1 liter = 1000 cm³ = 1000 mL.',
        ],
        hindiKeyPoints: [
          'घन इकाइयों (सेमी³, मीटर³) या द्रव इकाइयों (लीटर, मिलीलीटर) में मापा जाता है।',
          '1 लीटर = 1000 सेमी³ = 1000 मिलीलीटर।',
        ],
        example: 'A water tank measuring 2m × 1m × 1.5m has a volume of 3 m³ = 3,000 liters.',
        hindiExample: '2मी × 1मी × 1.5मी की पानी की टंकी का आयतन 3 घन मीटर = 3,000 लीटर है।',
        commonTrap: 'Mixing units when multiplying (e.g. multiplying meters with centimeters without converting first).',
        hindiCommonTrap: 'गुणा करते समय इकाइयों को मिलाना (जैसे मीटर को सेंटीमीटर में बदले बिना गुणा करना)।',
        realWorldUse: 'Designing fuel tanks, measuring medicine doses, calculating shipping container freight capacity.',
        hindiRealWorldUse: 'ईंधन टैंक डिजाइन करना, दवा की खुराक नापना, और कार्गो कंटेनर क्षमता तय करना।',
      ),
    );
  }

  void _populateGeometryRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
    String gradeLower,
  ) {
    rules.addAll([
      'Area of a rectangle = length × breadth (A = l × b).',
      'Perimeter of any polygon = Sum of all outer side lengths.',
      'Sum of interior angles of any triangle is ALWAYS 180°.',
      'Circumference of a circle = 2 × π × radius, where π ≈ 22/7 or 3.1416.',
    ]);
    hindiRules.addAll([
      'आयत का क्षेत्रफल = लंबाई × चौड़ाई (A = l × b)।',
      'किसी भी बहुभुज का परिमाप = सभी बाहरी भुजाओं की लंबाइयों का योग।',
      'किसी भी त्रिभुज के तीनों अंतः कोणों का योग हमेशा 180° होता है।',
      'वृत्त की परिधि = 2 × π × त्रिज्या, जहाँ π ≈ 22/7 या 3.1416 होता है।',
    ]);
    traps.addAll([
      'Units error: Length and breadth must be in the SAME unit before multiplying (convert cm to m first if mixed).',
      'Area is measured in square units (m², cm²), while perimeter is measured in linear units (m, cm).',
    ]);
    hindiTraps.addAll([
      'इकाई त्रुटि: गुणा करने से पहले लंबाई और चौड़ाई एक ही इकाई में होनी चाहिए (यदि अलग-अलग हों तो पहले सेमी को मीटर में बदलें)।',
      'क्षेत्रफल वर्ग इकाइयों (मीटर², सेमी²) में मापा जाता है, जबकि परिमाप साधारण इकाइयों (मीटर, सेमी) में मापा जाता है।',
    ]);
  }

  // ==========================================
  // NUMBER SYSTEM, FRACTIONS & DECIMALS
  // ==========================================
  void _populateNumberSystemDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    if (gradeLower.contains('lkg') || gradeLower.contains('ukg')) {
      defs.add(
        const ConceptDefinition(
          term: 'Counting & Numbers (गिनती और संख्याएं)',
          hindiTerm: 'गिनती और संख्याएं (Counting & Numbers)',
          definition: 'Numbers tell us exactly "how many" items, animals, or objects we have in a group.',
          hindiDefinition: 'संख्याएं हमें ठीक-ठीक बताती हैं कि हमारे पास किसी समूह में "कितनी" वस्तुएं या चीजें हैं।',
          formula: '1, 2, 3, 4, 5, 6, 7, 8, 9, 10...',
          keyPoints: [
            'Each object is counted once and only once.',
            'The final number spoken tells the total quantity.',
          ],
          hindiKeyPoints: [
            'प्रत्येक वस्तु को केवल एक बार गिना जाता है।',
            'बोली गई अंतिम संख्या कुल मात्रा बताती है।',
          ],
          example: 'Counting 3 red apples: "One, Two, Three apples!"',
          hindiExample: '3 लाल सेब गिनना: "एक, दो, तीन सेब!"',
          commonTrap: 'Skipping an object or counting the same item twice leads to wrong totals.',
          hindiCommonTrap: 'किसी वस्तु को छोड़ देना या एक ही वस्तु को दो बार गिनना गलत गिनती देता है।',
          realWorldUse: 'Counting fingers, sharing cookies with friends, and setting the dinner table.',
          hindiRealWorldUse: 'उंगलियां गिनना, दोस्तों में बिस्कुट बांटना और खाने की मेज लगाना।',
        ),
      );
      defs.add(
        const ConceptDefinition(
          term: 'Number Bonds & Addition (जोड़ना)',
          hindiTerm: 'जोड़ना (Addition)',
          definition: 'Putting two or more groups of items together to find the new total amount.',
          hindiDefinition: 'दो या दो से अधिक वस्तुओं के समूहों को एक साथ मिलाकर कुल संख्या ज्ञात करना।',
          formula: 'Part + Part = Whole (e.g. 2 + 3 = 5)',
          keyPoints: [
            'Addition always makes the total group bigger (or equal if adding zero).',
            'The plus symbol (+) means combine together.',
          ],
          hindiKeyPoints: [
            'जोड़ने से कुल समूह हमेशा बड़ा हो जाता है (शून्य जोड़ने पर समान रहता है)।',
            'धन का चिह्न (+) एक साथ मिलाने का प्रतीक है।',
          ],
          example: '2 birds on a branch + 1 more bird lands = 3 birds altogether.',
          hindiExample: 'डाल पर 2 पक्षी + 1 और पक्षी आया = कुल मिलाकर 3 पक्षी।',
          commonTrap: 'Adding 0 does not change the number: 4 + 0 is still 4!',
          hindiCommonTrap: '0 जोड़ने पर संख्या नहीं बदलती: 4 + 0 बराबर 4 ही रहता है!',
          realWorldUse: 'Adding up pocket money coins and scoring points in childhood games.',
          hindiRealWorldUse: 'सिक्के जोड़ना और खेल में अंक गिनना।',
        ),
      );
      return;
    }

    // Upper grades: Integers, Fractions, Rational Numbers
    defs.add(
      const ConceptDefinition(
        term: 'Integers (पूर्णांक)',
        hindiTerm: 'पूर्णांक (Integers)',
        definition: 'The complete set of numbers consisting of all positive natural counting numbers, zero, and their negative counterparts. Fractions and decimals are excluded.',
        hindiDefinition: 'सभी धनात्मक प्राकृतिक संख्याओं, शून्य और उनके ऋणात्मक रूपों का संपूर्ण संग्रह। इसमें भिन्न और दशमलव शामिल नहीं होते।',
        formula: 'ℤ = {..., -3, -2, -1, 0, 1, 2, 3, ...}',
        keyPoints: [
          'Zero (0) is neither positive nor negative; it is neutral.',
          'On a number line, moving right increases value; moving left decreases value.',
          'Every integer has an additive inverse: the additive inverse of +5 is -5.',
        ],
        hindiKeyPoints: [
          'शून्य (0) न तो धनात्मक है और न ही ऋणात्मक; यह उदासीन है।',
          'संख्या रेखा पर, दाईं ओर जाने पर मान बढ़ता है; बाईं ओर जाने पर मान घटता है।',
          'प्रत्येक पूर्णांक का एक योज्य प्रतिलोम होता है: +5 का योज्य प्रतिलोम -5 है।',
        ],
        example: '-8 is smaller than -2, because -8 is further to the left on the number line.',
        hindiExample: '-8 संख्या -2 से छोटी है, क्योंकि -8 संख्या रेखा पर अधिक बाईं ओर स्थित है।',
        commonTrap: 'Thinking that -10 is bigger than -2 because 10 > 2. In negative numbers, greater magnitude means SMALLER value!',
        hindiCommonTrap: 'यह सोचना कि -10 संख्या -2 से बड़ी है क्योंकि 10 > 2 है। ऋणात्मक संख्याओं में बड़ा अंक वास्तव में छोटा मान होता है!',
        realWorldUse: 'Measuring sub-zero winter temperatures (-15°C), underwater scuba depths (-50m), and bank balances.',
        hindiRealWorldUse: 'शून्य से नीचे का तापमान (-15°C), समुद्र की गहराई (-50 मीटर) और बैंक खातों का लेन-देन।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Rational Numbers (परिमेय संख्याएँ)',
        hindiTerm: 'परिमेय संख्याएँ (Rational Numbers)',
        definition: 'Any number that can be expressed strictly in the fractional form p / q, where both p and q are integers and the denominator q is NOT equal to zero (q ≠ 0).',
        hindiDefinition: 'वह कोई भी संख्या जिसे p / q के भिन्न रूप में लिखा जा सकता है, जहाँ p और q दोनों पूर्णांक हैं तथा हर q कभी भी शून्य के बराबर नहीं होता (q ≠ 0)।',
        formula: 'ℚ = { p / q : p, q ∈ ℤ and q ≠ 0 }',
        keyPoints: [
          'All natural numbers, whole numbers, and integers are rational numbers (e.g. 5 = 5/1).',
          'Every decimal that terminates (0.75 = ¾) or repeats endlessly (0.333... = ⅓) is rational.',
        ],
        hindiKeyPoints: [
          'सभी प्राकृतिक संख्याएं, पूर्ण संख्याएं और पूर्णांक परिमेय संख्याएं हैं (उदा. 5 = 5/1)।',
          'प्रत्येक शांत दशमलव (0.75 = ¾) या अशांत आवर्ती दशमलव (0.333... = ⅓) परिमेय होता है।',
        ],
        example: '-¾, 0.5 (which is ½), 7 (which is 7/1), and 0 (which is 0/1) are all rational numbers.',
        hindiExample: '-¾, 0.5 (जो ½ है), 7 (जो 7/1 है), और 0 (जो 0/1 है) सभी परिमेय संख्याएं हैं।',
        commonTrap: 'Division by zero is undefined! Writing 5/0 is invalid and does NOT represent a rational number.',
        hindiCommonTrap: 'शून्य से भाग अपरिभाषित है! 5/0 लिखना अमान्य है और यह परिमेय संख्या नहीं है।',
        realWorldUse: 'Sharing pizza slices, measuring recipe ingredients (½ cup flour), calculating loan interest rates.',
        hindiRealWorldUse: 'पिज़्ज़ा बांटना, खाना पकाने में सामग्री नापना (½ कप आटा), और बैंक ब्याज दरों की गणना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Prime Factorization & HCF / LCM (अभाज्य गुणनखंडन)',
        hindiTerm: 'अभाज्य गुणनखंडन एवं म.स.प. / ल.स.प. (HCF & LCM)',
        definition: 'Expressing a composite number as the unique product of its prime building blocks. HCF is the highest common divisor, and LCM is the smallest common multiple.',
        hindiDefinition: 'किसी भाज्य संख्या को उसकी अभाज्य संख्याओं के गुणनफल के रूप में व्यक्त करना। म.स.प. सबसे बड़ा उभयनिष्ठ भाजक है, और ल.स.प. सबसे छोटा उभयनिष्ठ गुणज है।',
        formula: 'Product of Two Numbers (A × B) = HCF(A, B) × LCM(A, B)',
        keyPoints: [
          'A prime number has exactly two factors: 1 and itself.',
          'HCF divides both numbers completely without remainder.',
          'LCM is divisible by both numbers completely without remainder.',
        ],
        hindiKeyPoints: [
          'अभाज्य संख्या के केवल दो गुणनखंड होते हैं: 1 और स्वयं वह संख्या।',
          'म.स.प. दोनों संख्याओं को बिना शेषफल के पूरी तरह विभाजित करता है।',
          'ल.स.प. दोनों संख्याओं से बिना शेषफल के पूरी तरह विभाजित होता है।',
        ],
        example: 'For 12 and 18: Prime factors are 12 = 2² × 3, 18 = 2 × 3². HCF = 2 × 3 = 6; LCM = 2² × 3² = 36.',
        hindiExample: '12 और 18 के लिए: 12 = 2² × 3, 18 = 2 × 3²। म.स.प. = 2 × 3 = 6; ल.स.प. = 2² × 3² = 36।',
        commonTrap: '1 is NEITHER prime NOR composite! The smallest prime number is 2 (and it is the only even prime).',
        hindiCommonTrap: '1 न तो अभाज्य संख्या है और न ही भाज्य! सबसे छोटी अभाज्य संख्या 2 है (और यह एकमात्र सम अभाज्य संख्या है)।',
        realWorldUse: 'Traffic lights syncing intervals, gear teeth alignment in watches, and public-key cryptography on the internet.',
        hindiRealWorldUse: 'ट्रैफ़िक लाइटों का समय निर्धारण, घड़ियों में गियर का तालमेल, और इंटरनेट पर डेटा सुरक्षा (Cryptography)।',
      ),
    );
  }

  void _populateNumberSystemRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
    String gradeLower,
  ) {
    rules.addAll([
      'Denominator can never be zero (q ≠ 0) in any rational number; division by zero is strictly undefined.',
      'Sign rules for multiplication/division: (+) × (+) = (+), (-) × (-) = (+), (+) × (-) = (-).',
      'To add fractions with different denominators, first convert both to equivalent fractions with their LCM.',
      'Product of two numbers = HCF × LCM (A × B = HCF × LCM).',
      'Laws of exponents: aᵐ × aⁿ = aᵐ⁺ⁿ, and aᵐ ÷ aⁿ = aᵐ⁻ⁿ.',
    ]);
    hindiRules.addAll([
      'परिमेय संख्या का हर शून्य नहीं हो सकता (q ≠ 0); शून्य से भाग पूरी तरह अपरिभाषित है।',
      'गुणा/भाग के चिह्न नियम: (+) × (+) = (+), (-) × (-) = (+), (+) × (-) = (-)।',
      'असमान हर वाली भिन्नों को जोड़ने के लिए, पहले ल.स.प. लेकर समान हर वाली तुल्य भिन्न बनाएं।',
      'दो संख्याओं का गुणनफल = म.स.प. × ल.स.प. (A × B = HCF × LCM)।',
      'घातांक के नियम: aᵐ × aⁿ = aᵐ⁺ⁿ, तथा aᵐ ÷ aⁿ = aᵐ⁻ⁿ।',
    ]);
    traps.addAll([
      'Adding fractions by simply adding tops and bottoms (e.g. 1/2 + 1/3 ≠ 2/5). You MUST find the common denominator (5/6)!',
      'Sign mistake in integer subtraction: subtracting a negative is equivalent to adding a positive: 5 - (-3) = 5 + 3 = 8.',
    ]);
    hindiTraps.addAll([
      'भिन्नों को सीधे अंश में अंश और हर में हर जोड़कर हल न करें (उदा. 1/2 + 1/3 ≠ 2/5)। पहले ल.स.प. निकालना अनिवार्य है (5/6)!',
      'ऋणात्मक संख्या घटाते समय चिह्न की गलती: ऋणात्मक को घटाना धनात्मक जोड़ने के समान है: 5 - (-3) = 5 + 3 = 8।',
    ]);
  }

  // ==========================================
  // ALGEBRA & EQUATIONS
  // ==========================================
  void _populateAlgebraDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Variable & Constant (चर एवं अचर)',
        hindiTerm: 'चर एवं अचर (Variable & Constant)',
        definition: 'A variable is an unknown symbol (usually letters like x, y, a) that can take different numerical values. A constant is a fixed numerical quantity with a permanent value.',
        hindiDefinition: 'चर एक अज्ञात प्रतीक है (जैसे x, y, z) जो विभिन्न संख्यात्मक मान ले सकता है। अचर एक निश्चित संख्यात्मक मान होता है जो कभी नहीं बदलता।',
        formula: 'In 3x + 5 = 11: "x" is the variable, "3" is the coefficient, "5" and "11" are constants.',
        keyPoints: [
          'Variables represent unknown quantities we solve for in problems.',
          'Like terms have the exact same variables raised to the exact same powers (e.g. 3x² and 7x²).',
        ],
        hindiKeyPoints: [
          'चर उन अज्ञात मानों का प्रतिनिधित्व करते हैं जिन्हें हम प्रश्नों में हल करते हैं।',
          'समान पदों में चर और उनकी घातें बिल्कुल एक जैसी होती हैं (उदा. 3x² और 7x²)।',
        ],
        example: 'If a pen costs ₹x, then 4 pens cost 4x rupees. Here x can be any price.',
        hindiExample: 'यदि एक पेन की कीमत ₹x है, तो 4 पेनों की कीमत 4x रुपये होगी। यहाँ x कोई भी कीमत हो सकती है।',
        commonTrap: 'You CANNOT combine unlike terms! 3x + 2y does NOT equal 5xy. They remain 3x + 2y.',
        hindiCommonTrap: 'असमान पदों को आपस में जोड़ा नहीं जा सकता! 3x + 2y कभी भी 5xy के बराबर नहीं होता।',
        realWorldUse: 'Writing computer algorithms, calculating taxi fares (base fare + ₹x per km), predicting satellite trajectories.',
        hindiRealWorldUse: 'कंप्यूटर प्रोग्रामिंग, टैक्सी का किराया तय करना (मूल किराया + ₹x प्रति किमी), उपग्रहों की कक्षा की गणना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Linear Equation in One Variable (एक चर वाले रैखिक समीकरण)',
        hindiTerm: 'एक चर वाले रैखिक समीकरण (Linear Equations)',
        definition: 'An algebraic statement of equality containing exactly one unknown variable with an exponent of 1. It acts like a perfectly balanced beam scale.',
        hindiDefinition: 'समानता का एक बीजीय कथन जिसमें घात 1 वाला केवल एक अज्ञात चर होता है। यह एक संतुलित तराजू की तरह कार्य करता है।',
        formula: 'Standard Form: ax + b = c (where a ≠ 0)',
        keyPoints: [
          'Whatever operation is performed on the left-hand side (LHS) must also be performed on the right-hand side (RHS).',
          'Transposition rule: A term changes its sign when moved across the equals sign (+ becomes -, × becomes ÷).',
        ],
        hindiKeyPoints: [
          'जो संक्रिया बाएं पक्ष (LHS) पर की जाती है, वही दाएं पक्ष (RHS) पर भी की जानी चाहिए।',
          'पक्षांतरण नियम: बराबर के चिह्न के दूसरी ओर ले जाने पर पद का चिह्न बदल जाता है (+ बन जाता है -, × बन जाता है ÷)।',
        ],
        example: '2x + 6 = 16 ⟹ 2x = 16 - 6 ⟹ 2x = 10 ⟹ x = 10 / 2 = 5.',
        hindiExample: '2x + 6 = 16 ⟹ 2x = 16 - 6 ⟹ 2x = 10 ⟹ x = 10 / 2 = 5.',
        commonTrap: 'Forgetting to change signs when transposing a term across the equals sign (+5 transposed becomes -5)!',
        hindiCommonTrap: 'बराबर चिह्न के दूसरी तरफ ले जाते समय पद का चिह्न बदलना भूल जाना (+5 पक्षांतरित होकर -5 बनता है)!',
        realWorldUse: 'Finding unknown ages, determining speed/distance travel times, adjusting recipes, business budgeting.',
        hindiRealWorldUse: 'आयु संबंधी पहेलियां हल करना, यात्रा की गति और समय निकालना, व्यापार में बजट की योजना बनाना।',
      ),
    );
  }

  void _populateAlgebraRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
    String gradeLower,
  ) {
    rules.addAll([
      'Transposition: Moving +a to other side becomes -a; moving ×a becomes ÷a.',
      'Distributive Law: a(b + c) = ab + ac.',
      'Algebraic Identity 1: (a + b)² = a² + 2ab + b².',
      'Algebraic Identity 2: (a - b)² = a² - 2ab + b².',
      'Algebraic Identity 3: (a + b)(a - b) = a² - b².',
    ]);
    hindiRules.addAll([
      'पक्षांतरण: +a दूसरी तरफ जाकर -a बनता है; ×a दूसरी तरफ जाकर ÷a बनता है।',
      'वितरण नियम: a(b + c) = ab + ac।',
      'बीजीय सर्वसमिका 1: (a + b)² = a² + 2ab + b²।',
      'बीजीय सर्वसमिका 2: (a - b)² = a² - 2ab + b²।',
      'बीजीय सर्वसमिका 3: (a + b)(a - b) = a² - b²।',
    ]);
    traps.addAll([
      'Freshmen error: (a + b)² is NOT equal to a² + b²! You must remember the middle term: + 2ab.',
      'Negative sign outside brackets flips ALL signs inside: -(2x - 3) = -2x + 3.',
    ]);
    hindiTraps.addAll([
      'आम गलती: (a + b)² कभी भी a² + b² के बराबर नहीं होता! मध्य पद (+ 2ab) जोड़ना अनिवार्य है।',
      'कोष्ठक के बाहर ऋण चिह्न होने पर अंदर के सभी चिह्न पलट जाते हैं: -(2x - 3) = -2x + 3।',
    ]);
  }

  // ==========================================
  // COMMERCIAL MATH, RATIOS, PERCENTAGES, TIME
  // ==========================================
  void _populateCommercialMathDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Percentage (प्रतिशतता)',
        hindiTerm: 'प्रतिशतता (Percentage)',
        definition: 'A fraction or ratio where the denominator is always fixed at 100. The symbol "%" literally means "out of one hundred" (per centum).',
        hindiDefinition: 'एक भिन्न या अनुपात जिसका हर (Denominator) हमेशा 100 होता है। "%" प्रतीक का शाब्दिक अर्थ "प्रति सौ" होता है।',
        formula: 'Percentage = (Value / Total) × 100%',
        keyPoints: [
          'To convert a fraction to %, multiply by 100 (e.g. ¾ × 100 = 75%).',
          'To convert % to fraction, divide by 100 and simplify (e.g. 20% = 20/100 = ⅕).',
        ],
        hindiKeyPoints: [
          'भिन्न को प्रतिशत में बदलने के लिए 100 से गुणा करें (उदा. ¾ × 100 = 75%)।',
          'प्रतिशत को भिन्न में बदलने के लिए 100 से भाग देकर सरल करें (उदा. 20% = 20/100 = ⅕)।',
        ],
        example: 'Scoring 45 marks out of 50 in an exam: (45 / 50) × 100 = 90%.',
        hindiExample: 'परीक्षा में 50 में से 45 अंक प्राप्त करना: (45 / 50) × 100 = 90%।',
        commonTrap: 'Finding 20% of 80 is NOT 80 - 20 = 60. It is (20/100) × 80 = 16!',
        hindiCommonTrap: '80 का 20% निकालना 80 - 20 = 60 नहीं है। यह (20/100) × 80 = 16 होता है!',
        realWorldUse: 'Exam report cards, store sales discounts (30% off), mobile battery charging indicators, bank interest rates.',
        hindiRealWorldUse: 'परीक्षा परिणाम पत्र, दुकानों पर छूट (30% छूट), मोबाइल बैटरी चार्जिंग संकेत, बैंक ब्याज दरें।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Simple Interest (साधारण ब्याज)',
        hindiTerm: 'साधारण ब्याज (Simple Interest)',
        definition: 'The fixed fee paid by a borrower for using borrowed money (Principal) over a specified time duration at a fixed annual rate percentage.',
        hindiDefinition: 'किसी निश्चित वार्षिक दर प्रतिशत पर निश्चित समयावधि के लिए उधार ली गई धनराशि (मूलधन) का उपयोग करने के बदले दिया जाने वाला अतिरिक्त शुल्क।',
        formula: 'SI = (P × R × T) / 100 • Total Amount A = P + SI',
        keyPoints: [
          'P = Principal (initial sum borrowed or invested).',
          'R = Rate of interest per annum (percentage per year).',
          'T = Time duration (must be expressed strictly in YEARS).',
        ],
        hindiKeyPoints: [
          'P = मूलधन (उधार ली गई या निवेश की गई प्रारंभिक राशि)।',
          'R = वार्षिक ब्याज दर (प्रति वर्ष प्रतिशत)।',
          'T = समयावधि (हमेशा वर्षों में व्यक्त की जानी चाहिए)।',
        ],
        example: 'Borrowing ₹10,000 at 5% annual interest for 2 years: SI = (10,000 × 5 × 2) / 100 = ₹1,000. Total repaid = ₹11,000.',
        hindiExample: '₹10,000 की राशि 5% वार्षिक ब्याज पर 2 वर्ष के लिए: SI = (10,000 × 5 × 2) / 100 = ₹1,000। कुल लौटाई गई राशि = ₹11,000।',
        commonTrap: 'If Time is given in months (e.g. 6 months), you MUST convert it to years (6/12 = 0.5 years) before applying formula!',
        hindiCommonTrap: 'यदि समय महीनों में दिया हो (जैसे 6 महीने), तो सूत्र लगाने से पहले उसे वर्षों में बदलना अनिवार्य है (6/12 = 0.5 वर्ष)!',
        realWorldUse: 'Home loans, fixed deposit bank savings, automobile financing, and student education loans.',
        hindiRealWorldUse: 'गृह ऋण (Home Loan), बैंक में फिक्स्ड डिपॉजिट बचत, वाहन ऋण और छात्र शिक्षा ऋण।',
      ),
    );
  }

  void _populateCommercialMathRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
    String gradeLower,
  ) {
    rules.addAll([
      'Profit = Selling Price - Cost Price (SP - CP when SP > CP).',
      'Loss = Cost Price - Selling Price (CP - SP when CP > SP).',
      'Profit % = (Profit / CP) × 100. (Profit % is ALWAYS calculated on Cost Price CP).',
      'Simple Interest: SI = (P × R × T) / 100, where T is always in years.',
      'Unitary Method: Divide to find 1 item value, then multiply to find target quantity.',
    ]);
    hindiRules.addAll([
      'लाभ = विक्रय मूल्य - क्रय मूल्य (SP - CP जब SP > CP हो)।',
      'हानि = क्रय मूल्य - विक्रय मूल्य (CP - SP जब CP > SP हो)।',
      'लाभ % = (लाभ / CP) × 100 (लाभ % की गणना हमेशा क्रय मूल्य CP पर की जाती है)।',
      'साधारण ब्याज: SI = (P × R × T) / 100, जहाँ T हमेशा वर्षों में होता है।',
      'ऐकिक नियम (Unitary Method): 1 वस्तु का मान निकालने के लिए भाग दें, फिर अभीष्ट मात्रा के लिए गुणा करें।',
    ]);
    traps.addAll([
      'Calculating profit percentage on Selling Price instead of Cost Price CP. Profit % = (Profit/CP)*100!',
      'Forgetting to convert time in months to years when computing Simple Interest.',
    ]);
    hindiTraps.addAll([
      'क्रय मूल्य (CP) के बजाय विक्रय मूल्य पर लाभ प्रतिशत निकालना। लाभ % हमेशा (लाभ/CP)*100 होता है!',
      'साधारण ब्याज निकालते समय महीनों में दिए गए समय को वर्षों में बदलना भूल जाना।',
    ]);
  }

  // ==========================================
  // BASIC OPERATIONS & PLACE VALUE
  // ==========================================
  void _populateOperationsDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Place Value & Face Value (स्थानीय मान एवं अंकित मान)',
        hindiTerm: 'स्थानीय मान एवं अंकित मान (Place & Face Value)',
        definition: 'Face value is the actual digit itself regardless of position. Place value is the value a digit holds based on its position (Ones, Tens, Hundreds, Thousands).',
        hindiDefinition: 'अंकित मान संख्या का स्वयं का वास्तविक मान है। स्थानीय मान किसी अंक का उसकी स्थिति (इकाई, दहाई, सैकड़ा, हजार) के आधार पर मान होता है।',
        formula: 'Place Value = Face Value × Position Multiplier (1, 10, 100, 1000...)',
        keyPoints: [
          'In 4,567: The face value of 5 is simply 5.',
          'The place value of 5 is 5 × 100 = 500 (Hundreds place).',
        ],
        hindiKeyPoints: [
          '4,567 में: 5 का अंकित मान केवल 5 है।',
          '5 का स्थानीय मान 5 × 100 = 500 है (सैकड़े का स्थान)।',
        ],
        example: 'In the number 7,823: 7 represents 7,000; 8 represents 800; 2 represents 20; 3 represents 3.',
        hindiExample: 'संख्या 7,823 में: 7 का मान 7,000 है; 8 का मान 800 है; 2 का मान 20 है; 3 का मान 3 है।',
        commonTrap: 'Confusing Place Value with Face Value. Face value NEVER changes, place value depends on position!',
        hindiCommonTrap: 'स्थानीय मान और अंकित मान में भ्रम होना। अंकित मान कभी नहीं बदलता, स्थानीय मान स्थिति पर निर्भर करता है!',
        realWorldUse: 'Counting currency notes (e.g. knowing a ₹500 note has a higher place value than a ₹50 note), odometer readings.',
        hindiRealWorldUse: 'मुद्रा के नोट गिनना (जैसे ₹500 के नोट का मूल्य ₹50 के नोट से अधिक होना), वाहनों का ओडोमीटर पढ़ना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Multiplication & Division Properties (गुणा एवं भाग)',
        hindiTerm: 'गुणा एवं भाग (Multiplication & Division)',
        definition: 'Multiplication is rapid repeated addition of equal groups. Division is equal sharing or partitioning a total into equal groups.',
        hindiDefinition: 'गुणा समान समूहों का त्वरित बार-बार जोड़ है। भाग किसी कुल राशि का समान समूहों में समान बंटवारा है।',
        formula: 'Dividend = (Divisor × Quotient) + Remainder',
        keyPoints: [
          'Multiplication by 0 is always 0 (a × 0 = 0).',
          'Multiplication by 1 leaves the number unchanged (a × 1 = a).',
          'Division by zero is mathematically impossible (undefined).',
        ],
        hindiKeyPoints: [
          'शून्य से गुणा करने पर उत्तर हमेशा शून्य होता है (a × 0 = 0)।',
          '1 से गुणा करने पर संख्या अपरिवर्तित रहती है (a × 1 = a)।',
          'शून्य से भाग देना गणितीय रूप से असंभव (अपरिभाषित) है।',
        ],
        example: '6 × 4 = 24 means 6 + 6 + 6 + 6 = 24. Also 24 ÷ 4 = 6.',
        hindiExample: '6 × 4 = 24 का अर्थ है 6 + 6 + 6 + 6 = 24। साथ ही 24 ÷ 4 = 6।',
        commonTrap: 'In division, remainder must ALWAYS be strictly less than the divisor! If remainder >= divisor, you can divide further.',
        hindiCommonTrap: 'भाग में, शेषफल हमेशा भाजक से छोटा होना चाहिए! यदि शेषफल >= भाजक है, तो भाग और आगे दिया जा सकता है।',
        realWorldUse: 'Distributing sweets equally among children, calculating grocery bills, sharing pizza slices.',
        hindiRealWorldUse: 'बच्चों में समान मिठाइयाँ बाँटना, किराना बिल की गणना करना, पिज़्ज़ा के टुकड़े बराबर बाँटना।',
      ),
    );
  }

  void _populateOperationsRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
    String gradeLower,
  ) {
    rules.addAll([
      'Order of Operations (BODMAS): Brackets ⟹ Orders ⟹ Division ⟹ Multiplication ⟹ Addition ⟹ Subtraction.',
      'Dividend = (Divisor × Quotient) + Remainder.',
      'Commutative Law of Multiplication: a × b = b × a.',
    ]);
    hindiRules.addAll([
      'संक्रियाओं का क्रम (BODMAS): कोष्ठक ⟹ घात ⟹ भाग ⟹ गुणा ⟹ जोड़ ⟹ घटाव।',
      'भाज्य = (भाजक × भागफल) + शेषफल।',
      'गुणा का क्रमविनिमेय नियम: a × b = b × a।',
    ]);
    traps.addAll([
      'Ignoring BODMAS: In 4 + 2 × 5, you MUST multiply first (2×5 = 10), then add (4+10 = 14). Do not calculate (4+2)×5 = 30!',
    ]);
    hindiTraps.addAll([
      'BODMAS की अनदेखी करना: 4 + 2 × 5 में पहले गुणा करना अनिवार्य है (2×5 = 10), फिर जोड़ें (4+10 = 14)। पहले जोड़कर 30 न निकालें!',
    ]);
  }

  // ==========================================
  // ENGLISH DOMAINS
  // ==========================================
  void _populatePhonicsDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Phonics & Letter Sounds (ध्वनि और अक्षर)',
        hindiTerm: 'ध्वनि और अक्षर (Phonics & Letter Sounds)',
        definition: 'Phonics connects the visual written letter symbols (graphemes) to their corresponding spoken speech sounds (phonemes).',
        hindiDefinition: 'ध्वनिविज्ञान (Phonics) लिखे गए अक्षरों (अक्षर चिह्नों) को उनकी बोली जाने वाली ध्वनियों से जोड़ता है।',
        formula: 'Letter + Sound = Word Building (e.g. /c/ + /æ/ + /t/ = Cat)',
        keyPoints: [
          'There are 26 letters in English that produce 44 distinct speech sounds.',
          'Consonants produce quick, stopping sounds; vowels produce open, flowing sounds.',
        ],
        hindiKeyPoints: [
          'अंग्रेजी वर्णमाला में 26 अक्षर होते हैं जो 44 विशिष्ट ध्वनियां उत्पन्न करते हैं।',
          'व्यंजन (Consonants) स्पष्ट ध्वनियां देते हैं; स्वर (Vowels) खुली, प्रवाहमयी ध्वनि देते हैं।',
        ],
        example: 'The letter "B" produces the popping sound /b/ as in "Ball" and "Bat".',
        hindiExample: 'अक्षर "B" से /ब/ ध्वनि निकलती है जैसे "Ball" और "Bat" में।',
        commonTrap: 'Confusing letter NAMES (Bee, See) with letter SOUNDS (/b/, /k/). We read with sounds, not names!',
        hindiCommonTrap: 'अक्षर के नाम (बी, सी) और उसकी वास्तविक ध्वनि (/ब/, /क/) में भ्रम होना। हम ध्वनियों से पढ़ते हैं, नामों से नहीं!',
        realWorldUse: 'Sounding out new words while reading storybooks, spelling names correctly, and developing clear pronunciation.',
        hindiRealWorldUse: 'कहानियों की किताबें पढ़ते समय नए शब्दों का उच्चारण करना और सही वर्तनी (Spelling) लिखना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Rhyming Words (तुकबंदी वाले शब्द)',
        hindiTerm: 'तुकबंदी वाले शब्द (Rhyming Words)',
        definition: 'Two or more words that share the exact same ending vowel and consonant sound, while their beginning letter sounds differ.',
        hindiDefinition: 'दो या दो से अधिक शब्द जिनकी अंतिम स्वर और व्यंजन ध्वनि बिल्कुल समान होती है, जबकि उनका पहला अक्षर अलग होता है।',
        formula: 'Different Start + Identical End Sound (e.g. C-at & H-at)',
        keyPoints: [
          'Cat, Bat, Hat, Mat, Rat all rhyme because they end with the "-at" sound.',
          'Words do not need to look identical in spelling to rhyme; they only need to sound the same.',
        ],
        hindiKeyPoints: [
          'Cat, Bat, Hat, Mat, Rat सभी तुकबंदी करते हैं क्योंकि वे "-at" ध्वनि पर समाप्त होते हैं।',
          'तुकबंदी के लिए वर्तनी का समान दिखना जरूरी नहीं है; केवल ध्वनि का समान होना आवश्यक है।',
        ],
        example: '"The fat cat sat on a mat wearing a hat!"',
        hindiExample: '"The fat cat sat on a mat wearing a hat!"',
        commonTrap: 'Assuming words that look similar always rhyme. "Cough" and "Through" look similar but DO NOT rhyme!',
        hindiCommonTrap: 'यह मान लेना कि जो शब्द एक जैसे दिखते हैं वे हमेशा तुकबंदी करते हैं। "Cough" और "Through" दिखते समान हैं लेकिन तुकबंदी नहीं करते!',
        realWorldUse: 'Composing nursery rhymes, song lyrics, poetry, and bedtime storytelling.',
        hindiRealWorldUse: 'कविताओं, गीतों और बाल कहानियों की रचना में।',
      ),
    );
  }

  void _populatePhonicsRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
  ) {
    rules.addAll([
      'The 5 core vowels are A, E, I, O, U. Every English word must have at least one vowel sound.',
      'Rhyming words share the same terminal acoustic cadence (ending sound).',
      'Capital letters are mandatory for the beginning of every sentence and for proper nouns.',
    ]);
    hindiRules.addAll([
      'अंग्रेजी में 5 मुख्य स्वर हैं: A, E, I, O, U। प्रत्येक अंग्रेजी शब्द में कम से कम एक स्वर ध्वनि होनी चाहिए।',
      'तुकबंदी वाले शब्द समान अंतिम ध्वनि साझा करते हैं।',
      'प्रत्येक वाक्य की शुरुआत में और व्यक्तिवाचक संज्ञाओं के लिए बड़े अक्षर (Capital Letters) का प्रयोग अनिवार्य है।',
    ]);
    traps.addAll([
      'Silent letters: Words like "Knight", "Knee", and "Write" have silent starting letters that are not pronounced.',
    ]);
    hindiTraps.addAll([
      'मूक अक्षर (Silent Letters): "Knight", "Knee" और "Write" जैसे शब्दों में पहले अक्षर का उच्चारण नहीं किया जाता।',
    ]);
  }

  void _populateNounsDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Noun (संज्ञा)',
        hindiTerm: 'संज्ञा (Noun)',
        definition: 'A part of speech that names a specific person, place, animal, object, feeling, or abstract idea.',
        hindiDefinition: 'किसी व्यक्ति, स्थान, प्राणी, वस्तु, भाव या विचार के नाम को संज्ञा कहते हैं।',
        formula: 'Person (Teacher) + Place (School) + Thing (Book) + Idea (Courage)',
        keyPoints: [
          'Common Noun: General name of everyday things (boy, city, river, dog). Starts with lowercase.',
          'Proper Noun: Specific unique official name (Aarav, Mumbai, Ganga, Bruno). ALWAYS starts with capital letter.',
          'Collective Noun: Name for a group of things (a herd of cattle, a flock of birds, a pack of wolves).',
        ],
        hindiKeyPoints: [
          'जातिवाचक संज्ञा (Common Noun): सामान्य नाम (boy, city, river)। छोटे अक्षर से शुरू होता है।',
          'व्यक्तिवाचक संज्ञा (Proper Noun): विशिष्ट आधिकारिक नाम (Aarav, Mumbai)। हमेशा बड़े अक्षर से शुरू होता है।',
          'समूहवाचक संज्ञा (Collective Noun): समूह का नाम (a herd of cattle, a flock of birds)।',
        ],
        example: '"Rohit (Proper) took his dog (Common) to Central Park (Proper)."',
        hindiExample: '"Rohit (व्यक्तिवाचक) ने अपने dog (जातिवाचक) को Central Park (व्यक्तिवाचक) में घुमाया।"',
        commonTrap: 'Forgetting to capitalize proper nouns: writing "mumbai" or "tuesday" instead of "Mumbai" and "Tuesday".',
        hindiCommonTrap: 'व्यक्तिवाचक संज्ञा को छोटे अक्षर से लिखना: "Mumbai" और "Tuesday" को हमेशा Capital letter से शुरू करें!',
        realWorldUse: 'Writing addresses, identifying people, drafting documents, reading maps and signs.',
        hindiRealWorldUse: 'पते लिखना, लोगों की पहचान करना, कानूनी दस्तावेज बनाना, और मानचित्र पढ़ना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Pronouns (सर्वनाम)',
        hindiTerm: 'सर्वनाम (Pronouns)',
        definition: 'A word used in place of a noun to avoid monotonous and clumsy repetition in speech and writing.',
        hindiDefinition: 'संज्ञा के स्थान पर प्रयुक्त होने वाले शब्द जो बार-बार नाम दोहराने की असुविधा से बचाते हैं।',
        formula: 'Noun ⟹ Replaced by Pronoun (e.g. Riya sings well ⟹ She sings well)',
        keyPoints: [
          'Personal Pronouns: I, you, he, she, it, we, they (Subject pronouns); me, him, her, us, them (Object pronouns).',
          'Possessive Pronouns: mine, yours, his, hers, ours, theirs (show ownership).',
        ],
        hindiKeyPoints: [
          'पुरुषवाचक सर्वनाम: I, you, he, she, it, we, they (कर्ता रूप); me, him, her, us, them (कर्म रूप)।',
          'अधिकारवाचक सर्वनाम: mine, yours, his, hers, ours, theirs (स्वामित्व दर्शाते हैं)।',
        ],
        example: '"Ananya is smart because she reads books every day."',
        hindiExample: '"Ananya होशियार है क्योंकि she (वह) प्रतिदिन पुस्तकें पढ़ती है।"',
        commonTrap: 'Confusing "it\'s" (it is) with "its" (possessive pronoun). "The dog wagged its tail" has NO apostrophe!',
        hindiCommonTrap: '"it\'s" (it is) और "its" (स्वामित्व) में भ्रम होना। "The dog wagged its tail" में apostrophe नहीं आता!',
        realWorldUse: 'Fluent everyday conversation, storytelling, writing letters and emails.',
        hindiRealWorldUse: 'सहज दैनिक बातचीत, कहानियाँ सुनाना, पत्र और ईमेल लिखना।',
      ),
    );
  }

  void _populateNounsRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
  ) {
    rules.addAll([
      'Singular to plural: Add "-s" (book ⟹ books), "-es" for words ending in s, sh, ch, x (box ⟹ boxes).',
      'Irregular plurals change completely: child ⟹ children, foot ⟹ feet, mouse ⟹ mice.',
      'Articles: Use "A" before consonant sounds (a book, a university); use "An" before vowel sounds (an apple, an hour).',
    ]);
    hindiRules.addAll([
      'एकवचन से बहुवचन: "-s" जोड़ें (book ⟹ books), s, sh, ch, x पर समाप्त होने वाले शब्दों में "-es" जोड़ें (box ⟹ boxes)।',
      'अनियमित बहुवचन पूरी तरह बदलते हैं: child ⟹ children, foot ⟹ feet, mouse ⟹ mice।',
      'उपपद (Articles): व्यंजन ध्वनि से पहले "A" लगाएं (a book, a university); स्वर ध्वनि से पहले "An" लगाएं (an apple, an hour)।',
    ]);
    traps.addAll([
      'The "An" rule is based on SOUND, not letter! We say "an honest man" (silent h produces vowel sound) and "a university" (starts with /yu/ consonant sound).',
    ]);
    hindiTraps.addAll([
      '"An" का नियम ध्वनि पर आधारित है, अक्षर पर नहीं! हम "an honest man" कहते हैं (क्योंकि h मूक है और स्वर ध्वनि आती है) तथा "a university" (क्योंकि यह /य/ व्यंजन ध्वनि से शुरू होता है)।',
    ]);
  }

  void _populateVerbsAndTensesDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Verb & Tenses (क्रिया एवं काल)',
        hindiTerm: 'क्रिया एवं काल (Verbs & Tenses)',
        definition: 'A verb conveys an action, occurrence, or state of being. Tense tells us the exact time when that action occurs: Past (yesterday), Present (now), or Future (tomorrow).',
        hindiDefinition: 'क्रिया किसी कार्य के करने, होने या स्थिति को दर्शाती है। काल हमें यह बताता है कि कार्य किस समय हुआ: भूतकाल, वर्तमान काल, या भविष्य काल।',
        formula: 'Present (I play) • Past (I played) • Future (I will play)',
        keyPoints: [
          'Simple Present: Used for daily habits, universal truths, and routines (The Sun rises in the east).',
          'Simple Past: Actions completed in the past (He visited the museum yesterday).',
          'Simple Future: Actions that will take place later (We will travel next week).',
          'Continuous Tense: Actions happening continuously (is/am/are + verb-ing).',
        ],
        hindiKeyPoints: [
          'सामान्य वर्तमान: दैनिक आदतों और शाश्वत सत्यों के लिए (सूरज पूर्व में उगता है)।',
          'सामान्य भूतकाल: बीते समय में पूरे हुए कार्य (उसने कल संग्रहालय देखा)।',
          'सामान्य भविष्य: आगे होने वाले कार्य (हम अगले सप्ताह यात्रा करेंगे)।',
          'अपूर्ण काल (Continuous): जारी रहने वाले कार्य (is/am/are + verb-ing)।',
        ],
        example: '"She writes (Present) letters. Yesterday she wrote (Past) a letter. Tomorrow she will write (Future) a letter."',
        hindiExample: '"She writes (वर्तमान). Yesterday she wrote (भूतकाल). Tomorrow she will write (भविष्य)."',
        commonTrap: 'Subject-Verb mismatch: singular third-person subjects NEED the "s": "He walks", NOT "He walk"!',
        hindiCommonTrap: 'कर्ता और क्रिया का तालमेल: एकवचन कर्ता के साथ क्रिया में "s/es" लगाना न भूलें: "He walks", "He walk" गलत है!',
        realWorldUse: 'Describing schedules, reading news stories, making promises, and writing historical timelines.',
        hindiRealWorldUse: 'दैनिक कार्यक्रम बताना, समाचार पढ़ना, वादे करना और ऐतिहासिक घटनाएं लिखना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Active & Passive Voice (कर्तृवाच्य एवं कर्मवाच्य)',
        hindiTerm: 'कर्तृवाच्य एवं कर्मवाच्य (Active & Passive Voice)',
        definition: 'In active voice, the subject performs the action. In passive voice, the subject receives the action, shifting focus onto the result or object.',
        hindiDefinition: 'कर्तृवाच्य (Active) में कर्ता स्वयं कार्य करता है। कर्मवाच्य (Passive) में कर्म पर ध्यान केंद्रित होता है और कर्ता द्वारा कार्य किया जाता है।',
        formula: 'Active: S + V + O ⟹ Passive: O + helping verb + V3 (Past Participle) + by + S',
        keyPoints: [
          'Passive voice ALWAYS uses the third form of the verb (V3 - Past Participle).',
          'Pronouns transform: I ⟹ me, He ⟹ him, She ⟹ her, They ⟹ them.',
        ],
        hindiKeyPoints: [
          'Passive voice में हमेशा क्रिया की तीसरी फॉर्म (V3 - Past Participle) का प्रयोग होता है।',
          'सर्वनाम बदलते हैं: I ⟹ me, He ⟹ him, She ⟹ her, They ⟹ them।',
        ],
        example: 'Active: "Alexander Fleming discovered penicillin." ⟹ Passive: "Penicillin was discovered by Alexander Fleming."',
        hindiExample: 'Active: "राम ने पत्र लिखा।" ⟹ Passive: "पत्र राम द्वारा लिखा गया (A letter was written by Ram)."',
        commonTrap: 'Only TRANSITIVE verbs (verbs that take a direct object) can be converted to passive voice!',
        hindiCommonTrap: 'केवल सकर्मक क्रियाओं (Transitive Verbs) को ही Passive Voice में बदला जा सकता है!',
        realWorldUse: 'Scientific lab reports, newspaper crime reports, formal announcements ("The match has been postponed").',
        hindiRealWorldUse: 'वैज्ञानिक अनुसंधान रिपोर्ट, समाचार पत्र की सुर्खियां, और औपचारिक घोषणाएं।',
      ),
    );
  }

  void _populateVerbsRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
  ) {
    rules.addAll([
      'Subject-Verb Agreement: A singular subject takes a singular verb (The cat sleeps); a plural subject takes a plural verb (The cats sleep).',
      'Modal Verbs (can, could, may, might, must, should) are ALWAYS followed by the base form of the main verb without "-s" or "-ed".',
      'Past Participle (V3) is strictly required after have/has/had (e.g. has eaten, had seen).',
    ]);
    hindiRules.addAll([
      'कर्ता-क्रिया तालमेल: एकवचन कर्ता के साथ एकवचन क्रिया (The cat sleeps); बहुवचन कर्ता के साथ बहुवचन क्रिया (The cats sleep)।',
      'मोडल वर्ब्स (can, could, may, must, should) के बाद हमेशा मुख्य क्रिया का मूल रूप आता है।',
      'have/has/had के बाद हमेशा क्रिया की तीसरी फॉर्म (V3) का प्रयोग अनिवार्य है (has eaten, had seen)।',
    ]);
    traps.addAll([
      'Phrases with "Neither...nor" or "Either...or": The verb agrees with the subject CLOSER to it! (Neither the teacher nor the students were present).',
    ]);
    hindiTraps.addAll([
      '"Neither...nor" या "Either...or" में क्रिया हमेशा सबसे निकटतम कर्ता के अनुसार बदलती है!',
    ]);
  }

  void _populateSyntaxDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Adjectives & Adverbs (विशेषण एवं क्रियाविशेषण)',
        hindiTerm: 'विशेषण एवं क्रियाविशेषण (Adjectives & Adverbs)',
        definition: 'Adjectives describe or give more information about nouns (blue sky, sweet mango). Adverbs modify or describe verbs, adjectives, or other adverbs, usually telling how, when, or where (runs quickly, speaks softly).',
        hindiDefinition: 'विशेषण (Adjectives) संज्ञा की विशेषता या गुण बताते हैं (जैसे नीला आकाश)। क्रियाविशेषण (Adverbs) क्रिया, विशेषण या अन्य क्रियाविशेषण की विशेषता बताते हैं कि कार्य कैसे, कब या कहाँ हुआ (जैसे तेजी से दौड़ना)।',
        formula: 'Adjective modifies Noun • Adverb modifies Verb (often ends in -ly)',
        keyPoints: [
          'Degrees of Comparison: Positive (Fast), Comparative (Faster), Superlative (Fastest).',
          'Use "-er" / "-est" for short words; use "more" / "most" for long words (more beautiful, most beautiful).',
        ],
        hindiKeyPoints: [
          'तुलना की अवस्थाएं: Positive (Fast), Comparative (Faster), Superlative (Fastest)।',
          'छोटे शब्दों में "-er" / "-est" लगाएं; लंबे शब्दों में "more" / "most" का प्रयोग करें।',
        ],
        example: '"The clever (Adjective) fox ran swiftly (Adverb) into the dark (Adjective) forest."',
        hindiExample: '"The clever (विशेषण) fox ran swiftly (क्रियाविशेषण) into the dark (विशेषण) forest."',
        commonTrap: 'Confusing "good" with "well". "Good" is an adjective (a good book); "well" is an adverb (he sang well)!',
        hindiCommonTrap: '"good" और "well" में भ्रम। "Good" विशेषण है (a good boy); "well" क्रियाविशेषण है (he played well)!',
        realWorldUse: 'Writing expressive stories, describing products in advertising, giving accurate directions.',
        hindiRealWorldUse: 'रोचक कहानियाँ लिखना, विज्ञापनों में उत्पादों का विवरण देना, और सही दिशा-निर्देश देना।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Prepositions & Conjunctions (संबंधबोधक एवं समुच्चयबोधक)',
        hindiTerm: 'संबंधबोधक एवं समुच्चयबोधक (Prepositions & Conjunctions)',
        definition: 'Prepositions show position, direction, or time relationship between a noun and other words (in, on, under, behind). Conjunctions are connecting words that join words, phrases, or clauses (and, but, because, although).',
        hindiDefinition: 'संबंधबोधक (Prepositions) किसी संज्ञा का अन्य शब्दों के साथ स्थान, दिशा या समय का संबंध दर्शाते हैं। समुच्चयबोधक (Conjunctions) शब्दों या उपवाक्यों को आपस में जोड़ने वाले योजक शब्द हैं।',
        formula: 'Preposition + Noun Phrase (on the table) • Clause + Conjunction + Clause',
        keyPoints: [
          'Common prepositions: in, at, on, through, between, among, under, above.',
          'Between is used for TWO items; Among is used for THREE or more items.',
          'Coordinating conjunctions (FANBOYS): For, And, Nor, But, Or, Yet, So.',
        ],
        hindiKeyPoints: [
          'प्रमुख संबंधबोधक: in, at, on, through, between, among, under, above।',
          'Between का प्रयोग केवल दो वस्तुओं के लिए होता है; Among का प्रयोग तीन या अधिक के लिए होता है।',
          'जोड़ने वाले शब्द (Conjunctions): and (और), but (लेकिन), because (क्योंकि), although (यद्यपि)।',
        ],
        example: '"The cat jumped onto the table and ate the fish because it was hungry."',
        hindiExample: '"The cat jumped onto the table and ate the fish because it was hungry."',
        commonTrap: 'Using "between" for more than two people: write "among the five friends", NOT "between the five friends"!',
        hindiCommonTrap: 'दो से अधिक लोगों के लिए "between" का प्रयोग करना गलत है: "among the five friends" लिखें!',
        realWorldUse: 'Giving navigation directions (turn right at the signal), writing complex logical arguments.',
        hindiRealWorldUse: 'रास्ते के निर्देश देना (सिग्नल पर मुड़ें), तार्किक तर्क और निबंध लिखना।',
      ),
    );
  }

  void _populateSyntaxRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
  ) {
    rules.addAll([
      'Always use "between" when comparing exactly two items, and "among" for groups of three or more.',
      'Superlative degree adjectives MUST always be preceded by the definite article "the" (the tallest, the most brilliant).',
      'A sentence must express a complete thought with a Subject and a Predicate.',
    ]);
    hindiRules.addAll([
      'ठीक दो वस्तुओं के लिए हमेशा "between" का प्रयोग करें, तथा तीन या अधिक के समूह के लिए "among" लगाएं।',
      'Superlative डिग्री के विशेषण से पहले हमेशा "the" लगाना अनिवार्य है (the tallest, the best)।',
      'एक पूर्ण वाक्य में कर्ता (Subject) और विधेय (Predicate) होना चाहिए जो पूर्ण अर्थ व्यक्त करे।',
    ]);
    traps.addAll([
      'Double comparatives error: NEVER say "more faster" or "most tallest". Say "faster" and "tallest"!',
    ]);
    hindiTraps.addAll([
      'दोहरी तुलना की गलती: कभी भी "more faster" या "most tallest" न कहें। केवल "faster" और "tallest" कहें!',
    ]);
  }

  void _populateGeneralEnglishDefinitions(
    List<ConceptDefinition> defs,
    String gradeLower,
    String titleLower,
  ) {
    defs.add(
      const ConceptDefinition(
        term: 'Synonyms & Antonyms (पर्यायवाची एवं विलोम शब्द)',
        hindiTerm: 'पर्यायवाची एवं विलोम शब्द (Synonyms & Antonyms)',
        definition: 'Synonyms are words with identical or very similar meanings (Joyful / Happy). Antonyms are words with directly opposite meanings (Hot / Cold, Ancient / Modern).',
        hindiDefinition: 'पर्यायवाची (Synonyms) वे शब्द हैं जिनका अर्थ समान होता है (जैसे प्रसन्न / खुश)। विलोम (Antonyms) वे शब्द हैं जिनका अर्थ एक-दूसरे के सर्वथा विपरीत होता है (जैसे गर्म / ठंडा)।',
        formula: 'Synonym: Word ≈ Word • Antonym: Word ⟷ Opposite Word',
        keyPoints: [
          'Using rich synonyms prevents repetitive writing and enriches vocabulary.',
          'Many antonyms can be formed using negative prefixes: un- (happy/unhappy), dis- (honest/dishonest), in- (complete/incomplete).',
        ],
        hindiKeyPoints: [
          'समानार्थी शब्दों के प्रयोग से भाषा समृद्ध और रोचक बनती है।',
          'कई विलोम शब्द उपसर्ग जोड़कर बनते हैं: un- (happy/unhappy), dis- (honest/dishonest)।',
        ],
        example: 'Synonyms: "Huge" and "Gigantic". Antonyms: "Victory" and "Defeat".',
        hindiExample: 'पर्यायवाची: "Huge" और "Gigantic"। विलोम शब्द: "Victory" और "Defeat"।',
        commonTrap: 'Context matters! While "fast" and "quick" are synonyms, we say "fast food", NOT "quick food"!',
        hindiCommonTrap: 'संदर्भ महत्वपूर्ण है! यद्यपि "fast" और "quick" समानार्थी हैं, हम "fast food" कहते हैं, "quick food" नहीं!',
        realWorldUse: 'Creative story writing, essay composition, speech delivery, and competitive exam vocabulary.',
        hindiRealWorldUse: 'रचनात्मक कहानी लेखन, निबंध लेखन, वाद-विवाद प्रतियोगिता और शब्दावली संवर्धन।',
      ),
    );
    defs.add(
      const ConceptDefinition(
        term: 'Punctuation & Capitalization (विराम चिह्न)',
        hindiTerm: 'विराम चिह्न (Punctuation Marks)',
        definition: 'Standard typographic marks used in written sentences to clarify meaning, indicate natural pauses, and prevent ambiguity.',
        hindiDefinition: 'लिखित वाक्यों में अर्थ को स्पष्ट करने, स्वाभाविक ठहराव दर्शाने और भ्रम को दूर करने के लिए उपयोग किए जाने वाले मानक चिह्न।',
        formula: 'Full Stop (.) • Comma (,) • Question Mark (?) • Exclamation Mark (!) • Apostrophe (\')',
        keyPoints: [
          'Full stop (.) ends a declarative sentence.',
          'Comma (,) separates items in a list and introduces brief pauses.',
          'Apostrophe (\') shows possession (Rohan\'s bag) or contraction (don\'t).',
        ],
        hindiKeyPoints: [
          'पूर्ण विराम (.) साधारण वाक्य की समाप्ति दर्शाता है।',
          'अल्पविराम (,) सूची में वस्तुओं को अलग करता है और संक्षिप्त ठहराव देता है।',
          'एपोस्ट्रॉफी (\') अधिकार (Rohan\'s bag) या संक्षिप्त रूप (don\'t) दर्शाता है।',
        ],
        example: '"Let\'s eat, Grandma!" (inviting her to eat) vs "Let\'s eat Grandma!" (without comma, disastrous meaning!).',
        hindiExample: '"Let\'s eat, Grandma!" (अल्पविराम के साथ सही अर्थ) बनाम "Let\'s eat Grandma!" (अल्पविराम न होने से अनर्थ!)।',
        commonTrap: 'Missing commas can completely alter the meaning of legal and academic sentences!',
        hindiCommonTrap: 'अल्पविराम छूट जाने से पूरे वाक्य का अर्थ बदल सकता है!',
        realWorldUse: 'Writing books, texting clearly, publishing newspapers, drafting legal agreements.',
        hindiRealWorldUse: 'पुस्तकें लिखना, स्पष्ट संदेश भेजना, समाचार पत्र प्रकाशित करना, कानूनी समझौते तैयार करना।',
      ),
    );
  }

  void _populateGeneralEnglishRules(
    List<String> rules,
    List<String> hindiRules,
    List<String> traps,
    List<String> hindiTraps,
  ) {
    rules.addAll([
      'Capitalize the first letter of every sentence and the pronoun "I" wherever it appears.',
      'A complete sentence requires both a subject and a verb and must express a complete idea.',
      'Use quotation marks ("...") to enclose the exact spoken words in direct speech.',
    ]);
    hindiRules.addAll([
      'प्रत्येक वाक्य का पहला अक्षर और सर्वनाम "I" जहाँ भी आए, उसे हमेशा बड़े अक्षर (Capital) में लिखें।',
      'एक पूर्ण वाक्य में कर्ता और क्रिया दोनों होने चाहिए और वह पूर्ण विचार व्यक्त करना चाहिए।',
      'प्रत्यक्ष कथन (Direct Speech) में बोले गए वास्तविक शब्दों को उद्धरण चिह्नों ("...") में रखें।',
    ]);
    traps.addAll([
      'Run-on sentences: Joining two independent clauses without a conjunction or semicolon creates a grammatical run-on error.',
    ]);
    hindiTraps.addAll([
      'दो स्वतंत्र वाक्यों को बिना योजक शब्द या अर्धविराम के जोड़ना व्याकरण की दृष्टि से त्रुटिपूर्ण है।',
    ]);
  }

  // ==========================================
  // HELPER: CHAPTER-SPECIFIC DEFINITIONS BUILDER
  // ==========================================
  void _populateChapterSpecificDefinitions(
    List<ConceptDefinition> defs,
    Chapter chapter, {
    required bool isEnglish,
  }) {
    for (final concept in chapter.keyConcepts) {
      if (defs.any((d) => d.term.toLowerCase() == concept.toLowerCase())) continue;
      defs.add(_createConceptDefinition(concept, chapter, isEnglish: isEnglish));
    }
  }

  ConceptDefinition _createConceptDefinition(
    String concept,
    Chapter chapter, {
    required bool isEnglish,
  }) {
    final hindiConcept = HindiCurriculumTranslator.translateConcept(concept);
    final conceptLower = concept.toLowerCase();

    // 1. Shapes and Spatial concepts
    if (conceptLower.contains('circle') || conceptLower.contains('square') || conceptLower.contains('triangle')) {
      return ConceptDefinition(
        term: concept,
        hindiTerm: hindiConcept,
        definition: '2D plane shapes: Circles are round with 0 straight sides; Squares have 4 equal sides and 4 corners; Triangles have 3 straight sides and 3 corners.',
        hindiDefinition: 'द्वि-आयामी (2D) आकृतियाँ: वृत्त बिना किसी कोने के गोल होते हैं; वर्ग में 4 समान भुजाएँ और 4 कोने होते हैं; त्रिभुज में 3 भुजाएँ और 3 कोने होते हैं।',
        formula: 'Circle: 0 corners • Square: 4 equal sides • Triangle: 3 sides',
        keyPoints: [
          'Circles roll smoothly because of continuous curvature.',
          'Squares and triangles slide on their flat straight edges.',
        ],
        hindiKeyPoints: [
          'घुमावदार होने के कारण वृत्त आसानी से लुढ़कते हैं।',
          'सपाट भुजाओं के कारण वर्ग और त्रिभुज फिसलते हैं।',
        ],
        example: 'Coin (Circle), Chessboard tile (Square), Samosa slice (Triangle).',
        hindiExample: 'सिक्का (वृत्त), कैरम बोर्ड (वर्ग), समोसा (त्रिभुज)।',
        commonTrap: 'Confusing 2D flat shapes (circle, square) with 3D solid objects (sphere, cube).',
        hindiCommonTrap: '2D समतल आकृतियों (वृत्त, वर्ग) और 3D ठोस वस्तुओं (गोला, घन) में भ्रम होना।',
        realWorldUse: 'Traffic signs, wheels, construction tiles, and architectural designs.',
        hindiRealWorldUse: 'ट्रैफिक संकेत, पहिए, फर्श की टाइलें और भवन निर्माण।',
      );
    }

    if (conceptLower.contains('big vs small') || conceptLower.contains('tall vs short') || conceptLower.contains('heavy vs light') || conceptLower.contains('more vs less')) {
      return ConceptDefinition(
        term: concept,
        hindiTerm: hindiConcept,
        definition: 'Comparative measurement allows us to observe and rank objects by physical attributes such as size, height, weight, and volume.',
        hindiDefinition: 'तुलनात्मक मापन हमें आकार, ऊंचाई, भार और मात्रा जैसे भौतिक गुणों के आधार पर वस्तुओं की तुलना करने की अनुमति देता है।',
        formula: 'Direct Comparison: Compare side-by-side using a common baseline',
        keyPoints: [
          'Line up objects at the exact same starting line to compare height or length fairly.',
          'Bigger objects do not always weigh more than smaller, denser objects.',
        ],
        hindiKeyPoints: [
          'लंबाई या ऊंचाई की सही तुलना के लिए वस्तुओं को एक ही आधार रेखा पर रखें।',
          'बड़ी वस्तुएं हमेशा छोटी भारी वस्तुओं से अधिक वजनदार नहीं होतीं।',
        ],
        example: 'An elephant is BIG, a mouse is SMALL. A giraffe is TALL, a rabbit is SHORT.',
        hindiExample: 'हाथी बड़ा (BIG) है, चूहा छोटा (SMALL) है। जिराफ लंबा (TALL) है, खरगोश छोटा (SHORT) है।',
        commonTrap: 'Judging weight purely by visual size instead of actual mass.',
        hindiCommonTrap: 'वास्तविक भार को जाने बिना केवल देखने में बड़ा होने से वस्तु को भारी मान लेना।',
        realWorldUse: 'Packing luggage, arranging shelves, choosing clothing sizes.',
        hindiRealWorldUse: 'सामान पैक करना, अलमारियां व्यवस्थित करना, कपड़ों का आकार चुनना।',
      );
    }

    if (conceptLower.contains('inside vs outside') || conceptLower.contains('top vs bottom') || conceptLower.contains('near vs far')) {
      return ConceptDefinition(
        term: concept,
        hindiTerm: hindiConcept,
        definition: 'Spatial relationships describe where an object is located relative to boundaries, reference points, and surfaces.',
        hindiDefinition: 'स्थानिक संबंध यह दर्शाते हैं कि कोई वस्तु सीमाओं, संदर्भ बिंदुओं और सतहों के सापेक्ष कहाँ स्थित है।',
        formula: 'Spatial Position: Located relative to a reference boundary or surface',
        keyPoints: [
          'Inside means enclosed within boundaries; Outside means in the exterior space.',
          'Top is the highest surface; Bottom is the base or lowest surface.',
        ],
        hindiKeyPoints: [
          'Inside का अर्थ सीमा के भीतर होना है; Outside का अर्थ बाहरी स्थान में होना है।',
          'Top सबसे ऊपरी सतह है; Bottom आधार या सबसे निचली सतह है।',
        ],
        example: 'Pencils are INSIDE the pencil box; the eraser is OUTSIDE on the desk.',
        hindiExample: 'पेंसिलें बॉक्स के अंदर (INSIDE) हैं; रबर मेज पर बाहर (OUTSIDE) है।',
        commonTrap: 'Confusing top/bottom orientation when looking at tilted objects.',
        hindiCommonTrap: 'तिरछी वस्तुओं को देखते समय ऊपर/नीचे की स्थिति में भ्रम होना।',
        realWorldUse: 'GPS navigation, organizing rooms, following road directions.',
        hindiRealWorldUse: 'जीपीएस नेविगेशन, कमरों की व्यवस्था, सड़क के दिशा-निर्देशों का पालन।',
      );
    }

    if (conceptLower.contains('counting') || conceptLower.contains('number recognition') || conceptLower.contains('one-to-one')) {
      return ConceptDefinition(
        term: concept,
        hindiTerm: hindiConcept,
        definition: 'One-to-one correspondence assigns exactly one number word to each object counted, where the final count represents the total quantity.',
        hindiDefinition: 'गिनती में प्रत्येक वस्तु को ठीक एक संख्या दी जाती है, और बोली गई अंतिम संख्या कुल मात्रा को दर्शाती है।',
        formula: '1-to-1 Correspondence: Each object counted once and only once',
        keyPoints: [
          'Touch each object as you say the number name.',
          'The order in which objects are counted does not change the total sum.',
        ],
        hindiKeyPoints: [
          'संख्या बोलते समय प्रत्येक वस्तु को अपनी उंगली से छुएं।',
          'वस्तुओं को किसी भी क्रम में गिनने पर कुल योग नहीं बदलता।',
        ],
        example: 'Counting 5 apples: 1, 2, 3, 4, 5 apples in total.',
        hindiExample: '5 सेब गिनना: 1, 2, 3, 4, 5 कुल सेब।',
        commonTrap: 'Skipping an object or counting the same item twice when counting quickly.',
        hindiCommonTrap: 'जल्दबाजी में किसी वस्तु को छोड़ देना या एक ही वस्तु को दो बार गिन लेना।',
        realWorldUse: 'Paying money, counting inventory, checking attendance in class.',
        hindiRealWorldUse: 'दुकान पर पैसे देना, सामान गिनना, कक्षा में उपस्थिति दर्ज करना।',
      );
    }

    if (conceptLower.contains('pattern') || conceptLower.contains('sorting') || conceptLower.contains('predicting')) {
      return ConceptDefinition(
        term: concept,
        hindiTerm: hindiConcept,
        definition: 'A pattern is a repeating or growing arrangement of numbers, shapes, or colors that follows a predictable mathematical rule.',
        hindiDefinition: 'पैटर्न संख्याओं, आकृतियों या रंगों की एक दोहराई जाने वाली या बढ़ती हुई व्यवस्था है जो एक निश्चित नियम का पालन करती है।',
        formula: 'Pattern Rule: Core Unit Repeats (e.g. AB, AAB, ABC)',
        keyPoints: [
          'Identify the repeating unit to predict what comes next.',
          'Patterns form the foundation of algebraic thinking and sequences.',
        ],
        hindiKeyPoints: [
          'आगे क्या आएगा यह जानने के लिए दोहराए जाने वाले मुख्य भाग को पहचानें।',
          'पैटर्न बीजगणित और अनुक्रमों (Sequences) का आधार हैं।',
        ],
        example: 'Red, Blue, Red, Blue, [Next is Red!]. 2, 4, 6, 8, [Next is 10!].',
        hindiExample: 'लाल, नीला, लाल, नीला, [अगला लाल होगा!]। 2, 4, 6, 8, [अगला 10 होगा!]।',
        commonTrap: 'Guessing without looking at the complete cycle of repetition.',
        hindiCommonTrap: 'दोहराव के पूरे चक्र को देखे बिना केवल अनुमान लगाना।',
        realWorldUse: 'Textile fabric designs, architectural tiling, seasons of the year, computer code.',
        hindiRealWorldUse: 'कपड़ों के डिजाइन, फर्श की टाइलें, ऋतुओं का चक्र, कंप्यूटर प्रोग्रामिंग।',
      );
    }

    // Default dynamic pedagogical synthesis tailored specifically to this chapter
    return ConceptDefinition(
      term: concept,
      hindiTerm: hindiConcept,
      definition: isEnglish
          ? 'Essential curriculum concept in ${chapter.title} (${chapter.grade}): $concept teaches students precise grammatical structure, vocabulary usage, and comprehension rules.'
          : 'Core syllabus concept in ${chapter.title} (${chapter.grade}): $concept establishes formal mathematical principles, accurate calculation methods, and problem-solving strategies.',
      hindiDefinition: isEnglish
          ? '${chapter.title} (${chapter.grade}) का महत्वपूर्ण विषय: $hindiConcept विद्यार्थियों को सटीक व्याकरण, शब्दावली और समझ के नियम सिखाता है।'
          : '${chapter.title} (${chapter.grade}) की मुख्य अवधारणा: $hindiConcept गणितीय सिद्धांतों, सटीक गणना विधियों और समस्या समाधान रणनीतियों को स्थापित करता है।',
      formula: chapter.rules.isNotEmpty ? chapter.rules.first : (isEnglish ? 'Rule of $concept' : 'Principle of $concept'),
      keyPoints: [
        'Understand the specific properties and definitions associated with $concept.',
        chapter.rules.length > 1 ? chapter.rules[1] : 'Apply standard step-by-step methods when solving exercises.',
      ],
      hindiKeyPoints: [
        '$hindiConcept से जुड़े विशिष्ट गुणों और परिभाषाओं को गहराई से समझें।',
        chapter.rules.length > 1 ? HindiCurriculumTranslator.translateRule(chapter.rules[1]) : 'अभ्यास हल करते समय मानक चरणबद्ध विधियों का पालन करें।',
      ],
      example: chapter.exampleQuestion ?? 'Applying $concept in textbook questions.',
      hindiExample: chapter.exampleQuestion != null ? HindiCurriculumTranslator.translatePrompt(chapter.exampleQuestion!) : 'पाठ्यपुस्तक के प्रश्नों में $hindiConcept का उपयोग।',
      commonTrap: chapter.mascotAdvice ?? 'Rushing calculations without reviewing the given values.',
      hindiCommonTrap: chapter.mascotAdvice != null ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!) : 'दी गई संख्याओं की दोबारा जाँच किए बिना जल्दबाजी में उत्तर देना।',
      realWorldUse: chapter.funFact ?? 'Applied in everyday life, science, commerce, and communication.',
      hindiRealWorldUse: chapter.funFact != null ? HindiCurriculumTranslator.translateStep(chapter.funFact!) : 'दैनिक जीवन, विज्ञान, वाणिज्य और संचार में व्यापक रूप से उपयोगी।',
    );
  }

  void _ensureMinimumDefinitions(
    List<ConceptDefinition> defs,
    Chapter chapter, {
    bool isEnglish = false,
  }) {
    if (defs.length >= 3) return;
    _populateChapterSpecificDefinitions(defs, chapter, isEnglish: isEnglish);
  }

  // ==========================================
  // SOLVED EXAMPLES POPULATION
  // ==========================================
  void _populateMathSolvedExamples(
    List<SolvedReadingExample> list,
    Chapter chapter,
    String gradeLower,
  ) {
    if (chapter.exampleQuestion != null) {
      list.add(
        SolvedReadingExample(
          question: chapter.exampleQuestion!,
          hindiQuestion: HindiCurriculumTranslator.translatePrompt(chapter.exampleQuestion!),
          steps: [
            'Step 1: Read the problem carefully and identify the given quantities.',
            'Step 2: Choose the appropriate formula or mathematical rule.',
            'Step 3: ${chapter.exampleExplanation ?? 'Calculate methodically to find the result.'}',
          ],
          hindiSteps: [
            'चरण 1: प्रश्न को ध्यान से पढ़ें और दी गई संख्याओं की पहचान करें।',
            'चरण 2: उपयुक्त सूत्र या गणितीय नियम का चयन करें।',
            'चरण 3: ${chapter.exampleExplanation != null ? HindiCurriculumTranslator.translateStep(chapter.exampleExplanation!) : 'परिणाम प्राप्त करने के लिए व्यवस्थित गणना करें।'}',
          ],
          finalAnswer: chapter.exampleAnswer ?? 'Solution Verified',
          hindiFinalAnswer: chapter.exampleAnswer ?? 'सत्यापित समाधान',
          conceptHighlight: chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts.first : chapter.title,
          hindiConceptHighlight: chapter.keyConcepts.isNotEmpty
              ? HindiCurriculumTranslator.translateConcept(chapter.keyConcepts.first)
              : HindiCurriculumTranslator.translateChapterTitle(chapter.title),
        ),
      );
    }

    if (list.isNotEmpty) return;

    final titleLower = chapter.title.toLowerCase();

    if (titleLower.contains('shape') || titleLower.contains('geometry') || titleLower.contains('space')) {
      list.add(
        const SolvedReadingExample(
          question: 'Which of the following shapes has zero straight edges and can roll smoothly: Cube, Triangle, or Circle?',
          hindiQuestion: 'निम्नलिखित में से किस आकृति में शून्य सीधी भुजाएँ होती हैं और वह आसानी से लुढ़क सकती है: घन, त्रिभुज या वृत्त?',
          steps: [
            'Step 1: Recall the definitions of shapes: a cube has 12 straight edges, a triangle has 3 straight edges.',
            'Step 2: A circle has a continuous curved boundary with 0 straight edges and 0 corners.',
            'Step 3: Objects with round curved surfaces roll without getting blocked by sharp corners.',
          ],
          hindiSteps: [
            'चरण 1: आकृतियों की परिभाषा याद करें: घन में 12 सीधी भुजाएँ होती हैं, त्रिभुज में 3 सीधी भुजाएँ होती हैं।',
            'चरण 2: वृत्त में 0 सीधी भुजाएँ और 0 कोने होते हैं, इसका सिरा वक्राकार होता है।',
            'चरण 3: गोल घुमावदार सतह वाली वस्तुएं कोनों की रुकावट के बिना आसानी से लुढ़कती हैं।',
          ],
          finalAnswer: 'Circle (वृत्त)',
          hindiFinalAnswer: 'वृत्त (Circle)',
          conceptHighlight: 'Curved vs Flat Surfaces',
          hindiConceptHighlight: 'घुमावदार बनाम सपाट सतह',
        ),
      );
    } else if (titleLower.contains('rational') || titleLower.contains('integer') || titleLower.contains('fraction')) {
      list.add(
        const SolvedReadingExample(
          question: 'Is the fraction -7/3 a rational number? Justify with formal definition.',
          hindiQuestion: 'क्या भिन्न -7/3 एक परिमेय संख्या है? औपचारिक परिभाषा के साथ सिद्ध करें।',
          steps: [
            'Step 1: Recall the definition of a rational number: any number in form p / q where p, q ∈ ℤ and q ≠ 0.',
            'Step 2: Here, numerator p = -7 (which is a valid integer) and denominator q = 3 (a non-zero integer).',
            'Step 3: Since both conditions are satisfied, -7/3 is classified as a rational number.',
          ],
          hindiSteps: [
            'चरण 1: परिमेय संख्या की परिभाषा: कोई भी संख्या जो p / q रूप में हो जहाँ p, q पूर्णांक हैं और q ≠ 0।',
            'चरण 2: यहाँ अंश p = -7 (एक पूर्णांक) है और हर q = 3 (एक गैर-शून्य पूर्णांक) है।',
            'चरण 3: चूँकि दोनों शर्तें पूरी होती हैं, इसलिए -7/3 एक परिमेय संख्या है।',
          ],
          finalAnswer: 'Yes, -7/3 is a valid rational number.',
          hindiFinalAnswer: 'हाँ, -7/3 एक मान्य परिमेय संख्या है।',
          conceptHighlight: 'Rational Numbers (p/q, q ≠ 0)',
          hindiConceptHighlight: 'परिमेय संख्या (p/q, q ≠ 0)',
        ),
      );
    } else if (titleLower.contains('algebra') || titleLower.contains('equation')) {
      list.add(
        const SolvedReadingExample(
          question: 'Solve the linear equation for the unknown variable x: 3x + 7 = 22',
          hindiQuestion: 'अज्ञात चर x के लिए रैखिक समीकरण हल करें: 3x + 7 = 22',
          steps: [
            'Step 1: Isolate the variable term by subtracting 7 from both sides: 3x = 22 - 7 ⟹ 3x = 15.',
            'Step 2: Divide both sides by the coefficient 3: x = 15 / 3 ⟹ x = 5.',
            'Step 3: Verification: Substitute x = 5 into 3(5) + 7 = 15 + 7 = 22 (LHS = RHS).',
          ],
          hindiSteps: [
            'चरण 1: दोनों पक्षों से 7 घटाकर चर पद को अलग करें: 3x = 22 - 7 ⟹ 3x = 15।',
            'चरण 2: दोनों पक्षों को गुणांक 3 से भाग दें: x = 15 / 3 ⟹ x = 5।',
            'चरण 3: जाँच: x = 5 रखने पर 3(5) + 7 = 15 + 7 = 22 (बायाँ पक्ष = दायाँ पक्ष)।',
          ],
          finalAnswer: 'x = 5',
          hindiFinalAnswer: 'x = 5',
          conceptHighlight: 'Balancing Linear Equations',
          hindiConceptHighlight: 'रैखिक समीकरण संतुलन',
        ),
      );
    } else if (titleLower.contains('percent') || titleLower.contains('profit') || titleLower.contains('interest')) {
      list.add(
        const SolvedReadingExample(
          question: 'Calculate the Simple Interest on a principal amount of ₹2,000 invested at 5% per annum for 3 years.',
          hindiQuestion: '₹2,000 के मूलधन पर 5% वार्षिक दर से 3 वर्ष का साधारण ब्याज ज्ञात करें।',
          steps: [
            'Step 1: Write down the known values: Principal (P) = ₹2,000, Rate (R) = 5%, Time (T) = 3 years.',
            'Step 2: Apply the standard Simple Interest formula: SI = (P × R × T) / 100.',
            'Step 3: Substitute and compute: SI = (2000 × 5 × 3) / 100 = 30000 / 100 = 300.',
          ],
          hindiSteps: [
            'चरण 1: ज्ञात मान लिखें: मूलधन (P) = ₹2,000, दर (R) = 5%, समय (T) = 3 वर्ष।',
            'चरण 2: मानक साधारण ब्याज सूत्र लागू करें: SI = (P × R × T) / 100।',
            'चरण 3: मान रखकर गणना करें: SI = (2000 × 5 × 3) / 100 = 30000 / 100 = 300।',
          ],
          finalAnswer: 'Simple Interest = ₹300',
          hindiFinalAnswer: 'साधारण ब्याज = ₹300',
          conceptHighlight: 'SI = (P × R × T) / 100',
          hindiConceptHighlight: 'साधारण ब्याज सूत्र',
        ),
      );
    } else {
      list.add(
        SolvedReadingExample(
          question: 'Apply core mathematical concepts from ${chapter.title} to calculate the step-by-step result.',
          hindiQuestion: '${chapter.title} की मुख्य अवधारणाओं को लागू करके चरणबद्ध परिणाम प्राप्त करें।',
          steps: [
            'Step 1: Read the problem carefully and note all given numerical data and units.',
            'Step 2: Identify the fundamental rules and operation order applicable to this topic.',
            'Step 3: Execute calculations methodically and re-check with inverse operations.',
          ],
          hindiSteps: [
            'चरण 1: प्रश्न को ध्यान से पढ़ें और सभी संख्यात्मक मान व इकाइयाँ नोट करें।',
            'चरण 2: इस विषय पर लागू होने वाले मूलभूत नियमों और क्रम की पहचान करें।',
            'चरण 3: व्यवस्थित गणना करें और विपरीत संक्रिया से पुनः जाँच करें।',
          ],
          finalAnswer: 'Step-by-Step Solution Verified',
          hindiFinalAnswer: 'चरणबद्ध समाधान सत्यापित',
          conceptHighlight: chapter.title,
          hindiConceptHighlight: HindiCurriculumTranslator.translateChapterTitle(chapter.title),
        ),
      );
    }
  }

  void _populateEnglishSolvedExamples(
    List<SolvedReadingExample> list,
    Chapter chapter,
    String gradeLower,
  ) {
    if (chapter.exampleQuestion != null) {
      list.add(
        SolvedReadingExample(
          question: chapter.exampleQuestion!,
          hindiQuestion: HindiCurriculumTranslator.translatePrompt(chapter.exampleQuestion!),
          steps: [
            'Step 1: Examine the sentence structure and identify the key grammar parts.',
            'Step 2: Apply the relevant grammatical rule or phonics sound principle.',
            'Step 3: ${chapter.exampleExplanation ?? 'Select the grammatically accurate word.'}',
          ],
          hindiSteps: [
            'चरण 1: वाक्य की संरचना की जांच करें और मुख्य व्याकरणिक अंगों को पहचानें।',
            'चरण 2: संबंधित व्याकरण नियम या ध्वनि सिद्धांत लागू करें।',
            'चरण 3: ${chapter.exampleExplanation != null ? HindiCurriculumTranslator.translateStep(chapter.exampleExplanation!) : 'व्याकरण की दृष्टि से सही शब्द का चयन करें।'}',
          ],
          finalAnswer: chapter.exampleAnswer ?? 'Correct Word Choice',
          hindiFinalAnswer: chapter.exampleAnswer ?? 'सही शब्द चयन',
          conceptHighlight: chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts.first : chapter.title,
          hindiConceptHighlight: chapter.keyConcepts.isNotEmpty
              ? HindiCurriculumTranslator.translateConcept(chapter.keyConcepts.first)
              : HindiCurriculumTranslator.translateChapterTitle(chapter.title),
        ),
      );
    }

    if (list.isNotEmpty) return;

    final titleLower = chapter.title.toLowerCase();

    if (titleLower.contains('phonic') || titleLower.contains('alphabet') || titleLower.contains('rhym')) {
      list.add(
        const SolvedReadingExample(
          question: 'Which word rhymes with "Bat" and begins with the sound /m/: Dog, Mat, or Sun?',
          hindiQuestion: 'कौन सा शब्द "Bat" के साथ तुकबंदी करता है और /m/ ध्वनि से शुरू होता है: Dog, Mat या Sun?',
          steps: [
            'Step 1: Identify the ending sound of "Bat", which is "-at".',
            'Step 2: Rhyming words must end with the exact same "-at" sound.',
            'Step 3: Mat ends with "-at" and starts with the letter sound /m/ (M-at).',
          ],
          hindiSteps: [
            'चरण 1: "Bat" की अंतिम ध्वनि पहचानें, जो "-at" है।',
            'चरण 2: तुकबंदी वाले शब्द की अंतिम ध्वनि भी ठीक "-at" होनी चाहिए।',
            'चरण 3: Mat "-at" पर समाप्त होता है और /m/ ध्वनि से शुरू होता है।',
          ],
          finalAnswer: 'Mat',
          hindiFinalAnswer: 'Mat (चटाई)',
          conceptHighlight: 'Phonics & Rhyming Words',
          hindiConceptHighlight: 'ध्वनि एवं तुकबंदी',
        ),
      );
    } else if (titleLower.contains('noun') || titleLower.contains('pronoun')) {
      list.add(
        const SolvedReadingExample(
          question: 'Identify the Proper Noun and Common Noun in: "Kavita visited the historical museum yesterday."',
          hindiQuestion: 'इस वाक्य में व्यक्तिवाचक संज्ञा (Proper) और जातिवाचक संज्ञा (Common) पहचानें: "Kavita visited the historical museum yesterday."',
          steps: [
            'Step 1: Identify all naming words in the sentence: "Kavita" and "museum".',
            'Step 2: "Kavita" is the specific name of an individual, starting with a capital letter ⟹ Proper Noun.',
            'Step 3: "museum" refers generally to any exhibition building ⟹ Common Noun.',
          ],
          hindiSteps: [
            'चरण 1: वाक्य में संज्ञा शब्दों की पहचान करें: "Kavita" और "museum"।',
            'चरण 2: "Kavita" एक विशिष्ट व्यक्ति का नाम है और बड़े अक्षर से शुरू है ⟹ व्यक्तिवाचक संज्ञा (Proper Noun)।',
            'चरण 3: "museum" सामान्य स्थान का नाम है ⟹ जातिवाचक संज्ञा (Common Noun)।',
          ],
          finalAnswer: 'Proper Noun: Kavita | Common Noun: museum',
          hindiFinalAnswer: 'व्यक्तिवाचक संज्ञा: Kavita | जातिवाचक संज्ञा: museum',
          conceptHighlight: 'Proper vs Common Nouns',
          hindiConceptHighlight: 'व्यक्तिवाचक बनाम जातिवाचक संज्ञा',
        ),
      );
    } else if (titleLower.contains('voice')) {
      list.add(
        const SolvedReadingExample(
          question: 'Convert the following Active Voice sentence into Passive Voice: "The artist painted a magnificent landscape."',
          hindiQuestion: 'निम्नलिखित Active Voice वाक्य को Passive Voice में बदलें: "The artist painted a magnificent landscape."',
          steps: [
            'Step 1: Identify the components: Subject = "The artist", Verb = "painted" (Simple Past), Object = "a magnificent landscape".',
            'Step 2: Move the object to the front as the new subject: "A magnificent landscape".',
            'Step 3: Add past auxiliary "was" + Past Participle V3 "painted" + "by" + original subject: "by the artist".',
          ],
          hindiSteps: [
            'चरण 1: अंगों की पहचान करें: कर्ता = "The artist", क्रिया = "painted" (भूतकाल), कर्म = "a magnificent landscape"।',
            'चरण 2: कर्म को आगे लाकर नया कर्ता बनाएं: "A magnificent landscape"।',
            'चरण 3: सहायक क्रिया "was" + V3 "painted" + "by the artist" जोड़ें।',
          ],
          finalAnswer: 'A magnificent landscape was painted by the artist.',
          hindiFinalAnswer: 'A magnificent landscape was painted by the artist.',
          conceptHighlight: 'Active to Passive Voice',
          hindiConceptHighlight: 'कर्तृवाच्य से कर्मवाच्य परिवर्तन',
        ),
      );
    } else {
      list.add(
        SolvedReadingExample(
          question: 'Identify the key grammatical element and correct usage for topics in ${chapter.title}.',
          hindiQuestion: '${chapter.title} के विषयों के लिए मुख्य व्याकरणिक तत्व और सही प्रयोग की पहचान करें।',
          steps: [
            'Step 1: Read the sentence aloud and observe the subject, verb, and tense.',
            'Step 2: Apply the governing grammatical rule or phonetic pattern.',
            'Step 3: Verify agreement and punctuation to ensure clear, flawless meaning.',
          ],
          hindiSteps: [
            'चरण 1: वाक्य को बोलकर पढ़ें और कर्ता, क्रिया और काल पर ध्यान दें।',
            'चरण 2: संबंधित व्याकरण नियम या ध्वनि पैटर्न को लागू करें।',
            'चरण 3: अर्थ की स्पष्टता सुनिश्चित करने के लिए तालमेल और विराम चिह्नों की जाँच करें।',
          ],
          finalAnswer: 'Grammar Rule Applied Correctly',
          hindiFinalAnswer: 'व्याकरण नियम का सही प्रयोग',
          conceptHighlight: chapter.title,
          hindiConceptHighlight: HindiCurriculumTranslator.translateChapterTitle(chapter.title),
        ),
      );
    }
  }

  // ==========================================
  // MATHEMATICS DETAILED TEXTBOOK SECTIONS
  // ==========================================
  void _populateMathTextbookSections(
    List<ChapterSection> sections,
    List<String> points,
    List<String> hindiPoints,
    List<String> facts,
    List<String> hindiFacts,
    Chapter chapter,
    String titleLower,
    String gradeLower,
  ) {
    if (chapter.keyConcepts.isNotEmpty) {
      sections.addAll([
        ChapterSection(
          sectionNumber: '1.1',
          title: 'Foundations of ${chapter.title}',
          hindiTitle: '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के आधारभूत सिद्धांत',
          content: chapter.description.isNotEmpty
              ? '${chapter.description} In this chapter, students explore foundational principles including: ${chapter.keyConcepts.join(", ")}. Understanding these concepts develops critical problem-solving skills and rigorous analytical thinking.'
              : 'Mastering ${chapter.title} builds core mastery in ${chapter.grade} curriculum. In this chapter, students explore foundational principles including: ${chapter.keyConcepts.join(", ")}. Understanding these concepts develops critical problem-solving skills and rigorous analytical thinking.',
          hindiContent: '${HindiCurriculumTranslator.translateChapterDescription(chapter.description.isNotEmpty ? chapter.description : chapter.title, chapter.title)} इस अध्याय में विद्यार्थी मुख्य अवधारणाओं का गहन अध्ययन करते हैं: ${chapter.keyConcepts.map((c) => HindiCurriculumTranslator.translateConcept(c)).join(", ")}। इन सिद्धांतों को समझकर तार्किक एवं विश्लेषणात्मक चिंतन मजबूत होता है।',
          calloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? chapter.mascotAdvice!
              : 'Read each definition and rule carefully before applying formulas to questions.',
          hindiCalloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
              : 'प्रश्नों को हल करने से पहले प्रत्येक परिभाषा और नियम को ध्यानपूर्वक पढ़ें।',
          quickCheckQuestion: 'What are the foundational key concepts covered in ${chapter.title}?',
          hindiQuickCheckQuestion: '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} में मुख्य रूप से कौन-सी अवधारणाएँ शामिल हैं?',
          quickCheckAnswer: chapter.keyConcepts.join(', '),
          hindiQuickCheckAnswer: chapter.keyConcepts.map((c) => HindiCurriculumTranslator.translateConcept(c)).join(', '),
        ),
        ChapterSection(
          sectionNumber: '1.2',
          title: 'Core Rules & Principles of ${chapter.title}',
          hindiTitle: '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के प्रमुख नियम एवं सूत्र',
          content: chapter.rules.isNotEmpty
              ? 'Every topic in ${chapter.title} is governed by fundamental mathematical principles and proven rules. Applying these rules systematically ensures accuracy and speed in calculations:\n\n${chapter.rules.asMap().entries.map((e) => "• Rule ${e.key + 1}: ${e.value}").join("\n")}'
              : 'Mastering the standard properties and analytical techniques of ${chapter.title} provides a consistent foundation for all higher mathematics.',
          hindiContent: chapter.rules.isNotEmpty
              ? '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के सभी प्रश्न निश्चित गणितीय नियमों और सिद्धांतों पर आधारित होते हैं। इन नियमों का पालन करने से गणना में सटीकता और गति मिलती है:\n\n${chapter.rules.asMap().entries.map((e) => "• नियम ${e.key + 1}: ${HindiCurriculumTranslator.translateRule(e.value)}").join("\n")}'
              : '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के मूलभूत सिद्धांतों को समझना उच्चतर गणित की नींव को मजबूत करता है।',
          keyFormula: chapter.rules.isNotEmpty ? chapter.rules.first : '${chapter.title} Core Principles',
          calloutTip: 'Always verify boundary conditions and check for calculation traps before submitting your answer!',
          hindiCalloutTip: 'अंतिम उत्तर लिखने से पहले गणना की सटीकता और सीमा शर्तों की पुनः जाँच अवश्य करें!',
          quickCheckQuestion: chapter.rules.isNotEmpty
              ? 'What is a key rule to remember for ${chapter.title}?'
              : 'Why are core rules important in ${chapter.title}?',
          hindiQuickCheckQuestion: chapter.rules.isNotEmpty
              ? '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} का मुख्य नियम क्या है?'
              : 'नियमों का पालन क्यों आवश्यक है?',
          quickCheckAnswer: chapter.rules.isNotEmpty ? chapter.rules.first : 'They guarantee consistent, correct problem-solving.',
          hindiQuickCheckAnswer: chapter.rules.isNotEmpty ? HindiCurriculumTranslator.translateRule(chapter.rules.first) : 'वे सटीक और सही समाधान सुनिश्चित करते हैं।',
        ),
        ChapterSection(
          sectionNumber: '1.3',
          title: 'Classroom Solved Problem & Demonstration',
          hindiTitle: 'कक्षा में हल किया गया आदर्श प्रश्न',
          content: 'Exemplar Problem Demonstration:\nQuestion: ${chapter.exampleQuestion ?? "Standard solved problem for ${chapter.title}."}\n\nStep-by-Step Method:\n${chapter.exampleExplanation ?? "Apply the core rules of ${chapter.title} step by step to arrive at the solution."}\n\nFinal Conclusion: ${chapter.exampleAnswer ?? "The solution is derived systematically."}',
          hindiContent: 'आदर्श उदाहरण हल:\nप्रश्न: ${HindiCurriculumTranslator.translateStep(chapter.exampleQuestion ?? chapter.title)}\n\nचरणबद्ध विधि:\n${HindiCurriculumTranslator.translateStep(chapter.exampleExplanation ?? "चरणबद्ध रूप से नियमों को लागू करें।")}\n\nअंतिम उत्तर: ${HindiCurriculumTranslator.translateStep(chapter.exampleAnswer ?? "समाधान प्राप्त हुआ।")}',
          calloutTip: 'Notice how breaking down the question into clear steps prevents careless errors.',
          hindiCalloutTip: 'प्रश्न को छोटे-छोटे चरणों में बाँटकर हल करने से गलतियों की संभावना समाप्त हो जाती है।',
          quickCheckQuestion: chapter.exampleQuestion != null
              ? 'In the solved example for ${chapter.title}, what was the target answer?'
              : 'How should you approach solved examples?',
          hindiQuickCheckQuestion: chapter.exampleQuestion != null
              ? 'दिए गए उदाहरण में अंतिम उत्तर क्या था?'
              : 'प्रश्नों को हल करने का सही तरीका क्या है?',
          quickCheckAnswer: chapter.exampleAnswer ?? 'Follow systematic step-by-step reasoning.',
          hindiQuickCheckAnswer: chapter.exampleAnswer != null
              ? HindiCurriculumTranslator.translateStep(chapter.exampleAnswer!)
              : 'चरणबद्ध तार्किक विधि का पालन करें।',
        ),
        ChapterSection(
          sectionNumber: '1.4',
          title: 'Real-World Wonder & Curiosity',
          hindiTitle: 'व्यावहारिक उपयोग एवं रोचक तथ्य',
          content: 'Real-World Application:\n${chapter.funFact ?? "The concepts of ${chapter.title} are used across engineering, science, economics, and everyday decision making."}\n\nExpert Tip:\n${chapter.mascotAdvice ?? "Consistently revise the core definitions and test your understanding through practice questions."}',
          hindiContent: 'दैनिक जीवन में उपयोग:\n${HindiCurriculumTranslator.translateStep(chapter.funFact ?? "${chapter.title} की अवधारणाओं का उपयोग विज्ञान, प्रौद्योगिकी और दैनिक जीवन में होता है।")}\n\nविशेषज्ञ सलाह:\n${HindiCurriculumTranslator.translateHint(chapter.mascotAdvice ?? "अवधारणाओं को नियमित रूप से दोहराएं और अभ्यास प्रश्नों को हल करें।")}',
          calloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? chapter.mascotAdvice!
              : 'Practice makes math intuitive and fun!',
          hindiCalloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
              : 'नियमित अभ्यास से गणित सरल और रोचक बन जाता है!',
          quickCheckQuestion: 'Where is ${chapter.title} applied in real-world scenarios?',
          hindiQuickCheckQuestion: 'वास्तविक दुनिया में ${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} का क्या उपयोग है?',
          quickCheckAnswer: chapter.funFact ?? 'In everyday life, sciences, architecture, and problem solving.',
          hindiQuickCheckAnswer: chapter.funFact != null
              ? HindiCurriculumTranslator.translateStep(chapter.funFact!)
              : 'दैनिक जीवन, विज्ञान और समस्याओं के समाधान में।',
        ),
      ]);

      for (final r in chapter.rules) {
        if (!points.contains(r)) {
          points.add(r);
          hindiPoints.add(HindiCurriculumTranslator.translateRule(r));
        }
      }
      points.add('Master all ${chapter.keyConcepts.length} core concepts: ${chapter.keyConcepts.join(", ")}.');
      hindiPoints.add('सभी ${chapter.keyConcepts.length} मुख्य अवधारणाओं में महारत हासिल करें: ${chapter.keyConcepts.map((c) => HindiCurriculumTranslator.translateConcept(c)).join(", ")}।');
      points.add('Always verify units and mathematical steps carefully in ${chapter.title}.');
      hindiPoints.add('${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} में हमेशा इकाइयों और गणितीय चरणों की सावधानीपूर्वक जाँच करें।');

      if (chapter.funFact != null && chapter.funFact!.trim().isNotEmpty) {
        facts.add(chapter.funFact!.trim());
        hindiFacts.add(HindiCurriculumTranslator.translateStep(chapter.funFact!.trim()));
      }
      if (facts.isEmpty) {
        facts.add('Mathematics is the universal language of patterns, reasoning, and discoveries across nature!');
        hindiFacts.add('गणित प्रकृति में प्रतिमानों, तर्क और खोजों की सार्वभौमिक भाषा है!');
      }
      return;
    }

    if (titleLower.contains('shape') ||
        titleLower.contains('geometry') ||
        (titleLower.contains('line') && !titleLower.contains('linear')) ||
        titleLower.contains('angle') ||
        titleLower.contains('triangle') ||
        titleLower.contains('quadrilateral') ||
        titleLower.contains('circle') ||
        titleLower.contains('area') ||
        titleLower.contains('perimeter') ||
        titleLower.contains('volume') ||
        titleLower.contains('mensuration')) {
      sections.addAll([
        const ChapterSection(
          sectionNumber: '1.1',
          title: 'Foundations of Space & Dimensionality',
          hindiTitle: 'स्थान एवं विमाओं के आधारभूत सिद्धांत',
          content: 'Every object in our physical universe occupies space. Two-dimensional (2D) shapes are completely flat plane figures having only length and breadth with zero thickness—such as circles, rectangles, squares, and triangles. In contrast, three-dimensional (3D) objects possess length, breadth, and height or depth—such as cubes, cylinders, cones, and spheres. The physical boundary of a shape governs its motion: objects with flat plane faces slide smoothly along surfaces, whereas objects with continuous curved boundaries roll with minimal frictional resistance.',
          hindiContent: 'हमारे भौतिक ब्रह्मांड की प्रत्येक वस्तु स्थान घेरती है। द्वि-आयामी (2D) आकृतियाँ पूरी तरह से समतल होती हैं जिनमें केवल लंबाई और चौड़ाई होती है (मोटाई शून्य होती है)—जैसे वृत्त, आयत, वर्ग और त्रिभुज। इसके विपरीत, त्रि-आयामी (3D) ठोस वस्तुओं में लंबाई, चौड़ाई और ऊंचाई या गहराई तीनों विमाएँ होती हैं—जैसे घन, बेलन, शंकु और गोला। किसी आकृति की सतह उसकी गति तय करती है: सपाट सतह वाली वस्तुएं फिसलती हैं, जबकि घुमावदार सतह वाली वस्तुएं आसानी से लुढ़कती हैं।',
          calloutTip: 'A cylinder and a coin have BOTH flat circular faces and a curved surface, allowing them to both slide and roll!',
          hindiCalloutTip: 'एक बेलन या सिक्के में सपाट और घुमावदार दोनों सतहें होती हैं, इसलिए वह लुढ़क भी सकता है और फिसल भी सकता है!',
          quickCheckQuestion: 'Which motion occurs when a flat-bottomed wooden block is pushed across a table: Rolling or Sliding?',
          hindiQuickCheckQuestion: 'सपाट आधार वाले लकड़ी के गुटके को मेज पर धक्का देने पर क्या होता है: लुढ़कना या फिसलना?',
          quickCheckAnswer: 'Sliding (फिसलना), because flat surfaces maintain surface contact and cannot roll.',
          hindiQuickCheckAnswer: 'फिसलना (Sliding), क्योंकि सपाट सतहें लगातार संपर्क में रहती हैं और लुढ़क नहीं सकतीं।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'Angles, Lines & Polygon Classification',
          hindiTitle: 'कोण, रेखाएँ एवं बहुभुजों का वर्गीकरण',
          content: 'Lines form the framework of all rectilinear geometry. When two straight lines share a common endpoint (vertex), they form an angle measured in degrees (°). Angles are classified into four primary categories: Acute (< 90°), Right (= 90°), Obtuse (> 90° and < 180°), and Straight (= 180°). A closed polygon bounded entirely by straight line segments has specific angle sum properties: the interior angles of any triangle always add up to exactly 180° (Angle Sum Property: ∠A + ∠B + ∠C = 180°), while any four-sided quadrilateral has interior angles summing to 360°.',
          hindiContent: 'सीधी रेखाएँ ज्यामिति का आधार हैं। जब दो किरणें एक ही उभयनिष्ठ शीर्ष से निकलती हैं, तो वे एक कोण बनाती हैं जिसे अंश (डिग्री °) में मापा जाता है। कोण चार मुख्य प्रकार के होते हैं: न्यून कोण (< 90°), समकोण (= 90°), अधिक कोण (> 90° और < 180°), तथा ऋजु कोण (= 180°)। किसी भी त्रिभुज के तीनों अंतःकोणों का योग हमेशा ठीक 180° होता है (∠A + ∠B + ∠C = 180°), तथा किसी भी चतुर्भुज के चारों अंतःकोणों का योग 360° होता है।',
          keyFormula: 'Triangle Angle Sum: ∠A + ∠B + ∠C = 180° • Quadrilateral: Sum = 360°',
          calloutTip: 'Parallel lines never intersect, no matter how far they are extended in either direction.',
          hindiCalloutTip: 'समांतर रेखाएँ कभी भी एक दूसरे को नहीं काटतीं, चाहे उन्हें दोनों ओर कितना भी आगे बढ़ाया जाए।',
          quickCheckQuestion: 'If two angles in a triangle are 50° and 60°, what is the exact measurement of the third angle?',
          hindiQuickCheckQuestion: 'यदि किसी त्रिभुज के दो कोण 50° और 60° हैं, तो तीसरे कोण का मान क्या होगा?',
          quickCheckAnswer: '70° (180° - 50° - 60° = 70°).',
          hindiQuickCheckAnswer: '70° (180° - 50° - 60° = 70°)।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Mensuration: Perimeter, Area & Boundary Measures',
          hindiTitle: 'क्षेत्रमिति: परिमाप, क्षेत्रफल एवं सीमा मापन',
          content: 'Mensuration is the branch of mathematics dealing with the geometric measurement of lengths, surfaces, and volumes. Perimeter is the total linear distance around the outside edge of a closed 2D shape (measured in linear units: cm, m). Area is the total measure of flat planar surface enclosed within the boundary (measured in square units: cm², m²). For a rectangle of length l and breadth b, Perimeter = 2(l + b) and Area = l × b. For a circle of radius r, the boundary circumference is 2πr and the enclosed area is πr².',
          hindiContent: 'क्षेत्रमिति गणित की वह शाखा है जो लंबाइयों, सतहों और आयतनों के मापन से संबंधित है। परिमाप किसी बंद 2D आकृति के बाहरी घेरे की कुल लंबाई है (इकाई: सेमी, मीटर)। क्षेत्रफल उस आकृति की बंद सीमाओं के भीतर घिरे समतल क्षेत्र का माप है (इकाई: वर्ग सेमी, वर्ग मीटर)। लंबाई l और चौड़ाई b वाले आयत के लिए: परिमाप = 2(l + b) और क्षेत्रफल = l × b। त्रिज्या r वाले वृत्त की परिधि = 2πr और क्षेत्रफल = πr² होता है।',
          keyFormula: 'Rectangle: Area = l × b, P = 2(l + b) • Square: Area = s², P = 4s • Circle: Area = πr², C = 2πr',
          calloutTip: 'Never confuse perimeter with area! Perimeter is fence length (cm); area is the grass field enclosed (cm²).',
          hindiCalloutTip: 'परिमाप और क्षेत्रफल में कभी भ्रम न रखें! परिमाप बाड़ की लंबाई (सेमी) है; क्षेत्रफल अंदर की ज़मीन (वर्ग सेमी) है।',
          quickCheckQuestion: 'A rectangular garden is 10 m long and 4 m wide. What is its perimeter and area?',
          hindiQuickCheckQuestion: 'एक आयताकार बगीचा 10 मीटर लंबा और 4 मीटर चौड़ा है। इसका परिमाप और क्षेत्रफल क्या होगा?',
          quickCheckAnswer: 'Perimeter = 2(10 + 4) = 28 m; Area = 10 × 4 = 40 m².',
          hindiQuickCheckAnswer: 'परिमाप = 2(10 + 4) = 28 मीटर; क्षेत्रफल = 10 × 4 = 40 वर्ग मीटर।',
        ),
        const ChapterSection(
          sectionNumber: '1.4',
          title: 'Solid Shapes, Capacity & Spatial Applications',
          hindiTitle: 'ठोस आकृतियाँ, धारिता एवं त्रिविम अनुप्रयोग',
          content: 'When two-dimensional planes combine in three dimensions, they enclose space termed volume or capacity. A rectangular cuboid of length l, breadth b, and height h has Volume = l × b × h. Capacity measures how much liquid or fluid a container can hold (where 1,000 cm³ = 1 Liter). For regular convex polyhedra, Euler proved the universal topological invariant: Vertices - Edges + Faces = 2 (V - E + F = 2). For instance, a cube has 8 vertices, 12 edges, and 6 faces: 8 - 12 + 6 = 2.',
          hindiContent: 'जब 2D समतल आपस में मिलकर त्रिविम स्थान घेरते हैं, तो उसे आयतन (Volume) या धारिता (Capacity) कहते हैं। लंबाई l, चौड़ाई b और ऊंचाई h वाले घनाभ का आयतन = l × b × h होता है। धारिता यह दर्शाती है कि बर्तन में कितना तरल आ सकता है (1000 घन सेमी = 1 लीटर)। उत्तल बहुफलकों के लिए यूलर का सार्वभौमिक सूत्र लागू होता है: शीर्ष - किनारे + फलक = 2 (V - E + F = 2)। जैसे घन में: 8 - 12 + 6 = 2।',
          keyFormula: 'Cuboid Volume = l × b × h • Cube Volume = s³ • Euler\'s Formula: V - E + F = 2',
          calloutTip: '1 cubic meter (1 m³) holds exactly 1,000 liters of water!',
          hindiCalloutTip: '1 घन मीटर (1 m³) पानी की टंकी में ठीक 1,000 लीटर पानी समाता है!',
          quickCheckQuestion: 'How many faces, edges, and vertices does a standard playing dice (cube) possess?',
          hindiQuickCheckQuestion: 'एक पासे (घन) में कितने फलक, किनारे और शीर्ष होते हैं?',
          quickCheckAnswer: '6 Faces, 12 Edges, and 8 Vertices.',
          hindiQuickCheckAnswer: '6 फलक (Faces), 12 किनारे (Edges), और 8 शीर्ष (Vertices)।',
        ),
      ]);

      points.addAll([
        '2D shapes possess 2 dimensions (length, breadth); 3D solids possess 3 dimensions (length, breadth, height).',
        'Flat plane faces slide; round curved surfaces roll.',
        'The interior angle sum of a triangle is 180°; a quadrilateral is 360°.',
        'Perimeter measures boundary length (cm, m); area measures enclosed surface (cm², m²).',
        'Volume measures enclosed 3D capacity (cm³, m³), where 1,000 cm³ = 1 Liter.',
      ]);
      hindiPoints.addAll([
        '2D आकृतियों में 2 विमाएँ (लंबाई, चौड़ाई) होती हैं; 3D ठोस में 3 विमाएँ (लंबाई, चौड़ाई, ऊंचाई) होती हैं।',
        'सपाट सतह वाली वस्तुएं फिसलती हैं; घुमावदार सतह वाली वस्तुएं लुढ़कती हैं।',
        'त्रिभुज के अंतःकोणों का योग 180° तथा चतुर्भुज का 360° होता है।',
        'परिमाप बाहरी सीमा की लंबाई (सेमी) है; क्षेत्रफल घिरी सतह (वर्ग सेमी) है।',
        'आयतन 3D अंतरिक्ष की धारिता मापता है (घन सेमी), जहाँ 1,000 घन सेमी = 1 लीटर।',
      ]);

      facts.addAll([
        'Honeybees construct hexagonal honeycomb cells because hexagons use the minimum perimeter of beeswax while maximizing honey storage volume!',
        'Among all geometric shapes of a given perimeter, the circle encloses the absolute maximum area—which is why soap bubbles naturally form spheres.',
      ]);
      hindiFacts.addAll([
        'मधुमक्खियाँ षट्कोणीय (Hexagonal) छत्ते बनाती हैं क्योंकि षट्कोण मोम की न्यूनतम सीमा में अधिकतम शहद भंडारण करता है!',
        'दिए गए परिमाप में वृत्त सबसे अधिक क्षेत्रफल घेरता है—यही कारण है कि साबुन के बुलबुले स्वाभाविक रूप से गोल बनते हैं।',
      ]);
    } else if (titleLower.contains('number') ||
        titleLower.contains('integer') ||
        titleLower.contains('fraction') ||
        titleLower.contains('decimal') ||
        titleLower.contains('rational') ||
        titleLower.contains('factor') ||
        titleLower.contains('multiple') ||
        titleLower.contains('place value') ||
        titleLower.contains('exponent') ||
        titleLower.contains('power') ||
        titleLower.contains('set')) {
      sections.addAll([
        const ChapterSection(
          sectionNumber: '1.1',
          title: 'The Number System & The Real Number Line',
          hindiTitle: 'संख्या पद्धति एवं वास्तविक संख्या रेखा',
          content: 'Human civilization developed numbers to count objects, record trade, and measure the physical world. The natural counting numbers N = {1, 2, 3, ...} were expanded by Indian mathematicians who codified zero (0) to create Whole numbers W = {0, 1, 2, 3, ...}. When subtraction of larger from smaller numbers arose, negative numbers were introduced, completing the set of Integers Z = {..., -3, -2, -1, 0, 1, 2, 3, ...}. On a horizontal number line, numbers increase in value as you move to the right, and decrease as you move to the left. Zero is the neutral origin.',
          hindiContent: 'मानव सभ्यता ने वस्तुओं की गिनती, व्यापार और मापन के लिए संख्याओं का आविष्कार किया। प्राकृतिक संख्याएं N = {1, 2, 3, ...} थीं। भारतीय गणितज्ञों द्वारा शून्य (0) के आविष्कार ने पूर्ण संख्याओं W = {0, 1, 2, 3, ...} को जन्म दिया। छोटी संख्या से बड़ी घटाने पर ऋणात्मक संख्याएं आईं, जिससे पूर्णांक Z = {..., -3, -2, -1, 0, 1, 2, 3, ...} बने। संख्या रेखा पर दाईं ओर मान बढ़ता है और बाईं ओर घटता है। शून्य उदासीन केंद्र है।',
          calloutTip: 'Greater magnitude in negative numbers means smaller actual value: -50 is far smaller than -2!',
          hindiCalloutTip: 'ऋणात्मक संख्याओं में बड़ा अंक वास्तव में छोटा मान होता है: -50 संख्या -2 से बहुत छोटी है!',
          quickCheckQuestion: 'Which integer is larger: -15 or -3?',
          hindiQuickCheckQuestion: 'कौन सा पूर्णांक बड़ा है: -15 या -3?',
          quickCheckAnswer: '-3, because it lies further to the right on the number line.',
          hindiQuickCheckAnswer: '-3, क्योंकि यह संख्या रेखा पर अधिक दाईं ओर स्थित है।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'Integer Arithmetic & Sign Transformation Laws',
          hindiTitle: 'पूर्णांक अंकगणित एवं चिह्न परिवर्तन के नियम',
          content: 'Arithmetic with directed numbers follows strict sign laws. Addition of two integers with like signs preserves the sign (e.g. (+3) + (+5) = +8; (-4) + (-6) = -10). When adding integers with unlike signs, subtract the smaller absolute value from the larger, and attach the sign of the larger absolute value (e.g. (-9) + (+4) = -5). Subtraction is performed by adding the additive inverse: a - b = a + (-b). Multiplication and division obey four universal rules: (+) × (+) = (+), (-) × (-) = (+), (+) × (-) = (-), and (-) × (+) = (-).',
          hindiContent: 'चिह्नित संख्याओं के साथ गणना निश्चित नियमों पर आधारित होती है। समान चिह्नों को जोड़ने पर वही चिह्न रहता है: (+3) + (+5) = +8; (-4) + (-6) = -10। असमान चिह्नों में बड़े मान से छोटा घटाएं और बड़े का चिह्न लगाएं: (-9) + (+4) = -5। घटाना योज्य प्रतिलोम जोड़ने के समान है: a - b = a + (-b)। गुणा और भाग के नियम: समान चिह्नों का गुणनफल धनात्मक (+) होता है; असमान चिह्नों का गुणनफल ऋणात्मक (-) होता है।',
          keyFormula: 'Additive Inverse: a + (-a) = 0 • Product: (-) × (-) = (+) • (-) × (+) = (-)',
          calloutTip: 'Subtracting a negative number is identical to adding a positive number: 7 - (-3) = 7 + 3 = 10!',
          hindiCalloutTip: 'ऋणात्मक संख्या को घटाना धनात्मक जोड़ने के बराबर है: 7 - (-3) = 7 + 3 = 10!',
          quickCheckQuestion: 'Compute the value of: (-6) × (-4) + (-10)',
          hindiQuickCheckQuestion: 'मान ज्ञात करें: (-6) × (-4) + (-10)',
          quickCheckAnswer: '14 ((-6) × (-4) = +24; 24 + (-10) = 14).',
          hindiQuickCheckAnswer: '14 ((-6) × (-4) = +24; 24 + (-10) = 14)।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Rational Numbers, Fractions & Decimals',
          hindiTitle: 'परिमेय संख्याएँ, भिन्न एवं दशमलव',
          content: 'A rational number is formally defined as any number that can be expressed in the quotient form p / q, where both p and q are integers and the denominator q is NOT zero (q ≠ 0). All integers are rational numbers because they can be written with denominator 1 (e.g. 5 = 5/1). Every rational number can be represented as either a terminating decimal (e.g. 1/4 = 0.25) or a non-terminating repeating decimal (e.g. 1/3 = 0.333...). Rational numbers satisfy Closure, Commutative, and Associative properties under addition and multiplication.',
          hindiContent: 'परिमेय संख्या वह कोई भी संख्या है जिसे p / q के भिन्न रूप में लिखा जा सकता है, जहाँ p और q दोनों पूर्णांक हैं तथा हर q कभी भी शून्य नहीं होता (q ≠ 0)। सभी पूर्णांक परिमेय होते हैं (उदा. 5 = 5/1)। प्रत्येक परिमेय संख्या या तो शांत दशमलव (1/4 = 0.25) होती है या अशांत आवर्ती दशमलव (1/3 = 0.333...)। परिमेय संख्याएं योग और गुणा के अंतर्गत संवृत, क्रमविनिमेय और साहचर्य नियमों का पालन करती हैं।',
          keyFormula: 'Rational Number Form: p / q (where p, q ∈ Z and q ≠ 0)',
          calloutTip: 'Division by zero is mathematically undefined: 7/0 does not equal infinity, it is strictly invalid!',
          hindiCalloutTip: 'शून्य से भाग गणित में अपरिभाषित है: 7/0 कोई मान्य संख्या नहीं है!',
          quickCheckQuestion: 'Is 0.75 a rational number? If yes, express it as p / q in simplest form.',
          hindiQuickCheckQuestion: 'क्या 0.75 एक परिमेय संख्या है? यदि हाँ, तो इसे सरलतम रूप p / q में लिखें।',
          quickCheckAnswer: 'Yes, 0.75 = 75/100 = 3/4.',
          hindiQuickCheckAnswer: 'हाँ, 0.75 = 75/100 = 3/4 (सरलतम भिन्न)।',
        ),
        const ChapterSection(
          sectionNumber: '1.4',
          title: 'Prime Factorization, Divisibility & HCF / LCM',
          hindiTitle: 'अभाज्य गुणनखंडन, विभाज्यता एवं म.स.प. / ल.स.प.',
          content: 'A prime number is a positive integer greater than 1 that has exactly two distinct factors: 1 and itself (2, 3, 5, 7, 11, ...). 1 is NEITHER prime NOR composite. The Fundamental Theorem of Arithmetic establishes that every integer greater than 1 can be expressed uniquely as a product of prime powers. Highest Common Factor (HCF) is the greatest integer dividing all given numbers; Lowest Common Multiple (LCM) is the smallest positive integer divisible by all of them. For any two positive integers A and B: A × B = HCF(A, B) × LCM(A, B).',
          hindiContent: 'अभाज्य संख्या वह संख्या है जिसके केवल दो गुणनखंड होते हैं: 1 और स्वयं वह संख्या (2, 3, 5, 7, 11...)। संख्या 1 न तो अभाज्य है और न ही भाज्य। अंकगणित की आधारभूत प्रमेय के अनुसार प्रत्येक भाज्य संख्या को अभाज्य संख्याओं के गुणनफल के रूप में व्यक्त किया जा सकता है। महत्तम समापवर्तक (HCF/म.स.प.) सबसे बड़ा विभाजक है; लघुत्तम समापवर्त्य (LCM/ल.स.प.) सबसे छोटा उभयनिष्ठ गुणज है। सूत्र: A × B = HCF × LCM।',
          keyFormula: 'Product of Numbers = HCF × LCM (A × B = HCF × LCM)',
          calloutTip: '2 is the only EVEN prime number in existence; all other prime numbers are odd!',
          hindiCalloutTip: 'संख्या 2 संपूर्ण गणित में एकमात्र सम (Even) अभाज्य संख्या है; शेष सभी अभाज्य संख्याएं विषम होती हैं!',
          quickCheckQuestion: 'If HCF(12, 18) = 6, find LCM(12, 18) using the product formula.',
          hindiQuickCheckQuestion: 'यदि HCF(12, 18) = 6 है, तो गुणनफल सूत्र से LCM ज्ञात करें।',
          quickCheckAnswer: 'LCM = (12 × 18) / 6 = 216 / 6 = 36.',
          hindiQuickCheckAnswer: 'LCM = (12 × 18) / 6 = 216 / 6 = 36।',
        ),
      ]);

      points.addAll([
        'Natural numbers start from 1; Whole numbers start from 0; Integers include negatives.',
        'A rational number is in form p/q with integers p, q and q ≠ 0.',
        'Multiplying two negative numbers produces a positive result: (-) × (-) = (+).',
        'Division by zero is undefined throughout mathematics.',
        'For two positive integers A and B, Product (A × B) = HCF(A, B) × LCM(A, B).',
      ]);
      hindiPoints.addAll([
        'प्राकृतिक संख्याएं 1 से शुरू होती हैं; पूर्ण संख्याएं 0 से; पूर्णांकों में ऋणात्मक भी शामिल हैं।',
        'परिमेय संख्या p/q रूप में होती है जहाँ p, q पूर्णांक हैं और q ≠ 0।',
        'दो ऋणात्मक संख्याओं का गुणनफल हमेशा धनात्मक होता है: (-) × (-) = (+)।',
        'शून्य से भाग संपूर्ण गणित में अपरिभाषित है।',
        'दो संख्याओं का गुणनफल हमेशा उनके HCF और LCM के गुणनफल के बराबर होता है।',
      ]);

      facts.addAll([
        'The mathematical numeral zero and decimal place-value system were developed in ancient India by mathematicians Aryabhata and Brahmagupta, revolutionizing science worldwide.',
        '1729 is the smallest number that can be expressed as the sum of two cubes in two distinct ways: 1³ + 12³ = 9³ + 10³ = 1729 (The Hardy-Ramanujan Number).',
      ]);
      hindiFacts.addAll([
        'शून्य और दशमलव स्थानीय मान प्रणाली का आविष्कार प्राचीन भारत में आर्यभट्ट और ब्रह्मगुप्त द्वारा किया गया, जिसने विश्व भर के विज्ञान को बदल दिया।',
        '1729 सबसे छोटी संख्या है जिसे दो अलग-अलग तरीकों से दो घनों के योग के रूप में लिखा जा सकता है: 1³ + 12³ = 9³ + 10³ = 1729 (रामानुजन संख्या)।',
      ]);
    } else if (titleLower.contains('algebra') ||
        titleLower.contains('equation') ||
        titleLower.contains('variable') ||
        titleLower.contains('expression')) {
      sections.addAll([
        const ChapterSection(
          sectionNumber: '1.1',
          title: 'The Language of Variables & Symbolic Logic',
          hindiTitle: 'चरों की भाषा एवं बीजीय तर्क',
          content: 'Algebra is generalized arithmetic where letters replace unknown numbers, allowing mathematicians to formulate universal laws. A variable is an arbitrary symbol (usually letters like x, y, z) that can represent different numerical values. A constant is a fixed quantity with permanent numerical value (such as 5, -8, 3.14). An algebraic expression combines variables, constants, and operators (+, -, ×, ÷) without an equals sign (e.g. 3x + 7). When two expressions are asserted to have identical value with an equals sign (=), they form an Equation (e.g. 3x + 7 = 22).',
          hindiContent: 'बीजगणित सामान्यीकृत अंकगणित है जहाँ अक्षरों का प्रयोग अज्ञात संख्याओं के स्थान पर किया जाता है। चर (Variable) एक ऐसा प्रतीक है (जैसे x, y, z) जो विभिन्न मान ले सकता है। अचर (Constant) एक निश्चित मान होता है (जैसे 5, -8)। जब चर और अचर गणितीय चिह्नों से जुड़ते हैं तो वे बीजीय व्यंजक बनाते हैं (3x + 7)। जब दो व्यंजकों के बीच बराबर का चिह्न (=) लगाया जाता है, तो वह समीकरण (Equation) कहलाता है (3x + 7 = 22)।',
          calloutTip: 'Expressions like 4x + 3 can only be simplified; Equations like 4x + 3 = 19 can be SOLVED for x!',
          hindiCalloutTip: 'व्यंजकों (4x + 3) को केवल सरल किया जा सकता है; समीकरणों (4x + 3 = 19) में x का मान निकाला जा सकता है!',
          quickCheckQuestion: 'In the expression 7x - 12, what is the variable, the coefficient, and the constant?',
          hindiQuickCheckQuestion: 'व्यंजक 7x - 12 में चर, गुणांक और अचर क्या हैं?',
          quickCheckAnswer: 'Variable is x; Coefficient is 7; Constant is -12.',
          hindiQuickCheckAnswer: 'चर x है; x का गुणांक 7 है; अचर -12 है।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'Like Terms, Unlike Terms & Simplification',
          hindiTitle: 'समान पद, असमान पद एवं व्यंजकों का सरलीकरण',
          content: 'In algebra, terms are the building blocks separated by plus or minus signs. Like terms possess the exact same variables raised to the exact same powers (e.g. 5x² and -2x² are like terms; 4xy and 9xy are like terms). Unlike terms have different variables or exponents (e.g. 3x and 3y, or 2x and 2x²). Fundamental Rule: Only like terms can be added or subtracted together by combining their coefficients! 4x + 3x = 7x; however, 4x + 3y CANNOT be combined into 7xy—it remains 4x + 3y.',
          hindiContent: 'बीजगणित में पद (+) या (-) के चिह्नों द्वारा अलग होते हैं। समान पदों (Like terms) में चर और उनकी घातें बिल्कुल एक जैसी होती हैं (उदा. 5x² और -2x² समान पद हैं; 4xy और 9xy समान पद हैं)। असमान पदों में चर या घातें अलग होती हैं (3x और 3y)। मूलभूत नियम: केवल समान पदों को ही आपस में जोड़ा या घटाया जा सकता है! 4x + 3x = 7x; लेकिन 4x + 3y कभी 7xy नहीं बनता—वह 4x + 3y ही रहता है।',
          keyFormula: 'Addition of Like Terms: ax + bx = (a + b)x • (Unlike terms cannot combine)',
          calloutTip: 'Do not multiply coefficients when adding! 3x + 4x = 7x (NOT 7x²).',
          hindiCalloutTip: 'जोड़ते समय गुणा न करें! 3x + 4x = 7x होता है (7x² नहीं)।',
          quickCheckQuestion: 'Simplify the algebraic expression: 5x + 3y - 2x + 4y',
          hindiQuickCheckQuestion: 'व्यंजक को सरल करें: 5x + 3y - 2x + 4y',
          quickCheckAnswer: '3x + 7y (combine 5x - 2x = 3x, and 3y + 4y = 7y).',
          hindiQuickCheckAnswer: '3x + 7y (5x - 2x = 3x और 3y + 4y = 7y को मिलाकर)।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Solving Linear Equations: The Balance Scale & Transposition',
          hindiTitle: 'रैखिक समीकरण हल करना: तराजू मॉडल एवं पक्षांतरण',
          content: 'A linear equation in one variable contains a single unknown variable with exponent 1 (standard form: ax + b = c, where a ≠ 0). An equation acts like a perfectly balanced beam scale. Equality is preserved if and only if the exact same mathematical operation is applied to both sides. Transposition Method: A term can be moved from one side of the equals sign to the other by inverting its operation: addition (+) becomes subtraction (-), subtraction (-) becomes addition (+), multiplication (×) becomes division (÷), and division (÷) becomes multiplication (×).',
          hindiContent: 'एक चर वाले रैखिक समीकरण में घात 1 वाला केवल एक अज्ञात चर होता है (मानक रूप: ax + b = c, जहाँ a ≠ 0)। समीकरण एक संतुलित तराजू की तरह है। समानता तभी बनी रहती है जब दोनों पक्षों में समान संक्रिया की जाए। पक्षांतरण नियम: बराबर के चिह्न के दूसरी तरफ ले जाने पर संक्रिया उल्टी हो जाती है: जोड़ (+) घटाव (-) बन जाता है, घटाव (-) जोड़ (+) बन जाता है, गुणा (×) भाग (÷) बन जाता है, और भाग (÷) गुणा (×) बन जाता है।',
          keyFormula: 'Transposition: ax + b = c ⟹ ax = c - b ⟹ x = (c - b) / a',
          calloutTip: 'Always verify your answer by substituting the root back into the original equation!',
          hindiCalloutTip: 'हमेशा प्राप्त मान को मूल समीकरण में रखकर बाएँ और दाएँ पक्ष की सत्यता जाँचें!',
          quickCheckQuestion: 'Solve for x: 4x - 5 = 19',
          hindiQuickCheckQuestion: 'x का मान ज्ञात करें: 4x - 5 = 19',
          quickCheckAnswer: 'x = 6 (4x = 19 + 5 = 24 ⟹ x = 24 / 4 = 6).',
          hindiQuickCheckAnswer: 'x = 6 (4x = 19 + 5 = 24 ⟹ x = 24 / 4 = 6)।',
        ),
        const ChapterSection(
          sectionNumber: '1.4',
          title: 'Word Problem Formulation & Real-World Modeling',
          hindiTitle: 'इबारती प्रश्न निर्माण एवं वास्तविक मॉडलिंग',
          content: 'Word problems represent real-world physical and commercial challenges translated into mathematical algebra. Step 1: Read the problem carefully and identify the unknown quantity to designate as x. Step 2: Write expressions for all other quantities in terms of x. Step 3: Formulate the balancing equation based on the condition given. Step 4: Solve systematically for x. Step 5: Check the solution in the context of the original question (e.g. check that age or distance is positive).',
          hindiContent: 'इबारती (Word) प्रश्न व्यावहारिक स्थितियों को बीजगणित में बदलने का साधन हैं। चरण 1: प्रश्न को ध्यान से पढ़ें और अज्ञात राशि को x मानें। चरण 2: अन्य सभी राशियों को x के पदों में व्यक्त करें। चरण 3: दी गई शर्त के अनुसार समीकरण बनाएं। चरण 4: x का मान निकालें। चरण 5: जांचें कि उत्तर वास्तविक संदर्भ में सही बैठता है या नहीं (जैसे आयु या दूरी ऋणात्मक नहीं हो सकती)।',
          calloutTip: 'Watch out for consecutive integers: if the first is x, the next is x + 1, and the third is x + 2.',
          hindiCalloutTip: 'क्रमागत पूर्णांकों के लिए: यदि पहला x है, तो दूसरा x + 1 और तीसरा x + 2 होगा।',
          quickCheckQuestion: 'The sum of three consecutive integers is 36. Find the smallest integer.',
          hindiQuickCheckQuestion: 'तीन क्रमागत पूर्णांकों का योग 36 है। सबसे छोटा पूर्णांक ज्ञात करें।',
          quickCheckAnswer: '11 (x + (x+1) + (x+2) = 36 ⟹ 3x + 3 = 36 ⟹ 3x = 33 ⟹ x = 11).',
          hindiQuickCheckAnswer: '11 (x + (x+1) + (x+2) = 36 ⟹ 3x + 3 = 36 ⟹ 3x = 33 ⟹ x = 11)।',
        ),
      ]);

      points.addAll([
        'Variables represent unknown quantities; constants represent fixed numerical values.',
        'Only like terms (same variables and exponents) can be combined by addition or subtraction.',
        'Whatever operation is performed on the LHS of an equation must also be performed on the RHS.',
        'When a term crosses the equals sign (=), its operation inverts (+ to -, × to ÷).',
        'A linear equation in one variable has exactly one unique solution.',
      ]);
      hindiPoints.addAll([
        'चर अज्ञात मानों को दर्शाते हैं; अचर निश्चित मानों को दर्शाते हैं।',
        'केवल समान पदों को ही आपस में जोड़ा या घटाया जा सकता है।',
        'समीकरण के बाएँ पक्ष में जो संक्रिया की जाए, वही दाएँ पक्ष में भी करनी होगी।',
        'बराबर के चिह्न के दूसरी ओर जाने पर संक्रिया उलट जाती है (+ बन जाता है -, × बन जाता है ÷)।',
        'एक चर वाले रैखिक समीकरण का केवल एक अद्वितीय हल होता है।',
      ]);

      facts.addAll([
        'The word "Algebra" originates from the Arabic "Al-Jabr" meaning "reunion of broken parts", introduced by 9th-century mathematician Muhammad ibn Musa al-Khwarizmi.',
        'Modern computer search engines solve linear algebraic matrix equations with over 50 billion variables simultaneously to rank internet search results in milliseconds!',
      ]);
      hindiFacts.addAll([
        'बीजगणित (Algebra) शब्द की उत्पत्ति अरबी शब्द "अल-जबर" से हुई है जिसका अर्थ "टूटे हुए भागों को जोड़ना" है, जिसे 9वीं सदी के गणितज्ञ अल-ख्वारिज्मी ने दिया था।',
        'आधुनिक कंप्यूटर सर्च इंजन इंटरनेट परिणामों को मिलीसेकंड में छाँटने के लिए 50 अरब से अधिक चरों वाले बीजीय समीकरणों को हल करते हैं!',
      ]);
    } else if (titleLower.contains('ratio') ||
        titleLower.contains('proportion') ||
        titleLower.contains('percentage') ||
        titleLower.contains('profit') ||
        titleLower.contains('loss') ||
        titleLower.contains('interest') ||
        titleLower.contains('money') ||
        titleLower.contains('time') ||
        titleLower.contains('measurement') ||
        titleLower.contains('unitary') ||
        titleLower.contains('clock')) {
      sections.addAll([
        const ChapterSection(
          sectionNumber: '1.1',
          title: 'Comparison by Ratios & The Unitary Method',
          hindiTitle: 'अनुपात द्वारा तुलना एवं ऐकिक नियम',
          content: 'Comparison between two quantities of the same kind by division is called a Ratio (written a : b = a / b, where b ≠ 0). Ratios are pure dimensionless numbers and must always be simplified to lowest terms by dividing by their HCF. Proportion states that two ratios are equal: a : b = c : d, where Product of Extremes equals Product of Means (a × d = b × c). The Unitary Method is the fundamental problem-solving technique where we first determine the value of a single unit (by division) and then multiply to find the value of any required number of units.',
          hindiContent: 'समान प्रकार की दो राशियों की भाग द्वारा तुलना को अनुपात (Ratio) कहते हैं (a : b = a / b, जहाँ b ≠ 0)। अनुपात की कोई इकाई नहीं होती और इसे सरलतम रूप में लिखा जाता है। जब दो अनुपात समान होते हैं तो वे समानुपात (Proportion) कहलाते हैं: a : b = c : d, जहाँ बाह्य पदों का गुणनफल = मध्य पदों का गुणनफल (a × d = b × c)। ऐकिक नियम में पहले भाग द्वारा 1 इकाई का मान निकालते हैं, फिर गुणा करके अभीष्ट इकाइयों का मान ज्ञात करते हैं।',
          keyFormula: 'Proportion Law: a : b = c : d ⟹ a × d = b × c • Unit Value = Total Cost ÷ Quantity',
          calloutTip: 'Both quantities in a ratio MUST be converted to identical units before simplifying (e.g. 50 paise to ₹2 = 50p : 200p = 1 : 4).',
          hindiCalloutTip: 'अनुपात निकालने से पहले दोनों राशियों को एक ही इकाई में बदलना अनिवार्य है (उदा. 50 पैसे और ₹2 = 50 : 200 = 1 : 4)।',
          quickCheckQuestion: 'If 8 notebooks cost ₹240, what is the cost of 5 such notebooks using the unitary method?',
          hindiQuickCheckQuestion: 'यदि 8 कॉपियों की कीमत ₹240 है, तो ऐकिक नियम से 5 कॉपियों की कीमत क्या होगी?',
          quickCheckAnswer: '₹150 (Cost of 1 = 240 ÷ 8 = ₹30; Cost of 5 = 30 × 5 = ₹150).',
          hindiQuickCheckAnswer: '₹150 (1 कॉपी = 240 ÷ 8 = ₹30; 5 कॉपियाँ = 30 × 5 = ₹150)।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'The Power of Percentages & Universal Conversions',
          hindiTitle: 'प्रतिशत की शक्ति एवं सार्वभौमिक रूपांतरण',
          content: 'The word "Percent" originates from the Latin "per centum", meaning "by the hundred". A percentage represents a fraction with a standard denominator of 100, designated by the symbol %. Percentages allow direct, standardized comparison across disparate groups. Universal Conversion Rules: To convert any fraction or decimal into a percentage, multiply by 100% (e.g. 3/5 × 100% = 60%; 0.45 × 100% = 45%). To convert a percentage into a fraction or decimal, divide by 100 (e.g. 75% = 75/100 = 3/4 = 0.75).',
          hindiContent: 'प्रतिशत (Percent) शब्द लैटिन के "per centum" से बना है जिसका अर्थ है "प्रति सौ"। प्रतिशत वह भिन्न है जिसका हर 100 होता है, इसका प्रतीक % है। प्रतिशत विभिन्न आकारों के समूहों की निष्पक्ष तुलना करने में सहायक होता है। रूपांतरण नियम: किसी भी भिन्न या दशमलव को प्रतिशत में बदलने के लिए 100% से गुणा करें (3/5 × 100% = 60%)। प्रतिशत को भिन्न या दशमलव में बदलने के लिए 100 से भाग दें (75% = 75/100 = 3/4 = 0.75)।',
          keyFormula: 'Fraction to %: Fraction × 100% • % to Fraction: % ÷ 100',
          calloutTip: 'Percentage increase or decrease is ALWAYS calculated relative to the ORIGINAL base value!',
          hindiCalloutTip: 'प्रतिशत वृद्धि या कमी की गणना हमेशा मूल (Original) प्रारंभिक मान पर की जाती है!',
          quickCheckQuestion: 'Express 4/25 as a percentage, and 35% as a fraction in simplest form.',
          hindiQuickCheckQuestion: '4/25 को प्रतिशत में और 35% को सरलतम भिन्न में बदलें।',
          quickCheckAnswer: '4/25 = 16%; 35% = 7/20.',
          hindiQuickCheckAnswer: '4/25 = 16%; 35% = 7/20 (सरलतम रूप)।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Financial Mathematics: Cost Price, Selling Price, Profit & Loss',
          hindiTitle: 'वित्तीय गणित: क्रय मूल्य, विक्रय मूल्य, लाभ एवं हानि',
          content: 'In business and retail, the price at which an article is bought is its Cost Price (CP). The price at which it is sold is its Selling Price (SP). When SP > CP, a Profit is earned: Profit = SP - CP. When CP > SP, a Loss is incurred: Loss = CP - SP. Crucial Financial Principle: Profit Percentage and Loss Percentage are ALWAYS calculated strictly with respect to the Cost Price (CP), never on Selling Price: Profit % = (Profit / CP) × 100%; Loss % = (Loss / CP) × 100%.',
          hindiContent: 'व्यापार में जिस मूल्य पर वस्तु खरीदी जाती है उसे क्रय मूल्य (Cost Price - CP) कहते हैं। जिस मूल्य पर बेची जाती है उसे विक्रय मूल्य (Selling Price - SP) कहते हैं। जब SP > CP हो तो लाभ होता है: लाभ = SP - CP। जब CP > SP हो तो हानि होती है: हानि = CP - SP। महत्वपूर्ण वित्तीय सिद्धांत: लाभ प्रतिशत और हानि प्रतिशत की गणना हमेशा क्रय मूल्य (CP) पर की जाती है: लाभ % = (लाभ / CP) × 100%; हानि % = (हानि / CP) × 100%।',
          keyFormula: 'Profit = SP - CP • Loss = CP - SP • Profit % = (Profit/CP) × 100 • Loss % = (Loss/CP) × 100',
          calloutTip: 'Any overhead expenses (transportation, repairs, packaging) MUST be added to the buying price to get the true Cost Price!',
          hindiCalloutTip: 'दुकानदार द्वारा खर्च किए गए भाड़े या मरम्मत को हमेशा खरीद मूल्य में जोड़कर वास्तविक क्रय मूल्य निकाला जाता है!',
          quickCheckQuestion: 'A merchant buys a watch for ₹800 and sells it for ₹1,000. Calculate his profit percentage.',
          hindiQuickCheckQuestion: 'एक व्यापारी ₹800 में घड़ी खरीदकर ₹1,000 में बेचता है। उसका लाभ प्रतिशत ज्ञात करें।',
          quickCheckAnswer: 'Profit = ₹200; Profit % = (200 / 800) × 100% = 25%.',
          hindiQuickCheckAnswer: 'लाभ = ₹200; लाभ % = (200 / 800) × 100% = 25%।',
        ),
        const ChapterSection(
          sectionNumber: '1.4',
          title: 'Banking & Simple Interest Mechanics',
          hindiTitle: 'बैंकिंग एवं साधारण ब्याज की कार्यप्रणाली',
          content: 'When money is borrowed from a bank or lender, the initial sum borrowed is called the Principal (P). The extra payment made for using this money over a period is called Interest (I). The rate charged per year is the Rate of Interest per annum (R%), and the duration is the Time period (T years). In Simple Interest, the interest is calculated uniformly on the original principal throughout the entire duration: Simple Interest SI = (P × R × T) / 100. The Total Amount payable at maturity is Amount A = P + SI.',
          hindiContent: 'जब बैंक या किसी व्यक्ति से धन उधार लिया जाता है, तो उस मूल राशि को मूलधन (Principal - P) कहते हैं। उस धन के उपयोग के बदले जो अतिरिक्त भुगतान किया जाता है उसे ब्याज (Interest - I) कहते हैं। प्रति वर्ष लिए जाने वाले प्रतिशत को ब्याज दर (R%) और समय को T (वर्षों में) कहते हैं। साधारण ब्याज में पूरे समय केवल मूलधन पर ब्याज लगता है: साधारण ब्याज SI = (P × R × T) / 100। कुल देय राशि (मिश्रधन) A = P + SI होती है।',
          keyFormula: 'SI = (P × R × T) / 100 • Amount A = P + SI',
          calloutTip: 'Time period T MUST always be in YEARS! If given in months, divide by 12 (e.g. 6 months = 6/12 = 0.5 years).',
          hindiCalloutTip: 'समय T हमेशा वर्षों में होना चाहिए! यदि महीने दिए हों तो 12 से भाग दें (6 महीने = 6/12 = 0.5 वर्ष)।',
          quickCheckQuestion: 'Calculate the Simple Interest on ₹5,000 at 6% per annum for 2 years.',
          hindiQuickCheckQuestion: '₹5,000 पर 6% वार्षिक दर से 2 वर्ष का साधारण ब्याज क्या होगा?',
          quickCheckAnswer: 'SI = (5000 × 6 × 2) / 100 = ₹600; Total Amount = ₹5,600.',
          hindiQuickCheckAnswer: 'SI = (5000 × 6 × 2) / 100 = ₹600; कुल मिश्रधन = ₹5,600।',
        ),
      ]);

      points.addAll([
        'Ratios compare quantities by division and have no units; terms must be in the same unit.',
        'Percentage means per hundred; multiply by 100% to convert any fraction to a percentage.',
        'Profit % and Loss % are ALWAYS computed strictly on Cost Price (CP).',
        'Simple Interest formula: SI = (P × R × T) / 100, where T is strictly in years.',
        'Total Amount (Mishradhan) = Principal + Simple Interest (A = P + SI).',
      ]);
      hindiPoints.addAll([
        'अनुपात भाग द्वारा तुलना है और इसकी कोई इकाई नहीं होती; दोनों राशियाँ समान इकाई में होनी चाहिए।',
        'प्रतिशत का अर्थ प्रति सौ है; भिन्न को प्रतिशत बनाने के लिए 100% से गुणा करें।',
        'लाभ % और हानि % हमेशा क्रय मूल्य (CP) पर ही निकाले जाते हैं।',
        'साधारण ब्याज सूत्र: SI = (P × R × T) / 100, जहाँ समय T वर्षों में होना अनिवार्य है।',
        'मिश्रधन (Amount) = मूलधन + साधारण ब्याज (A = P + SI)।',
      ]);

      facts.addAll([
        'The percentage symbol "%" evolved from an Italian manuscript abbreviation "pc" with a tiny circle, which gradually morphed into a slash with two zeros.',
        'Commercial mathematics forms the foundation of modern algorithmic finance, stock markets, and global international trade!',
      ]);
      hindiFacts.addAll([
        'प्रतिशत का चिह्न "%" इतालवी पांडुलिपियों के "pc" से विकसित हुआ, जो समय के साथ तिरछी रेखा और दो शून्यों में बदल गया।',
        'व्यावसायिक गणित आधुनिक शेयर बाजारों, वैश्विक व्यापार और बैंकिंग प्रणाली का आधार है!',
      ]);
    } else {
      // Fallback / Elementary Operations
      sections.addAll([
        ChapterSection(
          sectionNumber: '1.1',
          title: 'Foundational Principles of ${chapter.title}',
          hindiTitle: '${chapter.title} के आधारभूत सिद्धांत',
          content: 'Mathematics is the science of structure, pattern, and logical deduction. In ${chapter.title}, we explore fundamental computational techniques and numerical relations. Mastery of this chapter builds essential numerical intuition, sharpening problem-solving speed and logical reasoning across everyday life and academic examinations.',
          hindiContent: 'गणित संरचना, पैटर्न और तार्किक निष्कर्ष का विज्ञान है। ${chapter.title} में हम मूलभूत गणना तकनीकों और संख्यात्मक संबंधों को सीखते हैं। इस अध्याय में दक्षता प्राप्त करने से समस्या-समाधान की गति बढ़ती है और दैनिक जीवन में तार्किक सोच मजबूत होती है।',
          calloutTip: 'Break complex problems into smaller, manageable sub-steps to ensure 100% accuracy.',
          hindiCalloutTip: 'कठिन प्रश्नों को छोटे-छोटे चरणों में बाँटकर हल करें ताकि उत्तर पूरी तरह सही आए।',
          quickCheckQuestion: 'Why is systematic step-by-step working essential in mathematics?',
          hindiQuickCheckQuestion: 'गणित में चरणबद्ध हल करना क्यों आवश्यक है?',
          quickCheckAnswer: 'It prevents computational slips and makes error detection straightforward.',
          hindiQuickCheckAnswer: 'यह गणना की गलतियों को रोकता है और त्रुटि पकड़ना आसान बनाता है।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'Order of Operations & Mathematical Precision (BODMAS)',
          hindiTitle: 'संक्रियाओं का क्रम एवं गणितीय शुद्धता (BODMAS)',
          content: 'When an expression contains multiple mathematical operations, ambiguity is avoided by applying the universal BODMAS rule: B - Brackets first ((), {}, []), O - Orders (powers, roots), D - Division, M - Multiplication, A - Addition, and S - Subtraction. Division and multiplication hold equal precedence and are solved from left to right; addition and subtraction also hold equal precedence and are evaluated left to right.',
          hindiContent: 'जब किसी व्यंजक में एक से अधिक संक्रियाएँ हों, तो सही परिणाम के लिए BODMAS नियम का पालन किया जाता है: B - कोष्ठक (Brackets), O - घात या क्रम (Orders), D - भाग (Division), M - गुणा (Multiplication), A - जोड़ (Addition), तथा S - घटाव (Subtraction)। भाग और गुणा समान वरीयता रखते हैं (बाएँ से दाएँ हल करें)। जोड़ और घटाव भी समान वरीयता रखते हैं।',
          keyFormula: 'BODMAS Order: Brackets ⟹ Orders ⟹ Division & Multiplication ⟹ Addition & Subtraction',
          calloutTip: 'Ignoring BODMAS is the #1 reason students lose marks in arithmetic exams!',
          hindiCalloutTip: 'BODMAS नियम की अनदेखी करना परीक्षाओं में अंक कटने का सबसे बड़ा कारण है!',
          quickCheckQuestion: 'Evaluate: 10 + 2 × 5 - 4',
          hindiQuickCheckQuestion: 'मान निकालें: 10 + 2 × 5 - 4',
          quickCheckAnswer: '16 (Multiplication first: 2 × 5 = 10; 10 + 10 = 20; 20 - 4 = 16).',
          hindiQuickCheckAnswer: '16 (पहले गुणा: 2 × 5 = 10; फिर 10 + 10 = 20; अंत में 20 - 4 = 16)।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Estimation, Rounding Off & Mental Math Strategies',
          hindiTitle: 'सन्निकटन, राउंड ऑफ एवं मानसिक गणित की रणनीतियाँ',
          content: 'Estimation provides a rapid, practical approximation of large calculations before exact arithmetic. When rounding to the nearest 10, inspect the units digit: if it is 5 or greater, round UP; if less than 5, round DOWN. When rounding to the nearest 100, inspect the tens digit. Mental math strategies include decomposition (e.g. 48 × 5 = (50 - 2) × 5 = 250 - 10 = 240) and compensation.',
          hindiContent: 'सन्निकटन (Estimation) सटीक गणना से पहले एक त्वरित व्यावहारिक अनुमान प्रदान करता है। निकटतम 10 तक राउंड करते समय इकाई का अंक देखें: यदि 5 या अधिक है तो ऊपर बढ़ाएं; यदि 5 से कम है तो नीचे रखें। मानसिक गणित की रणनीतियों जैसे संख्याओं को तोड़ना (48 × 5 = (50 - 2) × 5 = 240) से गणना बहुत तेज हो जाती है।',
          calloutTip: 'Use estimation to double check whether your calculated exam answers are realistically reasonable.',
          hindiCalloutTip: 'अपने उत्तर की व्यावहारिकता जांचने के लिए हमेशा मानसिक अनुमान का उपयोग करें।',
          quickCheckQuestion: 'Round 478 to the nearest 10 and to the nearest 100.',
          hindiQuickCheckQuestion: '478 को निकटतम 10 और निकटतम 100 तक राउंड ऑफ करें।',
          quickCheckAnswer: 'Nearest 10: 480; Nearest 100: 500.',
          hindiQuickCheckAnswer: 'निकटतम 10: 480; निकटतम 100: 500।',
        ),
      ]);

      points.addAll([
        'BODMAS governs the invariant hierarchy of operations in all mathematics.',
        'Multiplication and division have equal priority and are executed from left to right.',
        'Units must be identical across all quantities before performing calculations.',
        'Always check your final result using inverse operations (addition checks subtraction, multiplication checks division).',
      ]);
      hindiPoints.addAll([
        'BODMAS गणित में संक्रियाओं के क्रम का सार्वभौमिक नियम है।',
        'गुणा और भाग समान वरीयता रखते हैं और बाएँ से दाएँ हल किए जाते हैं।',
        'गणना करने से पहले सभी राशियों की इकाइयाँ समान होनी चाहिए।',
        'हमेशा विपरीत संक्रिया से अपने उत्तर की पुनः जाँच करें।',
      ]);

      facts.addAll([
        'The equals sign (=) was invented in 1557 by Welsh physician and mathematician Robert Recorde, who chose two parallel lines because "no two things can be more equal".',
      ]);
      hindiFacts.addAll([
        'बराबर के चिह्न (=) का आविष्कार 1557 में रॉबर्ट रिकॉर्ड ने किया था, जिन्होंने दो समांतर रेखाएं चुनीं क्योंकि "दो रेखाओं से अधिक समान कुछ नहीं हो सकता"।',
      ]);
    }
  }

  // ==========================================
  // ENGLISH DETAILED TEXTBOOK SECTIONS
  // ==========================================
  void _populateEnglishTextbookSections(
    List<ChapterSection> sections,
    List<String> points,
    List<String> hindiPoints,
    List<String> facts,
    List<String> hindiFacts,
    Chapter chapter,
    String titleLower,
    String gradeLower,
  ) {
    if (chapter.keyConcepts.isNotEmpty) {
      sections.addAll([
        ChapterSection(
          sectionNumber: '1.1',
          title: 'Foundations of ${chapter.title}',
          hindiTitle: '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के आधारभूत सिद्धांत',
          content: chapter.description.isNotEmpty
              ? '${chapter.description} In this chapter, students explore foundational principles including: ${chapter.keyConcepts.join(", ")}. Understanding these concepts develops strong reading fluency, grammar accuracy, and expressive writing.'
              : 'Mastering ${chapter.title} builds core mastery in ${chapter.grade} English curriculum. In this chapter, students explore foundational principles including: ${chapter.keyConcepts.join(", ")}. Understanding these concepts develops strong reading fluency, grammar accuracy, and expressive writing.',
          hindiContent: '${HindiCurriculumTranslator.translateChapterDescription(chapter.description.isNotEmpty ? chapter.description : chapter.title, chapter.title)} इस अध्याय में विद्यार्थी मुख्य अवधारणाओं का गहन अध्ययन करते हैं: ${chapter.keyConcepts.map((c) => HindiCurriculumTranslator.translateConcept(c)).join(", ")}। इन सिद्धांतों को समझकर अंग्रेजी भाषा पर मजबूत पकड़ बनती है।',
          calloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? chapter.mascotAdvice!
              : 'Read each rule and example aloud to internalize natural language flow.',
          hindiCalloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
              : 'स्वाभाविक भाषा प्रवाह को समझने के लिए प्रत्येक नियम और उदाहरण को बोलकर पढ़ें।',
          quickCheckQuestion: 'What are the foundational key concepts covered in ${chapter.title}?',
          hindiQuickCheckQuestion: '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} में मुख्य रूप से कौन-सी अवधारणाएँ शामिल हैं?',
          quickCheckAnswer: chapter.keyConcepts.join(', '),
          hindiQuickCheckAnswer: chapter.keyConcepts.map((c) => HindiCurriculumTranslator.translateConcept(c)).join(', '),
        ),
        ChapterSection(
          sectionNumber: '1.2',
          title: 'Core Rules & Usage of ${chapter.title}',
          hindiTitle: '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के प्रमुख नियम एवं प्रयोग',
          content: chapter.rules.isNotEmpty
              ? 'Every topic in ${chapter.title} is governed by standard grammar and usage conventions. Applying these rules systematically ensures flawless writing and speech:\n\n${chapter.rules.asMap().entries.map((e) => "• Rule ${e.key + 1}: ${e.value}").join("\n")}'
              : 'Mastering the standard rules and usage conventions of ${chapter.title} provides a solid foundation for clear communication.',
          hindiContent: chapter.rules.isNotEmpty
              ? '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के सभी प्रश्न व्याकरण के निश्चित नियमों और प्रयोगों पर आधारित होते हैं। इन नियमों का पालन करने से लेखन और संभाषण में शुद्धता आती है:\n\n${chapter.rules.asMap().entries.map((e) => "• नियम ${e.key + 1}: ${HindiCurriculumTranslator.translateRule(e.value)}").join("\n")}'
              : '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के मूलभूत व्याकरण नियमों को समझना भाषा कौशल को सशक्त बनाता है।',
          keyFormula: chapter.rules.isNotEmpty ? chapter.rules.first : '${chapter.title} Core Rules',
          calloutTip: 'Always read your sentence aloud to check if subject and verb agree naturally!',
          hindiCalloutTip: 'वाक्य को हमेशा बोलकर पढ़ें ताकि कर्ता और क्रिया के तालमेल की जाँच हो सके!',
          quickCheckQuestion: chapter.rules.isNotEmpty
              ? 'What is a key rule to remember for ${chapter.title}?'
              : 'Why are grammar rules important in ${chapter.title}?',
          hindiQuickCheckQuestion: chapter.rules.isNotEmpty
              ? '${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} का मुख्य नियम क्या है?'
              : 'व्याकरण के नियमों का पालन क्यों आवश्यक है?',
          quickCheckAnswer: chapter.rules.isNotEmpty ? chapter.rules.first : 'They ensure clear, accurate communication.',
          hindiQuickCheckAnswer: chapter.rules.isNotEmpty ? HindiCurriculumTranslator.translateRule(chapter.rules.first) : 'वे स्पष्ट और सटीक संवाद सुनिश्चित करते हैं।',
        ),
        ChapterSection(
          sectionNumber: '1.3',
          title: 'Classroom Solved Example & Usage',
          hindiTitle: 'कक्षा में हल किया गया आदर्श उदाहरण',
          content: 'Exemplar Demonstration:\nQuestion: ${chapter.exampleQuestion ?? "Standard solved problem for ${chapter.title}."}\n\nStep-by-Step Method:\n${chapter.exampleExplanation ?? "Apply the rules of ${chapter.title} step by step to identify the correct usage."}\n\nFinal Conclusion: ${chapter.exampleAnswer ?? "The answer is determined accurately."}',
          hindiContent: 'आदर्श उदाहरण हल:\nप्रश्न: ${HindiCurriculumTranslator.translateStep(chapter.exampleQuestion ?? chapter.title)}\n\nचरणबद्ध विधि:\n${HindiCurriculumTranslator.translateStep(chapter.exampleExplanation ?? "चरणबद्ध रूप से व्याकरण नियमों को लागू करें।")}\n\nअंतिम उत्तर: ${HindiCurriculumTranslator.translateStep(chapter.exampleAnswer ?? "सही उत्तर निर्धारित किया गया।")}',
          calloutTip: 'Break complex sentences into subject, verb, and object to identify rules easily.',
          hindiCalloutTip: 'नियमों को आसानी से समझने के लिए जटिल वाक्यों को कर्ता, क्रिया और कर्म में बाँटें।',
          quickCheckQuestion: chapter.exampleQuestion != null
              ? 'In the solved example for ${chapter.title}, what was the target answer?'
              : 'How should you approach grammar examples?',
          hindiQuickCheckQuestion: chapter.exampleQuestion != null
              ? 'दिए गए उदाहरण में अंतिम उत्तर क्या था?'
              : 'व्याकरण के उदाहरणों को समझने का सही तरीका क्या है?',
          quickCheckAnswer: chapter.exampleAnswer ?? 'Analyze sentence structure step by step.',
          hindiQuickCheckAnswer: chapter.exampleAnswer != null
              ? HindiCurriculumTranslator.translateStep(chapter.exampleAnswer!)
              : 'वाक्य संरचना का चरणबद्ध विश्लेषण करें।',
        ),
        ChapterSection(
          sectionNumber: '1.4',
          title: 'Real-World Wonder & Language Mastery',
          hindiTitle: 'भाषा का व्यावहारिक प्रयोग एवं रोचक तथ्य',
          content: 'Real-World Application:\n${chapter.funFact ?? "The concepts of ${chapter.title} are used in daily conversations, storytelling, public speaking, and literature."}\n\nExpert Tip:\n${chapter.mascotAdvice ?? "Practice reading English storybooks and writing short paragraphs every day to solidify your learning."}',
          hindiContent: 'दैनिक जीवन में उपयोग:\n${HindiCurriculumTranslator.translateStep(chapter.funFact ?? "${chapter.title} की अवधारणाओं का उपयोग दैनिक बातचीत, कहानी लेखन और साहित्य में होता है।")}\n\nविशेषज्ञ सलाह:\n${HindiCurriculumTranslator.translateHint(chapter.mascotAdvice ?? "अपनी भाषा को मजबूत करने के लिए प्रतिदिन अंग्रेजी कहानियाँ पढ़ें और छोटे अनुच्छेद लिखें।")}',
          calloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? chapter.mascotAdvice!
              : 'Daily reading enhances both vocabulary and intuition for correct grammar!',
          hindiCalloutTip: chapter.mascotAdvice != null && chapter.mascotAdvice!.trim().isNotEmpty
              ? HindiCurriculumTranslator.translateHint(chapter.mascotAdvice!)
              : 'प्रतिदिन पढ़ने से शब्दावली और सही व्याकरण की समझ दोनों बेहतर होती हैं!',
          quickCheckQuestion: 'Where is ${chapter.title} applied in real life?',
          hindiQuickCheckQuestion: 'वास्तविक जीवन में ${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} का क्या उपयोग है?',
          quickCheckAnswer: chapter.funFact ?? 'In reading, writing, formal communication, and creative expression.',
          hindiQuickCheckAnswer: chapter.funFact != null
              ? HindiCurriculumTranslator.translateStep(chapter.funFact!)
              : 'पढ़ने, लिखने, औपचारिक संवाद और रचनात्मक अभिव्यक्ति में।',
        ),
      ]);

      for (final r in chapter.rules) {
        if (!points.contains(r)) {
          points.add(r);
          hindiPoints.add(HindiCurriculumTranslator.translateRule(r));
        }
      }
      points.add('Master all ${chapter.keyConcepts.length} core concepts: ${chapter.keyConcepts.join(", ")}.');
      hindiPoints.add('सभी ${chapter.keyConcepts.length} मुख्य अवधारणाओं में महारत हासिल करें: ${chapter.keyConcepts.map((c) => HindiCurriculumTranslator.translateConcept(c)).join(", ")}।');
      points.add('Practice applying the rules of ${chapter.title} in speaking and writing daily.');
      hindiPoints.add('प्रतिदिन बोलने और लिखने में ${HindiCurriculumTranslator.translateChapterTitle(chapter.title)} के नियमों का अभ्यास करें।');

      if (chapter.funFact != null && chapter.funFact!.trim().isNotEmpty) {
        facts.add(chapter.funFact!.trim());
        hindiFacts.add(HindiCurriculumTranslator.translateStep(chapter.funFact!.trim()));
      }
      if (facts.isEmpty) {
        facts.add('English has grown over 1,400 years and is spoken by over 1.5 billion people worldwide!');
        hindiFacts.add('अंग्रेजी 1,400 वर्षों के दौरान विकसित हुई है और दुनिया भर में 1.5 अरब से अधिक लोग इसे बोलते हैं!');
      }
      return;
    }

    if (titleLower.contains('phonic') ||
        titleLower.contains('alphabet') ||
        titleLower.contains('rhym') ||
        titleLower.contains('letter') ||
        titleLower.contains('sound') ||
        titleLower.contains('sight')) {
      sections.addAll([
        const ChapterSection(
          sectionNumber: '1.1',
          title: 'The Sounds of English: Letters & Phonemes',
          hindiTitle: 'अंग्रेजी ध्वनियाँ: अक्षर एवं ध्वनि-विज्ञान',
          content: 'Spoken English is constructed from 44 distinct speech sounds called phonemes, which are represented in writing by 26 letters of the alphabet (graphemes). Letters are divided into two fundamental families: Vowels (A, E, I, O, U) and Consonants (all other 21 letters). Vowels produce continuous, open vocal sounds without stopping airflow. Consonants are created by shaping airflow using lips, tongue, or teeth. Every single word in the English language must contain at least one vowel sound.',
          hindiContent: 'बोली जाने वाली अंग्रेजी 44 विशिष्ट ध्वनियों (Phonemes) से बनती है, जिन्हें 26 अक्षरों द्वारा लिखा जाता है। अक्षरों के दो मुख्य परिवार हैं: स्वर (Vowels: A, E, I, O, U) और व्यंजन (Consonants: शेष 21 अक्षर)। स्वर खुली और बिना रुकावट की ध्वनि उत्पन्न करते हैं। व्यंजन होंठ, जीभ या दाँतों की सहायता से बोले जाते हैं। अंग्रेजी के प्रत्येक शब्द में कम से कम एक स्वर ध्वनि अवश्य होती है।',
          calloutTip: 'The letter "Y" sometimes functions as a vowel sound, such as in "Fly", "Gym", and "Happy"!',
          hindiCalloutTip: 'अक्षर "Y" कई बार स्वर की ध्वनि देता है, जैसे "Fly", "Gym" और "Happy" में!',
          quickCheckQuestion: 'How many letters are in the English alphabet, and how many speech sounds (phonemes) do they produce?',
          hindiQuickCheckQuestion: 'अंग्रेजी वर्णमाला में कितने अक्षर हैं और वे कितनी ध्वनियाँ उत्पन्न करते हैं?',
          quickCheckAnswer: '26 letters producing 44 distinct speech sounds.',
          hindiQuickCheckAnswer: '26 अक्षर जो 44 विशिष्ट ध्वनियाँ उत्पन्न करते हैं।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'Blending, CVC Words & Rhyming Patterns',
          hindiTitle: 'ध्वनि संयोजन, CVC शब्द एवं तुकबंदी',
          content: 'Early reading begins with blending: pushing individual letter sounds together smoothly to pronounce words. Consonant-Vowel-Consonant (CVC) words form the foundation of early decoding (e.g. /c/ + /a/ + /t/ = Cat; /s/ + /u/ + /n/ = Sun). Words that end with the exact same vowel and consonant sound rhyme with each other (e.g. Hat, Cat, Mat, Bat all belong to the "-at" word family). Rhyming words do not need identical spelling—they only need identical acoustic ending cadence (e.g. "Blue" and "Shoe").',
          hindiContent: 'प्रारंभिक पठन ध्वनि संयोजन (Blending) से शुरू होता है: अक्षरों की ध्वनियों को जोड़कर शब्द बनाना। व्यंजन-स्वर-व्यंजन (CVC) शब्द प्रारंभिक आधार हैं (/c/ + /a/ + /t/ = Cat; /s/ + /u/ + /n/ = Sun)। जिन शब्दों की अंतिम स्वर और व्यंजन ध्वनि एक जैसी होती है, वे तुकबंदी (Rhyming) वाले शब्द कहलाते हैं (जैसे Hat, Cat, Mat)। तुकबंदी में वर्तनी का एक जैसा दिखना ज़रूरी नहीं, केवल अंतिम ध्वनि का समान होना ज़रूरी है ("Blue" और "Shoe")।',
          keyFormula: 'CVC Structure: Consonant + Short Vowel + Consonant (e.g. B-a-t)',
          calloutTip: 'Look-alike words do not always rhyme: "Tough" and "Through" look similar but have totally different sounds!',
          hindiCalloutTip: 'दिखने में समान शब्द हमेशा तुकबंदी नहीं करते: "Tough" और "Through" दिखते एक जैसे हैं लेकिन ध्वनियाँ अलग हैं!',
          quickCheckQuestion: 'Which word rhymes with "Ring": Wing, Rang, or Run?',
          hindiQuickCheckQuestion: '"Ring" के साथ कौन सा शब्द तुकबंदी करता है: Wing, Rang या Run?',
          quickCheckAnswer: 'Wing (both end with the /-ɪŋ/ sound).',
          hindiQuickCheckAnswer: 'Wing (दोनों /-ɪŋ/ ध्वनि पर समाप्त होते हैं)।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'High-Frequency Sight Words & Reading Fluency',
          hindiTitle: 'दृष्टि शब्द (Sight Words) एवं धाराप्रवाह पठन',
          content: 'Sight words are high-frequency words that appear on almost every page of English books (such as: the, is, was, you, they, said, where). Many sight words do not follow standard phonetic decoding rules and must be recognized automatically on sight without sounding them out letter-by-letter. Recognizing sight words instantly frees cognitive attention, allowing young readers to focus entirely on story meaning and comprehension rather than mechanical decoding.',
          hindiContent: 'दृष्टि शब्द (Sight Words) वे शब्द हैं जो अंग्रेजी की किताबों में सबसे अधिक बार आते हैं (जैसे: the, is, was, you, they, said)। इनमें से कई शब्द सामान्य ध्वनि नियमों का पालन नहीं करते, इसलिए इन्हें देखते ही पहचानना ज़रूरी होता है। इन शब्दों को तुरंत पहचानने से बच्चे का ध्यान अर्थ समझने पर केंद्रित होता है।',
          calloutTip: 'Practice sight words using flashcards and bedtime storybook hunting!',
          hindiCalloutTip: 'कहानियों की किताबें पढ़ते समय दृष्टि शब्दों को पहचानने का अभ्यास करें!',
          quickCheckQuestion: 'Why can the word "Said" not be sounded out using regular short phonics rules?',
          hindiQuickCheckQuestion: '"Said" शब्द का सामान्य ध्वनि नियमों से उच्चारण क्यों नहीं किया जा सकता?',
          quickCheckAnswer: 'Because "ai" in "said" produces the short /e/ sound, making it an irregular sight word.',
          hindiQuickCheckAnswer: 'क्योंकि "said" में "ai" की ध्वनि /e/ जैसी निकलती है, इसलिए यह अनियमित दृष्टि शब्द है।',
        ),
      ]);

      points.addAll([
        'There are 26 letters and 44 distinct speech sounds in English.',
        'Every English word must contain at least one vowel sound (A, E, I, O, U, or Y).',
        'Rhyming words share the same terminal acoustic sound, regardless of spelling.',
        'Sight words must be recognized automatically on sight for reading fluency.',
      ]);
      hindiPoints.addAll([
        'अंग्रेजी में 26 अक्षर और 44 विशिष्ट ध्वनियाँ होती हैं।',
        'प्रत्येक अंग्रेजी शब्द में कम से कम एक स्वर ध्वनि अवश्य होनी चाहिए।',
        'तुकबंदी वाले शब्द समान अंतिम ध्वनि साझा करते हैं।',
        'धाराप्रवाह पठन के लिए दृष्टि शब्दों को देखते ही पहचानना अनिवार्य है।',
      ]);

      facts.addAll([
        'The sentence "The quick brown fox jumps over the lazy dog" is a pangram: it contains every single letter of the alphabet from A to Z!',
        'The most frequently used word in the entire English language is the definite article "the".',
      ]);
      hindiFacts.addAll([
        '"The quick brown fox jumps over the lazy dog" एक पेंगग्राम (Pangram) है: इसमें अंग्रेजी वर्णमाला के A से Z तक सभी 26 अक्षर आते हैं!',
        'संपूर्ण अंग्रेजी भाषा में सबसे अधिक बोला और लिखा जाने वाला शब्द "the" है।',
      ]);
    } else if (titleLower.contains('noun') ||
        titleLower.contains('pronoun') ||
        titleLower.contains('article')) {
      sections.addAll([
        const ChapterSection(
          sectionNumber: '1.1',
          title: 'The World of Nouns: Naming Everything Around Us',
          hindiTitle: 'संज्ञा का संसार: हमारे आसपास की हर वस्तु का नामकरण',
          content: 'A Noun is a foundational part of speech that names a person, place, animal, thing, emotion, or abstract idea. Nouns fall into distinct categories: 1. Common Nouns: General names for people, places, or objects (e.g. boy, city, river, car). 2. Proper Nouns: Specific, unique names of individuals, official entities, days, and places (e.g. Kabir, New Delhi, Ganga, Friday). Proper nouns ALWAYS begin with a capital letter. 3. Collective Nouns: Names for groups taken as a single unit (e.g. a pride of lions, a flock of birds, a team of players). 4. Abstract Nouns: Intangible qualities, feelings, or concepts that cannot be seen or touched (e.g. honesty, courage, happiness, wisdom).',
          hindiContent: 'संज्ञा (Noun) किसी व्यक्ति, स्थान, प्राणी, वस्तु, भाव या विचार के नाम को कहते हैं। संज्ञा के मुख्य प्रकार हैं: 1. जातिवाचक संज्ञा (Common Noun): सामान्य नाम (boy, city, river)। 2. व्यक्तिवाचक संज्ञा (Proper Noun): किसी विशिष्ट व्यक्ति, स्थान या दिन का नाम (Kabir, New Delhi, Ganga, Monday)—यह हमेशा बड़े अक्षर (Capital letter) से शुरू होता है। 3. समूहवाचक संज्ञा (Collective Noun): समूह का नाम (a flock of birds, a team of players)। 4. भाववाचक संज्ञा (Abstract Noun): गुण, भाव या विचार जिसे छुआ नहीं जा सकता (honesty, courage, freedom)।',
          calloutTip: 'Never forget to capitalize days of the week, months, and personal names: "Sunday", "August", "Priya".',
          hindiCalloutTip: 'दिनों, महीनों और व्यक्तियों के नाम हमेशा Capital Letter से लिखें: "Sunday", "August", "Priya"।',
          quickCheckQuestion: 'Identify the Abstract Noun and Proper Noun in: "Mahatma Gandhi showed tremendous courage."',
          hindiQuickCheckQuestion: 'इस वाक्य में व्यक्तिवाचक और भाववाचक संज्ञा पहचानें: "Mahatma Gandhi showed tremendous courage."',
          quickCheckAnswer: 'Proper Noun: Mahatma Gandhi; Abstract Noun: courage.',
          hindiQuickCheckAnswer: 'व्यक्तिवाचक संज्ञा: Mahatma Gandhi; भाववाचक संज्ञा: courage (साहस)।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'Singular, Plural & Irregular Number Transformations',
          hindiTitle: 'एकवचन, बहुवचन एवं अनियमित वचन परिवर्तन',
          content: 'Nouns change form to indicate number. Singular nouns name one person or object; Plural nouns name two or more. Standard pluralization rules: 1. Add "-s" to most nouns (book ⟹ books, chair ⟹ chairs). 2. Add "-es" to nouns ending in -s, -ss, -sh, -ch, -x, -z (box ⟹ boxes, watch ⟹ watches, dish ⟹ dishes). 3. For nouns ending in a consonant + y, replace "y" with "-ies" (baby ⟹ babies). 4. Irregular plurals do NOT follow standard suffix rules: child ⟹ children, foot ⟹ feet, tooth ⟹ teeth, man ⟹ men, mouse ⟹ mice, person ⟹ people. Some nouns remain identical in singular and plural: sheep ⟹ sheep, deer ⟹ deer, fish ⟹ fish.',
          hindiContent: 'संज्ञा एकवचन (एक वस्तु) या बहुवचन (दो या अधिक वस्तुएं) दर्शाने के लिए बदलती है। नियम: 1. अधिकांश शब्दों में "-s" जोड़ें (book ⟹ books)। 2. -s, -sh, -ch, -x पर समाप्त होने वाले शब्दों में "-es" जोड़ें (box ⟹ boxes, watch ⟹ watches)। 3. व्यंजन + y पर समाप्त होने वाले शब्दों में y हटाकर "-ies" लगाएं (baby ⟹ babies)। 4. अनियमित बहुवचन पूरी तरह बदलते हैं: child ⟹ children, foot ⟹ feet, tooth ⟹ teeth, mouse ⟹ mice। कुछ शब्द एकवचन और बहुवचन दोनों में समान रहते हैं: sheep, deer, fish।',
          keyFormula: 'Regular: Noun + s/es • Irregular: child ⟹ children • foot ⟹ feet • mouse ⟹ mice',
          calloutTip: 'If a vowel comes before "y", just add "-s" without changing: boy ⟹ boys, toy ⟹ toys, key ⟹ keys!',
          hindiCalloutTip: 'यदि "y" से पहले कोई स्वर (vowel) हो, तो केवल "-s" लगाएं: boy ⟹ boys, key ⟹ keys!',
          quickCheckQuestion: 'What is the correct plural form of "Wolf" and "Cactus"?',
          hindiQuickCheckQuestion: '"Wolf" और "Cactus" के सही बहुवचन रूप क्या हैं?',
          quickCheckAnswer: 'Wolf ⟹ Wolves (f becomes ves); Cactus ⟹ Cacti.',
          hindiQuickCheckAnswer: 'Wolf ⟹ Wolves; Cactus ⟹ Cacti।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Pronouns: Replacing Nouns to Create Natural Speech',
          hindiTitle: 'सर्वनाम: संज्ञा का दोहराव रोककर सहज भाषा का निर्माण',
          content: 'Pronouns are words used in place of nouns to avoid clumsy, repetitive sentence construction. Without pronouns, we would have to say: "Rohan saw Rohan\'s dog and Rohan fed Rohan\'s dog." With pronouns, we say: "Rohan saw his dog and he fed it." Types of Pronouns: 1. Personal Subject Pronouns: I, you, he, she, it, we, they. 2. Personal Object Pronouns: me, you, him, her, it, us, them. 3. Possessive Pronouns: mine, yours, his, hers, ours, theirs. 4. Demonstrative Pronouns: this, that (singular), these, those (plural). 5. Relative Pronouns: who, whom, whose, which, that.',
          hindiContent: 'संज्ञा के स्थान पर प्रयुक्त होने वाले शब्दों को सर्वनाम (Pronoun) कहते हैं, जो बार-बार नाम दोहराने की असुविधा से बचाते हैं। प्रकार: 1. पुरुषवाचक कर्ता सर्वनाम: I, you, he, she, it, we, they। 2. कर्म सर्वनाम: me, him, her, us, them। 3. अधिकारवाचक सर्वनाम: mine, yours, his, hers, ours, theirs। 4. संकेतवाचक सर्वनाम: this, that, these, those। 5. संबंधवाचक सर्वनाम: who, which, that।',
          calloutTip: 'Confusing "it\'s" (contraction of "it is") with "its" (possessive pronoun). "The cat licked its paws" has NO apostrophe!',
          hindiCalloutTip: '"it\'s" (it is) और "its" (स्वामित्व) में कभी भ्रम न रखें: "The dog wagged its tail" में apostrophe नहीं आता!',
          quickCheckQuestion: 'Replace the underlined nouns with suitable pronouns: "Sunita called Sunita\'s brother."',
          hindiQuickCheckQuestion: 'उपयुक्त सर्वनाम से वाक्य बदलें: "Sunita called Sunita\'s brother."',
          quickCheckAnswer: '"Sunita called her brother."',
          hindiQuickCheckAnswer: '"Sunita called her brother" (उसने अपने भाई को बुलाया)।',
        ),
        const ChapterSection(
          sectionNumber: '1.4',
          title: 'Articles & Determiners: The Rules of A, An, and The',
          hindiTitle: 'उपपद (Articles): A, An और The के नियम',
          content: 'Articles are words that define whether a noun is specific or unspecific. Indefinite Articles (A, An) are used before singular countable nouns when referring to general or non-specific items. GOLDEN PHONETIC RULE: Use "A" before a CONSONANT SOUND (a book, a doctor, a university - "u" produces consonant /yu/ sound). Use "An" before a VOWEL SOUND (an orange, an elephant, an honest man - silent "h" produces vowel /ɒ/ sound). The Definite Article "The" is used when referring to a specific, previously mentioned item, or unique entities in nature (the Sun, the Moon, the Himalayas, the Atlantic Ocean).',
          hindiContent: 'उपपद (Articles) यह दर्शाते हैं कि संज्ञा विशिष्ट है या सामान्य। Indefinite Articles (A, An): सामान्य एकवचन संज्ञाओं के साथ। स्वर्णिम ध्वनि नियम: व्यंजन ध्वनि से पहले "A" लगाएं (a book, a university - /य/ ध्वनि); स्वर ध्वनि से पहले "An" लगाएं (an apple, an honest man - silent "h" से /ऑ/ ध्वनि)। Definite Article (The): किसी विशिष्ट वस्तु, पहले से ज्ञात वस्तु, या प्राकृतिक रूप से अद्वितीय वस्तुओं के लिए (the Sun, the Ganga, the Earth)।',
          keyFormula: 'A + Consonant SOUND • An + Vowel SOUND • The + Specific / Unique entity',
          calloutTip: 'The choice between A and An depends strictly on SPOKEN SOUND, never on the written letter!',
          hindiCalloutTip: 'A और An का चुनाव केवल बोली जाने वाली ध्वनि (Sound) पर निर्भर करता है, लिखित अक्षर पर नहीं!',
          quickCheckQuestion: 'Fill in with A or An: "___ European traveler" and "___ hour of study".',
          hindiQuickCheckQuestion: 'A या An भरें: "___ European traveler" और "___ hour of study"।',
          quickCheckAnswer: '"A European" (starts with /yu/ consonant sound); "An hour" (silent h produces vowel sound).',
          hindiQuickCheckAnswer: '"A European" (/य/ व्यंजन ध्वनि); "An hour" (/आ/ स्वर ध्वनि)।',
        ),
      ]);

      points.addAll([
        'Proper nouns always start with a capital letter; common nouns do not.',
        'Collective nouns describe groups (a pride of lions); abstract nouns describe intangible qualities (courage).',
        'Irregular plurals change completely (child ⟹ children; foot ⟹ feet; mouse ⟹ mice).',
        'Pronouns replace nouns to avoid awkward repetition (he, she, it, they).',
        'Use "An" before vowel SOUNDS (an hour); use "A" before consonant SOUNDS (a university).',
      ]);
      hindiPoints.addAll([
        'व्यक्तिवाचक संज्ञा हमेशा Capital letter से शुरू होती है।',
        'समूहवाचक संज्ञा समूह को दर्शाती है; भाववाचक संज्ञा अमूर्त गुणों (साहस, ईमानदारी) को दर्शाती है।',
        'अनियमित बहुवचन पूरी तरह बदलते हैं (child ⟹ children, mouse ⟹ mice)।',
        'सर्वनाम संज्ञा के दोहराव को रोकते हैं (he, she, it, they)।',
        'स्वर ध्वनि से पहले "An" (an hour); व्यंजन ध्वनि से पहले "A" (a university) लगाएं।',
      ]);

      facts.addAll([
        'English collective nouns are poetically rich: a group of owls is called a "parliament of owls", a group of crows is a "murder of crows", and a group of flamingos is a "flamboyance"!',
        'The word "noun" comes from the Latin "nomen", meaning "name".',
      ]);
      hindiFacts.addAll([
        'अंग्रेजी में उल्लुओं के समूह को "parliament of owls" (संसद), कौवों के समूह को "murder of crows", और राजहंसों के समूह को "flamboyance" कहा जाता है!',
        '"Noun" शब्द लैटिन भाषा के "nomen" से आया है, जिसका अर्थ "नाम" होता है।',
      ]);
    } else if (titleLower.contains('verb') ||
        titleLower.contains('tense') ||
        titleLower.contains('voice') ||
        titleLower.contains('agreement') ||
        titleLower.contains('modal')) {
      sections.addAll([
        const ChapterSection(
          sectionNumber: '1.1',
          title: 'The Engine of Sentences: Action, Auxiliary & Modal Verbs',
          hindiTitle: 'वाक्यों का इंजन: मुख्य क्रिया, सहायक क्रिया एवं मोडल',
          content: 'A Verb is the most vital element of an English sentence; without a verb, a sentence cannot exist. Verbs perform three distinct functions: 1. Action Verbs: Express physical or mental actions (e.g. run, write, imagine, solve). 2. Helping / Auxiliary Verbs: Combine with main verbs to indicate tense, mood, or voice (is, am, are, was, were, has, have, had, do, does, did). 3. Modal Verbs: Express ability, permission, necessity, or obligation (can, could, may, might, must, should, will, would). Golden Modal Law: Modal verbs are ALWAYS followed by the base form of the main verb without "-s" or "-ed" (e.g. "He can swim", NOT "He can swims").',
          hindiContent: 'क्रिया (Verb) वाक्य का सबसे महत्वपूर्ण अंग है; बिना क्रिया के कोई वाक्य नहीं बन सकता। क्रिया तीन प्रमुख कार्य करती है: 1. मुख्य क्रिया (Action Verbs): शारीरिक या मानसिक कार्य (run, write, think)। 2. सहायक क्रिया (Auxiliary Verbs): काल और अवस्था बताने के लिए (is, am, are, was, were, has, have, had)। 3. मोडल क्रिया (Modal Verbs): क्षमता, अनुमति या आवश्यकता दर्शाने के लिए (can, could, may, must, should)। मोडल नियम: मोडल वर्ब के बाद हमेशा मुख्य क्रिया का मूल रूप (Base Form) आता है ("He can swim", "swims" गलत है)।',
          keyFormula: 'Modal + Base Verb (V1): can play • must go • should study',
          calloutTip: 'Auxiliary verbs "have / has / had" ALWAYS require the Past Participle (V3) form: "She has eaten", NOT "She has ate".',
          hindiCalloutTip: 'have / has / had के बाद हमेशा क्रिया की तीसरी फॉर्म (V3) आती है: "She has written" सही है, "wrote" गलत है।',
          quickCheckQuestion: 'Identify the helping verb and main verb in: "The students were preparing for their annual exams."',
          hindiQuickCheckQuestion: 'इस वाक्य में सहायक क्रिया और मुख्य क्रिया पहचानें: "The students were preparing for their annual exams."',
          quickCheckAnswer: 'Helping Verb: were; Main Verb: preparing.',
          hindiQuickCheckAnswer: 'सहायक क्रिया: were; मुख्य क्रिया: preparing (तैयारी कर रहे थे)।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'The Complete Matrix of Tenses: Past, Present & Future',
          hindiTitle: 'कालों का संपूर्ण चक्र: भूतकाल, वर्तमान काल एवं भविष्य काल',
          content: 'Tense indicates the precise time an action takes place: Past (completed), Present (happening now or habitual), or Future (yet to occur). Each tense has 4 primary aspects: 1. Simple: General facts, routines, or single completed events (Simple Present: "I walk"; Simple Past: "I walked"; Simple Future: "I will walk"). 2. Continuous / Progressive: Actions happening continuously over time (is/am/are + verb-ing; was/were + verb-ing; will be + verb-ing). 3. Perfect: Actions completed relative to a point in time (has/have + V3; had + V3; will have + V3). 4. Perfect Continuous: Actions ongoing up to a specific moment (has/have been + verb-ing).',
          hindiContent: 'काल (Tense) यह बताता है कि कार्य किस समय हुआ: वर्तमान, भूत या भविष्य। प्रत्येक काल के 4 प्रमुख रूप होते हैं: 1. Simple (सामान्य): दैनिक आदतें, शाश्वत सत्य या पूर्ण कार्य ("I write", "I wrote", "I will write")। 2. Continuous (अपूर्ण): जारी रहने वाले कार्य (is/am/are + verb-ing; was/were + verb-ing)। 3. Perfect (पूर्ण): पूरे हो चुके कार्य (has/have + V3; had + V3)। 4. Perfect Continuous: किसी समय से शुरू होकर जारी कार्य।',
          keyFormula: 'Simple: V1 / V2 / will+V1 • Continuous: be + V-ing • Perfect: have/has/had + V3',
          calloutTip: 'Universal truths and scientific facts ALWAYS remain in Simple Present: "The Earth revolves around the Sun" (never revolved)!',
          hindiCalloutTip: 'शाश्वत सत्य और वैज्ञानिक नियम हमेशा Simple Present में रहते हैं: "The Earth revolves around the Sun"!',
          quickCheckQuestion: 'Convert this sentence into Present Continuous Tense: "Aarav reads a mystery novel."',
          hindiQuickCheckQuestion: 'इस वाक्य को Present Continuous में बदलें: "Aarav reads a mystery novel."',
          quickCheckAnswer: '"Aarav is reading a mystery novel."',
          hindiQuickCheckAnswer: '"Aarav is reading a mystery novel" (आरव रहस्यमयी उपन्यास पढ़ रहा है)।',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Subject-Verb Agreement: The Golden Rule of Syntax',
          hindiTitle: 'कर्ता-क्रिया तालमेल: वाक्य विन्यास का स्वर्णिम नियम',
          content: 'Subject-Verb Agreement is the cardinal rule of English grammar: A singular subject requires a singular verb, and a plural subject requires a plural verb. 1. Third-person singular subjects (he, she, it, Rohan) require "-s" or "-es" in Simple Present: "The cat runs", NOT "The cat run". 2. Plural subjects (they, we, the children) take base verbs: "The cats run". 3. Two subjects joined by "and" take a plural verb: "Rohan and Priya are studying". 4. When subjects are joined by "either...or" or "neither...nor", the verb agrees with the CLOSER subject: "Neither the teacher nor the students were present."',
          hindiContent: 'कर्ता-क्रिया तालमेल (Subject-Verb Agreement) का नियम: एकवचन कर्ता के साथ एकवचन क्रिया, और बहुवचन कर्ता के साथ बहुवचन क्रिया आती है। 1. एकवचन तृतीय पुरुष (he, she, it, Mohan) के साथ क्रिया में "-s/-es" लगाना अनिवार्य है: "The boy plays", "play" गलत है। 2. बहुवचन कर्ता के साथ मूल क्रिया आती है: "The boys play"। 3. "and" से जुड़े दो कर्ता बहुवचन क्रिया लेते हैं। 4. "neither...nor" में क्रिया अपने सबसे नजदीकी कर्ता के अनुसार बदलती है।',
          keyFormula: 'Singular Subject + Verb-s (He runs) • Plural Subject + Base Verb (They run)',
          calloutTip: 'Indefinite pronouns like "Everyone", "Someone", "Each", and "Nobody" are strictly SINGULAR: "Everyone is happy", NOT "are happy"!',
          hindiCalloutTip: '"Everyone", "Each", "Nobody" हमेशा एकवचन होते हैं: "Everyone has arrived", "have" गलत है!',
          quickCheckQuestion: 'Choose the correct verb: "Neither the captain nor the players (was / were) ready."',
          hindiQuickCheckQuestion: 'सही क्रिया चुनें: "Neither the captain nor the players (was / were) ready."',
          quickCheckAnswer: 'were (agrees with the closer plural subject "players").',
          hindiQuickCheckAnswer: 'were (क्योंकि नजदीकी कर्ता "players" बहुवचन है)।',
        ),
        const ChapterSection(
          sectionNumber: '1.4',
          title: 'Active & Passive Voice: Shifting Sentence Perspective',
          hindiTitle: 'कर्तृवाच्य एवं कर्मवाच्य: वाक्य के दृष्टिकोण का परिवर्तन',
          content: 'Voice indicates whether the subject of the sentence performs or receives the action. 1. Active Voice: The subject performs the action directly: Subject + Verb + Object (e.g. "Alexander Fleming discovered penicillin."). Active voice is lively, clear, and direct. 2. Passive Voice: The subject receives the action; the object is moved to the primary focus: Object + appropriate form of "be" + Past Participle (V3) + by + Subject (e.g. "Penicillin was discovered by Alexander Fleming."). Passive voice is predominantly used in scientific writing, official reports, and news headlines where the result matters more than the actor.',
          hindiContent: 'वाच्य (Voice) यह दर्शाता है कि कर्ता कार्य कर रहा है या कार्य का प्रभाव झेल रहा है। 1. Active Voice (कर्तृवाच्य): कर्ता स्वयं कार्य करता है: कर्ता + क्रिया + कर्म ("राम ने पत्र लिखा")। 2. Passive Voice (कर्मवाच्य): कर्म को मुख्य स्थान दिया जाता है: कर्म + be का रूप + क्रिया की तीसरी फॉर्म (V3) + by + कर्ता ("पत्र राम द्वारा लिखा गया")। वैज्ञानिक रिपोर्टों और समाचारों में Passive Voice का अधिक प्रयोग होता है।',
          keyFormula: 'Active: S + V + O ⟹ Passive: O + be + V3 (Past Participle) + by + S',
          calloutTip: 'Only TRANSITIVE verbs (verbs that take a direct object) can be converted into passive voice! Intransitive verbs like "sleep", "laugh", and "arrive" cannot be made passive.',
          hindiCalloutTip: 'केवल सकर्मक क्रियाओं (जिनमें कर्म होता है) को ही Passive Voice में बदला जा सकता है! "He slept" का Passive नहीं बनता।',
          quickCheckQuestion: 'Convert to Passive Voice: "The chef cooked a delicious dinner."',
          hindiQuickCheckQuestion: 'Passive Voice में बदलें: "The chef cooked a delicious dinner."',
          quickCheckAnswer: '"A delicious dinner was cooked by the chef."',
          hindiQuickCheckAnswer: '"A delicious dinner was cooked by the chef" (स्वादिष्ट भोजन शेफ द्वारा पकाया गया)।',
        ),
      ]);

      points.addAll([
        'Verbs are the essential core of every sentence, expressing actions, states, or permissions.',
        'Modal verbs (can, could, may, must, should) are always followed by the base verb (V1).',
        'Singular subjects require singular verbs with "-s" in present tense (He walks; They walk).',
        'Universal scientific truths always remain in Simple Present tense.',
        'Passive voice always requires the Past Participle (V3) form of the main verb.',
      ]);
      hindiPoints.addAll([
        'क्रिया प्रत्येक वाक्य का अनिवार्य केंद्र है।',
        'मोडल वर्ब्स (can, must, should) के बाद हमेशा मुख्य क्रिया का मूल रूप आता है।',
        'वर्तमान काल में एकवचन कर्ता के साथ क्रिया में "-s/-es" लगाना अनिवार्य है।',
        'शाश्वत वैज्ञानिक सत्य हमेशा Simple Present काल में ही रहते हैं।',
        'Passive Voice में हमेशा क्रिया की तीसरी फॉर्म (V3) का प्रयोग होता है।',
      ]);

      facts.addAll([
        'The shortest grammatically complete sentence in the entire English language is the two-word command: "Go!" (where the implied subject is "You").',
        'The verb "set" has the largest number of distinct definitions in the Oxford English Dictionary: over 430 different senses!',
      ]);
      hindiFacts.addAll([
        'अंग्रेजी का सबसे छोटा पूर्ण वाक्य केवल दो अक्षरों का आदेश है: "Go!" (जाओ! जहाँ कर्ता "You" छिपा होता है)।',
        '"set" क्रिया के ऑक्सफोर्ड डिक्शनरी में 430 से अधिक विभिन्न अर्थ दर्ज हैं!',
      ]);
    } else {
      // Fallback / General English
      sections.addAll([
        ChapterSection(
          sectionNumber: '1.1',
          title: 'Foundations of ${chapter.title}',
          hindiTitle: '${chapter.title} के आधारभूत सिद्धांत',
          content: 'Effective communication requires grammatical accuracy, precise vocabulary, and organized expression. In ${chapter.title}, we explore essential rules and stylistic techniques that elevate reading comprehension and written clarity, enabling students to communicate fluently across academic, literary, and real-world contexts.',
          hindiContent: 'प्रभावी संचार के लिए व्याकरण की शुद्धता, सटीक शब्दावली और व्यवस्थित अभिव्यक्ति आवश्यक है। ${chapter.title} में हम उन नियमों और शैलियों को सीखते हैं जो भाषा की समझ और लेखन को निखारते हैं।',
          calloutTip: 'Read quality books daily: natural immersion is the fastest path to intuitive grammar mastery.',
          hindiCalloutTip: 'प्रतिदिन अच्छी किताबें पढ़ें: स्वाभाविक पठन ही व्याकरण में दक्षता पाने का सबसे तेज मार्ग है।',
          quickCheckQuestion: 'Why is clear sentence structure vital in formal writing?',
          hindiQuickCheckQuestion: 'औपचारिक लेखन में स्पष्ट वाक्य संरचना क्यों महत्वपूर्ण है?',
          quickCheckAnswer: 'It eliminates ambiguity and ensures the reader understands the exact intended meaning.',
          hindiQuickCheckAnswer: 'यह किसी भी प्रकार के भ्रम को दूर करती है और पाठक तक सही संदेश पहुँचाती है।',
        ),
        const ChapterSection(
          sectionNumber: '1.2',
          title: 'Punctuation Mechanics & Sentence Clarity',
          hindiTitle: 'विराम चिह्न एवं वाक्य की स्पष्टता',
          content: 'Punctuation marks act as traffic signals for readers, guiding cadence, pauses, and meaning. Full stops (.) end declarative statements; Question marks (?) conclude interrogative questions; Exclamation marks (!) convey intense emotion or surprise; Commas (,) introduce natural pauses and prevent comical misinterpretations (e.g. "Let\'s eat, Grandpa!" vs "Let\'s eat Grandpa!"). Quotation marks ("...") enclose exact spoken dialogue in direct speech.',
          hindiContent: 'विराम चिह्न पाठकों के लिए ट्रैफिक सिग्नल की तरह कार्य करते हैं जो ठहराव और अर्थ को स्पष्ट करते हैं। पूर्ण विराम (.) वाक्य की समाप्ति पर, प्रश्नवाचक चिह्न (?) प्रश्न के अंत में, और विस्मयादिबोधक चिह्न (!) गहरी भावना या आश्चर्य व्यक्त करने के लिए लगाया जाता है। अल्पविराम (,) संक्षिप्त ठहराव देता है और अर्थ का अनर्थ होने से बचाता है। उद्धरण चिह्न ("...") बोले गए वास्तविक शब्दों के लिए आते हैं।',
          keyFormula: 'Punctuation Rules: Capitalize first word • End with . / ? / ! • Use commas for lists',
          calloutTip: 'Every direct question MUST end with a question mark (?): "Where are you going?"',
          hindiCalloutTip: 'प्रत्येक प्रत्यक्ष प्रश्न के अंत में प्रश्नवाचक चिह्न (?) लगाना अनिवार्य है!',
          quickCheckQuestion: 'Punctuate correctly: "where did rohan put his backpack asked priya"',
          hindiQuickCheckQuestion: 'सही विराम चिह्न लगाएं: "where did rohan put his backpack asked priya"',
          quickCheckAnswer: '"Where did Rohan put his backpack?" asked Priya.',
          hindiQuickCheckAnswer: '"Where did Rohan put his backpack?" asked Priya.',
        ),
        const ChapterSection(
          sectionNumber: '1.3',
          title: 'Vocabulary Enhancement: Synonyms, Antonyms & Context Clues',
          hindiTitle: 'शब्दावली संवर्धन: पर्यायवाची, विलोम एवं संदर्भ संकेत',
          content: 'A robust vocabulary transforms simple ideas into vivid, persuasive communication. Synonyms are words having identical or nearly identical meanings (e.g. courageous ⟹ brave; gigantic ⟹ huge). Antonyms are words with opposing meanings (e.g. expand ⟹ contract; victory ⟹ defeat). Context clues are hints embedded within surrounding sentences that allow perceptive readers to deduce the definitions of unfamiliar vocabulary words without a dictionary.',
          hindiContent: 'समृद्ध शब्दावली साधारण विचारों को प्रभावशाली और सजीव बनाती है। पर्यायवाची (Synonyms) समान अर्थ वाले शब्द हैं (courageous ⟹ brave; huge ⟹ gigantic)। विलोम (Antonyms) विपरीत अर्थ वाले शब्द हैं (victory ⟹ defeat)। संदर्भ संकेत (Context clues) वाक्य के आसपास के वे शब्द हैं जिनकी मदद से पाठक किसी नए कठिन शब्द का अर्थ बिना डिक्शनरी के समझ लेता है।',
          calloutTip: 'Many antonyms are created by adding negative prefixes: un- (happy/unhappy), dis- (honest/dishonest), im- (possible/impossible).',
          hindiCalloutTip: 'कई विलोम शब्द उपसर्ग जोड़कर बनते हैं: un- (kind/unkind), dis- (agree/disagree), im- (patient/impatient)।',
          quickCheckQuestion: 'Give one synonym and one antonym for the word "Ancient".',
          hindiQuickCheckQuestion: '"Ancient" (प्राचीन) शब्द का एक पर्यायवाची और एक विलोम शब्द बताएं।',
          quickCheckAnswer: 'Synonym: Antique / Historic; Antonym: Modern / Contemporary.',
          hindiQuickCheckAnswer: 'पर्यायवाची: Antique / Historic; विलोम शब्द: Modern (आधुनिक)।',
        ),
      ]);

      points.addAll([
        'Punctuation marks clarify syntax, cadence, and prevent ambiguity.',
        'Proper nouns and the pronoun "I" must always be capitalized wherever they appear.',
        'Vocabulary depth directly correlates with reading comprehension score and creative expression.',
        'Use prefixes (un-, dis-, im-) to logically formulate antonyms.',
      ]);
      hindiPoints.addAll([
        'विराम चिह्न वाक्य के प्रवाह और अर्थ को स्पष्ट करते हैं।',
        'व्यक्तिवाचक संज्ञा और सर्वनाम "I" हमेशा Capital letter में लिखे जाते हैं।',
        'शब्दावली की गहराई सीधे तौर पर पठन समझ और रचनात्मक अभिव्यक्ति को बढ़ाती है।',
        'उपसर्गों (un-, dis-, im-) का प्रयोग करके विलोम शब्द बनाए जाते हैं।',
      ]);

      facts.addAll([
        'The Oxford English Dictionary contains over 600,000 defined words spanning more than 1,000 years of English history!',
      ]);
      hindiFacts.addAll([
        'ऑक्सफोर्ड इंग्लिश डिक्शनरी में 6 लाख से अधिक शब्द दर्ज हैं जो 1,000 वर्षों के अंग्रेजी इतिहास को दर्शाते हैं!',
      ]);
    }
  }
}
