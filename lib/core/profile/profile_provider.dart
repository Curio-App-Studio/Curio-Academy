import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/student_profile.dart';
import '../theme/tier_theme_provider.dart';

class StudentProfileNotifier extends StateNotifier<StudentProfile> {
  final Ref ref;

  StudentProfileNotifier(this.ref) : super(const StudentProfile()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final saved = await LocalStorageService.instance.getStudentProfile();
    if (saved != null) {
      state = saved;
      ref.read(gradeTierProvider.notifier).setTier(saved.tier);
    }
  }

  Future<void> updateProfile({
    required BoardType board,
    required StudentClass studentClass,
    String? name,
  }) async {
    final updated = state.copyWith(
      board: board,
      studentClass: studentClass,
      studentName: name,
    );
    state = updated;
    await LocalStorageService.instance.saveStudentProfile(updated);
    ref.read(gradeTierProvider.notifier).setTier(updated.tier);
  }
}

final studentProfileProvider =
    StateNotifierProvider<StudentProfileNotifier, StudentProfile>((ref) {
  return StudentProfileNotifier(ref);
});
