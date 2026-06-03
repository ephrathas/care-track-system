/// Optional staff profile fields stored on `users/{uid}`.
class TeacherProfile {
  final String? employeeId;
  final String? department;
  final String? preferredGradeLevelId;
  final String? preferredSubjectId;

  const TeacherProfile({
    this.employeeId,
    this.department,
    this.preferredGradeLevelId,
    this.preferredSubjectId,
  });

  factory TeacherProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const TeacherProfile();
    return TeacherProfile(
      employeeId: map['employeeId'] as String?,
      department: map['department'] as String?,
      preferredGradeLevelId: map['preferredGradeLevelId'] as String?,
      preferredSubjectId: map['preferredSubjectId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (employeeId != null) 'employeeId': employeeId,
        if (department != null) 'department': department,
        if (preferredGradeLevelId != null)
          'preferredGradeLevelId': preferredGradeLevelId,
        if (preferredSubjectId != null) 'preferredSubjectId': preferredSubjectId,
      };

  bool get isSetupComplete =>
      preferredGradeLevelId != null &&
      preferredGradeLevelId!.isNotEmpty &&
      preferredSubjectId != null &&
      preferredSubjectId!.isNotEmpty;
}

class HealthcareProfile {
  final String? clinicName;
  final String? licenseId;
  final String? room;
  final List<String> specialtyIds;

  const HealthcareProfile({
    this.clinicName,
    this.licenseId,
    this.room,
    this.specialtyIds = const [],
  });

  factory HealthcareProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const HealthcareProfile();
    return HealthcareProfile(
      clinicName: map['clinicName'] as String?,
      licenseId: map['licenseId'] as String?,
      room: map['room'] as String?,
      specialtyIds: List<String>.from(map['specialtyIds'] ?? []),
    );
  }

  bool coversSpecialty(String specialtyId) =>
      specialtyIds.contains(specialtyId);

  Map<String, dynamic> toMap() => {
        if (clinicName != null) 'clinicName': clinicName,
        if (licenseId != null) 'licenseId': licenseId,
        if (room != null) 'room': room,
        'specialtyIds': specialtyIds,
      };
}
