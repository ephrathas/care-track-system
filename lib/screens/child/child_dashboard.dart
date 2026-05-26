import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ChildDashboard extends StatefulWidget {
  const ChildDashboard({super.key});

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          const _ChildHomeTab(),
          const _ChildHomeworkTab(),
          const _ChildRewardsTab(),
          const _ChildProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) => setState(() => _navIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.stars_outlined),
            selectedIcon: Icon(Icons.stars_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'My Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
            label: 'My Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.face_outlined),
            selectedIcon: Icon(Icons.face_rounded),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== GLOBAL XP & BADGE CONTROLLER ====================
// Simple local model to simulate the gamification database in memory
class _GamificationData {
  static int currentXp = 340;
  static int currentLevel = 3;
  static int unlockedBadges = 5;

  static List<Map<String, dynamic>> initialBadges = [
    {
      'title': 'Math Whiz',
      'desc': 'Complete all fractions assignments',
      'unlocked': true,
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFF4A90E2)
    },
    {
      'title': 'Perfect Attendance',
      'desc': 'Check in every day for 2 consecutive weeks',
      'unlocked': true,
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF7ED321)
    },
    {
      'title': 'Star Student',
      'desc': 'Scored over 95% on Grade 3 English exam',
      'unlocked': true,
      'icon': Icons.star_rounded,
      'color': Colors.amber
    },
    {
      'title': 'Helper Bee',
      'desc': 'Marked helpful in classroom peer activities',
      'unlocked': true,
      'icon': Icons.pest_control_rodent_rounded,
      'color': Colors.pinkAccent
    },
    {
      'title': 'Science Explorer',
      'desc': 'Finish the Planet Earth Science project',
      'unlocked': false,
      'icon': Icons.biotech_rounded,
      'color': const Color(0xFF9013FE)
    },
    {
      'title': 'Fast Learner',
      'desc': 'Submit homework within 2 hours of assignment',
      'unlocked': false,
      'icon': Icons.bolt_rounded,
      'color': Colors.cyan
    },
  ];

  static List<Map<String, dynamic>> tasks = [
    {
      'id': 'T1',
      'title': 'Solve Math Fractions Worksheet',
      'subject': 'Mathematics',
      'xp': 50,
      'completed': false,
      'dueDate': 'Due tomorrow',
      'color': const Color(0xFF4A90E2)
    },
    {
      'id': 'T2',
      'title': 'Read Chapter 4 English Book',
      'subject': 'English Language',
      'xp': 40,
      'completed': false,
      'dueDate': 'Due in 2 days',
      'color': const Color(0xFF7ED321)
    },
    {
      'id': 'T3',
      'title': 'Plant Experiment Journal',
      'subject': 'Natural Sciences',
      'xp': 80,
      'completed': false,
      'dueDate': 'Due in 4 days',
      'color': const Color(0xFF9013FE)
    },
  ];
}

// ==================== HOME TAB ====================
class _ChildHomeTab extends StatefulWidget {
  const _ChildHomeTab();

  @override
  State<_ChildHomeTab> createState() => _ChildHomeTabState();
}

