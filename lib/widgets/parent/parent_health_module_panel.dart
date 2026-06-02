import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/firestore/firestore_health_repository.dart';
import '../../models/child_model.dart';
import '../../models/health_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';

/// Parent opt-in for school healthcare access + live profile summary.
class ParentHealthModulePanel extends StatelessWidget {
  final ChildModel child;
  final bool isDark;

  const ParentHealthModulePanel({
    super.key,
    required this.child,
    required this.isDark,
  });

  Future<void> _toggle(BuildContext context, bool value) async {
    final parentId = context.read<AuthProvider>().currentUser?.uid;
    if (parentId == null) return;

    final ok = await context.read<ChildProvider>().setHealthModuleEnabled(
          childId: child.id,
          parentId: parentId,
          enabled: value,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (value
                  ? 'Healthcare professionals at your school can now view ${child.name}\'s health profile.'
                  : 'Healthcare access revoked for ${child.name}.')
              : 'Could not update health settings. Try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = FirestoreHealthRepository();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          isDark: isDark,
          title: 'School healthcare access',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health tracking is optional. When enabled, verified healthcare staff at your school '
                'can view growth, vaccines, and schedule clinic visits.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: child.healthModuleEnabled,
                activeColor: AppTheme.softGreen,
                title: Text(
                  child.healthModuleEnabled ? 'Access enabled' : 'Access disabled',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text(
                  child.healthModuleEnabled
                      ? 'Healthcare dashboard can see this profile'
                      : 'Only you see health data until you enable access',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                  ),
                ),
                onChanged: (v) => _toggle(context, v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (child.healthModuleEnabled)
          StreamBuilder<HealthProfileModel?>(
            stream: repo.watchHealthProfile(child.id),
            builder: (context, snap) {
              final profile = snap.data;
              return _SectionCard(
                isDark: isDark,
                title: 'Health profile',
                child: profile == null
                    ? const Text(
                        'Profile syncing…',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (profile.latestHeight != null || profile.latestWeight != null)
                            Text(
                              'Growth: ${profile.latestHeight?.toStringAsFixed(1) ?? '—'} cm • '
                              '${profile.latestWeight?.toStringAsFixed(1) ?? '—'} kg',
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (profile.lastCheckup != null && profile.lastCheckup!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('Last checkup: ${profile.lastCheckup}', style: const TextStyle(fontSize: 12)),
                          ],
                          if (profile.vaccinations.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Text('Vaccinations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.vaccinations
                                  .map(
                                    (v) => Chip(
                                      label: Text(v.name, style: const TextStyle(fontSize: 11)),
                                      backgroundColor: AppTheme.softGreen.withOpacity(0.12),
                                      side: BorderSide.none,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (profile.allergies.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text('Allergies: ${profile.allergies.join(', ')}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ],
                      ),
              );
            },
          )
        else
          _SectionCard(
            isDark: isDark,
            title: 'Vaccination status (private)',
            child: child.vaccinations.isEmpty
                ? Text(
                    'No vaccines logged yet. Add them when enrolling or enable healthcare access.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: child.vaccinations
                        .map(
                          (v) => Chip(
                            label: Text(v, style: const TextStyle(fontSize: 11)),
                            backgroundColor: AppTheme.softGreen.withOpacity(0.12),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.isDark,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
