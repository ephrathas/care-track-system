import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/message_thread_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/dashboard/dashboard_tab_scaffold.dart';
import 'message_thread_tile.dart';

class MessagesInbox extends StatelessWidget {
  final String title;
  final bool showStartConversation;

  const MessagesInbox({
    super.key,
    required this.title,
    this.showStartConversation = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messaging = context.watch<MessagingProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return DashboardTabScaffold(
      title: title,
      body: messaging.isLoading
          ? const Center(child: CircularProgressIndicator())
          : messaging.threads.isEmpty
              ? _EmptyInbox(
                  isDark: isDark,
                  showStartConversation: showStartConversation,
                  onStart: user == null
                      ? null
                      : () async {
                          final thread = await context
                              .read<MessagingProvider>()
                              .ensureParentTeacherThread(
                                parentId: user.uid,
                                parentName: user.fullName,
                              );
                          if (!context.mounted || thread == null) return;
                          AppRoutes.push(
                            context,
                            AppRoutes.chat,
                            arguments: thread,
                          );
                        },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
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
  final VoidCallback? onStart;

  const _EmptyInbox({
    required this.isDark,
    required this.showStartConversation,
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
              showStartConversation
                  ? 'Start a secure chat with your child\'s teacher.'
                  : 'When parents message you, conversations appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : AppTheme.textSecondary),
            ),
            if (showStartConversation && onStart != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.chat_rounded),
                label: const Text('Message Teacher'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
