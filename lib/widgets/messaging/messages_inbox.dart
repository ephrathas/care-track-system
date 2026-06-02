import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/dashboard/dashboard_tab_scaffold.dart';
import 'message_thread_tile.dart';
import 'parent_start_chat_sheet.dart';
import 'teacher_compose_sheet.dart';

class MessagesInbox extends StatelessWidget {
  final String title;
  final bool showStartConversation;
  final bool isTeacherInbox;

  const MessagesInbox({
    super.key,
    required this.title,
    this.showStartConversation = false,
    this.isTeacherInbox = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messaging = context.watch<MessagingProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return DashboardTabScaffold(
      title: title,
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (isTeacherInbox) {
                  TeacherComposeSheet.show(context);
                } else if (showStartConversation) {
                  ParentStartChatSheet.show(context);
                }
              },
              icon: const Icon(Icons.edit_rounded),
              label: Text(isTeacherInbox ? 'Message parent' : 'Message teacher'),
            ),
      body: messaging.isLoading
          ? const Center(child: CircularProgressIndicator())
          : messaging.threads.isEmpty
              ? _EmptyInbox(
                  isDark: isDark,
                  showStartConversation: showStartConversation || isTeacherInbox,
                  isTeacher: isTeacherInbox,
                  onStart: user == null
                      ? null
                      : () {
                          if (isTeacherInbox) {
                            TeacherComposeSheet.show(context);
                          } else {
                            ParentStartChatSheet.show(context);
                          }
                        },
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
                  itemCount: messaging.threads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final thread = messaging.threads[index];
                    return MessageThreadTile(
                      thread: thread,
                      isDark: isDark,
                      onTap: () => AppRoutes.push(
                        context,
                        AppRoutes.chat,
                        arguments: thread,
                      ),
                    );
                  },
                ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  final bool isDark;
  final bool showStartConversation;
  final bool isTeacher;
  final VoidCallback? onStart;

  const _EmptyInbox({
    required this.isDark,
    required this.showStartConversation,
    this.isTeacher = false,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: isDark ? Colors.grey[600] : AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isTeacher
                  ? 'Message parents of students in your assigned classes only.'
                  : 'Message teachers assigned to your child\'s class section.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : AppTheme.textSecondary, height: 1.4),
            ),
            if (showStartConversation && onStart != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.chat_rounded),
                label: Text(isTeacher ? 'Message parent' : 'Message teacher'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
