import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/chapter_model.dart';
import 'concept_reading_service.dart';

/// Service providing complete story, poetry, and prose reading texts
/// for the Literature section (ICSE Orient BlackSwan, Miranda Publisher, and NCERT).
class LiteratureReadingService {
  static final LiteratureReadingService instance = LiteratureReadingService._internal();
  LiteratureReadingService._internal();

  Map<String, dynamic> _cache = {};
  bool _isLoaded = false;

  /// Loads the bundled literature reading dataset from JSON assets
  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/curriculum/literature_reading_data.json');
      final dynamic parsed = json.decode(jsonString);
      if (parsed is Map<String, dynamic>) {
        _cache = parsed;
        _isLoaded = true;
        return;
      }
    } catch (_) {
      // Fallback below
    }

    try {
      final file = File('assets/curriculum/literature_reading_data.json');
      if (file.existsSync()) {
        final jsonString = await file.readAsString();
        final dynamic parsed = json.decode(jsonString);
        if (parsed is Map<String, dynamic>) {
          _cache = parsed;
          _isLoaded = true;
        }
      }
    } catch (_) {
      // Keep empty if failed
    }
  }

  /// Whether reading material exists for this chapterId
  bool hasReadingData(String chapterId) {
    return _cache.containsKey(chapterId);
  }

  /// Checks if a chapter is a literature reader chapter (story/poem)
  bool isLiteratureChapter(Chapter chapter) {
    if (chapter.subjectId == 'english') return false;
    final isLang = chapter.subjectId == 'hindi';
    if (!isLang) return false;
    return chapter.publisher != 'grammar';
  }

  /// Retrieves raw reading data for a chapter
  Map<String, dynamic>? getReadingData(String chapterId) {
    return _cache[chapterId] as Map<String, dynamic>?;
  }

  /// Converts literature story data into ChapterStudyMaterial for TextbookReaderScreen
  ChapterStudyMaterial? buildStudyMaterial(Chapter chapter) {
    final data = getReadingData(chapter.chapterId);
    if (data == null) return null;

    final isPoem = data['isPoem'] as bool? ?? false;
    final author = data['author'] as String? ?? chapter.author ?? 'Author';
    final bookTitle = data['bookTitle'] as String? ?? chapter.bookTitle ?? 'Literature Reader';
    final rawSections = data['sections'] as List<dynamic>? ?? [];
    final rawGlossary = data['glossary'] as List<dynamic>? ?? [];

    final sections = <ChapterSection>[];
    for (var i = 0; i < rawSections.length; i++) {
        final s = rawSections[i] as Map<String, dynamic>;
        final secNum = s['sectionNumber']?.toString() ?? '${i + 1}';
        final title = s['title'] as String? ?? 'Scene ${i + 1}';
        final hindiTitle = s['hindiTitle'] as String? ?? title;
        final content = s['content'] as String? ?? '';
        final hindiContent = s['hindiContent'] as String? ?? content;
        final callout = s['calloutTip'] as String?;
        final hindiCallout = s['hindiCalloutTip'] as String?;
        final q = s['quickCheckQuestion'] as String?;
        final hq = s['hindiQuickCheckQuestion'] as String?;
        final a = s['quickCheckAnswer'] as String?;
        final ha = s['hindiQuickCheckAnswer'] as String?;

        sections.add(
          ChapterSection(
            sectionNumber: secNum,
            title: title,
            hindiTitle: hindiTitle,
            content: content,
            hindiContent: hindiContent,
            calloutTip: callout,
            hindiCalloutTip: hindiCallout,
            quickCheckQuestion: q,
            hindiQuickCheckQuestion: hq,
            quickCheckAnswer: a,
            hindiQuickCheckAnswer: ha,
          ),
        );
    }

    final definitions = <ConceptDefinition>[];
    for (final item in rawGlossary) {
      if (item is Map<String, dynamic>) {
        final word = item['word'] as String? ?? '';
        final meaning = item['meaning'] as String? ?? '';
        final hindiMeaning = item['hindiMeaning'] as String? ?? meaning;
        final ex = item['exampleSentence'] as String?;

        definitions.add(
          ConceptDefinition(
            term: word,
            hindiTerm: word,
            definition: meaning,
            hindiDefinition: hindiMeaning,
            example: ex != null ? 'Example: $ex' : null,
            hindiExample: ex != null ? 'उदाहरण: $ex' : null,
          ),
        );
      }
    }

    final moral = data['moral'] as String? ?? 'Kindness, wisdom, and moral courage enrich life.';
    final hindiMoral = data['hindiMoral'] as String? ?? moral;
    final authorBio = data['authorBio'] as String? ?? 'Written by $author.';
    final hindiAuthorBio = data['hindiAuthorBio'] as String? ?? 'रचयिता: $author।';

    return ChapterStudyMaterial(
      chapterId: chapter.chapterId,
      title: data['title'] as String? ?? chapter.title,
      hindiTitle: data['hindiTitle'] as String? ?? chapter.title,
      grade: chapter.grade,
      subjectId: chapter.subjectId,
      icon: isPoem ? '📜' : '📖',
      overview: data['overview'] as String? ?? chapter.description,
      hindiOverview: data['hindiOverview'] as String? ?? chapter.description,
      definitions: definitions,
      quickRulesAndFormulas: isPoem ? ['Verse Form: Stanzas', 'Author: $author', 'Book: $bookTitle'] : ['Genre: Classic Story', 'Author: $author', 'Book: $bookTitle'],
      hindiQuickRulesAndFormulas: isPoem ? ['विधा: कविता', 'रचयिता: $author', 'पुस्तक: $bookTitle'] : ['विधा: कहानी / गद्य', 'रचयिता: $author', 'पुस्तक: $bookTitle'],
      solvedExamples: const [],
      examTraps: const [],
      hindiExamTraps: const [],
      realWorldConnection: 'Literature fosters empathy, enhances vocabulary, and sharpens analytical thinking.',
      hindiRealWorldConnection: 'साहित्य पढ़ने से संवेदनशीलता, भाषा पर पकड़ और नैतिक सोच का विकास होता है।',
      proTip: 'Read aloud line-by-line to master expressive pronunciation, cadence, and voice modulation.',
      hindiProTip: 'कविताओं और संवादों को बोलकर पढ़ने से उच्चारण और वाचन शैली में निखार आता है।',
      textbookSections: sections,
      pointsToRemember: [
        'Central Theme: $moral',
        'Story Setting: $bookTitle',
        'Author & Style: Written by $author with vivid imagery and character dialogue.',
      ],
      hindiPointsToRemember: [
        'मुख्य सीख: $hindiMoral',
        'पाठ्यपुस्तक: $bookTitle',
        'रचनाकार: $author की यह रचना मानवीय मूल्यों को उजागर करती है।',
      ],
      didYouKnowFacts: [
        authorBio,
        'Reading full literary narratives increases vocabulary 4x faster than memorizing isolated word lists!',
      ],
      hindiDidYouKnowFacts: [
        hindiAuthorBio,
        'पूरी कहानियां और कविताएं पढ़ने से बच्चों का शब्दकोश और समझने की शक्ति चार गुना तेज़ी से बढ़ती है!',
      ],
    );
  }
}
