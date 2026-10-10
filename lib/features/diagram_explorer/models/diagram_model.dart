/// Single interactive hotspot on a visual diagram
class DiagramHotspot {
  final String id;
  final double x; // Relative X coordinate (0.0 to 1.0)
  final double y; // Relative Y coordinate (0.0 to 1.0)
  final String title;
  final String hindiTitle;
  final String emoji;
  final String description;
  final String hindiDescription;
  final String funFact;
  final String hindiFunFact;
  final String? audioText;

  const DiagramHotspot({
    required this.id,
    required this.x,
    required this.y,
    required this.title,
    required this.hindiTitle,
    required this.emoji,
    required this.description,
    required this.hindiDescription,
    required this.funFact,
    required this.hindiFunFact,
    this.audioText,
  });
}

/// Interactive science/EVS diagram model
class VisualDiagram {
  final String id;
  final String title;
  final String hindiTitle;
  final String emoji;
  final String category; // 'science', 'evs', 'biology'
  final String overview;
  final String hindiOverview;
  final List<DiagramHotspot> hotspots;
  final String visualTheme; // 'nature', 'body', 'space', 'water', 'eco'

  const VisualDiagram({
    required this.id,
    required this.title,
    required this.hindiTitle,
    required this.emoji,
    required this.category,
    required this.overview,
    required this.hindiOverview,
    required this.hotspots,
    required this.visualTheme,
  });
}
