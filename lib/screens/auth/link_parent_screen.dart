import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/domain/domain_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_primary_button.dart';

/// After student profile setup — show family link code (no Cloud Functions).
class LinkParentScreen extends StatelessWidget {
  const LinkParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final studentId = user?.linkedStudentId;

    if (studentId == null || studentId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Connect parent')),
        body: const Center(child: Text('Complete your student profile first.')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      appBar: AppBar(title: const Text('Connect a parent')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection(FirestoreCollections.children)
            .doc(studentId)
            .get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final linkCode = snap.data?.data()?['linkCode'] as String? ?? '------';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share this code with your parent',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your parent creates a Parent account in the app, then taps '
                  '"Link with code" and enters this number.',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    linkCode,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: linkCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy code'),
                ),
                const Spacer(),
                AuthPrimaryButton(
                  label: 'Continue to my dashboard',
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
