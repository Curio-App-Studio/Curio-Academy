import 'package:flutter/material.dart';

/// Represents an interactive target pixel/checkpoint along a character's stroke path.
class TracingCheckpoint {
  final int id;
  final Offset position;
  final int sector; // 0..8 (3x3 spatial quadrant)
  bool isCollected;

  TracingCheckpoint({
    required this.id,
    required this.position,
    required this.sector,
    this.isCollected = false,
  });

  TracingCheckpoint copyWith({
    int? id,
    Offset? position,
    int? sector,
    bool? isCollected,
  }) {
    return TracingCheckpoint(
      id: id ?? this.id,
      position: position ?? this.position,
      sector: sector ?? this.sector,
      isCollected: isCollected ?? this.isCollected,
    );
  }
}
