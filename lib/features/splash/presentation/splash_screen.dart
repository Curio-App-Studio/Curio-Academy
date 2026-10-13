import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../services/cloud_progress_service.dart';
import '../../../services/in_app_purchase_service.dart';
import '../../home_dashboard/presentation/home_dashboard_screen.dart';
import '../../onboarding/presentation/first_time_onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _bootstrapAndNavigate();
  }

  Future<void> _bootstrapAndNavigate() async {
    final stopwatch = Stopwatch()..start();

    // 1. On load after install, check for active Google Play VIP membership first
    try {
      await InAppPurchaseService.instance.restorePurchases().timeout(
        const Duration(milliseconds: 3000),
        onTimeout: () {},
      );
    } catch (_) {}

    // Check if membership is active
    var isVip = LocalStorageService.instance.isPremiumUser ||
        LocalStorageService.instance.isClosedTester;

    // If purchase stream is still settling in background, wait briefly
    if (!isVip && InAppPurchaseService.instance.purchasePendingNotifier.value) {
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        isVip = LocalStorageService.instance.isPremiumUser ||
            LocalStorageService.instance.isClosedTester;
        if (isVip) break;
      }
    }

    bool hasCloudBackup = false;

    // 2. Check and restore cloud backup for VIP / subscribed user or bound account (e.g. gpt.vivek@gmail.com)
    // Runs on fresh install so existing profiles and progress open the Dashboard directly!
    if (isVip || LocalStorageService.instance.boundMembershipEmail != null) {
      try {
        hasCloudBackup = await CloudProgressService().autoSyncAndRestore(force: true).timeout(
          const Duration(milliseconds: 5500),
          onTimeout: () => false,
        );
      } catch (e) {
        debugPrint('[SplashScreen] autoSyncAndRestore error: $e');
      }

      // If cloud backup existed and was restored, mark onboarded & enable cloud sync
      if (hasCloudBackup) {
        await LocalStorageService.instance.setOnboarded(true);
        await LocalStorageService.instance.setCloudSyncEnabled(true);
      }
    }

    // Ensure smooth minimum splash display duration for animations
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 2400) {
      await Future.delayed(Duration(milliseconds: 2400 - elapsed));
    }

    if (!mounted) return;

    final isOnboarded = LocalStorageService.instance.isOnboarded();
    final profile = await LocalStorageService.instance.getStudentProfile();
    final hasValidLocalProfile = profile != null &&
        profile.studentName.isNotEmpty &&
        profile.studentName != 'Little Champ' &&
        profile.studentName != 'Young Explorer';

    if (!mounted) return;

    // Requirements:
    // 1. If cloud backup exists -> skip profile page (go to HomeDashboard)
    // 2. If membership user but NO cloud backup exists:
    //    - If fresh start / no custom profile yet -> user will first come on profile page
    //    - If already created custom profile in prior session -> go to HomeDashboard
    // 3. If regular user -> isOnboarded determines if profile page is shown
    final bool shouldSkipProfile = hasCloudBackup ||
        (!isVip && isOnboarded) ||
        (isVip && (hasCloudBackup || (isOnboarded && hasValidLocalProfile)));

    debugPrint('[SplashScreen] isVip: $isVip, hasCloudBackup: $hasCloudBackup, shouldSkipProfile: $shouldSkipProfile, isOnboarded: $isOnboarded, profileName: ${profile?.studentName}');

    final Widget targetScreen = shouldSkipProfile
        ? const HomeDashboardScreen()
        : const FirstTimeOnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFA),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Logo Emblem with Glowing Background Ring
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE2C89A).withValues(alpha: 0.35),
                              blurRadius: 36,
                              spreadRadius: 8,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: const Color(0xFF2C5E78).withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/images/curio_logo_transparent.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Title & Tagline with smooth slide & fade
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'Curio Academy',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SPARK YOUR POTENTIAL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 16,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Subtle loading bar & footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: 140,
                              height: 4,
                              child: LinearProgressIndicator(
                                value: _controller.value,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF7B25),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Personalized Math & English Learning',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
