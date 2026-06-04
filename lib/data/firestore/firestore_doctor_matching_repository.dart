import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/school_config.dart';
import '../../core/domain/domain_enums.dart';
import '../../core/health/health_concerns.dart';
import '../../models/doctor_matching_models.dart';
import '../../models/user_model.dart';
import 'firestore_helpers.dart';

class FirestoreDoctorMatchingRepository {
  final FirebaseFirestore _db;

  FirestoreDoctorMatchingRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<MatchedDoctor>> findDoctorsForSpecialty({
    required String schoolId,
    required String specialtyId,
  }) async {
    final snap = await _db
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: 'Healthcare')
        .where('schoolId', isEqualTo: schoolId)
        .get();

    final doctors = <MatchedDoctor>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final profile = data['healthcareProfile'] as Map<String, dynamic>?;
      final ids = List<String>.from(profile?['specialtyIds'] ?? []);
      if (!ids.contains(specialtyId)) continue;
      doctors.add(
        MatchedDoctor(
          doctorId: doc.id,
          fullName: data['fullName'] as String? ?? 'Doctor',
          email: data['email'] as String? ?? '',
          specialtyIds: ids,
          clinicName: profile?['clinicName'] as String?,
        ),
      );
    }
    doctors.sort((a, b) => a.fullName.compareTo(b.fullName));
    return doctors;
  }

  Future<DoctorMatchRequest?> findPendingRequest({
    required String studentId,
    required String specialtyId,
  }) async {
    final snap = await _db
        .collection(FirestoreCollections.doctorMatchRequests)
        .where('studentId', isEqualTo: studentId)
        .where('specialtyId', isEqualTo: specialtyId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return DoctorMatchRequest.fromMap(doc.data(), doc.id);
  }

  Future<String> createMatchRequest({
    required String schoolId,
    required String parentId,
    required String studentId,
    required String studentName,
    required String specialtyId,
    String? parentNote,
  }) async {
    final existing = await findPendingRequest(
      studentId: studentId,
      specialtyId: specialtyId,
    );
    if (existing != null) return existing.id;

    final label = HealthConcerns.byId(specialtyId)?.label ?? specialtyId;
    final ref = await _db.collection(FirestoreCollections.doctorMatchRequests).add(
      FirestoreHelpers.withTimestamps(
        {
          'schoolId': schoolId,
          'parentId': parentId,
          'studentId': studentId,
          'studentName': studentName,
          'specialtyId': specialtyId,
          'specialtyLabel': label,
          'status': 'pending',
          if (parentNote != null && parentNote.isNotEmpty) 'parentNote': parentNote,
        },
        isCreate: true,
      ),
    );
    return ref.id;
  }

  Future<void> notifyAdminsOfDoctorRequest({
    required String schoolId,
    required String studentName,
    required String specialtyLabel,
    required String requestId,
    required String parentId,
  }) async {
    final admins = await _db
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: 'Admin')
        .get();

    for (final doc in admins.docs) {
      final data = doc.data();
      final adminSchool = data['schoolId'] as String?;
      if (adminSchool != null &&
          adminSchool.isNotEmpty &&
          adminSchool != schoolId) {
        continue;
      }
      await _db.collection(FirestoreCollections.notifications).add({
        'recipientId': doc.id,
        'recipientRole': 'Admin',
        'type': NotificationType.doctorMatchRequest.id,
        'title': 'Doctor needed for student',
        'body':
            'No $specialtyLabel doctor is available for $studentName. Please add or assign a healthcare professional.',
        'relatedStudentId': requestId,
        'relatedEntityId': parentId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> notifyParentDoctorAvailable({
    required String parentId,
    required String studentName,
    required String specialtyLabel,
    required String studentId,
  }) async {
    await _db.collection(FirestoreCollections.notifications).add({
      'recipientId': parentId,
      'recipientRole': 'Parent',
      'type': NotificationType.doctorAvailable.id,
      'title': 'Doctor now available',
      'body':
          'A $specialtyLabel professional is available for $studentName. Open the Health tab to assign them.',
      'relatedStudentId': studentId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> fulfillPendingRequestsForSpecialty({
    required String schoolId,
    required String specialtyId,
  }) async {
    final snap = await _db
        .collection(FirestoreCollections.doctorMatchRequests)
        .where('schoolId', isEqualTo: schoolId)
        .where('specialtyId', isEqualTo: specialtyId)
        .where('status', isEqualTo: 'pending')
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        'status': 'fulfilled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final data = doc.data();
      await notifyParentDoctorAvailable(
        parentId: data['parentId'] as String? ?? '',
        studentName: data['studentName'] as String? ?? 'your child',
        specialtyLabel: data['specialtyLabel'] as String? ?? specialtyId,
        studentId: data['studentId'] as String? ?? '',
      );
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }

  Stream<List<DoctorMatchRequest>> watchPendingRequestsForSchool(String schoolId) {
    return _db
        .collection(FirestoreCollections.doctorMatchRequests)
        .where('schoolId', isEqualTo: schoolId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => DoctorMatchRequest.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
          return list;
        });
  }

  Stream<List<StudentDoctorAssignment>> watchAssignmentsForStudent(String studentId) {
    return _db
        .collection(FirestoreCollections.studentDoctorAssignments)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StudentDoctorAssignment.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<DoctorMatchRequest>> watchPendingRequestsForStudent(String studentId) {
    return _db
        .collection(FirestoreCollections.doctorMatchRequests)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DoctorMatchRequest.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<String>> watchAssignedStudentIdsForDoctor(String doctorId) {
    return _db
        .collection(FirestoreCollections.studentDoctorAssignments)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
          final ids = <String>[];
          for (final doc in snap.docs) {
            final sid = doc.data()['studentId'] as String? ?? '';
            if (sid.isNotEmpty) ids.add(sid);
          }
          return ids;
        });
  }

  Future<void> notifyDoctorOfPatientAssignment({
    required String doctorId,
    required String studentName,
    required String specialtyLabel,
    required String studentId,
  }) async {
    await _db.collection(FirestoreCollections.notifications).add({
      'recipientId': doctorId,
      'recipientRole': 'Healthcare',
      'type': NotificationType.doctorPatientAssigned.id,
      'title': 'New patient assigned',
      'body':
          '$studentName needs $specialtyLabel follow-up. Open Pediatric Directory to review their profile.',
      'relatedStudentId': studentId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> assignDoctor({
    required String schoolId,
    required String parentId,
    required String studentId,
    required MatchedDoctor doctor,
    required String specialtyId,
  }) async {
    final label = HealthConcerns.byId(specialtyId)?.label ?? specialtyId;
    final ref = await _db.collection(FirestoreCollections.studentDoctorAssignments).add(
      FirestoreHelpers.withTimestamps(
        {
          ...StudentDoctorAssignment(
            id: '',
            schoolId: schoolId,
            studentId: studentId,
            parentId: parentId,
            doctorId: doctor.doctorId,
            doctorName: doctor.fullName,
            specialtyId: specialtyId,
            specialtyLabel: label,
            assignedAt: DateTime.now(),
          ).toMap(),
          'assignedAt': FieldValue.serverTimestamp(),
        },
        isCreate: true,
      ),
    );

    await _db.collection(FirestoreCollections.children).doc(studentId).set(
      {
        'assignedDoctorId': doctor.doctorId,
        'healthModuleEnabled': true,
      },
      SetOptions(merge: true),
    );

    final accessRef =
        _db.collection(FirestoreCollections.healthcareAccess).doc(studentId);
    final existingAccess = await accessRef.get();
    final allowed = existingAccess.exists
        ? List<String>.from(
            existingAccess.data()?['allowedProfessionalIds'] ?? [],
          )
        : <String>[];
    if (!allowed.contains(doctor.doctorId)) {
      allowed.add(doctor.doctorId);
    }
    await accessRef.set(
      FirestoreHelpers.withTimestamps(
        {
          'studentId': studentId,
          'parentId': parentId,
          'granted': true,
          'grantedAt': FieldValue.serverTimestamp(),
          'allowedProfessionalIds': allowed,
        },
        isCreate: true,
      ),
      SetOptions(merge: true),
    );

    final childDoc =
        await _db.collection(FirestoreCollections.children).doc(studentId).get();
    final childData = childDoc.data();
    final studentName = childData?['fullName'] as String? ??
        childData?['name'] as String? ??
        'Student';

    await notifyDoctorOfPatientAssignment(
      doctorId: doctor.doctorId,
      studentName: studentName,
      specialtyLabel: label,
      studentId: studentId,
    );

    final parentUser = await getUser(parentId);
    final studentUserId = childData?['studentUserId'] as String? ?? '';
    await _ensureHealthcareCommunicationThreads(
      parentId: parentId,
      parentName: parentUser?.fullName ?? 'Parent',
      studentId: studentId,
      studentName: studentName,
      studentUserId: studentUserId.isEmpty ? null : studentUserId,
      doctor: doctor,
      specialtyLabel: label,
    );

    final pending = await findPendingRequest(
      studentId: studentId,
      specialtyId: specialtyId,
    );
    if (pending != null) {
      await _db.collection(FirestoreCollections.doctorMatchRequests).doc(pending.id).update({
        'status': 'fulfilled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return ref.id;
  }

  Future<void> updateHealthcareSpecialties({
    required String doctorUserId,
    required List<String> specialtyIds,
    String schoolId = SchoolConfig.defaultSchoolId,
  }) async {
    await _db.collection(FirestoreCollections.users).doc(doctorUserId).set(
      {
        'schoolId': schoolId,
        'healthcareProfile': {
          'specialtyIds': specialtyIds,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    for (final specialtyId in specialtyIds) {
      await fulfillPendingRequestsForSpecialty(
        schoolId: schoolId,
        specialtyId: specialtyId,
      );
    }
  }

  Future<List<UserModel>> listHealthcareStaff(String schoolId) async {
    final snap = await _db
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: 'Healthcare')
        .where('schoolId', isEqualTo: schoolId)
        .get();
    return snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['uid'] = doc.id;
    return UserModel.fromMap(data);
  }

  Future<void> _ensureHealthcareCommunicationThreads({
    required String parentId,
    required String parentName,
    required String studentId,
    required String studentName,
    required String? studentUserId,
    required MatchedDoctor doctor,
    required String specialtyLabel,
  }) async {
    await _ensureThreadIfMissing(
      parentId: parentId,
      parentName: parentName,
      doctor: doctor,
      studentId: studentId,
      studentName: studentName,
      threadType: 'healthcare',
      lastMessage: 'Health follow-up started ($specialtyLabel)',
    );

    if (studentUserId != null && studentUserId.isNotEmpty) {
      await _ensureThreadIfMissing(
        parentId: studentUserId,
        parentName: studentName,
        doctor: doctor,
        studentId: studentId,
        studentName: studentName,
        threadType: 'healthcare_student',
        lastMessage: 'Your school doctor is available for $specialtyLabel follow-up.',
      );
    }
  }

  Future<void> _ensureThreadIfMissing({
    required String parentId,
    required String parentName,
    required MatchedDoctor doctor,
    required String studentId,
    required String studentName,
    required String threadType,
    required String lastMessage,
  }) async {
    final existing = await _db
        .collection(FirestoreCollections.messageThreads)
        .where('parentId', isEqualTo: parentId)
        .where('teacherId', isEqualTo: doctor.doctorId)
        .where('studentId', isEqualTo: studentId)
        .where('threadType', isEqualTo: threadType)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    await _db.collection(FirestoreCollections.messageThreads).add(
      FirestoreHelpers.withTimestamps(
        {
          'parentId': parentId,
          'teacherId': doctor.doctorId,
          'parentName': parentName,
          'teacherName': doctor.fullName,
          'lastMessage': lastMessage,
          'lastMessageAt': DateTime.now().toIso8601String(),
          'studentId': studentId,
          'studentName': studentName,
          'threadType': threadType,
          'unreadByParent': true,
          'unreadByTeacher': false,
        },
        isCreate: true,
      ),
    );
  }
}
