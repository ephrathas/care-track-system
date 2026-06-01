import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/config/school_config.dart';
import '../data/firestore/firestore_academic_repository.dart';
import '../models/academic_models.dart';
import '../models/teacher_teaching_slot.dart';

class TeacherHomeworkProvider with ChangeNotifier {
  final FirestoreAcademicRepository _academic;

  TeacherHomeworkProvider({FirestoreAcademicRepository? academic})
      : _academic = academic ?? FirestoreAcademicRepository();

  List<AssignmentModel> assignments = [];
  bool isLoading = true;
  String? error;

  StreamSubscription<List<AssignmentModel>>? _sub;

  void startListening(String teacherId) {
    _sub?.cancel();
    isLoading = true;
    error = null;
    notifyListeners();

    _sub = _academic.watchAssignmentsForTeacher(teacherId).listen(
      (list) {
        assignments = list;
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

  Future<bool> publishAssignment({
    required String teacherId,
    required TeacherTeachingSlot slot,
    required String title,
    String? description,
    required DateTime dueAt,
  }) async {
    error = null;
    notifyListeners();
    try {
      await _academic.createAssignment(
        AssignmentModel(
          id: '',
          schoolId: SchoolConfig.defaultSchoolId,
          classRoomId: slot.classRoomId,
          subjectId: slot.subjectId,
          teacherId: teacherId,
          title: title.trim(),
          description: description?.trim().isEmpty == true ? null : description?.trim(),
          dueAt: dueAt,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    assignments = [];
    isLoading = true;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
