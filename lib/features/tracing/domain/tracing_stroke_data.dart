import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Represents a single continuous stroke guide for a character (e.g. left leg of 'A')
class TracingStrokeGuide {
  final int index;
  final List<Offset> normalizedPoints;

  const TracingStrokeGuide({
    required this.index,
    required this.normalizedPoints,
  });

  Offset get startPoint => normalizedPoints.isNotEmpty ? normalizedPoints.first : const Offset(0.5, 0.5);
  Offset get endPoint => normalizedPoints.isNotEmpty ? normalizedPoints.last : const Offset(0.5, 0.5);

  /// Converts normalized (0.0 to 1.0) points into actual screen canvas coordinates
  List<Offset> toScreenCoordinates(Rect bounds) {
    return normalizedPoints.map((p) {
      return Offset(
        bounds.left + p.dx * bounds.width,
        bounds.top + p.dy * bounds.height,
      );
    }).toList();
  }
}

/// Catalog containing canonical, preschool-tested stroke orders and paths
class TracingStrokeCatalog {
  static final Map<String, List<TracingStrokeGuide>> _catalog = _initCatalog();

  static List<TracingStrokeGuide> getStrokes(String character) {
    final strokes = _catalog[character];
    if (strokes != null && strokes.isNotEmpty) {
      return strokes;
    }
    return _generateFallbackStrokes(character);
  }

