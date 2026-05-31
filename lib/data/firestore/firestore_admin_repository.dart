import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/school_config.dart';
import '../../core/domain/domain_enums.dart';
import '../../models/school_model.dart';
import '../repositories/user_repository.dart';
import 'firestore_helpers.dart';
import 'firestore_user_repository.dart';

class FirestoreAdminRepository implements AdminRepository {
  final FirebaseFirestore _db;
  final FirestoreUserRepository _users;

  FirestoreAdminRepository({
    FirebaseFirestore? db,
    FirestoreUserRepository? users,
  })  : _db = db ?? FirebaseFirestore.instance,
        _users = users ?? FirestoreUserRepository(db: db);

  @override
  Future<bool> isAdminBootstrapNeeded(String schoolId) async {
    final doc = await _db.collection(FirestoreCollections.schools).doc(schoolId).get();
    return !doc.exists;
  }

  /// True when no school exists and no Admin user is registered yet.
  Future<bool> canClaimFirstAdmin() async {
    final needsBootstrap = await isAdminBootstrapNeeded(SchoolConfig.defaultSchoolId);
    if (!needsBootstrap) return false;
    return !(await _users.hasAnyAdmin());
  }

  @override
  Future<void> bootstrapSchool(SchoolBootstrapRequest request) async {
    final schoolId = SchoolConfig.defaultSchoolId;
    final schoolRef = _db.collection(FirestoreCollections.schools).doc(schoolId);
    final userRef = _db.collection(FirestoreCollections.users).doc(request.adminUid);

    final school = SchoolModel(
      id: schoolId,
      name: request.schoolName,
      type: SchoolType.school,
      isActive: true,
    );

    final batch = _db.batch();
    batch.set(
      schoolRef,
      FirestoreHelpers.withTimestamps(school.toMap(), isCreate: true),
    );
    batch.set(
      userRef,
      {
        'role': 'Admin',
        'schoolId': schoolId,
        'fullName': request.adminFullName,
        'email': request.adminEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  /// First registered user can become Admin when no school is set up yet.
  Future<void> claimFirstAdminAndBootstrap(SchoolBootstrapRequest request) async {
    if (!await canClaimFirstAdmin()) {
      throw StateError('School setup is already complete or an admin exists.');
    }
    await bootstrapSchool(request);
  }
}
