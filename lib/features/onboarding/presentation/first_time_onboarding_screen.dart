import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/student_profile.dart';
import '../../../shared/components/language_switch_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [
          LanguageSwitchButton(),
          SizedBox(width: 12),
        ],
      ),
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
      ),
    );
  }
}