  static Map<String, List<TracingStrokeGuide>> _initCatalog() {
    return {
      // --- UPPERCASE A-Z ---
      'A': [
        // Stroke 1: Left leg (top to bottom-left)
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.50, 0.15),
            Offset(0.44, 0.28),
            Offset(0.38, 0.42),
            Offset(0.32, 0.56),
            Offset(0.26, 0.70),
            Offset(0.20, 0.85),
          ],
        ),
        // Stroke 2: Right leg (top to bottom-right)
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.50, 0.15),
            Offset(0.56, 0.28),
            Offset(0.62, 0.42),
            Offset(0.68, 0.56),
            Offset(0.74, 0.70),
            Offset(0.80, 0.85),
          ],
        ),
        // Stroke 3: Crossbar (left to right)
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.33, 0.62),
            Offset(0.42, 0.62),
            Offset(0.50, 0.62),
            Offset(0.58, 0.62),
            Offset(0.67, 0.62),
          ],
        ),
      ],

      'B': [
        // Stroke 1: Vertical spine (top to bottom)
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.25, 0.29),
            Offset(0.25, 0.43),
            Offset(0.25, 0.57),
            Offset(0.25, 0.71),
            Offset(0.25, 0.85),
          ],
        ),
        // Stroke 2: Top loop
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.48, 0.14),
            Offset(0.68, 0.20),
            Offset(0.74, 0.32),
            Offset(0.66, 0.46),
            Offset(0.45, 0.50),
            Offset(0.25, 0.50),
          ],
        ),
        // Stroke 3: Bottom loop
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.25, 0.50),
            Offset(0.50, 0.50),
            Offset(0.72, 0.55),
            Offset(0.78, 0.68),
            Offset(0.70, 0.80),
            Offset(0.48, 0.85),
            Offset(0.25, 0.85),
          ],
        ),
      ],

      'C': [
        // Stroke 1: Curved arc (top right around to bottom right)
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.76, 0.24),
            Offset(0.62, 0.15),
            Offset(0.45, 0.14),
            Offset(0.30, 0.25),
            Offset(0.22, 0.42),
            Offset(0.22, 0.58),
            Offset(0.30, 0.75),
            Offset(0.45, 0.86),
            Offset(0.62, 0.85),
            Offset(0.76, 0.76),
          ],
        ),
      ],

      'D': [
        // Stroke 1: Spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.25, 0.29),
            Offset(0.25, 0.43),
            Offset(0.25, 0.57),
            Offset(0.25, 0.71),
            Offset(0.25, 0.85),
          ],
        ),
        // Stroke 2: Curved belly
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.48, 0.14),
            Offset(0.68, 0.23),
            Offset(0.78, 0.38),
            Offset(0.80, 0.50),
            Offset(0.78, 0.62),
            Offset(0.68, 0.77),
            Offset(0.48, 0.86),
            Offset(0.25, 0.85),
          ],
        ),
      ],

      'E': [
        // Stroke 1: Vertical spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.26, 0.15),
            Offset(0.26, 0.32),
            Offset(0.26, 0.50),
            Offset(0.26, 0.68),
            Offset(0.26, 0.85),
          ],
        ),
        // Stroke 2: Top bar
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.26, 0.15),
            Offset(0.44, 0.15),
            Offset(0.62, 0.15),
            Offset(0.78, 0.15),
          ],
        ),
        // Stroke 3: Middle bar
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.26, 0.50),
            Offset(0.42, 0.50),
            Offset(0.58, 0.50),
            Offset(0.70, 0.50),
          ],
        ),
        // Stroke 4: Bottom bar
        const TracingStrokeGuide(
          index: 3,
          normalizedPoints: [
            Offset(0.26, 0.85),
            Offset(0.44, 0.85),
            Offset(0.62, 0.85),
            Offset(0.78, 0.85),
          ],
        ),
      ],

      'F': [
        // Stroke 1: Vertical spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.26, 0.15),
            Offset(0.26, 0.32),
            Offset(0.26, 0.50),
            Offset(0.26, 0.68),
            Offset(0.26, 0.85),
          ],
        ),
        // Stroke 2: Top bar
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.26, 0.15),
            Offset(0.44, 0.15),
            Offset(0.62, 0.15),
            Offset(0.78, 0.15),
          ],
        ),
        // Stroke 3: Middle bar
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.26, 0.50),
            Offset(0.42, 0.50),
            Offset(0.58, 0.50),
            Offset(0.70, 0.50),
          ],
        ),
      ],

      'G': [
        // Stroke 1: Outer C curve
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.76, 0.24),
            Offset(0.62, 0.15),
            Offset(0.45, 0.14),
            Offset(0.30, 0.25),
            Offset(0.22, 0.42),
            Offset(0.22, 0.58),
            Offset(0.30, 0.75),
            Offset(0.45, 0.86),
            Offset(0.65, 0.85),
            Offset(0.76, 0.72),
            Offset(0.76, 0.56),
          ],
        ),
        // Stroke 2: Crossbar inward
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.76, 0.56),
            Offset(0.62, 0.56),
            Offset(0.50, 0.56),
          ],
        ),
      ],

      'H': [
        // Stroke 1: Left spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.26, 0.15),
            Offset(0.26, 0.38),
            Offset(0.26, 0.62),
            Offset(0.26, 0.85),
          ],
        ),
        // Stroke 2: Right spine
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.74, 0.15),
            Offset(0.74, 0.38),
            Offset(0.74, 0.62),
            Offset(0.74, 0.85),
          ],
        ),
        // Stroke 3: Crossbar
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.26, 0.50),
            Offset(0.42, 0.50),
            Offset(0.58, 0.50),
            Offset(0.74, 0.50),
          ],
        ),
      ],

      'I': [
        // Stroke 1: Main vertical spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.50, 0.15),
            Offset(0.50, 0.32),
            Offset(0.50, 0.50),
            Offset(0.50, 0.68),
            Offset(0.50, 0.85),
          ],
        ),
      ],

      'J': [
        // Stroke 1: Spine with bottom hook
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.62, 0.15),
            Offset(0.62, 0.35),
            Offset(0.62, 0.55),
            Offset(0.60, 0.72),
            Offset(0.50, 0.85),
            Offset(0.35, 0.84),
            Offset(0.25, 0.72),
          ],
        ),
      ],

      'K': [
        // Stroke 1: Left spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.26, 0.15),
            Offset(0.26, 0.38),
            Offset(0.26, 0.62),
            Offset(0.26, 0.85),
          ],
        ),
        // Stroke 2: Top diagonal into center
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.75, 0.15),
            Offset(0.58, 0.28),
            Offset(0.42, 0.42),
            Offset(0.28, 0.52),
          ],
        ),
        // Stroke 3: Bottom diagonal out
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.32, 0.50),
            Offset(0.46, 0.62),
            Offset(0.62, 0.74),
            Offset(0.78, 0.85),
          ],
        ),
      ],

      'L': [
        // Stroke 1: Spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.26, 0.15),
            Offset(0.26, 0.38),
            Offset(0.26, 0.62),
            Offset(0.26, 0.85),
          ],
        ),
        // Stroke 2: Foot
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.26, 0.85),
            Offset(0.44, 0.85),
            Offset(0.62, 0.85),
            Offset(0.78, 0.85),
          ],
        ),
      ],

      'M': [
        // Stroke 1: Left spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.20, 0.85),
            Offset(0.20, 0.62),
            Offset(0.20, 0.38),
            Offset(0.20, 0.15),
          ],
        ),
        // Stroke 2: Left diagonal down to center
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.20, 0.15),
            Offset(0.30, 0.35),
            Offset(0.40, 0.55),
            Offset(0.50, 0.75),
          ],
        ),
        // Stroke 3: Right diagonal up from center
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.50, 0.75),
            Offset(0.60, 0.55),
            Offset(0.70, 0.35),
            Offset(0.80, 0.15),
          ],
        ),
        // Stroke 4: Right spine down
        const TracingStrokeGuide(
          index: 3,
          normalizedPoints: [
            Offset(0.80, 0.15),
            Offset(0.80, 0.38),
            Offset(0.80, 0.62),
            Offset(0.80, 0.85),
          ],
        ),
      ],

      'N': [
        // Stroke 1: Left spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.22, 0.85),
            Offset(0.22, 0.62),
            Offset(0.22, 0.38),
            Offset(0.22, 0.15),
          ],
        ),
        // Stroke 2: Diagonal down-right
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.22, 0.15),
            Offset(0.36, 0.32),
            Offset(0.50, 0.50),
            Offset(0.64, 0.68),
            Offset(0.78, 0.85),
          ],
        ),
        // Stroke 3: Right spine up
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.78, 0.85),
            Offset(0.78, 0.62),
            Offset(0.78, 0.38),
            Offset(0.78, 0.15),
          ],
        ),
      ],

      'O': [
        // Stroke 1: Complete oval loop counter-clockwise
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.50, 0.14),
            Offset(0.32, 0.22),
            Offset(0.20, 0.42),
            Offset(0.20, 0.58),
            Offset(0.32, 0.78),
            Offset(0.50, 0.86),
            Offset(0.68, 0.78),
            Offset(0.80, 0.58),
            Offset(0.80, 0.42),
            Offset(0.68, 0.22),
            Offset(0.50, 0.14),
          ],
        ),
      ],

      'P': [
        // Stroke 1: Vertical spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.25, 0.32),
            Offset(0.25, 0.50),
            Offset(0.25, 0.68),
            Offset(0.25, 0.85),
          ],
        ),
        // Stroke 2: Top loop
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.48, 0.14),
            Offset(0.70, 0.20),
            Offset(0.76, 0.34),
            Offset(0.66, 0.48),
            Offset(0.45, 0.54),
            Offset(0.25, 0.54),
          ],
        ),
      ],

      'R': [
        // Stroke 1: Vertical spine
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.25, 0.32),
            Offset(0.25, 0.50),
            Offset(0.25, 0.68),
            Offset(0.25, 0.85),
          ],
        ),
        // Stroke 2: Top loop
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.25, 0.15),
            Offset(0.48, 0.14),
            Offset(0.70, 0.20),
            Offset(0.76, 0.34),
            Offset(0.66, 0.48),
            Offset(0.45, 0.54),
            Offset(0.25, 0.54),
          ],
        ),
        // Stroke 3: Leg diagonal out
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.45, 0.54),
            Offset(0.56, 0.64),
            Offset(0.68, 0.74),
            Offset(0.78, 0.85),
          ],
        ),
      ],

      'S': [
        // Stroke 1: S snake curve
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.75, 0.25),
            Offset(0.58, 0.15),
            Offset(0.38, 0.20),
            Offset(0.30, 0.32),
            Offset(0.42, 0.46),
            Offset(0.58, 0.54),
            Offset(0.72, 0.65),
            Offset(0.68, 0.80),
            Offset(0.48, 0.86),
            Offset(0.26, 0.78),
          ],
        ),
      ],

      'T': [
        // Stroke 1: Top crossbar
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.18, 0.15),
            Offset(0.38, 0.15),
            Offset(0.50, 0.15),
            Offset(0.68, 0.15),
            Offset(0.82, 0.15),
          ],
        ),
        // Stroke 2: Center spine down
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.50, 0.15),
            Offset(0.50, 0.32),
            Offset(0.50, 0.50),
            Offset(0.50, 0.68),
            Offset(0.50, 0.85),
          ],
        ),
      ],

      'U': [
        // Stroke 1: U curve down and up
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.24, 0.15),
            Offset(0.24, 0.40),
            Offset(0.24, 0.62),
            Offset(0.32, 0.80),
            Offset(0.50, 0.86),
            Offset(0.68, 0.80),
            Offset(0.76, 0.62),
            Offset(0.76, 0.40),
            Offset(0.76, 0.15),
          ],
        ),
      ],

      'V': [
        // Stroke 1: Left diagonal down to vertex
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.22, 0.15),
            Offset(0.31, 0.38),
            Offset(0.40, 0.62),
            Offset(0.50, 0.85),
          ],
        ),
        // Stroke 2: Right diagonal up from vertex
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.50, 0.85),
            Offset(0.60, 0.62),
            Offset(0.69, 0.38),
            Offset(0.78, 0.15),
          ],
        ),
      ],

      'W': [
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.18, 0.15),
            Offset(0.26, 0.50),
            Offset(0.34, 0.85),
          ],
        ),
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.34, 0.85),
            Offset(0.42, 0.50),
            Offset(0.50, 0.25),
          ],
        ),
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.50, 0.25),
            Offset(0.58, 0.50),
            Offset(0.66, 0.85),
          ],
        ),
        const TracingStrokeGuide(
          index: 3,
          normalizedPoints: [
            Offset(0.66, 0.85),
            Offset(0.74, 0.50),
            Offset(0.82, 0.15),
          ],
        ),
      ],

      'X': [
        // Stroke 1: Main diagonal top-left to bottom-right
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.24, 0.15),
            Offset(0.37, 0.32),
            Offset(0.50, 0.50),
            Offset(0.63, 0.68),
            Offset(0.76, 0.85),
          ],
        ),
        // Stroke 2: Secondary diagonal top-right to bottom-left
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.76, 0.15),
            Offset(0.63, 0.32),
            Offset(0.50, 0.50),
            Offset(0.37, 0.68),
            Offset(0.24, 0.85),
          ],
        ),
      ],

      'Y': [
        // Stroke 1: Left arm to center
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.24, 0.15),
            Offset(0.37, 0.32),
            Offset(0.50, 0.50),
          ],
        ),
        // Stroke 2: Right arm to center
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.76, 0.15),
            Offset(0.63, 0.32),
            Offset(0.50, 0.50),
          ],
        ),
        // Stroke 3: Stem down
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.50, 0.50),
            Offset(0.50, 0.68),
            Offset(0.50, 0.85),
          ],
        ),
      ],

      'Z': [
        // Stroke 1: Top bar
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.24, 0.15),
            Offset(0.42, 0.15),
            Offset(0.60, 0.15),
            Offset(0.76, 0.15),
          ],
        ),
        // Stroke 2: Main diagonal
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.76, 0.15),
            Offset(0.62, 0.38),
            Offset(0.48, 0.62),
            Offset(0.24, 0.85),
          ],
        ),
        // Stroke 3: Bottom bar
        const TracingStrokeGuide(
          index: 2,
          normalizedPoints: [
            Offset(0.24, 0.85),
            Offset(0.42, 0.85),
            Offset(0.60, 0.85),
            Offset(0.76, 0.85),
          ],
        ),
      ],

      // --- NUMBERS ---
      '1': [
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.38, 0.28),
            Offset(0.50, 0.15),
            Offset(0.50, 0.38),
            Offset(0.50, 0.62),
            Offset(0.50, 0.85),
          ],
        ),
      ],

      '2': [
        // Stroke 1: Top hook and diagonal down to bottom-left
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.28, 0.28),
            Offset(0.42, 0.15),
            Offset(0.65, 0.15),
            Offset(0.75, 0.28),
            Offset(0.68, 0.45),
            Offset(0.48, 0.65),
            Offset(0.25, 0.85),
          ],
        ),
        // Stroke 2: Horizontal foot
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.25, 0.85),
            Offset(0.45, 0.85),
            Offset(0.65, 0.85),
            Offset(0.80, 0.85),
          ],
        ),
      ],

      '3': [
        // Stroke 1: Top arc
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.28, 0.20),
            Offset(0.50, 0.15),
            Offset(0.70, 0.22),
            Offset(0.70, 0.38),
            Offset(0.50, 0.48),
          ],
        ),
        // Stroke 2: Bottom arc
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.50, 0.48),
            Offset(0.74, 0.56),
            Offset(0.74, 0.74),
            Offset(0.54, 0.85),
            Offset(0.28, 0.80),
          ],
        ),
      ],

      '4': [
        // Stroke 1: Diagonal down-right + horizontal bar
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.62, 0.15),
            Offset(0.42, 0.42),
            Offset(0.22, 0.65),
            Offset(0.42, 0.65),
            Offset(0.62, 0.65),
            Offset(0.80, 0.65),
          ],
        ),
        // Stroke 2: Vertical stem
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.62, 0.35),
            Offset(0.62, 0.50),
            Offset(0.62, 0.68),
            Offset(0.62, 0.85),
          ],
        ),
      ],

      '5': [
        // Stroke 1: Vertical drop + belly
        const TracingStrokeGuide(
          index: 0,
          normalizedPoints: [
            Offset(0.35, 0.18),
            Offset(0.35, 0.42),
            Offset(0.55, 0.40),
            Offset(0.75, 0.52),
            Offset(0.75, 0.72),
            Offset(0.55, 0.85),
            Offset(0.30, 0.80),
          ],
        ),
        // Stroke 2: Top bar
        const TracingStrokeGuide(
          index: 1,
          normalizedPoints: [
            Offset(0.35, 0.18),
            Offset(0.55, 0.18),
            Offset(0.75, 0.18),
          ],
        ),
      ],
    };
  }

  /// Automatic fallback stroke generator for any characters not hardcoded above
  static List<TracingStrokeGuide> _generateFallbackStrokes(String character) {
    return [
      const TracingStrokeGuide(
        index: 0,
        normalizedPoints: [
          Offset(0.30, 0.20),
          Offset(0.30, 0.50),
          Offset(0.30, 0.80),
          Offset(0.50, 0.85),
          Offset(0.70, 0.70),
          Offset(0.70, 0.30),
        ],
      ),
    ];
  }
}
