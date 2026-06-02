import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_branding.dart';
import '../../core/navigation/kidcare_logout.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_admin_provider.dart';
import '../../widgets/settings/appearance_setting.dart';
import 'admin_governance_tab.dart';
import 'admin_management_tabs.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _tab = 0;

  Future<void> _editSchoolName(BuildContext context, SchoolAdminProvider admin) async {
    final controller = TextEditingController(text: admin.school?.name ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('School name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display name',
            hintText: 'e.g. Bisrat Academy',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final saved = await admin.updateSchoolName(controller.text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'School name updated.' : admin.error ?? 'Could not save.'),
      ),
    );
  }

  Future<void> _showStarterCurriculumDialog(BuildContext context, SchoolAdminProvider admin) async {
    var from = 1;
    var to = 5;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Load starter curriculum'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Creates grades with section A and subject slots (no teachers yet). '
                'Skips grades that already exist.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: from,
                      decoration: const InputDecoration(labelText: 'From grade'),
                      items: List.generate(12, (i) => i + 1)
                          .map((n) => DropdownMenuItem(value: n, child: Text('Grade $n')))
                          .toList(),
                      onChanged: (v) => setState(() => from = v ?? 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: to,
                      decoration: const InputDecoration(labelText: 'To grade'),
                      items: List.generate(12, (i) => i + 1)
                          .map((n) => DropdownMenuItem(value: n, child: Text('Grade $n')))
                          .toList(),
                      onChanged: (v) => setState(() => to = v ?? 5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Load')),
          ],
        ),
      ),
    );
    if (result != true || !context.mounted) return;
    if (from > to) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('"From" must be less than or equal to "To".')),
      );
      return;
    }
    final message = await admin.seedGradesRange(fromLevel: from, toLevel: to);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<SchoolAdminProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: ThemeHelpers.pageBackground(context),
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              admin.school?.name ?? 'School Admin',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage grades, sections & staff',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit school name',
            onPressed: () => _editSchoolName(context, admin),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => kidCareLogout(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _OverviewTab(
            schoolName: admin.school?.name,
            userName: user?.fullName,
            onLoadStarter: () => _showStarterCurriculumDialog(context, admin),
            onEditSchoolName: () => _editSchoolName(context, admin),
          ),
          const AdminGradesAndSectionsTab(),
          const AdminSubjectsTab(),
          const AdminTeachersTab(),
          const AdminGovernanceTab(),
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      size: 36, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.fullName ?? 'Admin',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              const AppearanceSetting(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers_rounded),
            label: 'Grades',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Staff',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Admins',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String? schoolName;
  final String? userName;
  final VoidCallback onLoadStarter;
  final VoidCallback onEditSchoolName;

  const _OverviewTab({
    this.schoolName,
    this.userName,
    required this.onLoadStarter,
    required this.onEditSchoolName,
  });

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<SchoolAdminProvider>();
    final sectionCount = admin.classes.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBlue, Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${userName ?? 'Admin'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                schoolName ?? AppBranding.name,
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
              ),
              TextButton.icon(
                onPressed: onEditSchoolName,
                icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.white70),
                label: const Text(
                  'Change school name',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Grades',
                value: '${admin.grades.length}',
                icon: Icons.layers_rounded,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'Sections',
                value: '$sectionCount',
                icon: Icons.class_rounded,
                color: AppTheme.softGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Subjects',
                value: '${admin.subjects.length}',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF9013FE),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'Teachers',
                value: '${admin.teachers.length}',
                icon: Icons.groups_rounded,
                color: const Color(0xFFE2894A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick setup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Grades tab → add unique grade names and sections (A, B…)\n'
                  '2. Subjects tab → add courses (shared across school)\n'
                  '3. Staff tab → assign a teacher to each section + subject\n'
                  '4. Parents can enroll only when all subjects have teachers\n'
                  '5. Admins tab → add other admins if needed',
                  style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onLoadStarter,
                  icon: const Icon(Icons.auto_stories_rounded, size: 20),
                  label: const Text('Load starter curriculum (pick grade range)'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CheckItem(done: admin.grades.isNotEmpty, label: 'At least one grade'),
        _CheckItem(done: sectionCount > 0, label: 'Sections per grade (e.g. 1-A, 1-B)'),
        _CheckItem(done: admin.subjects.isNotEmpty, label: 'Subjects defined'),
        _CheckItem(done: admin.teachers.isNotEmpty, label: 'Teachers linked to school'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final bool done;
  final String label;

  const _CheckItem({required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 20,
            color: done ? AppTheme.softGreen : AppTheme.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
