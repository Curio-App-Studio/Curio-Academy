import 'package:flutter/material.dart';
import 'audio_service.dart';

/// Global NavigatorObserver that immediately silences TTS speech and audio playback
/// whenever a screen is closed, popped via Back button, or replaced.
class AudioNavigatorObserver extends NavigatorObserver {
  static final AudioNavigatorObserver instance = AudioNavigatorObserver._internal();
  AudioNavigatorObserver._internal();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AudioService.instance.stopAudio();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // If navigating to a new full page route, silence any previous screen's voice
    if (route is PageRoute && previousRoute != null) {
      AudioService.instance.stopAudio();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    AudioService.instance.stopAudio();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AudioService.instance.stopAudio();
  }
}
