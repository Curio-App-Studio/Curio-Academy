import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/theme/grade_tier_extension.dart';
import '../../data/local/local_storage_service.dart';
import '../../services/ad_service.dart';
import '../components/curio_button.dart';

class RewardDialog extends StatefulWidget {
  final int starsAwarded;
  final int totalPoints;
  final String? message;
  final String title;
  final VoidCallback onContinue;
  final VoidCallback onReplay;
  final VoidCallback? onBackToQuestions;

  const RewardDialog({
    super.key,
    required this.starsAwarded,
    required this.totalPoints,
    this.message,
    this.title = 'AWESOME JOB!',
    required this.onContinue,
    required this.onReplay,
    this.onBackToQuestions,
  });

  static Future<void> show(
    BuildContext context, {
    required int starsAwarded,
    required int totalPoints,
    String? message,
    String title = 'AWESOME JOB!',
    required VoidCallback onContinue,
    required VoidCallback onReplay,
    VoidCallback? onBackToQuestions,
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
          onBackToQuestions: onBackToQuestions,
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
  bool _starsDoubled = false;
  bool _isLoadingReward = false;

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
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';
    final defaultTitle = isHindi ? 'शानदार कार्य!' : 'AWESOME JOB!';
    final displayTitle = widget.title == 'AWESOME JOB!' ? defaultTitle : widget.title;

    void handleBackToQuestions() {
      AudioService.instance.stopAudio();
      Navigator.of(context).pop();
      if (widget.onBackToQuestions != null) {
        widget.onBackToQuestions!();
      } else {
        Navigator.of(context).pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        handleBackToQuestions();
      },
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: min(MediaQuery.of(context).size.width * 0.88, 420),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
            child: SingleChildScrollView(
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
                const SizedBox(height: 18),
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF6F00),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message ??
                      (isHindi
                          ? 'शानदार प्रयास! आपने इस प्रश्न को पूरा कर लिया!'
                          : 'Fantastic work! You completed this challenge!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: tierTheme.promptFontSize * 0.9,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                // Star display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final filled = index < widget.starsAwarded;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.star_rounded,
                        size: 46,
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
                    isHindi
                        ? '+${widget.totalPoints} डिस्कवरी पॉइंट्स'
                        : '+${widget.totalPoints} Discovery Points',
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Bonus / Double Stars Button (Rewarded Video / Instant Free for Closed Testers)
                if (!_starsDoubled)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF3C7),
                        foregroundColor: const Color(0xFFB45309),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isLoadingReward
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB45309)),
                            )
                          : const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 22),
                      label: Text(
                        isHindi
                            ? '🌟 सितारे दोगुने करें (+${widget.starsAwarded} ⭐)'
                            : '🌟 Double Your Stars! (+${widget.starsAwarded} ⭐)',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      onPressed: _isLoadingReward
                          ? null
                          : () {
                              setState(() => _isLoadingReward = true);
                              AdService().showRewardedAd(
                                onUserEarnedReward: (reward) async {
                                  AudioService.instance.playSfx(CurioSfx.starAward);
                                  await LocalStorageService.instance.addBonusStars(widget.starsAwarded);
                                  if (mounted) {
                                    setState(() {
                                      _starsDoubled = true;
                                      _isLoadingReward = false;
                                    });
                                  }
                                },
                                onDismissed: () {
                                  if (mounted && !_starsDoubled) {
                                    setState(() => _isLoadingReward = false);
                                  }
                                },
                                onFailedToLoad: () {
                                  if (mounted) {
                                    setState(() => _isLoadingReward = false);
                                  }
                                },
                              );
                            },
                    ),
                  ),
                if (_starsDoubled)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          isHindi ? 'दोगुने सितारे जुड़ गए! 🎉' : 'Stars Doubled Successfully! 🎉',
                          style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Primary Action Buttons: Replay & Next
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFFF6F00), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onReplay();
                        },
                        child: Text(
                          isHindi ? 'फिर से खेलें' : 'Replay',
                          style: const TextStyle(
                            color: Color(0xFFFF6F00),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CurioButton(
                        label: isHindi ? 'अगला प्रश्न 🚀' : 'Next 🚀',
                        backgroundColor: const Color(0xFFFF6F00),
                        onPressed: () {
                          AudioService.instance.stopAudio();
                          Navigator.of(context).pop();
                          AdService().showInterstitialAdIfReady(
                            onCompleted: widget.onContinue,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Dedicated Back to Question List button
                TextButton.icon(
                  onPressed: handleBackToQuestions,
                  icon: const Icon(Icons.list_alt_rounded, size: 18, color: Color(0xFF475569)),
                  label: Text(
                    isHindi ? 'प्रश्नावली पर वापस जाएं 📋' : 'Back to Question List 📋',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
