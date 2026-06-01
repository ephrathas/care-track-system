import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/firestore/firestore_school_structure_repository.dart';
import '../data/firestore/firestore_student_repository.dart';
import '../models/class_room_model.dart';
import '../models/class_subject_model.dart';
import '../models/grade_level_model.dart';
import '../models/subject_model.dart';
import '../models/student_model.dart';
import '../models/teacher_teaching_slot.dart';
import 'school_admin_provider.dart';

class TeacherOverviewProvider with ChangeNotifier {
  final FirestoreSchoolStructureRepository _structure;
  final FirestoreStudentRepository _students;

  TeacherOverviewProvider({
    FirestoreSchoolStructureRepository? structure,
    FirestoreStudentRepository? students,
  })  : _structure = structure ?? FirestoreSchoolStructureRepository(),
        _students = students ?? FirestoreStudentRepository();

  List<ClassSubjectModel> _rawAssignments = [];
  List<TeacherTeachingSlot> slots = [];
  int rosterCount = 0;
  bool isLoading = true;
  String? error;

  StreamSubscription<List<ClassSubjectModel>>? _assignmentsSub;
  StreamSubscription<List<StudentModel>>? _rosterSub;
  SchoolAdminProvider? _school;
  VoidCallback? _schoolListener;

  String get badgeText {
    if (slots.isEmpty) {
      return 'No class assignments yet — ask admin to link you';
    }
    if (slots.length == 1) {
      final s = slots.first;
      return '${s.gradeName} · ${s.className}';
    }
    return '${slots.length} teaching slots · $rosterCount students';
  }

  void startListening({
    required String teacherId,
    required SchoolAdminProvider school,
  }) {
    stopListening();
    _school = school;
    isLoading = true;
    error = null;
    notifyListeners();

    _schoolListener = _resolveSlots;
    school.addListener(_schoolListener!);

    _assignmentsSub = _structure.watchTeacherAssignments(teacherId).listen(
      (list) {
        _rawAssignments = list;
        isLoading = false;
        _resolveSlots();
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );

    _rosterSub = _students.watchStudentsForTeacher(teacherId).listen(
      (students) {
        rosterCount = students.length;
        notifyListeners();
      },
    );
  }

  void _resolveSlots() {
    final school = _school;
    if (school == null) return;

    final resolved = <TeacherTeachingSlot>[];
    for (final assignment in _rawAssignments) {
      final classRoom = _findClass(school.classes, assignment.classRoomId);
      if (classRoom == null) continue;

      final subject = _findSubject(school.subjects, assignment.subjectId);
      final grade = _findGrade(school.grades, classRoom.gradeLevelId);
      final subjectName = subject?.name ?? 'Subject';
      final accent = _accentForSubject(subjectName);

      resolved.add(
        TeacherTeachingSlot(
          subjectName: subjectName,
          className: classRoom.name,
          gradeName: grade?.name ?? 'Grade',
          classRoomId: classRoom.id,
          subjectId: assignment.subjectId,
          icon: _iconForSubject(subjectName),
          accentColor: accent,
        ),
      );
    }

    resolved.sort((a, b) => a.gradeName.compareTo(b.gradeName));
    slots = resolved;
  }

  ClassRoomModel? _findClass(List<ClassRoomModel> list, String id) {
    for (final c in list) {
      if (c.id == id) return c;
    }
    return null;
  }

  SubjectModel? _findSubject(List<SubjectModel> list, String id) {
    for (final s in list) {
      if (s.id == id) return s;
    }
    return null;
  }

  GradeLevelModel? _findGrade(List<GradeLevelModel> list, String id) {
    for (final g in list) {
      if (g.id == id) return g;
    }
    return null;
  }

  static IconData _iconForSubject(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return Icons.calculate_rounded;
    if (n.contains('english')) return Icons.menu_book_rounded;
    if (n.contains('science')) return Icons.biotech_rounded;
    if (n.contains('art') || n.contains('music')) return Icons.palette_rounded;
    if (n.contains('physical') || n.contains('sport')) {
      return Icons.sports_soccer_rounded;
    }
    return Icons.menu_book_rounded;
  }

  static Color _accentForSubject(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return const Color(0xFF4A90E2);
    if (n.contains('english')) return const Color(0xFF7ED321);
    if (n.contains('science')) return const Color(0xFF9013FE);
    if (n.contains('art') || n.contains('music')) return const Color(0xFFE2894A);
    return const Color(0xFF4A90E2);
  }

  void stopListening() {
    _assignmentsSub?.cancel();
    _assignmentsSub = null;
    _rosterSub?.cancel();
    _rosterSub = null;
    if (_schoolListener != null && _school != null) {
      _school!.removeListener(_schoolListener!);
    }
    _schoolListener = null;
    _school = null;
    _rawAssignments = [];
    slots = [];
    rosterCount = 0;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
