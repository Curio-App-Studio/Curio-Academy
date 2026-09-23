import 'grade_tier.dart';

/// Educational boards supported
enum BoardType {
  cbse('CBSE', 'Central Board of Secondary Education'),
  icse('ICSE', 'Indian Certificate of Secondary Education'),
  stateBoard('State Board', 'State Board Curriculum');

  final String code;
  final String title;
  const BoardType(this.code, this.title);

  String get shortCode => this == BoardType.stateBoard ? 'State' : code;

  static BoardType fromJson(dynamic json) {
    final str = json?.toString().toUpperCase() ?? 'CBSE';
    return BoardType.values.firstWhere(
      (b) => b.code.toUpperCase() == str || b.name.toUpperCase() == str,
      orElse: () => BoardType.cbse,
    );
  }

  String toJson() => code;
}

/// Supported classes from LKG to Class 8
enum StudentClass {
  lkg('LKG', 'Lower Kindergarten', GradeTier.earlyExplorer, 0),
  ukg('UKG', 'Upper Kindergarten', GradeTier.earlyExplorer, 0),
  class1('Class 1', 'Class 1 (Grade 1)', GradeTier.earlyExplorer, 1),
  class2('Class 2', 'Class 2 (Grade 2)', GradeTier.primaryBuilder, 2),
  class3('Class 3', 'Class 3 (Grade 3)', GradeTier.primaryBuilder, 3),
  class4('Class 4', 'Class 4 (Grade 4)', GradeTier.primaryBuilder, 4),
  class5('Class 5', 'Class 5 (Grade 5)', GradeTier.primaryBuilder, 5),
  class6('Class 6', 'Class 6 (Grade 6)', GradeTier.middleAchiever, 6),
  class7('Class 7', 'Class 7 (Grade 7)', GradeTier.middleAchiever, 7),
  class8('Class 8', 'Class 8 (Grade 8)', GradeTier.middleAchiever, 8);

  final String label;
  final String description;
  final GradeTier tier;
  final int gradeNumber;

  const StudentClass(this.label, this.description, this.tier, this.gradeNumber);

  bool get isKindergarten => this == StudentClass.lkg || this == StudentClass.ukg;

  static StudentClass fromJson(dynamic json) {
    final str = json?.toString().toLowerCase() ?? 'class 1';
    return StudentClass.values.firstWhere(
      (c) => c.label.toLowerCase() == str || c.name.toLowerCase() == str,
      orElse: () => StudentClass.class1,
    );
  }

  String toJson() => label;
}

/// Persistent student profile storing Board and Class preferences
class StudentProfile {
  final BoardType board;
  final StudentClass studentClass;
  final String studentName;

  const StudentProfile({
    this.board = BoardType.cbse,
    this.studentClass = StudentClass.class1,
    this.studentName = 'Young Explorer',
  });

  GradeTier get tier => studentClass.tier;

  StudentProfile copyWith({
    BoardType? board,
    StudentClass? studentClass,
    String? studentName,
  }) {
    return StudentProfile(
      board: board ?? this.board,
      studentClass: studentClass ?? this.studentClass,
      studentName: studentName ?? this.studentName,
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      board: BoardType.fromJson(json['board']),
      studentClass: StudentClass.fromJson(json['studentClass']),
      studentName: json['studentName'] as String? ?? 'Young Explorer',
    );
  }

  Map<String, dynamic> toJson() => {
    'board': board.toJson(),
    'studentClass': studentClass.toJson(),
    'studentName': studentName,
  };
}
