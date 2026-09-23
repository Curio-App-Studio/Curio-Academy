import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/local/local_storage_service.dart';
import '../../data/models/voice_settings.dart';

/// Sound feedback effects available in Curio
enum CurioSfx {
  bubblePop,
  correctCheer,
  gentleWobble,
  starAward,
  click,
  applause,
}

abstract class IAudioService {
  Future<void> playSfx(CurioSfx sfx);
  Future<void> speakPrompt(String text);
  void stopAudio();
}

/// Robust Kid-friendly Audio & Haptic Service
/// Gracefully combines SystemSound, HapticFeedback, AudioPlayer, and FlutterTts
class AudioService implements IAudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  FlutterTts? _flutterTts;
  AudioPlayer? _audioPlayer;
  bool _isTtsInitialized = false;
  VoiceSettings _currentVoiceSettings = const VoiceSettings();
  final ValueNotifier<bool> muteNotifier = ValueNotifier<bool>(false);

  bool get isMuted => muteNotifier.value;
  VoiceSettings get currentVoiceSettings => _currentVoiceSettings;

  Future<void> _initTts() async {
    muteNotifier.value = LocalStorageService.instance.isAudioMuted();
    if (_isTtsInitialized) return;
    try {
      _flutterTts = FlutterTts();
      _currentVoiceSettings = LocalStorageService.instance.getVoiceSettings();
      await _applyVoiceSettings(_currentVoiceSettings);
      _isTtsInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CurioAudioTTS] Init error: $e');
      }
    }
  }

  Future<void> toggleMute() async {
    final newMute = !muteNotifier.value;
    muteNotifier.value = newMute;
    await LocalStorageService.instance.saveAudioMuted(newMute);
    if (newMute) {
      stopAudio();
    }
  }

  Future<void> setMuted(bool muted) async {
    muteNotifier.value = muted;
    await LocalStorageService.instance.saveAudioMuted(muted);
    if (muted) {
      stopAudio();
    }
  }

  Future<void> setVoiceSettings(VoiceSettings settings) async {
    _currentVoiceSettings = settings;
    await LocalStorageService.instance.saveVoiceSettings(settings);
    await _applyVoiceSettings(settings);
  }

  Future<void> _applyVoiceSettings(VoiceSettings settings) async {
    if (_flutterTts == null) return;
    try {
      await _flutterTts!.setSpeechRate(settings.speechRate);
      await _flutterTts!.setPitch(settings.pitch);
      await _flutterTts!.setVolume(1.0);

      final isSupported = await _flutterTts!.isLanguageAvailable(settings.locale);
      if (isSupported == true) {
        await _flutterTts!.setLanguage(settings.locale);
      } else {
        await _flutterTts!.setLanguage("en-US");
      }

      if (settings.systemVoiceName != null && settings.systemVoiceName!.isNotEmpty) {
        await _flutterTts!.setVoice({
          "name": settings.systemVoiceName!,
          "locale": settings.locale,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CurioAudioTTS] Error applying voice settings: $e');
      }
    }
  }

  Future<List<Map<String, String>>> getAvailableVoices() async {
    await _initTts();
    if (_flutterTts == null) return [];
    try {
      final dynamic voices = await _flutterTts!.getVoices;
      if (voices is List) {
        final List<Map<String, String>> result = [];
        for (final v in voices) {
          if (v is Map) {
            final name = v['name']?.toString() ?? '';
            final locale = v['locale']?.toString() ?? '';
            if (name.isNotEmpty && locale.toLowerCase().startsWith('en')) {
              result.add({'name': name, 'locale': locale});
            }
          }
        }
        return result;
      }
    } catch (_) {}
    return [];
  }

  Future<void> testVoiceSample(VoiceSettings settings) async {
    await _initTts();
    await _applyVoiceSettings(settings);
    final personaGreeting = switch (settings.persona) {
      VoicePersona.buddy => "Hi there! I am Curio Buddy! Let's explore together!",
      VoicePersona.teacher => "Hello! Welcome to your learning session. Let's practice step by step.",
      VoicePersona.mentor => "Greetings, scholar! Every challenge is an opportunity to learn.",
      VoicePersona.robot => "Beep boop! Curio Spark online! Ready for awesome knowledge!",
    };
    await speakPrompt(personaGreeting);
  }

  @override
  Future<void> playSfx(CurioSfx sfx) async {
    if (isMuted) return;
    switch (sfx) {
      case CurioSfx.bubblePop:
        await HapticFeedback.mediumImpact();
        await SystemSound.play(SystemSoundType.click);
        break;
      case CurioSfx.correctCheer:
        await HapticFeedback.heavyImpact();
        await SystemSound.play(SystemSoundType.click);
        break;
      case CurioSfx.applause:
        await HapticFeedback.mediumImpact();
        break;
      case CurioSfx.gentleWobble:
        await HapticFeedback.selectionClick();
        break;
      case CurioSfx.starAward:
        await HapticFeedback.mediumImpact();
        await SystemSound.play(SystemSoundType.click);
        break;
      case CurioSfx.click:
        await HapticFeedback.selectionClick();
        await SystemSound.play(SystemSoundType.click);
        break;
    }
  }

  @override
  Future<void> speakPrompt(String text) async {
    if (isMuted) return;
    if (kDebugMode) {
      debugPrint('[CurioAudioTTS] Speaking prompt: "$text"');
    }

    try {
      await _initTts();
      if (_flutterTts != null) {
        final cleanText = _cleanTextForSpeech(text);
        await _flutterTts!.stop();
        if (cleanText.trim().isNotEmpty) {
          await _flutterTts!.speak(cleanText);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CurioAudioTTS] Speech error: $e');
      }
    }
  }

  @override
  void stopAudio() {
    try {
      _flutterTts?.stop();
      _audioPlayer?.stop();
    } catch (_) {}
  }

  /// Cleans math notation, markdown, and emojis so speech synthesizer sounds natural
  String _cleanTextForSpeech(String input) {
    return input
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('•', ', ')
        .replaceAll('−', ' minus ')
        .replaceAll('-', ' minus ')
        .replaceAll('+', ' plus ')
        .replaceAll('×', ' multiplied by ')
        .replaceAll('÷', ' divided by ')
        .replaceAll('=', ' equals ')
        .replaceAll('≠', ' does not equal ')
        .replaceAll('²', ' squared ')
        .replaceAll('³', ' cubed ')
        .replaceAll('√', ' square root of ')
        .replaceAll('π', ' pi ')
        .replaceAll(
          RegExp(r'[\u{1F300}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}]',
              unicode: true),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
