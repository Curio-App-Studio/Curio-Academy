import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../models/student_attempt_model.dart';
import '../models/student_profile.dart';
import '../models/voice_settings.dart';

/// Contract for offline-first local persistence (SharedPreferences / Hive)
abstract class ILocalStorageService {
  Future<void> init();
  Future<void> recordActivityCompleted(String activityId, int starsEarned);
  Future<List<String>> getCompletedActivities();
  Future<int> getTotalStars();
  int get totalStars;
  Future<void> saveStudentProfile(StudentProfile profile);
  Future<StudentProfile?> getStudentProfile();

  // Custom chapter activities persistence
  Future<void> saveChapterActivities(String chapterId, List<Activity> activities);
  List<Activity>? getChapterActivities(String chapterId);

  // Student response persistence & retries
  Future<void> saveQuestionAttempt(StudentQuestionAttempt attempt);
  StudentQuestionAttempt? getQuestionAttempt(String activityId);
  int getStarsForActivity(String activityId);
  Map<String, StudentQuestionAttempt> getAllQuestionAttempts();
  Future<void> clearQuestionAttempt(String activityId);

  // Voice preferences persistence
  VoiceSettings getVoiceSettings();
  Future<void> saveVoiceSettings(VoiceSettings settings);

  // Audio mute persistence
  bool isAudioMuted();
  Future<void> saveAudioMuted(bool muted);

  // Language preferences persistence
  String getAppLanguage();
  Future<void> saveAppLanguage(String langCode);

  int getNextQuestionIndexForChapter(String chapterId, List<Activity> activities);
}

/// Robust offline storage implementation using SharedPreferences
/// Ensures Board, Class, Dynamic Questions, and Student Responses persist across app restarts and reboots.
class LocalStorageService implements ILocalStorageService {
  static final LocalStorageService instance = LocalStorageService._internal();
  LocalStorageService._internal();

  static const String _keyBoard = 'curio_student_board';
  static const String _keyClass = 'curio_student_class';
  static const String _keyName = 'curio_student_name';
  static const String _keyStars = 'curio_total_stars';
  static const String _keyCompleted = 'curio_completed_activities';
  static const String _keyQuestionAttempts = 'curio_question_attempts';
  static const String _keyOnboarded = 'curio_user_onboarded';
  static const String _keyVoiceSettings = 'curio_voice_settings';
  static const String _keyAudioMuted = 'curio_audio_muted';
  static const String _keyLanguage = 'curio_app_language';
  static const String _prefixChapterActivities = 'curio_chapter_act_';

  SharedPreferences? _prefs;
  StudentProfile? _cachedProfile;
  VoiceSettings? _cachedVoiceSettings;
  bool _cachedAudioMuted = false;
  String _cachedLanguage = 'en';
  final Set<String> _completedActivities = {};
  int _totalStars = 0;

  final ValueNotifier<int> totalStarsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  final Map<String, StudentQuestionAttempt> _cachedAttempts = {};
  final Map<String, List<Activity>> _cachedChapterActivities = {};

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final boardStr = _prefs?.getString(_keyBoard);
      final classStr = _prefs?.getString(_keyClass);
      final nameStr = _prefs?.getString(_keyName);

      if (boardStr != null && classStr != null) {
        _cachedProfile = StudentProfile(
          board: BoardType.fromJson(boardStr),
          studentClass: StudentClass.fromJson(classStr),
          studentName: nameStr ?? 'Explorer',
        );
      }
      final completed = _prefs?.getStringList(_keyCompleted) ?? [];
      _completedActivities.addAll(completed);

