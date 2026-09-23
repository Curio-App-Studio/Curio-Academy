import 'package:flutter/material.dart';

class BubbleItem {
  final String id;
  final String label;
  final dynamic value;
  final String displayType;
  final Color color;
  double x; // normalized 0.0 to 1.0
  double y; // normalized 0.0 to 1.0
  double vx; // normalized velocity
  double vy; // normalized velocity
  final double radius;
  bool isPopped;
  bool isWobbling;
  double wobbleOffset;

  BubbleItem({
    required this.id,
    required this.label,
    required this.value,
    required this.displayType,
    required this.color,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.radius = 48.0,
    this.isPopped = false,
    this.isWobbling = false,
    this.wobbleOffset = 0.0,
  });

  factory BubbleItem.fromJson(Map<String, dynamic> json, int index, int total) {
    // Distribute initial positions evenly across viewport
    final normX = 0.15 + (index % 3) * 0.35 + (index * 0.05) % 0.15;
    final normY = 0.20 + (index ~/ 3) * 0.28 + (index * 0.07) % 0.10;
    
    // Slight random drift velocity
    final vx = (index.isEven ? 0.0008 : -0.0008) * (1.0 + (index % 3) * 0.3);
    final vy = (index % 3 == 0 ? -0.0012 : 0.0010) * (1.0 + (index % 2) * 0.4);

    Color parseColor(String? hex) {
      if (hex == null) return const Color(0xFF60A5FA);
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    }

    return BubbleItem(
      id: json['id'] as String? ?? 'b_$index',
      label: json['label'] as String? ?? '',
      value: json['value'],
      displayType: json['displayType'] as String? ?? 'number',
      color: parseColor(json['color'] as String?),
      x: normX.clamp(0.1, 0.85),
      y: normY.clamp(0.15, 0.80),
      vx: vx,
      vy: vy,
      radius: 46.0,
    );
  }
}
