import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Intelligent parser for child spoken spellings.
/// Handles letter-by-letter speech (e.g. "C - A - T", "see ay tea"),
/// whole word speech ("CAT"), and spaced or punctuated sequences.
class VoiceSpellingParser {
  static final Map<String, String> _phoneticLetterMap = {
    'ay': 'A',
    'a': 'A',
    'bee': 'B',
    'be': 'B',
    'b': 'B',
    'see': 'C',
    'sea': 'C',
    'si': 'C',
    'c': 'C',
    'dee': 'D',
    'd': 'D',
    'ee': 'E',
    'e': 'E',
    'ef': 'F',
    'eff': 'F',
    'f': 'F',
    'gee': 'G',
    'g': 'G',
    'aitch': 'H',
    'h': 'H',
    'eye': 'I',
    'i': 'I',
    'jay': 'J',
    'j': 'J',
    'kay': 'K',
    'k': 'K',
    'el': 'L',
    'ell': 'L',
    'l': 'L',
    'em': 'M',
    'm': 'M',
    'en': 'N',
    'n': 'N',
    'oh': 'O',
    'o': 'O',
    'pee': 'P',
    'p': 'P',
    'cue': 'Q',
    'queue': 'Q',
    'q': 'Q',
    'ar': 'R',
    'are': 'R',
    'r': 'R',
    'ess': 'S',
    'es': 'S',
    's': 'S',
    'tee': 'T',
    'tea': 'T',
    'ti': 'T',
    't': 'T',
    'you': 'U',
    'u': 'U',
    'vee': 'V',
    'we': 'V',
    'v': 'V',
    'double you': 'W',
    'double u': 'W',
    'w': 'W',
    'ex': 'X',
    'x': 'X',
    'why': 'Y',
    'y': 'Y',
    'zed': 'Z',
    'zee': 'Z',
    'z': 'Z',
  };

  /// Parses raw speech recognition text into an ordered list of uppercase letters.
  /// If the raw speech matches the target word directly, returns target word's letters.
  static List<String> parseToLetters(String rawText, {String? targetWord}) {
    if (rawText.trim().isEmpty) return [];

    final cleanText = rawText.trim().toUpperCase();

    // 1. Direct whole word match with target
    if (targetWord != null && targetWord.isNotEmpty) {
      final targetUpper = targetWord.trim().toUpperCase();
      // Direct whole word speech (e.g. child said "CAT" or "cat")
      if (cleanText == targetUpper || cleanText.replaceAll(' ', '') == targetUpper) {
        return targetUpper.split('');
      }
    }

    // 2. Tokenize by whitespace, hyphens, periods, and commas
    final normalized = rawText
        .toLowerCase()
        .replaceAll(RegExp(r'[\-,\.\;]'), ' ')
        .replaceAll('double u', 'w')
        .replaceAll('double you', 'w');

    final tokens = normalized.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final List<String> letters = [];

    for (final token in tokens) {
      if (_phoneticLetterMap.containsKey(token)) {
        letters.add(_phoneticLetterMap[token]!);
      } else if (token.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(token)) {
        letters.add(token.toUpperCase());
      } else {
        // Multi-letter word spoken in sequence
        for (final char in token.split('')) {
          if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
            letters.add(char.toUpperCase());
          }
        }
      }
    }

    return letters;
  }
}

/// Service managing Speech-to-Text for Voice-based spelling mode
class VoiceSpellingService {
  static final VoiceSpellingService instance = VoiceSpellingService._internal();
  VoiceSpellingService._internal();

  stt.SpeechToText? _speech;
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _speech?.isAvailable ?? false;

  Future<bool> init() async {
    if (_isInitialized && _speech != null) {
      return _speech!.isAvailable;
    }
    try {
      _speech = stt.SpeechToText();
      _isInitialized = await _speech!.initialize(
        onError: (val) {
          debugPrint('VoiceSpellingService error: ${val.errorMsg}');
          _isListening = false;
        },
        onStatus: (val) {
          debugPrint('VoiceSpellingService status: $val');
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('VoiceSpellingService init exception: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Start listening for voice spelling
  Future<void> startListening({
    required String targetWord,
    required void Function(String recognizedWords, List<String> parsedLetters, bool isMatch) onResult,
    void Function(String errorMessage)? onError,
    void Function()? onListeningComplete,
  }) async {
    final ready = await init();
    if (!ready || _speech == null) {
      onError?.call('Microphone access is unavailable or speech service not ready.');
      return;
    }

    _isListening = true;

    try {
      await _speech!.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          final letters = VoiceSpellingParser.parseToLetters(words, targetWord: targetWord);
          final isMatch = letters.join('').toUpperCase() == targetWord.toUpperCase();
          onResult(words, letters, isMatch);

          if (result.finalResult) {
            _isListening = false;
            onListeningComplete?.call();
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
          localeId: 'en_IN', // Default to Indian English, fallbacks to device default
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    } catch (e) {
      _isListening = false;
      onError?.call('Could not start listening: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speech != null && _isListening) {
      try {
        await _speech!.stop();
      } catch (e) {
        debugPrint('VoiceSpellingService stop error: $e');
      }
    }
    _isListening = false;
  }
}
