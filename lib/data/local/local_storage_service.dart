import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../models/student_attempt_model.dart';
import '../models/student_profile.dart';
import '../models/subscription_record.dart';
import '../models/voice_settings.dart';

/// Contract for offline-first local persistence (SharedPreferences / Hive)
abstract class ILocalStorageService {
  Future<void> init();
  Future<void> recordActivityCompleted(String activityId, int starsEarned);
  Future<List<String>> getCompletedActivities();
  Future<int> getTotalStars();
  int get totalStars;
  int get totalPoints;
  Future<void> addDiscoveryPoints(int points);
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

  // Table chant style persistence (default: traditional '2 ones are 2')
  String getTableChantStyle();
  Future<void> saveTableChantStyle(String style);

  // Streak & Mistake Vault
  int get streakCount;
  Future<void> recordDailyActivity();
  int get mistakeCount;
  List<StudentQuestionAttempt> getMistakes();

  int getNextQuestionIndexForChapter(String chapterId, List<Activity> activities);

  // Closed Testing & Ad-Free status
  bool get isClosedTester;
  Future<void> setClosedTester(bool value);

  // Paid Membership (In-App Purchases / Subscriptions)
  bool get isPremiumUser;
  Future<void> setPremiumUser(bool value);
  String? get premiumSubscriptionType;
  Future<void> setPremiumSubscriptionType(String? type);
  DateTime? get subscriptionStartDate;
  DateTime? get subscriptionEndDate;
  Future<void> setSubscriptionDates({DateTime? startDate, DateTime? endDate});
  bool get isSubscriptionCanceled;
  Future<void> setSubscriptionCanceled(bool value);
  Future<void> cancelPremiumStatus();
  List<SubscriptionRecord> getSubscriptionHistory();
  Future<void> saveSubscriptionHistory(List<SubscriptionRecord> history);

  // Bonus stars (rewarded activities)
  Future<void> addBonusStars(int count);
}

/// Robust offline storage implementation using SharedPreferences
/// Ensures Board, Class, Dynamic Questions, and Student Responses persist across app restarts and reboots.
class LocalStorageService implements ILocalStorageService {
  static final LocalStorageService instance = LocalStorageService._internal();
  LocalStorageService._internal();

  static const String _keyBoard = 'curio_student_board';
  static const String _keyClass = 'curio_student_class';
  static const String _keyName = 'curio_student_name';
  static const String _keyAvatar = 'curio_student_avatar';
  static const String _keyStars = 'curio_total_stars';
  static const String _keyPoints = 'curio_total_points';
  static const String _keyCompleted = 'curio_completed_activities';
  static const String _keyQuestionAttempts = 'curio_question_attempts';
  static const String _keyOnboarded = 'curio_user_onboarded';
  static const String _keyVoiceSettings = 'curio_voice_settings';
  static const String _keyAudioMuted = 'curio_audio_muted';
  static const String _keyLanguage = 'curio_app_language';
  static const String _keyStreakCount = 'curio_streak_count';
  static const String _keyLastActiveDate = 'curio_last_active_date';
  static const String _keyIsClosedTester = 'curio_is_closed_tester';
  static const String _keyIsPremiumUser = 'curio_is_premium_user';
  static const String _keyPremiumSubType = 'curio_premium_sub_type';
  static const String _keySubscriptionStartDate = 'curio_subscription_start_date';
  static const String _keySubscriptionEndDate = 'curio_subscription_end_date';
  static const String _keySubscriptionCanceled = 'curio_subscription_canceled';
  static const String _keySubscriptionHistory = 'curio_subscription_history';
  static const String _keyBonusStars = 'curio_bonus_stars';
  static const String _keySpeedMathHighScore = 'curio_speed_math_high_score';
  static const String _keySpellBeeHighScore = 'curio_spell_bee_high_score';
  static const String _keySpellBeeMistakes = 'curio_spell_bee_mistakes';
  static const String _keySpellBeeMockBestScore = 'curio_spell_bee_mock_best';
  static const String _keySpellBeeExamsCount = 'curio_spell_bee_exams_count';
  static const String _prefixSpellBeeStage = 'curio_spell_bee_stage_';
  static const String _keyClaimedChests = 'curio_claimed_island_chests';
  static const String _keyCompletedChapters = 'curio_completed_chapters';
  static const String _prefixChapterActivities = 'curio_chapter_act_';
  static const String _keyTableChantStyle = 'curio_table_chant_style';

