import 'staff_profile_models.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final String? profilePic;
  final String? schoolId;
  final String? phone;
  final TeacherProfile? teacherProfile;
  final HealthcareProfile? healthcareProfile;
  final String? linkedStudentId;
  final bool mustChangePassword;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePic,
    this.schoolId,
    this.phone,
    this.teacherProfile,
    this.healthcareProfile,
    this.linkedStudentId,
    this.mustChangePassword = false,
  });

  UserModel copyWith({
    String? fullName,
    String? role,
    String? profilePic,
    String? schoolId,
    String? phone,
    TeacherProfile? teacherProfile,
    HealthcareProfile? healthcareProfile,
    String? linkedStudentId,
    bool? mustChangePassword,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
      schoolId: schoolId ?? this.schoolId,
      phone: phone ?? this.phone,
      teacherProfile: teacherProfile ?? this.teacherProfile,
      healthcareProfile: healthcareProfile ?? this.healthcareProfile,
      linkedStudentId: linkedStudentId ?? this.linkedStudentId,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

  bool get hasProfilePhoto => profilePic != null && profilePic!.isNotEmpty;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'Parent',
      profilePic: map['profilePic'],
      schoolId: map['schoolId'] as String?,
      phone: map['phone'] as String?,
      teacherProfile: TeacherProfile.fromMap(
        map['teacherProfile'] as Map<String, dynamic>?,
      ),
      healthcareProfile: HealthcareProfile.fromMap(
        map['healthcareProfile'] as Map<String, dynamic>?,
      ),
      linkedStudentId: map['linkedStudentId'] as String?,
      mustChangePassword: map['mustChangePassword'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      if (profilePic != null) 'profilePic': profilePic,
      if (schoolId != null) 'schoolId': schoolId,
      if (phone != null) 'phone': phone,
      if (teacherProfile != null) 'teacherProfile': teacherProfile!.toMap(),
      if (healthcareProfile != null)
        'healthcareProfile': healthcareProfile!.toMap(),
      if (linkedStudentId != null) 'linkedStudentId': linkedStudentId,
      'mustChangePassword': mustChangePassword,
    };
  }
}
