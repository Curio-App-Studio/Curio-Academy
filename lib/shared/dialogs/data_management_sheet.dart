import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/profile/profile_provider.dart';
import '../../data/local/local_storage_service.dart';
import '../../features/onboarding/presentation/first_time_onboarding_screen.dart';
import '../../core/audio/audio_service.dart';
import '../../services/cloud_progress_service.dart';
import '../../app.dart';

/// Modal bottom sheet allowing parents to manage data, reset progress, or delete
/// cloud data in compliance with Google Play Families and Data Deletion Policy.
class DataManagementSheet extends ConsumerStatefulWidget {
  const DataManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DataManagementSheet(),
    );
  }

  @override
  ConsumerState<DataManagementSheet> createState() => _DataManagementSheetState();
}

class _DataManagementSheetState extends ConsumerState<DataManagementSheet> {
  bool _gatePassed = false;
  late int _num1;
  late int _num2;
  final TextEditingController _gateController = TextEditingController();
  String? _gateError;

  @override
  void initState() {
    super.initState();
    _generateChallenge();
  }

  @override
  void dispose() {
    _gateController.dispose();
    super.dispose();
  }

  void _generateChallenge() {
    final rand = Random();
    _num1 = rand.nextInt(7) + 3; // 3 to 9
    _num2 = rand.nextInt(7) + 3; // 3 to 9
  }

