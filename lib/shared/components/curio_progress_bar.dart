import 'package:flutter/material.dart';

class CurioProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int currentStars;
  final int totalStars;
  final Color? barColor;
  final Color? backgroundColor;

  const CurioProgressBar({
    super.key,
    required this.progress,
    this.currentStars = 0,
    this.totalStars = 5,
    this.barColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final activeColor = barColor ?? theme.colorScheme.primary;
    final trackColor = backgroundColor ?? Colors.white.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Star Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD54F),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66FFB300),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFE65100),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          // Bar
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fillWidth = (constraints.maxWidth * clampedProgress).clamp(0.0, double.infinity);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      height: 20,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            activeColor,
                            activeColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$currentStars / $totalStars',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
