import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/student_profile.dart';

/// Reusable profile form used by both [AvatarSelectorDialog] (Edit Profile)
/// and [FirstTimeOnboardingScreen] (Initial Setup).
///
/// Ensures both pages remain 100% synchronized in content, fields, and tiered class selection.
class StudentProfileForm extends ConsumerWidget {
  final TextEditingController nameController;
  final String? nameError;
  final ValueChanged<String>? onNameChanged;
  final BoardType selectedBoard;
  final ValueChanged<BoardType> onBoardChanged;
  final StudentClass selectedClass;
  final ValueChanged<StudentClass> onClassChanged;
  final String selectedAvatar;
  final ValueChanged<String> onAvatarChanged;

  const StudentProfileForm({
    super.key,
    required this.nameController,
    this.nameError,
    this.onNameChanged,
    required this.selectedBoard,
    required this.onBoardChanged,
    required this.selectedClass,
    required this.onClassChanged,
    required this.selectedAvatar,
    required this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Student Name Input Field
        Text(
          strings.studentNameLabel,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          onChanged: onNameChanged,
          decoration: InputDecoration(
            counterText: '',
            hintText: strings.studentNameHint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            errorText: nameError,
            prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFFFF7B25)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            filled: true,
            fillColor: const Color(0xFFFFF7ED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFED7AA), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: nameError != null ? const Color(0xFFEF4444) : const Color(0xFFFED7AA),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: nameError != null ? const Color(0xFFEF4444) : const Color(0xFFFF7B25),
                width: 2,
              ),
            ),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 18),

        // 2. Select Educational Board
        Text(
          strings.selectBoardTitle,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: BoardType.values.map((board) {
            final isSelected = board == selectedBoard;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    onBoardChanged(board);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFCBD5E1),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      board.code,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 18),

        // 3. Select Class / Grade (Tiered grouping)
        Text(
          strings.selectClassGradeTitle,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),

        // Tier 1: Early Explorers (Pre-primary & Grade 1)
        _buildTierHeader('Early Explorers (Pre-primary & Grade 1)', const Color(0xFF059669)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            StudentClass.lkg,
            StudentClass.ukg,
            StudentClass.class1,
          ].map(_buildClassChip).toList(),
        ),

        const SizedBox(height: 10),

        // Tier 2: Primary Builders (Grade 2 to 5)
        _buildTierHeader('Primary Builders (Grade 2 to 5)', const Color(0xFFFF7B25)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            StudentClass.class2,
            StudentClass.class3,
            StudentClass.class4,
            StudentClass.class5,
          ].map(_buildClassChip).toList(),
        ),

        const SizedBox(height: 10),

        // Tier 3: Middle Achievers (Grade 6 to 8)
        _buildTierHeader('Middle Achievers (Grade 6 to 8)', const Color(0xFF6366F1)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            StudentClass.class6,
            StudentClass.class7,
            StudentClass.class8,
          ].map(_buildClassChip).toList(),
        ),

        const SizedBox(height: 18),

        // 4. Choose Mascot Avatar
        Text(
          strings.chooseAvatarTitle,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: StudentProfile.availableAvatars.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = StudentProfile.availableAvatars[index];
              final emoji = item['emoji']!;
              final isSelected = selectedAvatar == emoji;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  onAvatarChanged(emoji);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF7B25) : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF7B25).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTierHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassChip(StudentClass studentClass) {
    final isSelected = studentClass == selectedClass;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        AudioService.instance.playSfx(CurioSfx.click);
        onClassChanged(studentClass);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7B25) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFEA580C) : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF7B25).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          studentClass.label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF334155),
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