  void _verifyGate() {
    final expected = _num1 * _num2;
    final entered = int.tryParse(_gateController.text.trim());
    if (entered == expected) {
      AudioService.instance.playSfx(CurioSfx.correctCheer);
      setState(() {
        _gatePassed = true;
        _gateError = null;
      });
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      setState(() {
        _gateError = 'Incorrect. Try again!';
        _generateChallenge();
        _gateController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              if (!_gatePassed)
                _buildParentalGate(isHindi)
              else
                _buildOptions(context, isHindi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentalGate(bool isHindi) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFFFEF2F2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_rounded,
            size: 34,
            color: Color(0xFFDC2626),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isHindi ? 'अभिभावक सुरक्षा जाँच' : 'Parent Zone 🛡️',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isHindi
              ? 'डेटा और रीसेट सेटिंग्स तक पहुँचने के लिए गणित प्रश्न हल करें:'
              : 'Please solve this challenge to access Data & Reset settings:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          ),
          child: Text(
            '$_num1 × $_num2 = ?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _gateController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Answer',
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _gateError,
            ),
            onSubmitted: (_) => _verifyGate(),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 160,
          child: ElevatedButton(
            onPressed: _verifyGate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isHindi ? 'सत्यापित करें' : 'Verify & Continue',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context, bool isHindi) {
    final isVip = LocalStorageService.instance.isPremiumUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'डेटा और रीसेट विकल्प' : 'Data & Reset Management',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    isVip
                        ? (isHindi ? 'VIP सदस्यता सक्रिय 👑' : 'VIP Membership Active 👑')
                        : (isHindi ? 'मुफ़्त संस्करण' : 'Free Plan'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isVip ? const Color(0xFFD97706) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 10),

        // 0. Cloud Auto-Sync Toggle Switch
        _buildCloudSyncTile(context, isHindi, isVip),
        const SizedBox(height: 12),

        // 1. Reset Learning Progress Only
        _buildActionTile(
          icon: Icons.restart_alt_rounded,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: isHindi ? 'सीखने की प्रगति रीसेट करें' : 'Reset Learning Progress',
          subtitle: isHindi
              ? 'सितारे, अंक और पूर्ण किए गए पाठ 0 पर रीसेट होंगे। छात्र प्रोफ़ाइल और VIP सदस्यता सुरक्षित रहेगी।'
              : 'Resets stars, points, and chapter completions to 0. Keeps student profile and VIP membership intact.',
          onTap: () => _confirmResetProgress(context, isHindi),
        ),
        const SizedBox(height: 12),

        // 2. Reset All App Data (Keep VIP Membership)
        _buildActionTile(
          icon: Icons.refresh_rounded,
          iconBg: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF7C3AED),
          title: isHindi ? 'सभी ऐप डेटा रीसेट करें (VIP रखें)' : 'Reset All App Data (Keep VIP)',
          subtitle: isHindi
              ? 'छात्र प्रोफ़ाइल और सभी प्रगति हटाकर नई शुरुआत करें। VIP सदस्यता 100% सुरक्षित रहेगी।'
              : 'Wipes student profile and progress to start completely fresh. VIP Membership is strictly preserved.',
          onTap: () => _confirmResetAllAppData(context, isHindi),
        ),
        const SizedBox(height: 12),

        // 3. Delete Cloud Data (Data Deletion Policy)
        _buildActionTile(
          icon: Icons.cloud_off_rounded,
          iconBg: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          title: isHindi ? 'क्लाउड डेटा हटाएं (डेटा हटाना नीति)' : 'Delete Cloud Data (Data Deletion Policy)',
          subtitle: isHindi
              ? 'Google Play डेटा विलोपन नीति के तहत Cloud Firestore से बैकअप हमेशा के लिए हटा दें।'
              : 'Permanently deletes all cloud backup data from Cloud Firestore under Google Play Data Deletion Policy.',
          onTap: () => _confirmDeleteCloudData(context, isHindi),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildCloudSyncTile(BuildContext context, bool isHindi, bool isVip) {
    return ValueListenableBuilder<bool>(
      valueListenable: LocalStorageService.instance.cloudSyncEnabledNotifier,
      builder: (context, isSyncEnabled, _) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSyncEnabled ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSyncEnabled ? const Color(0xFF86EFAC) : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSyncEnabled ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSyncEnabled ? Icons.cloud_sync_rounded : Icons.cloud_off_rounded,
                  color: isSyncEnabled ? const Color(0xFF16A34A) : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isHindi ? 'क्लाउड ऑटो-सिंक' : 'Cloud Auto-Sync',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSyncEnabled ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSyncEnabled
                                ? (isHindi ? 'सक्रिय' : 'ON')
                                : (isHindi ? 'बंद' : 'OFF'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isSyncEnabled ? const Color(0xFF15803D) : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSyncEnabled
                          ? (isHindi
                              ? 'प्रगति क्लाउड पर स्वचालित रूप से बैकअप हो रही है।'
                              : 'Progress is automatically backed up to Cloud Firestore.')
                          : (isHindi
                              ? 'क्लाउड बैकअप बंद है। डेटा केवल इसी डिवाइस पर रहेगा।'
                              : 'Cloud backup paused. Progress is only stored on this device.'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isSyncEnabled,
                activeThumbColor: const Color(0xFF16A34A),
                activeTrackColor: const Color(0xFF86EFAC),
                onChanged: (bool value) async {
                  if (value) {
                    if (!isVip) {
                      AudioService.instance.playSfx(CurioSfx.gentleWobble);
                      appScaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            isHindi
                                ? 'क्लाउड सिंक के लिए VIP सदस्यता आवश्यक है।'
                                : 'VIP Membership required for Cloud Auto-Sync.',
                          ),
                          backgroundColor: const Color(0xFFD97706),
                        ),
                      );
                      return;
                    }
                    AudioService.instance.playSfx(CurioSfx.correctCheer);
                    await LocalStorageService.instance.setCloudSyncEnabled(true);
                    final syncSuccess = await CloudProgressService().syncProgressToCloud(force: true);
                    appScaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          syncSuccess
                              ? (isHindi
                                  ? 'क्लाउड ऑटो-सिंक सक्रिय किया गया और बैकअप पूरा हुआ!'
                                  : 'Cloud Auto-Sync enabled and progress backed up!')
                              : (isHindi
                                  ? 'क्लाउड ऑटो-सिंक सक्रिय किया गया।'
                                  : 'Cloud Auto-Sync enabled.'),
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    );
                  } else {
                    AudioService.instance.playSfx(CurioSfx.click);
                    await LocalStorageService.instance.setCloudSyncEnabled(false);
                    await CloudProgressService().deleteCloudData();
                    appScaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          isHindi
                              ? 'क्लाउड ऑटो-सिंक बंद किया गया और क्लाउड बैकअप हटा दिया गया।'
                              : 'Cloud Auto-Sync disabled & cloud backup deleted from Firebase.',
                        ),
                        backgroundColor: Colors.grey.shade800,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmResetProgress(BuildContext parentContext, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isHindi ? 'प्रगति रीसेट करें?' : 'Reset Learning Progress?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isHindi
              ? 'यह सभी सितारे, अंक और अध्याय प्रगति को 0 पर रीसेट कर देगा। छात्र प्रोफ़ाइल और VIP सदस्यता सुरक्षित रहेगी।'
              : 'This will reset all stars, discovery points, and chapter attempts back to 0. Your student profile and VIP membership will remain untouched.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              await LocalStorageService.instance.resetProgressOnly();
              appScaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(
                    isHindi
                        ? 'सीखने की प्रगति सफलतापूर्वक 0 पर रीसेट कर दी गई है।'
                        : 'Learning progress successfully reset to 0.',
                  ),
                  backgroundColor: const Color(0xFFD97706),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            child: Text(isHindi ? 'हाँ, रीसेट करें' : 'Yes, Reset Progress'),
          ),
        ],
      ),
    );
  }

  void _confirmResetAllAppData(BuildContext parentContext, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isHindi ? 'सभी ऐप डेटा रीसेट करें?' : 'Reset All App Data?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isHindi
              ? 'यह छात्र प्रोफ़ाइल और सीखने की प्रगति को पूरी तरह मिटा देगा। आपकी VIP सदस्यता 100% सुरक्षित रहेगी। आप नई प्रोफ़ाइल सेट कर सकेंगे।'
              : 'This will clear the student profile and learning progress to start fresh. Your VIP Membership is strictly preserved. You will be taken to profile setup.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final profileNotifier = ref.read(studentProfileProvider.notifier);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              await LocalStorageService.instance.resetAllAppDataExceptMembership();
              profileNotifier.resetProfile();
              appNavigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const FirstTimeOnboardingScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
            ),
            child: Text(isHindi ? 'हाँ, पूरी तरह रीसेट करें' : 'Yes, Reset All Data'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCloudData(BuildContext parentContext, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isHindi ? 'क्लाउड बैकअप हटाएं?' : 'Delete Cloud Backup?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isHindi
              ? 'Google Play डेटा विलोपन नीति के अनुसार, यह Cloud Firestore से आपके बैकअप को हमेशा के लिए हटा देगा।'
              : 'Under Google Play Data Deletion Policy, this permanently deletes your backup records from Cloud Firestore.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              final success = await CloudProgressService().deleteCloudData();
              appScaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? (isHindi
                            ? 'क्लाउड डेटा हमेशा के लिए हटा दिया गया है।'
                            : 'Cloud backup permanently deleted from Firestore.')
                        : (isHindi
                            ? 'क्लाउड डेटा हटाने में विफल।'
                            : 'Failed to delete cloud data.'),
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: Text(isHindi ? 'हाँ, क्लाउड डेटा हटाएं' : 'Yes, Delete Cloud Data'),
          ),
        ],
      ),
    );
  }
}
