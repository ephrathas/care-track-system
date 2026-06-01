import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/config/school_config.dart';
import '../core/domain/domain_enums.dart';
import '../data/firestore/firestore_academic_repository.dart';
import '../data/firestore/firestore_student_repository.dart';
import '../models/academic_models.dart';
import '../models/student_model.dart';

class TeacherAttendanceProvider with ChangeNotifier {
  final FirestoreStudentRepository _students;
  final FirestoreAcademicRepository _academic;

  TeacherAttendanceProvider({
    FirestoreStudentRepository? students,
    FirestoreAcademicRepository? academic,
  })  : _students = students ?? FirestoreStudentRepository(),
        _academic = academic ?? FirestoreAcademicRepository();

  List<StudentModel> roster = [];
  final Map<String, bool> presentByStudentId = {};
  bool isLoading = true;
  bool isSaving = false;
  String? error;

  StreamSubscription<List<StudentModel>>? _rosterSub;
  final List<StreamSubscription<List<AttendanceRecordModel>>> _classSubs = [];

  DateTime get _today => DateTime.now();

  void startListening(String teacherId) {
    stopListening();
    isLoading = true;
    notifyListeners();

    _rosterSub = _students.watchStudentsForTeacher(teacherId).listen(
      (list) async {
        roster = list;
        await _reloadTodayAttendance();
        _resubscribeClassStreams(list);
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void _resubscribeClassStreams(List<StudentModel> list) {
    for (final sub in _classSubs) {
      sub.cancel();
    }
    _classSubs.clear();

    final classIds = list
        .map((s) => s.classRoomId)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet();

    for (final classId in classIds) {
      _classSubs.add(
        _academic.watchAttendanceForClass(classId, _today).listen((_) async {
          await _reloadTodayAttendance();
          notifyListeners();
        }),
      );
    }
  }

  Future<void> _reloadTodayAttendance() async {
    if (roster.isEmpty) {
      presentByStudentId.clear();
      return;
    }
    final statuses = await _academic.fetchAttendanceForStudentsOnDate(
      studentIds: roster.map((s) => s.id).toList(),
      date: _today,
    );
    for (final student in roster) {
      final status = statuses[student.id];
      if (status == null) {
        presentByStudentId.putIfAbsent(student.id, () => true);
      } else {
        presentByStudentId[student.id] = status == AttendanceStatus.present ||
            status == AttendanceStatus.late ||
            status == AttendanceStatus.excused;
      }
    }
  }

  bool isPresent(String studentId) => presentByStudentId[studentId] ?? true;

  Future<void> setPresent({
    required StudentModel student,
    required String teacherId,
    required bool present,
  }) async {
    presentByStudentId[student.id] = present;
    notifyListeners();

    isSaving = true;
    notifyListeners();

    try {
      final classRoomId = student.classRoomId ?? '';
      if (classRoomId.isEmpty) {
        error = 'Student has no class assignment.';
        return;
      }

      await _academic.markAttendance(
        AttendanceRecordModel(
          id: AttendanceRecordModel.compositeId(student.id, _today),
          schoolId: student.schoolId.isNotEmpty
              ? student.schoolId
              : SchoolConfig.defaultSchoolId,
          studentId: student.id,
          classRoomId: classRoomId,
          date: _today,
          status: present ? AttendanceStatus.present : AttendanceStatus.absent,
          markedBy: teacherId,
          markedAt: DateTime.now(),
        ),
      );
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void stopListening() {
    _rosterSub?.cancel();
    _rosterSub = null;
    for (final sub in _classSubs) {
      sub.cancel();
    }
    _classSubs.clear();
    roster = [];
    presentByStudentId.clear();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
