/// Optional staff profile fields stored on `users/{uid}`.
class TeacherProfile {
  final String? employeeId;
  final String? department;

  const TeacherProfile({this.employeeId, this.department});

  factory TeacherProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const TeacherProfile();
    return TeacherProfile(
      employeeId: map['employeeId'] as String?,
      department: map['department'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (employeeId != null) 'employeeId': employeeId,
        if (department != null) 'department': department,
      };
}

class HealthcareProfile {
  final String? clinicName;
  final String? licenseId;
  final String? room;

  const HealthcareProfile({this.clinicName, this.licenseId, this.room});

  factory HealthcareProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const HealthcareProfile();
    return HealthcareProfile(
      clinicName: map['clinicName'] as String?,
      licenseId: map['licenseId'] as String?,
      room: map['room'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (clinicName != null) 'clinicName': clinicName,
        if (licenseId != null) 'licenseId': licenseId,
        if (room != null) 'room': room,
      };
}
