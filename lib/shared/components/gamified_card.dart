import 'package:flutter/material.dart';
import '../../core/theme/grade_tier_extension.dart';

class GamifiedCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const GamifiedCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tierTheme = context.tierTheme;
    final bg = backgroundColor ?? tierTheme.cardBackground;
    final border = borderColor ?? bg.withValues(alpha: 0.7);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: tierTheme.borderRadius,
        border: Border.all(color: border, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: tierTheme.borderRadius,
        child: InkWell(
          borderRadius: tierTheme.borderRadius,
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
