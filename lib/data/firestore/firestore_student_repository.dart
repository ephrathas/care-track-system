import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/school_config.dart';
import '../../core/domain/domain_enums.dart';
import '../../models/enrollment_model.dart';
import '../../models/student_model.dart';
import '../repositories/student_repository.dart';
import 'firestore_helpers.dart';

class FirestoreStudentRepository implements StudentRepository {
  final FirebaseFirestore _db;

  FirestoreStudentRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _children =>
      _db.collection(FirestoreCollections.children);

  CollectionReference<Map<String, dynamic>> get _enrollments =>
      _db.collection(FirestoreCollections.enrollments);

  @override
  Stream<List<StudentModel>> watchStudentsByParent(String parentId) {
    return _children
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StudentModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Stream<StudentModel?> watchStudent(String studentId) {
    return _children.doc(studentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StudentModel.fromMap(doc.data()!, doc.id);
    });
  }

  @override
  Future<String> createStudent(StudentModel student) async {
    final ref = _children.doc(student.id);
    await ref.set(
      FirestoreHelpers.withTimestamps(student.toMap(), isCreate: true),
    );
    return ref.id;
  }

  @override
  Future<void> updateStudent(StudentModel student) async {
    await _children.doc(student.id).update(
          FirestoreHelpers.withTimestamps(student.toMap()),
        );
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    await _children.doc(studentId).delete();
  }

