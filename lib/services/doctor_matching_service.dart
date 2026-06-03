import '../core/config/school_config.dart';
import '../core/health/health_concerns.dart';
import '../data/firestore/firestore_doctor_matching_repository.dart';

/// Matches students to school doctors by health concern, or escalates to admin.
class DoctorMatchingService {
  final FirestoreDoctorMatchingRepository _repo;

  DoctorMatchingService({FirestoreDoctorMatchingRepository? repo})
      : _repo = repo ?? FirestoreDoctorMatchingRepository();

  Future<void> processConcernsForStudent({
    required String schoolId,
    required String parentId,
    required String studentId,
    required String studentName,
    required List<String> concernIds,
    required bool usesPrivateDoctor,
  }) async {
    if (usesPrivateDoctor || concernIds.isEmpty) return;

    final unique = concernIds.toSet().where((id) => id.isNotEmpty).toList();

    for (final specialtyId in unique) {
      if (specialtyId == HealthConcerns.none) continue;

      final doctors = await _repo.findDoctorsForSpecialty(
        schoolId: schoolId,
        specialtyId: specialtyId,
      );

      if (doctors.isNotEmpty) {
        await _repo.notifyParentDoctorAvailable(
          parentId: parentId,
          studentName: studentName,
          specialtyLabel: HealthConcerns.byId(specialtyId)?.label ?? specialtyId,
          studentId: studentId,
        );
        continue;
      }

      final requestId = await _repo.createMatchRequest(
        schoolId: schoolId,
        parentId: parentId,
        studentId: studentId,
        studentName: studentName,
        specialtyId: specialtyId,
      );

      await _repo.notifyAdminsOfDoctorRequest(
        schoolId: schoolId,
        studentName: studentName,
        specialtyLabel: HealthConcerns.byId(specialtyId)?.label ?? specialtyId,
        requestId: requestId,
        parentId: parentId,
      );
    }
  }
}
