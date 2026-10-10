import '../../../data/models/student_profile.dart';

/// Represents a single word challenge in Curio Spell Bee
class SpellBeeWord {
  final String word; // e.g. "ACCOMMODATE"
  final String definition; // e.g. "To provide lodging or sufficient space for"
  final String exampleSentence; // e.g. "The auditorium can accommodate over two thousand guests."
  final String emoji; // e.g. "🏨"
  final String phonetic; // e.g. "/əˈkɒm.ə.deɪt/"
  final String partOfSpeech; // e.g. "Verb"
  final String origin; // e.g. "Latin"
  final List<String> confusables; // Common misspellings for Olympiad MCQ
  final int difficulty; // 1 (beginner) to 5 (champion)
  final StudentClass targetClass;

  const SpellBeeWord({
    required this.word,
    required this.definition,
    required this.exampleSentence,
    required this.emoji,
    this.phonetic = '',
    this.partOfSpeech = 'Noun',
    this.origin = 'English',
    this.confusables = const [],
    this.difficulty = 1,
    required this.targetClass,
  });

  /// Uppercase letters for tile comparison
  List<String> get letterList => word.toUpperCase().split('');

  /// Word length
  int get length => word.length;

  /// Generates 4 distinct choices for Olympiad MCQ (1 correct + 3 tricky variations)
  List<String> getMcqChoices() {
    final correct = word.toUpperCase();
    final set = <String>{correct};

    // 1. Add predefined confusable spellings if available
    for (final c in confusables) {
      if (c.toUpperCase() != correct) {
        set.add(c.toUpperCase());
        if (set.length >= 4) break;
      }
    }

    // 2. Synthesize plausible typographical/phonetic distractors if fewer than 4
    if (set.length < 4) {
      final generated = _generateSyntheticDistractors(correct);
      for (final g in generated) {
        set.add(g);
        if (set.length >= 4) break;
      }
    }

    final list = set.toList();
    list.shuffle();
    return list;
  }

  static List<String> _generateSyntheticDistractors(String word) {
    final results = <String>[];
    // Common double-letter confusion
    final doublePattern = RegExp(r'(.)\1');
    if (doublePattern.hasMatch(word)) {
      results.add(word.replaceFirstMapped(doublePattern, (m) => m.group(1)!));
    }

    // Common vowel substitutions (e.g. e <-> i, a <-> e, c <-> s)
    if (word.contains('IE')) results.add(word.replaceFirst('IE', 'EI'));
    if (word.contains('EI')) results.add(word.replaceFirst('EI', 'IE'));
    if (word.contains('ABLE')) results.add(word.replaceFirst('ABLE', 'IBLE'));
    if (word.contains('IBLE')) results.add(word.replaceFirst('IBLE', 'ABLE'));
    if (word.contains('ANCE')) results.add(word.replaceFirst('ANCE', 'ENCE'));
    if (word.contains('ENCE')) results.add(word.replaceFirst('ENCE', 'ANCE'));

    // Consonant double additions
    if (word.contains('M') && !word.contains('MM')) results.add(word.replaceFirst('M', 'MM'));
    if (word.contains('C') && !word.contains('CC')) results.add(word.replaceFirst('C', 'CC'));
    if (word.contains('L') && !word.contains('LL')) results.add(word.replaceFirst('L', 'LL'));

    // Swap adjacent characters if length > 4
    if (word.length >= 4) {
      final chars = word.split('');
      final idx = chars.length ~/ 2;
      final temp = chars[idx];
      chars[idx] = chars[idx - 1];
      chars[idx - 1] = temp;
      results.add(chars.join(''));
    }

    // Fallback letter alterations
    if (results.isEmpty) {
      if (word.endsWith('S')) {
        results.add('${word}E');
      } else {
        results.add('${word}S');
      }
    }

    return results;
  }
}
