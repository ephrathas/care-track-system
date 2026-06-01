import 'package:flutter/material.dart';

/// One class + subject the teacher is assigned to teach.
class TeacherTeachingSlot {
  final String subjectName;
  final String className;
  final String gradeName;
  final String classRoomId;
  final IconData icon;
  final Color accentColor;

  const TeacherTeachingSlot({
    required this.subjectName,
    required this.className,
    required this.gradeName,
    required this.classRoomId,
    this.icon = Icons.menu_book_rounded,
    this.accentColor = const Color(0xFF4A90E2),
  });

  String get displayLabel => '$subjectName · $gradeName';
}
