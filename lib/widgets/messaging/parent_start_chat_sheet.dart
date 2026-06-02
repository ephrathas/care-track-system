import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/messaging_provider.dart';

/// Parent picks child → teacher assigned to that class → opens chat.
class ParentStartChatSheet extends StatefulWidget {
  const ParentStartChatSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ParentStartChatSheet(),
    );
  }

  @override
  State<ParentStartChatSheet> createState() => _ParentStartChatSheetState();
}

class _ParentStartChatSheetState extends State<ParentStartChatSheet> {
  ChildModel? _child;
  UserModel? _teacher;
  List<UserModel> _teachers = [];
  bool _loadingTeachers = false;
  bool _starting = false;

  Future<void> _loadTeachers(ChildModel child) async {
    setState(() {
      _child = child;
      _teacher = null;
      _loadingTeachers = true;
      _teachers = [];
    });
    final list = await context.read<MessagingProvider>().teachersForChild(child);
    if (!mounted) return;
    setState(() {
      _teachers = list;
      _loadingTeachers = false;
    });
  }

  Future<void> _start() async {
    final user = context.read<AuthProvider>().currentUser;
    final child = _child;
    final teacher = _teacher;
    if (user == null || child == null || teacher == null) return;

    setState(() => _starting = true);
    final thread = await context.read<MessagingProvider>().ensureThread(
          parentId: user.uid,
          parentName: user.fullName,
          teacher: teacher,
          child: child,
        );
    if (!mounted) return;
    setState(() => _starting = false);

    if (thread == null) {
      final err = context.read<MessagingProvider>().errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
      return;
    }

    Navigator.pop(context);
    AppRoutes.push(context, AppRoutes.chat, arguments: thread);
  }

  @override
  Widget build(BuildContext context) {
    final children = context.watch<ChildProvider>().children;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message a teacher',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Only teachers assigned to your child\'s class can be messaged.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (children.isEmpty)
            const Text('Add a child profile first.')
          else ...[
            DropdownButtonFormField<ChildModel>(
              value: _child,
              decoration: const InputDecoration(
                labelText: 'Your child',
                border: OutlineInputBorder(),
              ),
              items: children
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) {
                if (c != null) _loadTeachers(c);
              },
            ),
            const SizedBox(height: 12),
            if (_child != null && _child!.classRoomId == null)
              Text(
                'Enroll ${_child!.name} in a grade before messaging.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
              )
            else if (_loadingTeachers)
              const LinearProgressIndicator(minHeight: 2)
            else if (_child != null && _teachers.isEmpty)
              const Text(
                'No teachers assigned to this class yet. Ask the school admin.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              )
            else if (_teachers.isNotEmpty)
              DropdownButtonFormField<UserModel>(
                value: _teacher,
                decoration: const InputDecoration(
                  labelText: 'Teacher',
                  border: OutlineInputBorder(),
                ),
                items: _teachers
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.fullName)))
                    .toList(),
                onChanged: (t) => setState(() => _teacher = t),
              ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _starting || _teacher == null ? null : _start,
              child: _starting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Open conversation'),
            ),
          ),
        ],
      ),
    );
  }
}
