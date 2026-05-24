import 'package:flutter/material.dart';

class RoleOptions {
  RoleOptions._();

  static const List<Map<String, dynamic>> all = [
    {
      'title': 'Parent',
      'subtitle':
          "Track your child's health, growth, vaccination status, and explore the shop.",
      'icon': Icons.family_restroom_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Teacher',
      'subtitle':
          'Manage daily class attendance, assign classroom tasks, and submit academic progress.',
      'icon': Icons.school_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFF7ED321), Color(0xFF5CA216)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Healthcare',
      'subtitle':
          'Manage professional pediatric medical records, book appointments, and issue reports.',
      'icon': Icons.medical_services_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFFE2894A), Color(0xFFBD7135)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Child',
      'subtitle':
          'Engage in custom educational tasks, complete homework, and earn gamified badges.',
      'icon': Icons.child_care_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFF9013FE), Color(0xFF700CB5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];
}
