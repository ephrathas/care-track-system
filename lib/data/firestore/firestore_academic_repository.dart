import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/domain/domain_enums.dart';
import '../../models/academic_models.dart';
import '../repositories/academic_repository.dart';
import 'firestore_helpers.dart';

class FirestoreAcademicRepository implements AcademicRepository {
  final FirebaseFirestore _db;

  FirestoreAcademicRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _assignments =>
      _db.collection(FirestoreCollections.assignments);

  CollectionReference<Map<String, dynamic>> get _attendance =>
      _db.collection(FirestoreCollections.attendance);

  static DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<void> markAttendance(AttendanceRecordModel record) async {
    final day = _dayStart(record.date);
    final id = record.id.isNotEmpty
        ? record.id
        : AttendanceRecordModel.compositeId(record.studentId, day);
    await _attendance.doc(id).set(
          FirestoreHelpers.withTimestamps(
            {
              ...record.toMap(),
              'date': Timestamp.fromDate(day),
            },
            isCreate: true,
          ),
          SetOptions(merge: true),
        );
  }

  /// Loads today’s attendance for many students (one doc id per student per day).
  Future<Map<String, AttendanceStatus>> fetchAttendanceForStudentsOnDate({
    required List<String> studentIds,
    required DateTime date,
  }) async {
    final day = _dayStart(date);
    final result = <String, AttendanceStatus>{};
    for (final studentId in studentIds) {
      final docId = AttendanceRecordModel.compositeId(studentId, day);
      final doc = await _attendance.doc(docId).get();
      if (!doc.exists) continue;
      final record = AttendanceRecordModel.fromMap(doc.data()!, doc.id);
      result[studentId] = record.status;
    }
    return result;
  }

  /// Live updates for all attendance docs in a class on a given day.
  @override
  Stream<List<AttendanceRecordModel>> watchAttendanceForClass(
    String classRoomId,
    DateTime date,
  ) {
    final day = _dayStart(date);
    return _attendance
        .where('classRoomId', isEqualTo: classRoomId)
        .where('date', isEqualTo: Timestamp.fromDate(day))
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AttendanceRecordModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Stream<List<AssignmentModel>> watchAssignmentsForClass(String classRoomId) {
    return _assignments
        .where('classRoomId', isEqualTo: classRoomId)
        .snapshots()
        .map(_mapAssignments);
  }

  @override
  Stream<List<AssignmentModel>> watchAssignmentsForTeacher(String teacherId) {
    return _assignments
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(_mapAssignments);
  }

  @override
  Stream<List<AssignmentModel>> watchAssignmentsForStudent(String studentId) {
    // Assignments are class-scoped; student view resolves via enrollment in a later phase.
    return Stream.value(const <AssignmentModel>[]);
  }

  List<AssignmentModel> _mapAssignments(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final list = snap.docs
        .map((d) => AssignmentModel.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) {
      final aDue = a.dueAt ?? a.createdAt;
      final bDue = b.dueAt ?? b.createdAt;
      return bDue.compareTo(aDue);
    });
    return list;
  }

  @override
  Future<String> createAssignment(AssignmentModel assignment) async {
    final ref = await _assignments.add(
      FirestoreHelpers.withTimestamps(
        {
          ...assignment.toMap(),
          if (assignment.dueAt != null)
            'dueAt': Timestamp.fromDate(assignment.dueAt!),
          'createdAt': FieldValue.serverTimestamp(),
        },
        isCreate: true,
      ),
    );
    return ref.id;
  }

  @override
  Stream<List<AssessmentModel>> watchPublishedAssessmentsForStudent(
    String studentId,
  ) {
    return _db
        .collection(FirestoreCollections.assessments)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => AssessmentModel.fromMap(d.data(), d.id))
          .where((a) => a.isPublished)
          .toList();
      list.sort((a, b) {
        final aT = a.publishedAt ?? a.createdAt;
        final bT = b.publishedAt ?? b.createdAt;
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  @override
  Stream<List<AssessmentModel>> watchAssessmentsForTeacher(String teacherId) {
    return _db
        .collection(FirestoreCollections.assessments)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AssessmentModel.fromMap(d.data(), d.id)).toList());
  }

  @override
  Future<String> createAssessment(AssessmentModel assessment) async {
    final ref = await _db.collection(FirestoreCollections.assessments).add(
          FirestoreHelpers.withTimestamps(
            {
              ...assessment.toMap(),
              'publishedAt': FieldValue.serverTimestamp(),
            },
            isCreate: true,
          ),
        );
    return ref.id;
  }

  @override
  Future<void> publishAssessment(String assessmentId) async {
    await _db.collection(FirestoreCollections.assessments).doc(assessmentId).update({
      'publishedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
