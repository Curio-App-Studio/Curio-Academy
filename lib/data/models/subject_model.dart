import 'package:flutter/material.dart';

/// Represents a learning subject (Math, Science, English, etc.)
class Subject {
  final String id;
  final String name;
  final String iconRef;
  final int primaryColorHex;
  final int secondaryColorHex;
  final String description;
  final bool isEnabled;

  const Subject({
    required this.id,
    required this.name,
    required this.iconRef,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    this.description = '',
    this.isEnabled = true,
  });

  Color get primaryColor => Color(primaryColorHex);
  Color get secondaryColor => Color(secondaryColorHex);

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String? ?? 'math',
      name: json['name'] as String? ?? 'Mathematics',
      iconRef: json['iconRef'] as String? ?? 'assets/icons/math_compass.svg',
      primaryColorHex: json['primaryColorHex'] as int? ?? 0xFFFF8A00,
      secondaryColorHex: json['secondaryColorHex'] as int? ?? 0xFFFFC727,
      description: json['description'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconRef': iconRef,
    'primaryColorHex': primaryColorHex,
    'secondaryColorHex': secondaryColorHex,
    'description': description,
    'isEnabled': isEnabled,
  };

  Subject copyWith({
    String? id,
    String? name,
    String? iconRef,
    int? primaryColorHex,
    int? secondaryColorHex,
    String? description,
    bool? isEnabled,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      iconRef: iconRef ?? this.iconRef,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
