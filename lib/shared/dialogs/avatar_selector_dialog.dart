import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../core/services/in_app_review_service.dart';
import '../../../core/services/in_app_update_service.dart';
import '../../../data/models/student_profile.dart';
import '../components/student_profile_form.dart';

/// Comprehensive Student Profile and Settings Dialog.
/// Allows students to manage Name, Class, Board, and Avatar in one central place.
class AvatarSelectorDialog extends ConsumerStatefulWidget {
  const AvatarSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AvatarSelectorDialog(),
    );
  }

  @override
  ConsumerState<AvatarSelectorDialog> createState() => _AvatarSelectorDialogState();
}

/// Alias for semantic clarity
typedef StudentProfileDialog = AvatarSelectorDialog;

class _AvatarSelectorDialogState extends ConsumerState<AvatarSelectorDialog> {
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
    if (currentName.isEmpty ||
        currentName.toLowerCase() == 'little champ' ||
        currentName.toLowerCase() == 'young explorer') {
      _nameController = TextEditingController(text: '');
    } else {
      _nameController = TextEditingController(text: currentName);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
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

    ref.read(studentProfileProvider.notifier).updateProfile(
          name: finalName,
          avatar: _selectedAvatar,
          board: _selectedBoard,
          studentClass: _selectedClass,
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(_selectedAvatar, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Profile saved for $finalName (${_selectedClass.label} • ${_selectedBoard.code})! 🌟'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            // 1. Header with Close Button
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.manageProfileTitle,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.manageProfileSubtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),

            // 2. Scrollable Profile Form
            Expanded(
              child: SingleChildScrollView(
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
            ),

            const SizedBox(height: 10),

            // Secondary Quick Actions: Rate & Update Check
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AudioService.instance.playSfx(CurioSfx.click);
                      InAppReviewService.instance.showParentGatedReview(context);
                    },
                    icon: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                    label: Text(
                      strings.rateAndFeedback,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: strings.checkForUpdates,
                  icon: const Icon(Icons.sync_rounded, color: Color(0xFF64748B), size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    AudioService.instance.playSfx(CurioSfx.click);
                    await InAppUpdateService.instance.checkForUpdate(context: context);
                    if (context.mounted &&
                        InAppUpdateService.instance.updateInfo?.updateAvailability !=
                            UpdateAvailability.updateAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.upToDate),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 3. Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                label: Text(
                  strings.saveProfile,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7B25),
                  elevation: 2,
                  shadowColor: const Color(0xFFFF7B25).withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
