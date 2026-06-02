import 'package:cloud_functions/cloud_functions.dart';

import '../core/domain/domain_enums.dart';

/// Result when a parent provisions a student login (Scenario 1).
class CreateStudentAccountResult {
  final String studentId;
  final String studentUserId;
  final String studentEmail;
  final String temporaryPassword;

  const CreateStudentAccountResult({
    required this.studentId,
    required this.studentUserId,
    required this.studentEmail,
    required this.temporaryPassword,
  });

  factory CreateStudentAccountResult.fromMap(Map<String, dynamic> map) {
    return CreateStudentAccountResult(
      studentId: map['studentId'] as String? ?? '',
      studentUserId: map['studentUserId'] as String? ?? '',
      studentEmail: map['studentEmail'] as String? ?? '',
      temporaryPassword: map['temporaryPassword'] as String? ?? '',
    );
  }
}

/// Result when a student provisions a parent login (Scenario 2).
class CreateParentForStudentResult {
  final String parentId;
  final String parentEmail;
  final String temporaryPassword;

  const CreateParentForStudentResult({
    required this.parentId,
    required this.parentEmail,
    required this.temporaryPassword,
  });

  factory CreateParentForStudentResult.fromMap(Map<String, dynamic> map) {
    return CreateParentForStudentResult(
      parentId: map['parentId'] as String? ?? '',
      parentEmail: map['parentEmail'] as String? ?? '',
      temporaryPassword: map['temporaryPassword'] as String? ?? '',
    );
  }
}

/// Callable Cloud Functions for parent/student account linking.
class FamilyAccountService {
  final FirebaseFunctions _functions;

  FamilyAccountService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<CreateStudentAccountResult> createStudentAccount({
    required String fullName,
    required String studentEmail,
    String? dateOfBirthIso,
    String? gender,
    String? gradeLevelId,
    String? classRoomId,
    String schoolId = '',
    RelationshipType relationshipType = RelationshipType.guardian,
    List<String> vaccinations = const [],
  }) async {
    final callable = _functions.httpsCallable('createStudentAccount');
    final result = await callable.call<Map<String, dynamic>>({
      'fullName': fullName,
      'studentEmail': studentEmail.trim().toLowerCase(),
      if (dateOfBirthIso != null) 'dateOfBirth': dateOfBirthIso,
      if (gender != null) 'gender': gender,
      if (gradeLevelId != null) 'gradeLevelId': gradeLevelId,
      if (classRoomId != null) 'classRoomId': classRoomId,
      if (schoolId.isNotEmpty) 'schoolId': schoolId,
      'relationshipType': relationshipType.id,
      'vaccinations': vaccinations,
    });
    return CreateStudentAccountResult.fromMap(
      Map<String, dynamic>.from(result.data as Map),
    );
  }

  Future<CreateParentForStudentResult> createParentForStudent({
    required String parentName,
    required String parentEmail,
    RelationshipType relationshipType = RelationshipType.guardian,
  }) async {
    final callable = _functions.httpsCallable('createParentForStudent');
    final result = await callable.call<Map<String, dynamic>>({
      'parentName': parentName.trim(),
      'parentEmail': parentEmail.trim().toLowerCase(),
      'relationshipType': relationshipType.id,
    });
    return CreateParentForStudentResult.fromMap(
      Map<String, dynamic>.from(result.data as Map),
    );
  }
}