class _ChildHomeTabState extends State<_ChildHomeTab> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int xpNeeded = 500;
    final double xpProgress = _GamificationData.currentXp / xpNeeded;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildPlayfulHeader(context, user?.fullName ?? 'Emma', isDark, xpProgress),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  'My Active Quests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildQuestStats(isDark),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Today\'s Journey Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final list = [
                    ('08:30 AM', 'Mathematics Class', 'Learn divisions', Icons.calculate_rounded, const Color(0xFF4A90E2)),
                    ('10:00 AM', 'Recess & Playtime', 'Outdoor games', Icons.sports_esports_rounded, const Color(0xFF7ED321)),
                    ('11:00 AM', 'Reading Session', 'Storytelling module', Icons.auto_stories_rounded, const Color(0xFF9013FE)),
                  ];
                  final item = list[index];
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
                              color: item.$4.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item.$4, color: item.$5, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.$2,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.$3} • ${item.$1}',
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
                childCount: 3,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayfulHeader(BuildContext context, String name, bool isDark, double xpProgress) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9013FE), Color(0xFF700CB5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9013FE).withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Text(
                    '👧',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${_GamificationData.currentLevel} Explorer',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${_GamificationData.unlockedBadges} Badges',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text(
                  'My Progress (XP)',
                  style: TextStyle(color: Colors.white90, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_GamificationData.currentXp} / 500 XP',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: xpProgress,
                minHeight: 10,
                color: Colors.amber,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestStats(bool isDark) {
    final pendingCount = _GamificationData.tasks.where((t) => !t['completed']).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
              ),
              child: Column(
                children: [
                  const Text('Pending Quests', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    '$pendingCount',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: pendingCount > 0 ? const Color(0xFF9013FE) : const Color(0xFF7ED321),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
              ),
              child: const Column(
                children: [
                  Text('Level Rank', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    'Elite III',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HOMEWORK / TASKS TAB ====================
class _ChildHomeworkTab extends StatefulWidget {
  const _ChildHomeworkTab();

  @override
  State<_ChildHomeworkTab> createState() => _ChildHomeworkTabState();
}

class _ChildHomeworkTabState extends State<_ChildHomeworkTab> {
  void _completeTask(Map<String, dynamic> task) {
    if (task['completed'] == true) return;
    setState(() {
      task['completed'] = true;
      _GamificationData.currentXp += task['xp'] as int;

      // Unlocks dynamic Science Explorer badge if the third task is done
      if (task['id'] == 'T3') {
        for (var badge in _GamificationData.initialBadges) {
          if (badge['title'] == 'Science Explorer') {
            if (!badge['unlocked']) {
              badge['unlocked'] = true;
              _GamificationData.unlockedBadges++;
            }
          }
        }
      }

      // Check leveling up!
      if (_GamificationData.currentXp >= 500) {
        _GamificationData.currentLevel++;
        _GamificationData.currentXp -= 500;
        _showLevelUpDialog();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Quest completed! Earned +${task['xp']} XP!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF7ED321),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLevelUpDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Center(
            child: Text(
              '🎉 LEVEL UP! 🎉',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 22),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🌟 AMAZING WORK! 🌟',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'You reached Level ${_GamificationData.currentLevel}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.workspace_premium_rounded, size: 72, color: Colors.amber),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Awesome!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _GamificationData.tasks;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      appBar: AppBar(
        title: const Text('My Homework Quests', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = list[index];
          final completed = task['completed'] as bool;
          final accent = task['color'] as Color;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: completed
                    ? const Color(0xFF7ED321).withOpacity(0.3)
                    : (isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task['subject'],
                          style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        task['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: completed ? TextDecoration.lineThrough : null,
                          color: completed ? Colors.grey : (isDark ? Colors.white : AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 12, color: isDark ? Colors.grey[400] : AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            task['dueDate'],
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : AppTheme.textSecondary),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.bolt_rounded, size: 12, color: Colors.amber),
                          Text(
                            '+${task['xp']} XP',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (completed)
                  const CircleAvatar(
                    backgroundColor: Color(0xFF7ED321),
                    child: Icon(Icons.check_rounded, color: Colors.white),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _completeTask(task),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Claim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== REWARDS / BADGES TAB ====================
class _ChildRewardsTab extends StatelessWidget {
  const _ChildRewardsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badges = _GamificationData.initialBadges;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      appBar: AppBar(
        title: const Text('My Vault Badges', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final unlocked = badge['unlocked'] as bool;
          final accent = badge['color'] as Color;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unlocked
                    ? accent.withOpacity(0.3)
                    : (isDark ? Colors.grey.shade850 : Colors.grey.shade200),
              ),
              boxShadow: [
                if (unlocked)
                  BoxShadow(
                    color: accent.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: unlocked ? accent.withOpacity(0.12) : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge['icon'] as IconData,
                    color: unlocked ? accent : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  badge['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: unlocked ? (isDark ? Colors.white : AppTheme.textPrimary) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge['desc'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
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
class _ChildProfileTab extends StatelessWidget {
  const _ChildProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF9013FE).withOpacity(0.12),
              child: const Text(
                '👧',
                style: TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'Emma Watson',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'emma@kidcare.com',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 14),
            Chip(
              label: Text(
                user?.role ?? 'Child',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF9013FE).withOpacity(0.12),
              side: BorderSide.none,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
              ),
              child: const Column(
                children: [
                  _ProfileStatRow(label: 'Assigned School', value: 'North Academy Center'),
                  Divider(),
                  _ProfileStatRow(label: 'Assigned Class', value: 'Grade 3-A'),
                  Divider(),
                  _ProfileStatRow(label: 'Careparent Contact', value: '+1 (555) 019-2834'),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
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
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
