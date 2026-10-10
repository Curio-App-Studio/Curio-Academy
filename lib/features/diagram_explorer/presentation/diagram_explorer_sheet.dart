import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../data/diagram_data.dart';
import '../models/diagram_model.dart';

class DiagramExplorerSheet extends ConsumerStatefulWidget {
  final String? initialDiagramId;

  const DiagramExplorerSheet({
    super.key,
    this.initialDiagramId,
  });

  static Future<void> show(BuildContext context, {String? initialDiagramId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DiagramExplorerSheet(initialDiagramId: initialDiagramId),
    );
  }

  @override
  ConsumerState<DiagramExplorerSheet> createState() => _DiagramExplorerSheetState();
}

class _DiagramExplorerSheetState extends ConsumerState<DiagramExplorerSheet>
    with SingleTickerProviderStateMixin {
  late int _selectedDiagramIndex;
  DiagramHotspot? _selectedHotspot;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final initialId = widget.initialDiagramId;
    if (initialId != null) {
      final idx = DiagramData.diagrams.indexWhere((d) => d.id == initialId);
      _selectedDiagramIndex = idx >= 0 ? idx : 0;
    } else {
      _selectedDiagramIndex = 0;
    }

    final initialDiag = DiagramData.diagrams[_selectedDiagramIndex];
    if (initialDiag.hotspots.isNotEmpty) {
      _selectedHotspot = initialDiag.hotspots.first;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSelectDiagram(int index) {
    if (index == _selectedDiagramIndex) return;
    AudioService.instance.playSfx(CurioSfx.click);
    setState(() {
      _selectedDiagramIndex = index;
      final diag = DiagramData.diagrams[index];
      _selectedHotspot = diag.hotspots.isNotEmpty ? diag.hotspots.first : null;
    });
  }

  void _onTapHotspot(DiagramHotspot hotspot) {
    AudioService.instance.playSfx(CurioSfx.click);
    setState(() => _selectedHotspot = hotspot);
    final strings = ref.read(appLanguageProvider);
    final isHindi = strings.code == 'hi';
    final textToSpeak = isHindi
        ? '${hotspot.hindiTitle}. ${hotspot.hindiDescription}'
        : '${hotspot.title}. ${hotspot.description}';
    AudioService.instance.speakPrompt(textToSpeak);
  }

  Color _getThemePrimary(String theme) {
    switch (theme) {
      case 'nature':
        return const Color(0xFF059669);
      case 'body':
        return const Color(0xFFE11D48);
      case 'water':
        return const Color(0xFF0284C7);
      case 'space':
        return const Color(0xFF7C3AED);
      case 'eco':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  List<Color> _getThemeGradient(String theme) {
    switch (theme) {
      case 'nature':
        return [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)];
      case 'body':
        return [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)];
      case 'water':
        return [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)];
      case 'space':
        return [const Color(0xFF0F172A), const Color(0xFF1E1B4B)];
      case 'eco':
        return [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)];
      default:
        return [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final currentDiagram = DiagramData.diagrams[_selectedDiagramIndex];
    final themePrimary = _getThemePrimary(currentDiagram.visualTheme);
    final themeGradient = _getThemeGradient(currentDiagram.visualTheme);
    final isDarkCanvas = currentDiagram.visualTheme == 'space';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: themePrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(currentDiagram.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.isHindi ? currentDiagram.hindiTitle : currentDiagram.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        strings.tapHotspotsToLearn,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Diagram Selection Pills
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: DiagramData.diagrams.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final d = DiagramData.diagrams[idx];
                final isSelected = idx == _selectedDiagramIndex;
                final pillColor = _getThemePrimary(d.visualTheme);

                return ChoiceChip(
                  label: Text('${d.emoji} ${strings.isHindi ? d.hindiTitle : d.title}'),
                  selected: isSelected,
                  onSelected: (_) => _onSelectDiagram(idx),
                  selectedColor: pillColor,
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(
                    color: isSelected ? pillColor : const Color(0xFFE2E8F0),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Interactive Diagram Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkCanvas ? const Color(0xFF334155) : themePrimary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return Stack(
                      children: [
                        // Background decorative hint
                        Center(
                          child: Opacity(
                            opacity: isDarkCanvas ? 0.25 : 0.12,
                            child: Text(
                              currentDiagram.emoji,
                              style: TextStyle(
                                fontSize: w * 0.45,
                              ),
                            ),
                          ),
                        ),

                        // Hotspot Pins
                        ...currentDiagram.hotspots.map((hotspot) {
                          final isSelected = _selectedHotspot?.id == hotspot.id;
                          final pinX = (hotspot.x * w).clamp(24.0, w - 24.0);
                          final pinY = (hotspot.y * h).clamp(24.0, h - 24.0);

                          return Positioned(
                            left: pinX - 24,
                            top: pinY - 24,
                            child: GestureDetector(
                              onTap: () => _onTapHotspot(hotspot),
                              child: ScaleTransition(
                                scale: isSelected ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected ? themePrimary : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Colors.white : themePrimary,
                                      width: isSelected ? 2.5 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themePrimary.withValues(alpha: isSelected ? 0.4 : 0.2),
                                        blurRadius: isSelected ? 12 : 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      hotspot.emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Hotspot Detail Inspector Card
          if (_selectedHotspot != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: themePrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(_selectedHotspot!.emoji, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.isHindi ? _selectedHotspot!.hindiTitle : _selectedHotspot!.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: themePrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Material(
                        color: themePrimary.withValues(alpha: 0.1),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(Icons.volume_up_rounded, color: themePrimary, size: 20),
                          tooltip: 'Speak Explanation',
                          onPressed: () {
                            AudioService.instance.playSfx(CurioSfx.click);
                            final text = strings.isHindi
                                ? '${_selectedHotspot!.hindiTitle}. ${_selectedHotspot!.hindiDescription}. ${_selectedHotspot!.hindiFunFact}'
                                : '${_selectedHotspot!.title}. ${_selectedHotspot!.description}. ${_selectedHotspot!.funFact}';
                            AudioService.instance.speakPrompt(text);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.isHindi ? _selectedHotspot!.hindiDescription : _selectedHotspot!.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Wonder fact
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            strings.isHindi ? _selectedHotspot!.hindiFunFact : _selectedHotspot!.funFact,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
