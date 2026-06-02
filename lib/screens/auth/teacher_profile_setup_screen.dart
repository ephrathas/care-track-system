import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/school_config.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_admin_provider.dart';
import '../../widgets/auth/auth_primary_button.dart';

/// One-time teacher setup: preferred grade + subject (admin assigns official slots).
class TeacherProfileSetupScreen extends StatefulWidget {
  const TeacherProfileSetupScreen({super.key});

  @override
  State<TeacherProfileSetupScreen> createState() =>
      _TeacherProfileSetupScreenState();
}

class _TeacherProfileSetupScreenState extends State<TeacherProfileSetupScreen> {
  String? _gradeId;
  String? _subjectId;
  bool _saving = false;

  Future<void> _save() async {
    if (_gradeId == null || _subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select your preferred grade and subject.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'schoolId': user.schoolId ?? SchoolConfig.defaultSchoolId,
        'teacherProfile': {
          if (user.teacherProfile?.employeeId != null)
            'employeeId': user.teacherProfile!.employeeId,
          if (user.teacherProfile?.department != null)
            'department': user.teacherProfile!.department,
          'preferredGradeLevelId': _gradeId,
          'preferredSubjectId': _subjectId,
        },
        'teacherSetupComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await auth.refreshUserProfile();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final school = context.watch<SchoolAdminProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      appBar: AppBar(title: const Text('Teacher profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2894A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Tell the admin what you teach. They will assign you to a specific '
                  'grade section (e.g. Grade 1-A) and subject. One teacher typically '
                  'teaches one subject; you may be assigned to one or more sections.',
                  style: TextStyle(height: 1.45, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _gradeId,
                items: school.grades
                    .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                    .toList(),
                onChanged: school.grades.isEmpty ? null : (v) => setState(() => _gradeId = v),
                decoration: InputDecoration(
                  labelText: 'Preferred grade level',
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _subjectId,
                items: school.subjects
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged:
                    school.subjects.isEmpty ? null : (v) => setState(() => _subjectId = v),
                decoration: InputDecoration(
                  labelText: 'Primary subject',
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              if (school.grades.isEmpty || school.subjects.isEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'School structure not ready. Ask admin to add grades and subjects first.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              AuthPrimaryButton(
                label: _saving ? 'Saving…' : 'Continue to dashboard',
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
