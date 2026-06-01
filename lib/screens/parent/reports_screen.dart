import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/child_model.dart';
import '../../providers/child_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final children = Provider.of<ChildProvider>(context).children;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: children.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Add a child profile to view academic reports and progress charts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _SummaryBanner(isDark: isDark, childCount: children.length),
                const SizedBox(height: 16),
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChildReportCard(child: child, isDark: isDark),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final bool isDark;
  final int childCount;

  const _SummaryBanner({required this.isDark, required this.childCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.softGreen, Color(0xFF5CA216)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Snapshot',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tracking $childCount ${childCount == 1 ? 'child' : 'children'} • reports unlock after assessments are published',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildReportCard extends StatelessWidget {
  final ChildModel child;
  final bool isDark;

  const _ChildReportCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                backgroundImage: child.imageUrl.isNotEmpty ? NetworkImage(child.imageUrl) : null,
                child: child.imageUrl.isEmpty
                    ? Text(
                        child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      child.gradeLevelId != null
                          ? 'Enrolled • waiting for teacher assessments'
                          : 'Not enrolled in class yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'No report data yet.\nTeachers need to publish assignments/assessments first.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
