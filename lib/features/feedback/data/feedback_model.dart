import 'package:cloud_firestore/cloud_firestore.dart';

/// Categories of feedback parents and learners can submit
enum FeedbackCategory {
  feature('Feature Request 💡', 'सुझाव / नई सुविधा 💡'),
  bug('Report an Issue / Bug 🐛', 'समस्या या त्रुटि 🐛'),
  content('Question / Content Error 📝', 'प्रश्न में सुधार 📝'),
  audio('Audio & Pronunciation 🔊', 'ध्वनि / उच्चारण 🔊'),
  praise('Praise & Appreciation ❤️', 'प्रशंसा और प्यार ❤️'),
  other('Other Feedback ❓', 'अन्य प्रतिक्रिया ❓');

  final String labelEn;
  final String labelHi;
  const FeedbackCategory(this.labelEn, this.labelHi);

  String localized(bool isHindi) => isHindi ? labelHi : labelEn;

  static FeedbackCategory fromString(String? val) {
    if (val == null) return FeedbackCategory.feature;
    for (final c in FeedbackCategory.values) {
      if (c.name.toLowerCase() == val.toLowerCase() ||
          c.labelEn.toLowerCase() == val.toLowerCase()) {
        return c;
      }
    }
    return FeedbackCategory.other;
  }
}

/// Model encapsulating user feedback submitted to Firestore
class UserFeedback {
  final String? id;
  final int rating; // 1 to 5
  final FeedbackCategory category;
  final String comment;
  final String? contactInfo;
  final String? studentName;
  final String? studentClass;
  final String? board;
  final String appVersion;
  final String platform;
  final DateTime createdAt;

  const UserFeedback({
    this.id,
    required this.rating,
    required this.category,
    required this.comment,
    this.contactInfo,
    this.studentName,
    this.studentClass,
    this.board,
    this.appVersion = '1.0.0+11',
    this.platform = 'Android',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'category': category.name,
      'categoryLabel': category.labelEn,
      'comment': comment.trim(),
      'contactInfo': (contactInfo ?? '').trim(),
      'studentName': studentName ?? 'Anonymous',
      'studentClass': studentClass ?? 'Unknown',
      'board': board ?? 'CBSE',
      'appVersion': appVersion,
      'platform': platform,
      'createdAt': FieldValue.serverTimestamp(),
      'localTimestamp': createdAt.toIso8601String(),
    };
  }

  factory UserFeedback.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedDate;
    final created = map['createdAt'];
    if (created is Timestamp) {
      parsedDate = created.toDate();
    } else if (map['localTimestamp'] is String) {
      parsedDate = DateTime.tryParse(map['localTimestamp']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return UserFeedback(
      id: id,
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      category: FeedbackCategory.fromString(map['category'] as String?),
      comment: map['comment'] as String? ?? '',
      contactInfo: map['contactInfo'] as String?,
      studentName: map['studentName'] as String?,
      studentClass: map['studentClass'] as String?,
      board: map['board'] as String?,
      appVersion: map['appVersion'] as String? ?? '1.0.0+11',
      platform: map['platform'] as String? ?? 'Android',
      createdAt: parsedDate,
    );
  }
}
