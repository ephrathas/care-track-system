import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/role_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../models/child_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/healthcare_provider.dart';
import '../../widgets/dashboard/dashboard_hero_header.dart';
import '../../widgets/dashboard/dashboard_tab_scaffold.dart';
import '../../widgets/navigation/kidcare_dashboard_shell.dart';
import '../../widgets/profile/user_profile_avatar.dart';

class HealthcareDashboard extends StatefulWidget {
  const HealthcareDashboard({super.key});

  @override
  State<HealthcareDashboard> createState() => _HealthcareDashboardState();
}

class _HealthcareDashboardState extends State<HealthcareDashboard> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return KidCareDashboardShell(
      selectedIndex: _navIndex,
      onIndexChanged: (index) => setState(() => _navIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.healing_outlined),
          selectedIcon: Icon(Icons.healing_rounded),
          label: 'Home Center',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_shared_outlined),
          selectedIcon: Icon(Icons.folder_shared_rounded),
          label: 'Directory',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Visits',
        ),
        NavigationDestination(
          icon: Icon(Icons.medical_services_outlined),
          selectedIcon: Icon(Icons.medical_services_rounded),
          label: 'Credentials',
        ),
      ],
      children: const [
        _HealthcareHomeTab(),
        _HealthcarePatientsTab(),
        _HealthcareAppointmentsTab(),
        _HealthcareProfileTab(),
      ],
    );
  }
}

// ==================== HOME TAB ====================
class _HealthcareHomeTab extends StatelessWidget {
  const _HealthcareHomeTab();

  static const _appointmentAccents = [
    Color(0xFFE2894A),
    Color(0xFF4A90E2),
    Color(0xFF7ED321),
  ];

