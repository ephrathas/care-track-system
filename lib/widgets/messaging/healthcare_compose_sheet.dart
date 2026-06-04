import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/healthcare_provider.dart';
import '../../providers/messaging_provider.dart';

/// Doctor picks a parent from assigned patients → opens chat.
class HealthcareComposeSheet extends StatefulWidget {
  const HealthcareComposeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const HealthcareComposeSheet(),
    );
  }

  @override
  State<HealthcareComposeSheet> createState() => _HealthcareComposeSheetState();
}

class _HealthcareComposeSheetState extends State<HealthcareComposeSheet> {
  HealthcareParentContact? _contact;
  List<HealthcareParentContact> _contacts = [];
  bool _loading = true;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final patients = context.read<HealthcareProvider>().patients;
    final contacts =
        await context.read<MessagingProvider>().parentContactsFromPatients(patients);
    if (!mounted) return;
    setState(() {
      _contacts = contacts;
      _loading = false;
    });
  }

  Future<void> _start() async {
    final doctor = context.read<AuthProvider>().currentUser;
    final contact = _contact;
    if (doctor == null || contact == null) return;

    setState(() => _starting = true);
    final thread = await context.read<MessagingProvider>().ensureHealthcareToParentThread(
          doctor: doctor,
          contact: contact,
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message a parent',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Only parents of students assigned to you or with clinic access appear here.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const LinearProgressIndicator(minHeight: 2)
          else if (_contacts.isEmpty)
            const Text(
              'No assigned patients yet. Parents appear after health follow-up and assignment.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            )
          else
            DropdownButtonFormField<HealthcareParentContact>(
              value: _contact,
              decoration: const InputDecoration(
                labelText: 'Parent',
                border: OutlineInputBorder(),
              ),
              items: _contacts
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.parentName} (${c.subtitle})'),
                    ),
                  )
                  .toList(),
              onChanged: (c) => setState(() => _contact = c),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _starting || _contact == null ? null : _start,
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
