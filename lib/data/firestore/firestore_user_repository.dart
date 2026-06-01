import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/domain/domain_enums.dart';
import '../../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'firestore_helpers.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db;

  FirestoreUserRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestoreCollections.users);

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['uid'] = doc.id;
    return UserModel.fromMap(data);
  }

  @override
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    });
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.uid).set(
          FirestoreHelpers.withTimestamps(user.toMap(), isCreate: false),
          SetOptions(merge: true),
        );
  }

  @override
  Future<List<UserModel>> getUsersByRole(String schoolId, String role) async {
    Query<Map<String, dynamic>> query =
        _users.where('role', isEqualTo: role);
    if (schoolId.isNotEmpty) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();
  }

  Future<bool> hasAnyAdmin() async {
    final snapshot = await _users
        .where('role', isEqualTo: 'Admin')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
