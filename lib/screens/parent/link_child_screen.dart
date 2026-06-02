import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/domain_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../widgets/auth/auth_primary_button.dart';

/// Parent enters a 6-digit code from their child (free plan — no Cloud Functions).
class LinkChildScreen extends StatefulWidget {
  const LinkChildScreen({super.key});

  @override
  State<LinkChildScreen> createState() => _LinkChildScreenState();
}

class _LinkChildScreenState extends State<LinkChildScreen> {
  final _codeController = TextEditingController();
  RelationshipType _relationship = RelationshipType.guardian;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final parentId = context.read<AuthProvider>().currentUser?.uid;
    if (parentId == null) return;

    final name = await context.read<ChildProvider>().claimChildWithLinkCode(
          parentId: parentId,
          code: _codeController.text,
          relationshipType: _relationship,
        );

    if (!mounted) return;
    if (name != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Linked to $name successfully.'),
          backgroundColor: AppTheme.softGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ChildProvider>().errorMessage ?? 'Could not link child.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loading = context.watch<ChildProvider>().isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      appBar: AppBar(title: const Text('Link with code')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If your child registered first, ask them for their 6-digit family link code.',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Link code',
                hintText: '123456',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RelationshipType>(
              value: _relationship,
              items: RelationshipType.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _relationship = v);
              },
              decoration: const InputDecoration(labelText: 'Your relationship'),
            ),
            const Spacer(),
            AuthPrimaryButton(
              label: loading ? 'Linking…' : 'Link child',
              onPressed: loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