  SharedPreferences? _prefs;
  StudentProfile? _cachedProfile;
  VoiceSettings? _cachedVoiceSettings;
  bool _cachedAudioMuted = false;
  String _cachedLanguage = 'en';
  String _cachedTableChantStyle = 'traditional';
  bool _isClosedTester = false;
  bool _isPremiumUser = false;
  String? _premiumSubType;
  DateTime? _subscriptionStartDate;
  DateTime? _subscriptionEndDate;
  bool _isSubscriptionCanceled = false;
  final List<SubscriptionRecord> _cachedSubscriptionHistory = [];
  int _bonusStars = 0;
  int _speedMathHighScore = 0;
  int _spellBeeHighScore = 0;
  final List<String> _spellBeeMistakes = [];
  int _spellBeeMockBestScore = 0;
  int _spellBeeExamsCount = 0;
  final Set<String> _claimedChests = {};
  final Set<String> _completedChapters = {};
  final Set<String> _completedActivities = {};
  int _totalStars = 0;
  int _totalPoints = 0;
  int _streakCount = 1;

  final ValueNotifier<int> totalStarsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> totalPointsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');
  final ValueNotifier<int> streakNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> mistakeCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> closedTesterNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> premiumUserNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> subscriptionCanceledNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> subscriptionUpdateNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> speedMathHighScoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> spellBeeHighScoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<String>> spellBeeMistakesNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<int> spellBeeMockBestScoreNotifier = ValueNotifier<int>(0);

  @override
  bool get isClosedTester => _isClosedTester;

