import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_branding.dart';
import '../../core/navigation/kidcare_logout.dart';
import '../../core/theme/app_theme.dart';
import '../../models/grade_level_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_admin_provider.dart';
import '../../widgets/settings/appearance_setting.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<SchoolAdminProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(admin.school?.name ?? 'School Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => kidCareLogout(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _OverviewTab(schoolName: admin.school?.name, userName: user?.fullName),
          _GradesTab(admin: admin),
          _ClassesTab(admin: admin),
          _SubjectsTab(admin: admin),
          _AssignTeachersTab(admin: admin),
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
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.stacked_bar_chart_outlined), selectedIcon: Icon(Icons.stacked_bar_chart), label: 'Grades'),
          NavigationDestination(icon: Icon(Icons.class_outlined), selectedIcon: Icon(Icons.class_), label: 'Classes'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.link_outlined), selectedIcon: Icon(Icons.link), label: 'Teachers'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String? schoolName;
  final String? userName;

  const _OverviewTab({this.schoolName, this.userName});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<SchoolAdminProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StatCard(
          title: 'Grade levels',
          value: '${admin.grades.length}',
          icon: Icons.stacked_bar_chart_rounded,
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Classes',
          value: '${admin.classes.length}',
          icon: Icons.class_rounded,
          color: AppTheme.softGreen,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Subjects',
          value: '${admin.subjects.length}',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF9013FE),
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Teachers linked',
          value: '${admin.teachers.length}',
          icon: Icons.groups_rounded,
          color: const Color(0xFFE2894A),
        ),
        const SizedBox(height: 24),
        Text(
          'Setup checklist',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (admin.grades.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_stories_rounded, color: AppTheme.primaryBlue),
              title: const Text('Load Grades 1–5 catalog'),
              subtitle: const Text(
                'Seeds grades, subjects, and default teacher assignments. You can still edit everything in the tabs below.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final ok = await admin.seedDefaultCatalog();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Catalog loaded successfully.'
                          : (admin.error ?? 'Catalog could not be loaded.'),
                    ),
                  ),
                );
              },
            ),
          ),
        if (admin.grades.isEmpty) const SizedBox(height: 12),
        _CheckItem(
          done: admin.grades.isNotEmpty,
          label: 'Grades 1–5 (catalog or manual)',
        ),
        _CheckItem(done: admin.classes.isNotEmpty, label: 'Class sections'),
        _CheckItem(done: admin.subjects.isNotEmpty, label: 'Subjects'),
        _CheckItem(
          done: admin.teachers.isNotEmpty,
          label: 'Teachers registered & linked to school',
        ),
        _CheckItem(
          done: admin.teachers.isNotEmpty,
          label: 'Link Firebase teachers to catalog slots (Teachers tab)',
        ),
        const SizedBox(height: 16),
        Text(
          '${AppBranding.name} — one school per app deployment.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _GradesTab extends StatefulWidget {
  final SchoolAdminProvider admin;

  const _GradesTab({required this.admin});

  @override
  State<_GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<_GradesTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final ok = await widget.admin.addGradeLevel(name);
    if (ok && mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'New grade level',
                    hintText: 'Grade 1, Kindergarten…',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _add, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: widget.admin.grades.isEmpty
              ? _EmptyHint(message: 'No grades yet. Add Kindergarten, Grade 1, etc.')
              : ListView.builder(
                  itemCount: widget.admin.grades.length,
                  itemBuilder: (_, i) {
                    final g = widget.admin.grades[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${g.sortOrder}')),
                      title: Text(g.name),
                      subtitle: g.band != null ? Text(g.band!) : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ClassesTab extends StatefulWidget {
  final SchoolAdminProvider admin;

  const _ClassesTab({required this.admin});

  @override
  State<_ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<_ClassesTab> {
  final _nameController = TextEditingController();
  String? _gradeId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_gradeId == null || _nameController.text.trim().isEmpty) return;
    final ok = await widget.admin.addClassRoom(
      name: _nameController.text.trim(),
      gradeLevelId: _gradeId!,
    );
    if (ok && mounted) _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final grades = widget.admin.grades;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _gradeId,
                decoration: const InputDecoration(labelText: 'Grade level'),
                items: grades
                    .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                    .toList(),
                onChanged: grades.isEmpty ? null : (v) => setState(() => _gradeId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Class name',
                        hintText: '4-A, Lions…',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _add, child: const Text('Add')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.admin.classes.isEmpty
              ? _EmptyHint(message: 'Add grade levels first, then create classes.')
              : ListView.builder(
                  itemCount: widget.admin.classes.length,
                  itemBuilder: (_, i) {
                    final c = widget.admin.classes[i];
                    final grade = _gradeName(widget.admin.grades, c.gradeLevelId);
                    return ListTile(
                      leading: const Icon(Icons.class_rounded),
                      title: Text(c.name),
                      subtitle: Text(grade),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SubjectsTab extends StatefulWidget {
  final SchoolAdminProvider admin;

  const _SubjectsTab({required this.admin});

  @override
  State<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<_SubjectsTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final ok = await widget.admin.addSubject(name);
    if (ok && mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Subject name',
                    hintText: 'Mathematics, Science…',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _add, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: widget.admin.subjects.isEmpty
              ? _EmptyHint(message: 'Add subjects your school teaches.')
              : ListView.builder(
                  itemCount: widget.admin.subjects.length,
                  itemBuilder: (_, i) {
                    final s = widget.admin.subjects[i];
                    return ListTile(
                      leading: const Icon(Icons.menu_book_rounded),
                      title: Text(s.name),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AssignTeachersTab extends StatefulWidget {
  final SchoolAdminProvider admin;

  const _AssignTeachersTab({required this.admin});

  @override
  State<_AssignTeachersTab> createState() => _AssignTeachersTabState();
}

class _AssignTeachersTabState extends State<_AssignTeachersTab> {
  String? _classId;
  String? _subjectId;
  String? _teacherId;

  Future<void> _assign() async {
    if (_classId == null || _subjectId == null || _teacherId == null) return;
    final ok = await widget.admin.assignTeacher(
      classRoomId: _classId!,
      subjectId: _subjectId!,
      teacherId: _teacherId!,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher assigned')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = widget.admin;
    final teachers = admin.teachers;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (teachers.isEmpty)
          Column(
            children: [
              const _EmptyHint(
                message:
                    'No teachers linked yet. Register teacher accounts first, '
                    'then tap below to link them to this school.',
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final n = await admin.linkAllTeachersToSchool();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Linked $n teacher(s)')),
                    );
                  }
                },
                child: const Text('Link registered teachers'),
              ),
            ],
          )
        else ...[
          DropdownButtonFormField<String>(
            value: _classId,
            decoration: const InputDecoration(labelText: 'Class'),
            items: admin.classes
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _classId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _subjectId,
            decoration: const InputDecoration(labelText: 'Subject'),
            items: admin.subjects
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _subjectId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _teacherId,
            decoration: const InputDecoration(labelText: 'Teacher'),
            items: teachers
                .map((t) => DropdownMenuItem(value: t.uid, child: Text(t.fullName)))
                .toList(),
            onChanged: (v) => setState(() => _teacherId = v),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _assign, child: const Text('Assign teacher')),
        ],
      ],
    );
  }
}

String _gradeName(List<GradeLevelModel> grades, String id) {
  for (final g in grades) {
    if (g.id == id) return g.name;
  }
  return 'Grade';
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
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

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
      ),
    );
  }
}