  @override
  Future<EnrollmentModel> enrollStudent({
    required StudentModel student,
    required String classRoomId,
    required String gradeLevelId,
  }) async {
    final enrollmentRef = _enrollments.doc();
    final enrollment = EnrollmentModel(
      id: enrollmentRef.id,
      schoolId: student.schoolId,
      studentId: student.id,
      parentId: student.parentId,
      classRoomId: classRoomId,
      gradeLevelId: gradeLevelId,
      enrolledAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(
      enrollmentRef,
      FirestoreHelpers.withTimestamps(
        {
          ...enrollment.toMap(),
          'enrolledAt': FieldValue.serverTimestamp(),
        },
        isCreate: true,
      ),
    );
    batch.set(
      _children.doc(student.id),
      FirestoreHelpers.withTimestamps(
        {
          ...student.toMap(),
          'activeEnrollmentId': enrollmentRef.id,
          'gradeLevelId': gradeLevelId,
          'classRoomId': classRoomId,
        },
      ),
      SetOptions(merge: true),
    );
    await batch.commit();

    try {
      await _notifyTeachersOfEnrollment(
        schoolId: student.schoolId,
        classRoomId: classRoomId,
        studentName: student.fullName,
        enrollmentId: enrollmentRef.id,
      );
    } catch (_) {
      // Enrollment succeeded; teacher notification is best-effort.
    }

    return enrollment;
  }

  Future<void> _notifyTeachersOfEnrollment({
    required String schoolId,
    required String classRoomId,
    required String studentName,
    required String enrollmentId,
  }) async {
    final assignments = await _db
        .collection(FirestoreCollections.classSubjects)
        .where('classRoomId', isEqualTo: classRoomId)
        .where('isActive', isEqualTo: true)
        .get();

    final notified = <String>{};
    for (final doc in assignments.docs) {
      final teacherId = doc.data()['teacherId'] as String? ?? '';
      if (teacherId.isEmpty || notified.contains(teacherId)) continue;
      notified.add(teacherId);
      await _db.collection(FirestoreCollections.notifications).add({
        'schoolId': schoolId,
        'userId': teacherId,
        'type': 'new_enrollment',
        'title': 'New student enrolled',
        'body': '$studentName joined your class roster.',
        'enrollmentId': enrollmentId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Stream<List<EnrollmentModel>> watchEnrollmentsByClass(String classRoomId) {
    return _enrollments
        .where('classRoomId', isEqualTo: classRoomId)
        .where('status', isEqualTo: EnrollmentStatus.active.id)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EnrollmentModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Stream<List<StudentModel>> watchStudentsForClass(String classRoomId) {
    return _children
        .where('classRoomId', isEqualTo: classRoomId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StudentModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Stream<EnrollmentModel?> watchActiveEnrollment(String studentId) {
    return _enrollments
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: EnrollmentStatus.active.id)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return EnrollmentModel.fromMap(doc.data(), doc.id);
    });
  }

  @override
  Stream<List<StudentModel>> watchStudentsForTeacher(String teacherId) {
    return _db
        .collection(FirestoreCollections.classSubjects)
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncExpand((assignSnap) async* {
      final classIds = assignSnap.docs
          .map((d) => d.data()['classRoomId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      if (classIds.isEmpty) {
        yield <StudentModel>[];
        return;
      }
      final expanded = await _expandClassIdsForSameGrades(classIds);
      yield* _watchMergedRosterForClasses(expanded);
    });
  }

  /// Includes sibling class rooms in the same grade so enrollments still match
  /// when parents use a different room id than the teacher's staffed section.
  Future<List<String>> _expandClassIdsForSameGrades(List<String> classIds) async {
    final expanded = classIds.toSet();
    for (final classId in classIds) {
      final roomDoc =
          await _db.collection(FirestoreCollections.classRooms).doc(classId).get();
      if (!roomDoc.exists) continue;
      final gradeId = roomDoc.data()?['gradeLevelId'] as String? ?? '';
      if (gradeId.isEmpty) continue;
      final siblings = await _db
          .collection(FirestoreCollections.classRooms)
          .where('gradeLevelId', isEqualTo: gradeId)
          .where('isActive', isEqualTo: true)
          .get();
      for (final doc in siblings.docs) {
        expanded.add(doc.id);
      }
    }
    return expanded.toList();
  }

  Stream<List<StudentModel>> _watchMergedRosterForClasses(List<String> classIds) {
    final ids = classIds.toSet().toList();
    if (ids.isEmpty) return Stream.value(const []);

    if (ids.length == 1) {
      return _watchMergedRosterForSingleClass(ids.first);
    }

    final controller = StreamController<List<StudentModel>>.broadcast();
    final latestByClass = <String, List<StudentModel>>{};
    final subs = <StreamSubscription<List<StudentModel>>>[];

    void emitMerged() {
      final byId = <String, StudentModel>{};
      for (final list in latestByClass.values) {
        for (final student in list) {
          byId[student.id] = student;
        }
      }
      final merged = byId.values.toList()
        ..sort(
          (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
      if (!controller.isClosed) controller.add(merged);
    }

    controller.onListen = () {
      for (final classId in ids) {
        subs.add(
          _watchMergedRosterForSingleClass(classId).listen(
            (students) {
              latestByClass[classId] = students;
              emitMerged();
            },
            onError: controller.addError,
          ),
        );
      }
    };

    controller.onCancel = () {
      for (final sub in subs) {
        sub.cancel();
      }
    };

    return controller.stream;
  }

  /// Merges active enrollments + live children in the class (linking account does not remove either).
  Stream<List<StudentModel>> _watchMergedRosterForSingleClass(String classRoomId) {
    final controller = StreamController<List<StudentModel>>.broadcast();
    List<EnrollmentModel> enrollments = const [];
    List<StudentModel> byClassRoom = const [];

    Future<void> emitMerged() async {
      final byId = <String, StudentModel>{};

      for (final student in byClassRoom) {
        byId[student.id] = student;
      }

      for (final enrollment in enrollments) {
        if (byId.containsKey(enrollment.studentId)) continue;
        final doc = await _children.doc(enrollment.studentId).get();
        if (!doc.exists) continue;
        var student = StudentModel.fromMap(doc.data()!, enrollment.studentId);
        if (student.classRoomId == null || student.classRoomId!.isEmpty) {
          student = student.copyWith(
            classRoomId: enrollment.classRoomId,
            gradeLevelId: enrollment.gradeLevelId,
            activeEnrollmentId: enrollment.id,
          );
        }
        byId[student.id] = student;
      }

      final merged = byId.values.toList()
        ..sort(
          (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
      if (!controller.isClosed) controller.add(merged);
    }

    late StreamSubscription<List<EnrollmentModel>> enrollSub;
    late StreamSubscription<List<StudentModel>> childSub;

    controller.onListen = () {
      enrollSub = watchEnrollmentsByClass(classRoomId).listen(
        (value) {
          enrollments = value;
          emitMerged();
        },
        onError: controller.addError,
      );
      childSub = watchStudentsForClass(classRoomId).listen(
        (value) {
          byClassRoom = value;
          emitMerged();
        },
        onError: controller.addError,
      );
    };

    controller.onCancel = () {
      enrollSub.cancel();
      childSub.cancel();
    };

    return controller.stream;
  }

  /// Live roster for one or more class rooms — reads enrolled children directly.
  Stream<List<StudentModel>> _watchStudentsForClassIds(List<String> classIds) {
    final ids = classIds.toSet().toList();
    if (ids.isEmpty) return Stream.value(const []);

    if (ids.length == 1) {
      return watchStudentsForClass(ids.first);
    }

    return _children
        .where('classRoomId', whereIn: ids.length > 10 ? ids.sublist(0, 10) : ids)
        .snapshots()
        .map((snap) {
          final students = snap.docs
              .map((d) => StudentModel.fromMap(d.data(), d.id))
              .toList();
          students.sort(
            (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
          );
          return students;
        });
  }

  @override
  Future<void> linkStudentAccount({
    required String studentId,
    required String studentUserId,
  }) async {
    await _children.doc(studentId).update({
      'studentUserId': studentUserId,
      'accountMode': StudentAccountMode.selfLogin.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
