import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/core/audio/voice_spelling_service.dart';

void main() {
  group('VoiceSpellingParser Tests', () {
    test('Direct target word matching gives target letters', () {
      final letters = VoiceSpellingParser.parseToLetters('cat', targetWord: 'CAT');
      expect(letters, equals(['C', 'A', 'T']));

      final letters2 = VoiceSpellingParser.parseToLetters('elephant', targetWord: 'ELEPHANT');
      expect(letters2, equals(['E', 'L', 'E', 'P', 'H', 'A', 'N', 'T']));
    });

    test('Space-separated letter speech parsed correctly', () {
      final letters = VoiceSpellingParser.parseToLetters('C A T', targetWord: 'CAT');
      expect(letters, equals(['C', 'A', 'T']));

      final letters2 = VoiceSpellingParser.parseToLetters('d o g', targetWord: 'DOG');
      expect(letters2, equals(['D', 'O', 'G']));
    });

    test('Hyphenated and dotted letter speech parsed correctly', () {
      final letters = VoiceSpellingParser.parseToLetters('C-A-T', targetWord: 'CAT');
      expect(letters, equals(['C', 'A', 'T']));

      final letters2 = VoiceSpellingParser.parseToLetters('c.a.t.', targetWord: 'CAT');
      expect(letters2, equals(['C', 'A', 'T']));
    });

    test('Phonetic spoken letter names parsed correctly', () {
      // e.g. "see ay tea" for CAT
      final letters = VoiceSpellingParser.parseToLetters('see ay tea', targetWord: 'CAT');
      expect(letters, equals(['C', 'A', 'T']));

      // e.g. "bee ee dee" for BED
      final letters2 = VoiceSpellingParser.parseToLetters('bee ee dee', targetWord: 'BED');
      expect(letters2, equals(['B', 'E', 'D']));

      // e.g. "el eye oh en" for LION
      final letters3 = VoiceSpellingParser.parseToLetters('el eye oh en', targetWord: 'LION');
      expect(letters3, equals(['L', 'I', 'O', 'N']));
    });

    test('Double U phonetic spoken parsed correctly', () {
      final letters = VoiceSpellingParser.parseToLetters('double u i n', targetWord: 'WIN');
      expect(letters, equals(['W', 'I', 'N']));
    });

    test('Empty or blank input returns empty list', () {
      final letters = VoiceSpellingParser.parseToLetters('', targetWord: 'CAT');
      expect(letters, isEmpty);

      final letters2 = VoiceSpellingParser.parseToLetters('   ', targetWord: 'CAT');
      expect(letters2, isEmpty);
    });
  });
}
