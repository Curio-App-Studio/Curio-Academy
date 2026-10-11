import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/student_profile.dart';
import '../../../services/cloud_progress_service.dart';
import '../../../shared/components/student_profile_form.dart';
import '../../home_dashboard/presentation/home_dashboard_screen.dart';

/// First-time onboarding screen for setting up student profile.
///
/// Shares the exact same content, fields, and tiered class selection as [AvatarSelectorDialog].
class FirstTimeOnboardingScreen extends ConsumerStatefulWidget {
  const FirstTimeOnboardingScreen({super.key});

  @override
  ConsumerState<FirstTimeOnboardingScreen> createState() =>
      _FirstTimeOnboardingScreenState();
}

class _FirstTimeOnboardingScreenState
    extends ConsumerState<FirstTimeOnboardingScreen> {
  late TextEditingController _nameController;
  late String _selectedAvatar;
  late BoardType _selectedBoard;
  late StudentClass _selectedClass;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(studentProfileProvider);
    _selectedAvatar = profile.avatarIcon;
    _selectedBoard = profile.board;
    _selectedClass = profile.studentClass;

    final currentName = profile.studentName.trim();
    if (currentName.isNotEmpty &&
        currentName.toLowerCase() != 'young explorer' &&
        currentName.toLowerCase() != 'little champ') {
      _nameController = TextEditingController(text: currentName);
    } else {
      _nameController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    final rawName = _nameController.text.trim();
    if (rawName.isEmpty) {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      setState(() {
        _nameError = ref.strings.nameValidationError;
      });
      return;
    }

    AudioService.instance.playSfx(CurioSfx.correctCheer);
    final finalName = rawName;

    await ref.read(studentProfileProvider.notifier).updateProfile(
          name: finalName,
          avatar: _selectedAvatar,
          board: _selectedBoard,
          studentClass: _selectedClass,
        );

    await LocalStorageService.instance.setOnboarded(true);

    // If VIP membership is active and cloud sync is explicitly enabled, sync newly created student profile
    if (CloudProgressService().isVipEligible && LocalStorageService.instance.isCloudSyncEnabled) {
      CloudProgressService().syncProgressToCloud();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeDashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _restoreVipProgressWithParentGate() async {
    final strings = ref.strings;
    final num1 = 3 + Random().nextInt(6);
    final num2 = 2 + Random().nextInt(6);
    final expected = num1 * num2;
    final gateController = TextEditingController();
    String? errorText;

    final passedGate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Text('👨‍👩‍👦', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.isHindi ? 'अभिभावक सुरक्षा जाँच' : 'Parent Verification',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.isHindi
                    ? 'Google अकाउंट से VIP प्रोग्रेस पुनर्स्थापित करने के लिए हल करें:'
                    : 'Please solve this math question to restore progress from your Google account:',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  '$num1 × $num2 = ?',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gateController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Answer',
                  errorText: errorText,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(strings.isHindi ? 'रद्द करें' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final ans = int.tryParse(gateController.text.trim());
                if (ans == expected) {
                  Navigator.of(ctx).pop(true);
                } else {
                  setDialogState(() {
                    errorText = strings.isHindi ? 'गलत उत्तर' : 'Incorrect answer';
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7B25),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(strings.isHindi ? 'सत्यापित करें' : 'Verify'),
            ),
          ],
        ),
      ),
    );

    if (passedGate != true || !mounted) return;

    AudioService.instance.playSfx(CurioSfx.click);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          strings.isHindi
              ? 'Google अकाउंट से VIP सदस्यता व प्रोग्रेस खोजी जा रही है...'
              : 'Checking Google account for active VIP membership and cloud progress...',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    final result = await CloudProgressService().restoreVipProgress();
    if (!mounted) return;

    if (result.status == CloudRestoreStatus.success) {
      AudioService.instance.playSfx(CurioSfx.starAward);
      await ref.read(studentProfileProvider.notifier).loadProfile();
      await LocalStorageService.instance.setOnboarded(true);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                strings.isHindi ? 'प्रोग्रेस पुनर्स्थापित!' : 'Progress Restored!',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857)),
              ),
            ],
          ),
          content: Text(
            strings.isHindi
                ? 'स्वागत है ${result.studentName ?? ""}! आपके ${result.restoredStars ?? 0} सितारे और सभी पूर्ण अध्याय Google अकाउंट से सुरक्षित वापस आ गए हैं।'
                : 'Welcome back ${result.studentName ?? ""}! Your ${result.restoredStars ?? 0} stars and completed chapters have been restored from your Google account.',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(strings.isHindi ? 'सीखना जारी रखें 🚀' : 'Continue Learning 🚀'),
            ),
          ],
        ),
      );
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            strings.isHindi ? 'क्लाउड बैकअप नहीं मिला' : 'No VIP Backup Found',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            result.message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(strings.isHindi ? 'ठीक है' : 'OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Brand Logo & Welcome
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7B25).withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/curio_logo_mark.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.isHindi ? 'क्युरियो एकेडमी में स्वागत है!' : 'Welcome to Curio Academy',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.manageProfileSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Main Profile Form (Shared between Edit Profile and Onboarding)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: StudentProfileForm(
                  nameController: _nameController,
                  nameError: _nameError,
                  onNameChanged: (val) {
                    if (_nameError != null && val.trim().isNotEmpty) {
                      setState(() => _nameError = null);
                    }
                  },
                  selectedBoard: _selectedBoard,
                  onBoardChanged: (board) => setState(() => _selectedBoard = board),
                  selectedClass: _selectedClass,
                  onClassChanged: (cls) => setState(() => _selectedClass = cls),
                  selectedAvatar: _selectedAvatar,
                  onAvatarChanged: (avatar) => setState(() => _selectedAvatar = avatar),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7B25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0xFFFF7B25).withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        strings.isHindi ? 'सीखना शुरू करें' : 'Start Learning',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('🚀', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _restoreVipProgressWithParentGate,
                icon: const Icon(Icons.cloud_download_rounded, size: 16, color: Color(0xFF64748B)),
                label: Text(
                  strings.isHindi
                      ? 'VIP सदस्यता व प्रोग्रेस पुनर्स्थापित करें ☁️'
                      : 'Restore VIP Membership & Progress ☁️',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
