import 'package:flutter/material.dart';

import '../../core/academic/academic_resolver.dart';
import '../../core/theme/app_theme.dart';
import '../../models/class_subject_model.dart';

class GradeTeacherPreviewPanel extends StatelessWidget {
  final GradeEnrollmentPreview? preview;
  final bool isLoading;

  const GradeTeacherPreviewPanel({
    super.key,
    required this.preview,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (preview == null || preview!.teachers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.school_rounded,
                size: 20, color: isDark ? Colors.white70 : AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Teachers for ${preview!.grade.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          preview!.fromCatalogOnly
              ? 'Default assignments from school catalog.'
              : 'Assigned by your school — contact teachers below.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        ...preview!.teachers.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TeacherAssignmentCard(teacher: t, isDark: isDark),
          ),
        ),
      ],
    );
  }
}

class _TeacherAssignmentCard extends StatelessWidget {
  final AssignedTeacherView teacher;
  final bool isDark;

  const _TeacherAssignmentCard({
    required this.teacher,
    required this.isDark,
  });

  IconData _iconForKey(String? key) {
    switch (key) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'translate':
        return Icons.translate_rounded;
      case 'science':
        return Icons.biotech_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'computer':
        return Icons.computer_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _accentForSubject(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return const Color(0xFF4A90D9);
    if (n.contains('english')) return const Color(0xFF9013FE);
    if (n.contains('science')) return const Color(0xFF7ED321);
    if (n.contains('art') || n.contains('music')) return const Color(0xFFE2894A);
    if (n.contains('physical') || n.contains('sport')) return const Color(0xFF50E3C2);
    return AppTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForSubject(teacher.subject.name);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : accent.withOpacity(0.2),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: accent.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: accent.withOpacity(0.15),
              child: Icon(
                _iconForKey(teacher.subjectIconKey),
                color: accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.subject.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    teacher.teacherName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (teacher.teacherEmail != null &&
                      teacher.teacherEmail!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.mail_outline_rounded,
                            size: 14,
                            color: isDark ? Colors.grey[400] : AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            teacher.teacherEmail!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (teacher.isLinked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.softGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Linked',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.softGreen,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