      // Load stored question attempts
      final attemptsJsonStr = _prefs?.getString(_keyQuestionAttempts);
      if (attemptsJsonStr != null && attemptsJsonStr.isNotEmpty) {
        final dynamic decoded = jsonDecode(attemptsJsonStr);
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              _cachedAttempts[key] = StudentQuestionAttempt.fromJson(value);
            }
          });
        }
      }

      // Compute total stars directly from all attempted questions so it NEVER resets or drifts
      final computedStars = _calculateTotalStars();
      final storedStars = _prefs?.getInt(_keyStars) ?? 0;
      _totalStars = computedStars >= storedStars ? computedStars : storedStars;
      totalStarsNotifier.value = _totalStars;

      // Load stored language preference
      _cachedLanguage = _prefs?.getString(_keyLanguage) ?? 'en';
      languageNotifier.value = _cachedLanguage;

      // Load stored voice preferences
      final voiceJsonStr = _prefs?.getString(_keyVoiceSettings);
      if (voiceJsonStr != null && voiceJsonStr.isNotEmpty) {
        try {
          final dynamic decodedVoice = jsonDecode(voiceJsonStr);
          if (decodedVoice is Map<String, dynamic>) {
            _cachedVoiceSettings = VoiceSettings.fromJson(decodedVoice);
          }
        } catch (_) {}
      }
      _cachedAudioMuted = _prefs?.getBool(_keyAudioMuted) ?? false;
    } catch (_) {
      // Graceful fallback in unit test or restricted environments
    }
  }

  @override
  Future<void> recordActivityCompleted(String activityId, int starsEarned) async {
    _completedActivities.add(activityId);
    _totalStars += starsEarned;
    totalStarsNotifier.value = _totalStars;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setStringList(_keyCompleted, _completedActivities.toList());
      await _prefs?.setInt(_keyStars, _totalStars);
    } catch (_) {}
  }

  @override
  Future<List<String>> getCompletedActivities() async {
    return _completedActivities.toList();
  }

  @override
  Future<int> getTotalStars() async {
    return _totalStars;
  }

  @override
  int get totalStars => _totalStars;

  @override
  Future<void> saveStudentProfile(StudentProfile profile) async {
    _cachedProfile = profile;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyBoard, profile.board.code);
      await _prefs?.setString(_keyClass, profile.studentClass.label);
      await _prefs?.setString(_keyName, profile.studentName);
    } catch (_) {}
  }

  @override
  Future<StudentProfile?> getStudentProfile() async {
    if (_cachedProfile != null) return _cachedProfile;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final boardStr = _prefs?.getString(_keyBoard);
      final classStr = _prefs?.getString(_keyClass);
      final nameStr = _prefs?.getString(_keyName);
      if (boardStr != null && classStr != null) {
        _cachedProfile = StudentProfile(
          board: BoardType.fromJson(boardStr),
          studentClass: StudentClass.fromJson(classStr),
          studentName: nameStr ?? 'Explorer',
        );
        return _cachedProfile;
      }
    } catch (_) {}
    return _cachedProfile;
  }

  bool isOnboarded() {
    return _prefs?.getBool(_keyOnboarded) ?? (_cachedProfile != null);
  }

  Future<void> setOnboarded(bool value) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_keyOnboarded, value);
    } catch (_) {}
  }

  // --- Voice Settings Persistence ---

  @override
  VoiceSettings getVoiceSettings() {
    if (_cachedVoiceSettings != null) return _cachedVoiceSettings!;
    final raw = _prefs?.getString(_keyVoiceSettings);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _cachedVoiceSettings = VoiceSettings.fromJson(decoded);
        return _cachedVoiceSettings!;
      } catch (_) {}
    }
    _cachedVoiceSettings = const VoiceSettings();
    return _cachedVoiceSettings!;
  }

  @override
  Future<void> saveVoiceSettings(VoiceSettings settings) async {
    _cachedVoiceSettings = settings;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyVoiceSettings, jsonEncode(settings.toJson()));
    } catch (_) {}
  }

  // --- Audio Mute Persistence ---

  @override
  bool isAudioMuted() {
    return _prefs?.getBool(_keyAudioMuted) ?? _cachedAudioMuted;
  }

  @override
  Future<void> saveAudioMuted(bool muted) async {
    _cachedAudioMuted = muted;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_keyAudioMuted, muted);
    } catch (_) {}
  }

  // --- Chapter Activities Persistence ---

  @override
  Future<void> saveChapterActivities(String chapterId, List<Activity> activities) async {
    _cachedChapterActivities[chapterId] = List<Activity>.from(activities);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final jsonList = activities.map((a) => a.toJson()).toList();
      final encoded = jsonEncode(jsonList);
      await _prefs?.setString('$_prefixChapterActivities$chapterId', encoded);
    } catch (_) {}
  }

  @override
  List<Activity>? getChapterActivities(String chapterId) {
    if (_cachedChapterActivities.containsKey(chapterId)) {
      return _cachedChapterActivities[chapterId];
    }
    try {
      final stored = _prefs?.getString('$_prefixChapterActivities$chapterId');
      if (stored != null && stored.isNotEmpty) {
        final dynamic decoded = jsonDecode(stored);
        if (decoded is List) {
          final list = decoded
              .map((item) => Activity.fromJson(item as Map<String, dynamic>))
              .toList();
          _cachedChapterActivities[chapterId] = list;
          return list;
        }
      }
    } catch (_) {}
    return null;
  }

  // --- Student Attempts & Retries ---

  int _calculateTotalStars() {
    return _cachedAttempts.values.fold<int>(
      0,
      (sum, a) => sum + (a.isCorrect ? a.starsEarned : 0),
    );
  }

  @override
  int getStarsForActivity(String activityId) {
    final attempt = _cachedAttempts[activityId];
    if (attempt != null && attempt.isCorrect) {
      return attempt.starsEarned;
    }
    return 0;
  }

  @override
  Future<void> saveQuestionAttempt(StudentQuestionAttempt attempt) async {
    final existing = _cachedAttempts[attempt.activityId];
    // Keep best stars earned for this question
    final bestStars = (existing != null && existing.isCorrect)
        ? (existing.starsEarned > attempt.starsEarned ? existing.starsEarned : attempt.starsEarned)
        : attempt.starsEarned;

    final resolvedAttempt = StudentQuestionAttempt(
      activityId: attempt.activityId,
      chapterId: attempt.chapterId,
      selectedOptionIndex: attempt.selectedOptionIndex,
      selectedOptionText: attempt.selectedOptionText,
      isCorrect: attempt.isCorrect || (existing?.isCorrect ?? false),
      starsEarned: bestStars,
      timestamp: attempt.timestamp,
    );

    _cachedAttempts[attempt.activityId] = resolvedAttempt;
    if (resolvedAttempt.isCorrect) {
      _completedActivities.add(attempt.activityId);
    }
    _totalStars = _calculateTotalStars();
    totalStarsNotifier.value = _totalStars;

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final map = _cachedAttempts.map((k, v) => MapEntry(k, v.toJson()));
      await _prefs?.setString(_keyQuestionAttempts, jsonEncode(map));
      await _prefs?.setStringList(_keyCompleted, _completedActivities.toList());
      await _prefs?.setInt(_keyStars, _totalStars);
    } catch (_) {}
  }

  @override
  String getAppLanguage() => _cachedLanguage;

  @override
  Future<void> saveAppLanguage(String langCode) async {
    _cachedLanguage = langCode;
    languageNotifier.value = langCode;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyLanguage, langCode);
    } catch (_) {}
  }

  @override
  StudentQuestionAttempt? getQuestionAttempt(String activityId) {
    return _cachedAttempts[activityId];
  }

  @override
  Map<String, StudentQuestionAttempt> getAllQuestionAttempts() {
    return Map.unmodifiable(_cachedAttempts);
  }

  @override
  Future<void> clearQuestionAttempt(String activityId) async {
    _cachedAttempts.remove(activityId);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final map = _cachedAttempts.map((k, v) => MapEntry(k, v.toJson()));
      await _prefs?.setString(_keyQuestionAttempts, jsonEncode(map));
    } catch (_) {}
  }

  @override
  int getNextQuestionIndexForChapter(String chapterId, List<Activity> activities) {
    if (activities.isEmpty) return 0;

    int lastAttemptedIndex = -1;
    for (int i = 0; i < activities.length; i++) {
      if (_cachedAttempts.containsKey(activities[i].activityId)) {
        lastAttemptedIndex = i;
      }
    }

    // If none attempted yet, start at Question 1 (index 0)
    if (lastAttemptedIndex == -1) {
      return 0;
    }

    // Select the next question of the last attempted question
    final nextIndex = lastAttemptedIndex + 1;
    if (nextIndex < activities.length) {
      return nextIndex;
    }

    // If all existing questions have been attempted, return the next slot (or last)
    // The player will auto-generate or present the next question
    return (activities.length - 1).clamp(0, activities.length - 1);
  }
}
