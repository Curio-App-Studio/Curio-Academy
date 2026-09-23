import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/theme/grade_tier_extension.dart';
import '../components/curio_button.dart';

class RewardDialog extends StatefulWidget {
  final int starsAwarded;
  final int totalPoints;
  final String? message;
  final String title;
  final VoidCallback onContinue;
  final VoidCallback onReplay;

  const RewardDialog({
    super.key,
    required this.starsAwarded,
    required this.totalPoints,
    this.message,
    this.title = 'AWESOME JOB!',
    required this.onContinue,
    required this.onReplay,
  });

  static Future<void> show(
    BuildContext context, {
    required int starsAwarded,
    required int totalPoints,
    String? message,
    String title = 'AWESOME JOB!',
    required VoidCallback onContinue,
    required VoidCallback onReplay,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Reward',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return RewardDialog(
          starsAwarded: starsAwarded,
          totalPoints: totalPoints,
          message: message,
          title: title,
          onContinue: onContinue,
          onReplay: onReplay,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: child,
        );
      },
    );
  }

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playSfx(CurioSfx.starAward);
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tierTheme = context.tierTheme;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: min(MediaQuery.of(context).size.width * 0.88, 420),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Starburst
              AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _sparkleController.value * 2 * pi,
                    child: child,
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFFFEE58), Color(0xFFFF9800)],
                    ),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF6F00),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message ?? 'Fantastic work! You completed this challenge!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: tierTheme.promptFontSize * 0.9,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              // Star display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final filled = index < widget.starsAwarded;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: filled ? const Color(0xFFFFB300) : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Text(
                  '+${widget.totalPoints} Discovery Points',
                  style: const TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFFF6F00), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onReplay();
                      },
                      child: const Text(
                        'Replay',
                        style: TextStyle(
                          color: Color(0xFFFF6F00),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CurioButton(
                      label: 'Next 🚀',
                      backgroundColor: const Color(0xFFFF6F00),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onContinue();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