  static const _appointmentIcons = [
    Icons.favorite_rounded,
    Icons.vaccines_rounded,
    Icons.remove_red_eye_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final healthcare = Provider.of<HealthcareProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayVisits = healthcare.todayAppointments;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      body: SafeArea(
        child: healthcare.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE2894A)),
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: DashboardHeroHeader(
                      gradient: RoleStyles.forRole('Healthcare')['gradient'] as LinearGradient,
                      accentColor: RoleStyles.forRole('Healthcare')['accent'] as Color,
                      subtitle: 'Healthcare Center',
                      title: 'Hello, ${user?.fullName ?? 'Healthcare Professional'}',
                      badgeText: 'Metro Pediatrics Clinic • Room 402',
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildClinicStats(
                      isDark,
                      patientCount: healthcare.activePatientCount,
                      vaccineCount: healthcare.totalVaccineRecords,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text(
                        'Today\'s Hospital Appointments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                      ),
                    ),
                  ),
                  if (todayVisits.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event_available_rounded,
                                  color: isDark ? Colors.grey[400] : AppTheme.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No visits scheduled for today. Schedule one from the Pediatric Directory.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final visit = todayVisits[index];
                          final accent = _appointmentAccents[index % _appointmentAccents.length];
                          final icon = _appointmentIcons[index % _appointmentIcons.length];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSurface : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(icon, color: accent, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          visit.childName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${visit.title} • ${visit.timeLabel}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: todayVisits.length,
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Text(
                        'Urgent Clinical Alerts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.report_problem_rounded,
                                color: Colors.redAccent, size: 28),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vaccine Supply Alert',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.redAccent),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Measles/MMR booster doses are running low in Room 4.',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildClinicStats(bool isDark, {required int patientCount, required int vaccineCount}) {
    final stats = [
      ('Patients', '$patientCount Active', 'Registered in KidCare', const Color(0xFFE2894A), Icons.groups_rounded),
      ('Vaccines', '$vaccineCount On Record', 'Across all patients', const Color(0xFF4A90E2), Icons.vaccines_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: s == stats.first ? 10 : 0,
                left: s == stats.last ? 10 : 0,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(s.$5, color: s.$4, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    s.$2,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    s.$3,
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            isDark ? Colors.grey[400] : AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==================== PATIENTS DIRECTORY TAB ====================
class _HealthcarePatientsTab extends StatefulWidget {
  const _HealthcarePatientsTab();

  @override
  State<_HealthcarePatientsTab> createState() => _HealthcarePatientsTabState();
}

class _HealthcarePatientsTabState extends State<_HealthcarePatientsTab> {
  String _searchQuery = '';
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _vaccineController = TextEditingController();
  final _visitTitleController = TextEditingController();
  final _visitTimeController = TextEditingController();
  DateTime _scheduledVisitAt = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    9,
    0,
  );

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _vaccineController.dispose();
    _visitTitleController.dispose();
    _visitTimeController.dispose();
    super.dispose();
  }

  ChildModel? _patientById(String id, HealthcareProvider healthcare) {
    for (final patient in healthcare.patients) {
      if (patient.id == id) return patient;
    }
    return null;
  }

  void _openGrowthSheet(ChildModel patient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _heightController.text = patient.latestHeight?.toString() ?? '';
    _weightController.text = patient.latestWeight?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Growth Tracker - ${patient.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Patient Height (cm)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 132.5',
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.darkBackground
                      : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Patient Weight (kg)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 28.4',
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.darkBackground
                      : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final h = double.tryParse(_heightController.text);
                    final w = double.tryParse(_weightController.text);
                    if (h == null || w == null) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Please enter valid height and weight values')),
                      );
                      return;
                    }
                    final success = await Provider.of<HealthcareProvider>(sheetContext, listen: false)
                        .updateGrowthMetrics(childId: patient.id, height: h, weight: w);
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Updated growth metrics for ${patient.name}!'
                              : 'Could not save growth metrics. Please try again.',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: success ? const Color(0xFFE2894A) : Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2894A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Update Growth Logs',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openVaccineSheet(ChildModel patient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _vaccineController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final livePatient = _patientById(patient.id, Provider.of<HealthcareProvider>(sheetContext)) ?? patient;

        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Immunization Registry - ${livePatient.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Administered Vaccines:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              if (livePatient.vaccinations.isEmpty)
                const Text('No vaccines registered yet.', style: TextStyle(fontSize: 12, color: Colors.grey))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: livePatient.vaccinations.map((vax) {
                    return Chip(
                      label: Text(vax,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor:
                          const Color(0xFF4A90E2).withOpacity(0.12),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              const Text('Administer New Vaccine',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _vaccineController,
                decoration: InputDecoration(
                  hintText: 'e.g. Polio (IPV) - Booster 1',
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.darkBackground
                      : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final vaxName = _vaccineController.text.trim();
                    if (vaxName.isEmpty) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Please enter a vaccine description')),
                      );
                      return;
                    }
                    final success = await Provider.of<HealthcareProvider>(sheetContext, listen: false)
                        .addVaccine(childId: livePatient.id, vaccineName: vaxName);
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.vaccines_rounded,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                success
                                    ? 'Administered $vaxName successfully!'
                                    : 'Could not log vaccine. Please try again.',
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: success ? const Color(0xFF4A90E2) : Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Log Vaccine Inoculation',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openScheduleSheet(ChildModel patient) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _visitTitleController.text = 'Pediatric Checkup';
    final now = DateTime.now();
    _scheduledVisitAt = DateTime(now.year, now.month, now.day, 9, 0);
    _visitTimeController.text = DateFormat('hh:mm a').format(_scheduledVisitAt);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedule Visit - ${patient.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Visit Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _visitTitleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppTheme.darkBackground : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Visit Time', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _visitTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.access_time_rounded),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkBackground : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: sheetContext,
                    initialTime: TimeOfDay.fromDateTime(_scheduledVisitAt),
                  );
                  if (picked != null) {
                    final today = DateTime.now();
                    _scheduledVisitAt = DateTime(
                      today.year,
                      today.month,
                      today.day,
                      picked.hour,
                      picked.minute,
                    );
                    _visitTimeController.text = DateFormat('hh:mm a').format(_scheduledVisitAt);
                  }
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = _visitTitleController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Please enter a visit title')),
                      );
                      return;
                    }
                    final success = await Provider.of<HealthcareProvider>(sheetContext, listen: false)
                        .scheduleAppointment(
                      childId: patient.id,
                      childName: patient.name,
                      title: title,
                      scheduledAt: _scheduledVisitAt,
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Visit scheduled for ${patient.name}!'
                              : 'Could not schedule visit. Please try again.',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: success ? const Color(0xFFE2894A) : Colors.redAccent,
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2894A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirm Visit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final healthcare = Provider.of<HealthcareProvider>(context);
    final list = healthcare.searchPatients(_searchQuery);

    return DashboardTabScaffold(
      title: 'Pediatric Directory',
      body: healthcare.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE2894A)),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search patients by name...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_shared_outlined,
                                      size: 48, color: isDark ? Colors.grey[600] : AppTheme.textSecondary),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'No patients registered yet.\nWhen parents add children, they appear here.'
                                        : 'No patients match your search.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: isDark ? Colors.grey[400] : AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final p = list[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurface : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color(0xFFE2894A).withOpacity(0.12),
                                          backgroundImage:
                                              p.imageUrl.isNotEmpty ? NetworkImage(p.imageUrl) : null,
                                          child: p.imageUrl.isEmpty
                                              ? Text(
                                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : 'C',
                                                  style: const TextStyle(
                                                    color: Color(0xFFE2894A),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.name,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              Text(
                                                'ID: ${p.id.substring(0, 8)}… • ${p.age} years old',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Latest Height',
                                                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                            Text(p.heightLabel,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Latest Weight',
                                                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                            Text(p.weightLabel,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Last Checkup',
                                                  style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                              Text(
                                                p.checkupLabel,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _openGrowthSheet(p),
                                            icon: const Icon(Icons.show_chart_rounded, size: 16),
                                            label: const Text('Growth',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFFE2894A),
                                              side: const BorderSide(color: Color(0xFFE2894A)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _openVaccineSheet(p),
                                            icon: const Icon(Icons.vaccines_rounded, size: 16),
                                            label: const Text('Vaccines',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF4A90E2),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _openScheduleSheet(p),
                                            icon: const Icon(Icons.event_rounded, size: 16),
                                            label: const Text('Visit',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.primaryBlue,
                                              side: const BorderSide(color: AppTheme.primaryBlue),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
    );
  }
}

// ==================== CLINIC VISITS TAB ====================
class _HealthcareAppointmentsTab extends StatelessWidget {
  const _HealthcareAppointmentsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final healthcare = Provider.of<HealthcareProvider>(context);
    final appointments = healthcare.upcomingAppointments;

    return DashboardTabScaffold(
      title: 'Upcoming Clinic Visits',
      body: healthcare.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE2894A)),
              ),
            )
          : appointments.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_rounded,
                            size: 48, color: isDark ? Colors.grey[600] : AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'No clinic visits scheduled yet.\nUse the Visit button in Pediatric Directory.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? Colors.grey[400] : AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final visit = appointments[index];
                    final statusColor = visit.status == 'Active' ? Colors.green : AppTheme.textSecondary;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2894A).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.event_note_rounded, color: Color(0xFFE2894A), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      visit.childName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        visit.status,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${visit.title} • ${DateFormat('MMM dd, yyyy').format(visit.scheduledAt)} • ${visit.timeLabel}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== PROFILE TAB ====================
class _HealthcareProfileTab extends StatelessWidget {
  const _HealthcareProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DashboardTabScaffold(
      title: 'Profile Settings',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(child: UserProfileAvatar(radius: 44, user: user)),
          const SizedBox(height: 8),
          Text(
            'Tap your photo to update',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Healthcare Provider',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'pediatrician@kidcare.com',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Center(
            child: Chip(
              label: Text(
                user?.role ?? 'Healthcare',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFE2894A).withOpacity(0.12),
              side: BorderSide.none,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
            ),
            child: const Column(
              children: [
                _ProfileStatRow(
                    label: 'Assigned Clinic', value: 'Metro Pediatrics Clinic'),
                Divider(),
                _ProfileStatRow(
                    label: 'License Registry', value: 'MD-9283-49A'),
                Divider(),
                _ProfileStatRow(
                    label: 'Room Registry', value: 'Clinic Room 402'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                Provider.of<HealthcareProvider>(context, listen: false).stopListening();
                await Provider.of<AuthProvider>(context, listen: false).logout();
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text('Sign Out',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}