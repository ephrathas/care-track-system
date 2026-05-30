class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // Parent, Teacher, Child, or Healthcare
  final String? profilePic;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePic,
  });

  UserModel copyWith({
    String? fullName,
    String? role,
    String? profilePic,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  bool get hasProfilePhoto => profilePic != null && profilePic!.isNotEmpty;

  // Convert Firebase Data to Dart Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'Parent',
      profilePic: map['profilePic'],
    );
  }

  // Convert Dart Object to Firebase Data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'profilePic': profilePic,
    };
  }
}
