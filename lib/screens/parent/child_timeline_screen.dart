import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/child_model.dart';
import '../../widgets/parent/child_photo_avatar.dart';

class ChildTimelineScreen extends StatefulWidget {
  const ChildTimelineScreen({super.key});

  @override
  State<ChildTimelineScreen> createState() => _ChildTimelineScreenState();
}

class _ChildTimelineScreenState extends State<ChildTimelineScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ChildModel? _child;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _child ??= ModalRoute.of(context)?.settings.arguments as ChildModel?;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _child;
    if (child == null) {
      return const Scaffold(body: Center(child: Text('Child not found')));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ChildPhotoAvatar(
                          child: child,
                          radius: 36,
                          borderColor: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                child.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                child.classRoomId != null
                                    ? '${child.age} years • Enrolled in class'
                                    : '${child.age} years • Not enrolled yet',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap photo to update',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: isDark ? Colors.grey[400] : AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryBlue,
              tabs: const [
                Tab(text: 'Timeline'),
                Tab(text: 'Academics'),
                Tab(text: 'Health'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _TimelineTab(isDark: isDark),
            _AcademicsTab(isDark: isDark),
            _HealthTab(child: child, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final bool isDark;

  const _TimelineTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          isDark: isDark,
          title: 'Timeline',
          child: Text(
            'No activity timeline yet.\n\n'
            'Events will appear here when attendance, assignments, assessments, or health updates are published.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AcademicsTab extends StatelessWidget {
  final bool isDark;

  const _AcademicsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _SectionCard(
          isDark: isDark,
          title: 'Academics',
          child: Text(
            'No assessments yet.\n\nTeachers need to publish assignments and scores first.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthTab extends StatelessWidget {
  final ChildModel child;
  final bool isDark;

  const _HealthTab({
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _SectionCard(
          isDark: isDark,
          title: 'Vaccination Status',
          child: child.vaccinations.isEmpty
              ? const Text(
                  'No vaccines logged yet. Update the profile from Add Child.',
                  style: TextStyle(height: 1.4, color: AppTheme.textSecondary),
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
        const SizedBox(height: 14),
        _SectionCard(
          isDark: isDark,
          title: 'Health Updates',
          child: Text(
            'No health events yet.\n\nHealthcare timeline will appear when parents enable health access and records are added.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
            ),
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
