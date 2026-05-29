import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Bottom sheet for teachers to enter grades for a homework assignment.
class GradeEntrySheet extends StatefulWidget {
  final String assignmentTitle;
  final String subject;
  final List<String> students;

  const GradeEntrySheet({
    super.key,
    required this.assignmentTitle,
    required this.subject,
    required this.students,
  });

  static Future<void> show(
    BuildContext context, {
    required String assignmentTitle,
    required String subject,
    List<String>? students,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkSurface
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => GradeEntrySheet(
        assignmentTitle: assignmentTitle,
        subject: subject,
        students: students ??
            const [
              'Emma Watson',
              'Liam Neeson',
              'Olivia Rodrigo',
              'Noah Centineo',
              'Sophia Chen',
            ],
      ),
    );
  }

  @override
  State<GradeEntrySheet> createState() => _GradeEntrySheetState();
}

class _GradeEntrySheetState extends State<GradeEntrySheet> {
  final _scores = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    for (final name in widget.students) {
      _scores[name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _scores.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    var filled = 0;
    for (final entry in _scores.entries) {
      final score = int.tryParse(entry.value.text.trim());
      if (score != null && score >= 0 && score <= 100) filled++;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grades saved for $filled student${filled == 1 ? '' : 's'}.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.softGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit Grades',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.subject} • ${widget.assignmentTitle}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final name = widget.students[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _scores[name],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0–100',
                          isDense: true,
                          filled: true,
                          fillColor: isDark ? AppTheme.darkBackground : const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7ED321),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Save Grades',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