  @override
  Future<void> setClosedTester(bool value) async {
    _isClosedTester = value;
    closedTesterNotifier.value = value;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_keyIsClosedTester, value);
    } catch (_) {}
  }

  @override
  bool get isPremiumUser => _isPremiumUser;

  @override
  Future<void> setPremiumUser(bool value) async {
    _isPremiumUser = value;
    premiumUserNotifier.value = value;
    subscriptionUpdateNotifier.value++;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_keyIsPremiumUser, value);
    } catch (_) {}
  }

  @override
  String? get premiumSubscriptionType => _premiumSubType;

  @override
  Future<void> setPremiumSubscriptionType(String? type) async {
    _premiumSubType = type;
    subscriptionUpdateNotifier.value++;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (type != null) {
        await _prefs?.setString(_keyPremiumSubType, type);
      } else {
        await _prefs?.remove(_keyPremiumSubType);
      }
    } catch (_) {}
  }

  @override
  DateTime? get subscriptionStartDate {
    if (_subscriptionStartDate != null) return _subscriptionStartDate;
    if (_isPremiumUser) {
      _subscriptionStartDate = DateTime.now();
      _prefs?.setString(_keySubscriptionStartDate, _subscriptionStartDate!.toIso8601String());
    }
    return _subscriptionStartDate;
  }

  @override
  DateTime? get subscriptionEndDate {
    if (!_isPremiumUser) return null;
    if (_premiumSubType == 'curio_remove_ads_lifetime') {
      return null;
    }
    if (_subscriptionEndDate != null) return _subscriptionEndDate;

    final start = subscriptionStartDate ?? DateTime.now();
    if (_premiumSubType == 'curio_vip_annual') {
      _subscriptionEndDate = start.add(const Duration(days: 365));
    } else {
      _subscriptionEndDate = start.add(const Duration(days: 30));
    }
    _prefs?.setString(_keySubscriptionEndDate, _subscriptionEndDate!.toIso8601String());
    return _subscriptionEndDate;
  }

  @override
  bool get isSubscriptionCanceled => _isSubscriptionCanceled;

  @override
  Future<void> setSubscriptionCanceled(bool value) async {
    _isSubscriptionCanceled = value;
    subscriptionCanceledNotifier.value = value;
    subscriptionUpdateNotifier.value++;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_keySubscriptionCanceled, value);
    } catch (_) {}
  }

  @override
  Future<void> setSubscriptionDates({DateTime? startDate, DateTime? endDate}) async {
    _subscriptionStartDate = startDate;
    _subscriptionEndDate = endDate;
    subscriptionUpdateNotifier.value++;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (startDate != null) {
        await _prefs?.setString(_keySubscriptionStartDate, startDate.toIso8601String());
      } else {
        await _prefs?.remove(_keySubscriptionStartDate);
      }
      if (endDate != null) {
        await _prefs?.setString(_keySubscriptionEndDate, endDate.toIso8601String());
      } else {
        await _prefs?.remove(_keySubscriptionEndDate);
      }
    } catch (_) {}
  }

  @override
  Future<void> cancelPremiumStatus() async {
    _isPremiumUser = false;
    _premiumSubType = null;
    _subscriptionStartDate = null;
    _subscriptionEndDate = null;
    _isSubscriptionCanceled = false;
    premiumUserNotifier.value = false;
    subscriptionCanceledNotifier.value = false;
    subscriptionUpdateNotifier.value++;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_keyIsPremiumUser, false);
      await _prefs?.remove(_keyPremiumSubType);
      await _prefs?.remove(_keySubscriptionStartDate);
      await _prefs?.remove(_keySubscriptionEndDate);
      await _prefs?.remove(_keySubscriptionCanceled);
    } catch (_) {}
  }

  @override
  List<SubscriptionRecord> getSubscriptionHistory() {
    return List.unmodifiable(_cachedSubscriptionHistory);
  }

  @override
  Future<void> saveSubscriptionHistory(List<SubscriptionRecord> history) async {
    _cachedSubscriptionHistory.clear();
    _cachedSubscriptionHistory.addAll(history);
    subscriptionUpdateNotifier.value++;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final jsonList = history.map((r) => r.toJson()).toList();
      await _prefs?.setString(_keySubscriptionHistory, jsonEncode(jsonList));
    } catch (_) {}
  }

  @override
  Future<void> addBonusStars(int count) async {
    _bonusStars += count;
    _totalStars = _calculateTotalStars();
    totalStarsNotifier.value = _totalStars;
    await addDiscoveryPoints(count * 20);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setInt(_keyBonusStars, _bonusStars);
      await _prefs?.setInt(_keyStars, _totalStars);
    } catch (_) {}
  }

  @override
  int get streakCount => streakNotifier.value;

  @override
  int get mistakeCount => _cachedAttempts.values.where((a) => !a.isCorrect).length;

  @override
  List<StudentQuestionAttempt> getMistakes() {
    return _cachedAttempts.values.where((a) => !a.isCorrect).toList();
  }

  int get speedMathHighScore => _speedMathHighScore;

  Future<bool> updateSpeedMathHighScore(int score) async {
    if (score > _speedMathHighScore) {
      _speedMathHighScore = score;
      speedMathHighScoreNotifier.value = score;
      try {
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs?.setInt(_keySpeedMathHighScore, score);
      } catch (_) {}
      return true; // New high score
    }
    return false;
  }

  int get spellBeeHighScore => _spellBeeHighScore;

  Future<bool> updateSpellBeeHighScore(int score) async {
    if (score > _spellBeeHighScore) {
      _spellBeeHighScore = score;
      spellBeeHighScoreNotifier.value = score;
      try {
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs?.setInt(_keySpellBeeHighScore, score);
      } catch (_) {}
      return true; // New high score
    }
    return false;
  }

  int getSpellBeeStageStars(String classLabel, int stage) {
    return _prefs?.getInt('$_prefixSpellBeeStage${classLabel.toLowerCase()}_$stage') ?? 0;
  }

  Future<void> saveSpellBeeStageStars(String classLabel, int stage, int stars) async {
    final key = '$_prefixSpellBeeStage${classLabel.toLowerCase()}_$stage';
    final existing = _prefs?.getInt(key) ?? 0;
    if (stars > existing) {
      try {
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs?.setInt(key, stars);
      } catch (_) {}
    }
  }

  List<String> get spellBeeMistakes => List.unmodifiable(_spellBeeMistakes);
  int get spellBeeMockBestScore => _spellBeeMockBestScore;
  int get spellBeeExamsCount => _spellBeeExamsCount;

  Future<void> addSpellBeeMistake(String word) async {
    final clean = word.trim().toUpperCase();
    if (clean.isEmpty) return;
    if (!_spellBeeMistakes.contains(clean)) {
      _spellBeeMistakes.insert(0, clean);
      spellBeeMistakesNotifier.value = List.unmodifiable(_spellBeeMistakes);
      try {
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs?.setStringList(_keySpellBeeMistakes, _spellBeeMistakes);
      } catch (_) {}
    }
  }

  Future<void> removeSpellBeeMistake(String word) async {
    final clean = word.trim().toUpperCase();
    if (_spellBeeMistakes.remove(clean)) {
      spellBeeMistakesNotifier.value = List.unmodifiable(_spellBeeMistakes);
      try {
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs?.setStringList(_keySpellBeeMistakes, _spellBeeMistakes);
      } catch (_) {}
    }
  }

  Future<void> clearSpellBeeMistakes() async {
    _spellBeeMistakes.clear();
    spellBeeMistakesNotifier.value = [];
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove(_keySpellBeeMistakes);
    } catch (_) {}
  }

  Future<void> recordSpellBeeExamResult({required int score, required int total}) async {
    _spellBeeExamsCount++;
    if (score > _spellBeeMockBestScore) {
      _spellBeeMockBestScore = score;
      spellBeeMockBestScoreNotifier.value = score;
    }
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setInt(_keySpellBeeExamsCount, _spellBeeExamsCount);
      await _prefs?.setInt(_keySpellBeeMockBestScore, _spellBeeMockBestScore);
    } catch (_) {}
  }

  bool isChestClaimed(String chestId) => _claimedChests.contains(chestId);

  Future<void> claimChest(String chestId) async {
    _claimedChests.add(chestId);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setStringList(_keyClaimedChests, _claimedChests.toList());
    } catch (_) {}
  }

  final Map<String, StudentQuestionAttempt> _cachedAttempts = {};
  final Map<String, List<Activity>> _cachedChapterActivities = {};

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final boardStr = _prefs?.getString(_keyBoard);
      final classStr = _prefs?.getString(_keyClass);
      final nameStr = _prefs?.getString(_keyName);
      final avatarStr = _prefs?.getString(_keyAvatar);

      if (boardStr != null && classStr != null) {
        _cachedProfile = StudentProfile(
          board: BoardType.fromJson(boardStr),
          studentClass: StudentClass.fromJson(classStr),
          studentName: nameStr ?? 'Little Champ',
          avatarIcon: avatarStr ?? '🦁',
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

      // Load bonus stars
      _bonusStars = _prefs?.getInt(_keyBonusStars) ?? 0;

      // Closed testing status:
      // Reset any legacy automatic closed tester flag so users are standard free users.
      _isClosedTester = false;
      if (_prefs?.getBool(_keyIsClosedTester) == true) {
        await _prefs?.remove(_keyIsClosedTester);
      }
      closedTesterNotifier.value = false;

      // Reset any legacy test-mode VIP activations so test users start in clean free state.
      // Verified purchases will be delivered automatically by Google Play Billing stream.
      if (_prefs?.getBool('curio_legacy_test_vip_cleared_v2') != true) {
        await _prefs?.setBool('curio_legacy_test_vip_cleared_v2', true);
        await _prefs?.remove(_keyIsPremiumUser);
        await _prefs?.remove(_keyPremiumSubType);
      }

      // Paid membership status (Google Play purchase)
      _isPremiumUser = _prefs?.getBool(_keyIsPremiumUser) ?? false;
      _premiumSubType = _prefs?.getString(_keyPremiumSubType);
      premiumUserNotifier.value = _isPremiumUser;

      final startStr = _prefs?.getString(_keySubscriptionStartDate);
      final endStr = _prefs?.getString(_keySubscriptionEndDate);
      _isSubscriptionCanceled = _prefs?.getBool(_keySubscriptionCanceled) ?? false;
      subscriptionCanceledNotifier.value = _isSubscriptionCanceled;

      if (startStr != null && startStr.isNotEmpty) {
        _subscriptionStartDate = DateTime.tryParse(startStr);
      }
      if (endStr != null && endStr.isNotEmpty) {
        _subscriptionEndDate = DateTime.tryParse(endStr);
      }

      // If user is premium but dates were not recorded yet (e.g. existing installation):
      if (_isPremiumUser && _subscriptionStartDate == null) {
        final now = DateTime.now();
        _subscriptionStartDate = now;
        if (_premiumSubType == 'curio_remove_ads_lifetime') {
          _subscriptionEndDate = null;
        } else if (_premiumSubType == 'curio_vip_annual') {
          _subscriptionEndDate = now.add(const Duration(days: 365));
        } else {
          _subscriptionEndDate = now.add(const Duration(days: 30));
        }
        await _prefs?.setString(_keySubscriptionStartDate, _subscriptionStartDate!.toIso8601String());
        if (_subscriptionEndDate != null) {
          await _prefs?.setString(_keySubscriptionEndDate, _subscriptionEndDate!.toIso8601String());
        }
      }

      // Load subscription & purchase history
      final historyJsonStr = _prefs?.getString(_keySubscriptionHistory);
      if (historyJsonStr != null && historyJsonStr.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(historyJsonStr);
          if (decoded is List) {
            _cachedSubscriptionHistory.clear();
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                _cachedSubscriptionHistory.add(SubscriptionRecord.fromJson(item));
              }
            }
          }
        } catch (_) {}
      }

      // Compute total stars directly from all attempted questions so it NEVER resets or drifts
      final computedStars = _calculateTotalStars();
      final storedStars = _prefs?.getInt(_keyStars) ?? 0;
      _totalStars = computedStars >= storedStars ? computedStars : storedStars;
      totalStarsNotifier.value = _totalStars;

      // Load stored discovery points (backfill from stars if not present)
      final storedPoints = _prefs?.getInt(_keyPoints) ?? 0;
      _totalPoints = storedPoints > 0 ? storedPoints : (_totalStars * 15);
      totalPointsNotifier.value = _totalPoints;

      // Load speed math high score
      _speedMathHighScore = _prefs?.getInt(_keySpeedMathHighScore) ?? 0;
      speedMathHighScoreNotifier.value = _speedMathHighScore;

      // Load spell bee high score
      _spellBeeHighScore = _prefs?.getInt(_keySpellBeeHighScore) ?? 0;
      spellBeeHighScoreNotifier.value = _spellBeeHighScore;

      // Load spell bee mistake vault & mock exam stats
      _spellBeeMistakes.clear();
      _spellBeeMistakes.addAll(_prefs?.getStringList(_keySpellBeeMistakes) ?? []);
      spellBeeMistakesNotifier.value = List.unmodifiable(_spellBeeMistakes);
      _spellBeeMockBestScore = _prefs?.getInt(_keySpellBeeMockBestScore) ?? 0;
      spellBeeMockBestScoreNotifier.value = _spellBeeMockBestScore;
      _spellBeeExamsCount = _prefs?.getInt(_keySpellBeeExamsCount) ?? 0;

      // Load claimed adventure chests
      final storedChests = _prefs?.getStringList(_keyClaimedChests) ?? [];
      _claimedChests.addAll(storedChests);

      // Load completed chapters
      final storedChapters = _prefs?.getStringList(_keyCompletedChapters) ?? [];
      _completedChapters.addAll(storedChapters);

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
      _cachedTableChantStyle = _prefs?.getString(_keyTableChantStyle) ?? 'traditional';

      // Purge any legacy kindergarten chapter activities that only have Bubble Pop OR contain MCQs
      final keys = _prefs?.getKeys() ?? {};
      for (final key in keys) {
        if (key.startsWith(_prefixChapterActivities)) {
          final chId = key.substring(_prefixChapterActivities.length);
          if (chId.contains('lkg') || chId.contains('ukg')) {
            final acts = getChapterActivities(chId);
            if (acts != null && acts.isNotEmpty) {
              final hasOnlyBubble = acts.every((a) => a.activityType == ActivityType.bubblePop);
              final hasMcq = acts.any((a) => a.activityType == ActivityType.mcq);
              if (hasOnlyBubble || hasMcq) {
                _cachedChapterActivities.remove(chId);
                _prefs?.remove(key);
              }
            }
          }
        }
      }

      _initDailyStreak();
      mistakeCountNotifier.value = mistakeCount;
    } catch (_) {
      // Graceful fallback in unit test or restricted environments
    }
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void _initDailyStreak() {
    try {
      final today = _formatDate(DateTime.now());
      final lastDate = _prefs?.getString(_keyLastActiveDate);
      final savedStreak = _prefs?.getInt(_keyStreakCount) ?? 1;

      if (lastDate == null) {
        _streakCount = 1;
        _prefs?.setString(_keyLastActiveDate, today);
        _prefs?.setInt(_keyStreakCount, 1);
      } else if (lastDate == today) {
        _streakCount = savedStreak > 0 ? savedStreak : 1;
      } else {
        final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
        if (lastDate == yesterday) {
          _streakCount = savedStreak > 0 ? savedStreak : 1;
        } else {
          _streakCount = 1;
          _prefs?.setInt(_keyStreakCount, 1);
          _prefs?.setString(_keyLastActiveDate, today);
        }
      }
      streakNotifier.value = _streakCount;
    } catch (_) {
      streakNotifier.value = 1;
    }
  }

  @override
  Future<void> recordDailyActivity() async {
    try {
      final today = _formatDate(DateTime.now());
      final lastDate = _prefs?.getString(_keyLastActiveDate);
      final savedStreak = _prefs?.getInt(_keyStreakCount) ?? 1;

      if (lastDate != today) {
        final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
        if (lastDate == yesterday) {
          _streakCount = savedStreak + 1;
        } else {
          _streakCount = 1;
        }
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs?.setString(_keyLastActiveDate, today);
        await _prefs?.setInt(_keyStreakCount, _streakCount);
        streakNotifier.value = _streakCount;
      }
    } catch (_) {}
  }

  @override
  Future<void> recordActivityCompleted(String activityId, int starsEarned) async {
    _completedActivities.add(activityId);
    _totalStars += starsEarned;
    totalStarsNotifier.value = _totalStars;
    recordDailyActivity();
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

  /// Returns the number of question attempts given for this chapter
  int getChapterAnswerCount(String chapterId) {
    if (chapterId.isEmpty) return 0;
    return _cachedAttempts.values.where((a) => a.chapterId == chapterId).length;
  }

  /// Explicitly marks a chapter completed (e.g. after unit test or 5 answers)
  Future<void> markChapterCompleted(String chapterId) async {
    if (chapterId.isEmpty) return;
    _completedChapters.add(chapterId);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setStringList(_keyCompletedChapters, _completedChapters.toList());
    } catch (_) {}
  }

  /// A chapter is marked complete after giving at least 5 answers or completing a test
  bool isChapterCompleted(String chapterId) {
    if (chapterId.isEmpty) return false;
    if (_completedChapters.contains(chapterId)) return true;

    // Rule: Chapter is marked complete after giving at least 5 answers or a test
    if (getChapterAnswerCount(chapterId) >= 5) {
      _completedChapters.add(chapterId);
      markChapterCompleted(chapterId);
      return true;
    }

    // Also check if all chapter activities are completed (for short chapters)
    final acts = getChapterActivities(chapterId);
    if (acts != null && acts.isNotEmpty && acts.length < 5) {
      if (acts.every((a) => _completedActivities.contains(a.activityId))) {
        _completedChapters.add(chapterId);
        markChapterCompleted(chapterId);
        return true;
      }
    }

    return false;
  }

  @override
  Future<int> getTotalStars() async {
    return _totalStars;
  }

  @override
  int get totalStars => _totalStars;

  @override
  int get totalPoints => _totalPoints;

  @override
  Future<void> addDiscoveryPoints(int points) async {
    if (points <= 0) return;
    _totalPoints += points;
    totalPointsNotifier.value = _totalPoints;
    recordDailyActivity();
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setInt(_keyPoints, _totalPoints);
    } catch (_) {}
  }

  @override
  Future<void> saveStudentProfile(StudentProfile profile) async {
    _cachedProfile = profile;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyBoard, profile.board.code);
      await _prefs?.setString(_keyClass, profile.studentClass.label);
      await _prefs?.setString(_keyName, profile.studentName);
      await _prefs?.setString(_keyAvatar, profile.avatarIcon);
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
      final avatarStr = _prefs?.getString(_keyAvatar);
      if (boardStr != null && classStr != null) {
        _cachedProfile = StudentProfile(
          board: BoardType.fromJson(boardStr),
          studentClass: StudentClass.fromJson(classStr),
          studentName: nameStr ?? 'Little Champ',
          avatarIcon: avatarStr ?? '🦁',
        );
        return _cachedProfile;
      }
    } catch (_) {}
    return _cachedProfile;
  }

  StudentClass getStudentClass() {
    return _cachedProfile?.studentClass ?? StudentClass.class3;
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
    return _bonusStars +
        _cachedAttempts.values.fold<int>(
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

    // Auto-mark chapter complete if at least 5 answers have been recorded
    final chId = attempt.chapterId;
    if (chId.isNotEmpty && getChapterAnswerCount(chId) >= 5) {
      _completedChapters.add(chId);
    }

    _totalStars = _calculateTotalStars();
    totalStarsNotifier.value = _totalStars;
    mistakeCountNotifier.value = mistakeCount;
    recordDailyActivity();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final map = _cachedAttempts.map((k, v) => MapEntry(k, v.toJson()));
      await _prefs?.setString(_keyQuestionAttempts, jsonEncode(map));
      await _prefs?.setStringList(_keyCompleted, _completedActivities.toList());
      await _prefs?.setStringList(_keyCompletedChapters, _completedChapters.toList());
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
  String getTableChantStyle() => _cachedTableChantStyle;

  @override
  Future<void> saveTableChantStyle(String style) async {
    _cachedTableChantStyle = style;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyTableChantStyle, style);
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
    mistakeCountNotifier.value = mistakeCount;
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

  String? getPreferredPublisher(String subjectId) {
    return _prefs?.getString('curio_publisher_${subjectId.toLowerCase()}');
  }

  Future<void> savePreferredPublisher(String subjectId, String publisher) async {
    await _prefs?.setString('curio_publisher_${subjectId.toLowerCase()}', publisher);
  }
}
