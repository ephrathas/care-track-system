import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/add_child_display_mode.dart';
import '../../core/constants/parent_demo_data.dart';
import '../../core/constants/role_styles.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/child_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/marketplace_orders_provider.dart';
import '../../providers/parent_preferences_provider.dart';
import '../../widgets/dashboard/dashboard_hero_header.dart';
import '../../widgets/dashboard/dashboard_section_header.dart';
import '../../widgets/dashboard/dashboard_stat_card.dart';
import '../../widgets/dashboard/dashboard_tab_scaffold.dart';
import '../../widgets/navigation/kidcare_dashboard_shell.dart';
import '../../widgets/parent/add_child_action_button.dart';
import '../../widgets/parent/add_child_display_setting.dart';
import '../../widgets/profile/user_profile_avatar.dart';
import 'marketplace_tab.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _navIndex = 0;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return KidCareDashboardShell(
      selectedIndex: _navIndex,
      onIndexChanged: (index) => setState(() => _navIndex = index),
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Shop'),
        NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts'),
        NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile'),
      ],
      children: [
        _ParentHomeTab(greeting: _greeting()),
        const MarketplaceTab(),
        const _AlertsTab(),
        const _ProfileTab(),
      ],
    );
  }
}

class _ParentHomeTab extends StatelessWidget {
  final String greeting;

  const _ParentHomeTab({required this.greeting});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final childProvider = Provider.of<ChildProvider>(context);
    final parentPrefs = Provider.of<ParentPreferencesProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasChildren = childProvider.children.isNotEmpty;
    final showInlineAdd = hasChildren && parentPrefs.addChildDisplayMode == AddChildDisplayMode.inline;
    final showFloatingAdd = hasChildren && parentPrefs.addChildDisplayMode == AddChildDisplayMode.floating;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.warmNeutral,
      floatingActionButton: showFloatingAdd ? const AddChildFloatingButton() : null,
      body: SafeArea(
        child: childProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: DashboardHeroHeader(
                      gradient: RoleStyles.forRole('Parent')['gradient'] as LinearGradient,
                      accentColor: RoleStyles.forRole('Parent')['accent'] as Color,
                      subtitle: greeting,
                      title: user?.fullName ?? 'Parent',
                      badgeText:
                          '${childProvider.children.length} ${childProvider.children.length == 1 ? 'child' : 'children'} on your care plan',
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildQuickStats(context)),
                  SliverToBoxAdapter(child: _buildQuickActions(context)),
                  SliverToBoxAdapter(
                    child: DashboardSectionHeader(
                      title: 'My Children',
                      trailing: showInlineAdd ? const AddChildActionButton(compact: true) : null,
                    ),
                  ),
                  if (childProvider.children.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyChildrenState(context, isDark))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              index == childProvider.children.length - 1
                                  ? 0
                                  : 12),
                          child: _ChildProfileCard(
                              child: childProvider.children[index],
                              isDark: isDark),
                        ),
                        childCount: childProvider.children.length,
                      ),
                    ),
                  SliverToBoxAdapter(
                      child: _buildInsightCards(context, isDark)),
                  SliverToBoxAdapter(child: SizedBox(height: showFloatingAdd ? 88 : 24)),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const DashboardStatCard(
            icon: Icons.school_rounded,
            label: 'Attendance',
            value: '96%',
            subtitle: 'This week',
            accent: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 12),
          const DashboardStatCard(
            icon: Icons.favorite_rounded,
            label: 'Health',
            value: 'Good',
            subtitle: 'All checkups current',
            accent: AppTheme.softGreen,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.billing),
            child: const DashboardStatCard(
              icon: Icons.receipt_long_rounded,
              label: 'Billing',
              value: '\$120',
              subtitle: 'Due in 5 days',
              accent: Color(0xFFE2894A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      ('Marketplace', Icons.storefront_rounded, AppTheme.primaryBlue, null),
      ('Reports', Icons.bar_chart_rounded, AppTheme.softGreen, AppRoutes.reports),
      ('Billing', Icons.payments_rounded, const Color(0xFFE2894A), AppRoutes.billing),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: actions
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () {
                        final route = item.$4;
                        if (route != null) {
                          Navigator.pushNamed(context, route);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Open ${item.$1} from the Shop tab')),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            Icon(item.$2, color: item.$3, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              item.$1,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyChildrenState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care_rounded,
                size: 56, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text('No children added yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Add a child profile to track academics, health records, and marketplace recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                height: 1.45),
          ),
          const SizedBox(height: 20),
          const AddChildActionButton(),
          if (Provider.of<ParentPreferencesProvider>(context).addChildDisplayMode == AddChildDisplayMode.hidden)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Tip: You can also add children anytime from the side menu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[500] : AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightCards(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          _InsightPanel(
            isDark: isDark,
            title: 'Academic Progress',
            subtitle:
                'Math improved 12% this month. Reading homework due Friday.',
            icon: Icons.auto_graph_rounded,
            color: AppTheme.primaryBlue,
            onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
          ),
          const SizedBox(height: 12),
          _InsightPanel(
            isDark: isDark,
            title: 'Health Updates',
            subtitle:
                'Flu vaccination scheduled for May 28. No new alerts today.',
            icon: Icons.health_and_safety_rounded,
            color: AppTheme.softGreen,
          ),
          const SizedBox(height: 12),
          _InsightPanel(
            isDark: isDark,
            title: 'Billing & Payments',
            subtitle:
                'Tuition invoice #1042 is ready. Pay securely in one tap.',
            icon: Icons.payments_rounded,
            color: const Color(0xFFE2894A),
            actionLabel: 'View invoice',
            onTap: () => Navigator.pushNamed(context, AppRoutes.billing),
          ),
        ],
      ),
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  final ChildModel child;
  final bool isDark;

  const _ChildProfileCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final vaxCount = child.vaccinations.length;

    return Material(
      color: isDark ? AppTheme.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.childTimeline,
          arguments: child,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                  backgroundImage:
                      child.imageUrl.isNotEmpty ? NetworkImage(child.imageUrl) : null,
                  child: child.imageUrl.isEmpty
                      ? Text(
                          child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        '${child.age} years old • ${ParentDemoData.gradeForAge(child.age)}',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark ? Colors.grey[400] : AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vaxCount > 0
                            ? '$vaxCount vaccines logged'
                            : 'Vaccination profile incomplete',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: vaxCount > 0 ? AppTheme.softGreen : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey[500] : Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _InsightPanel({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppTheme.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                        ),
                      ),
                      if (actionLabel != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          actionLabel!,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = context.watch<MarketplaceOrdersProvider>().orders;

    final staticAlerts = [
      (
        'Attendance marked present',
        'Emma checked in at 8:12 AM',
        Icons.check_circle_rounded,
        AppTheme.softGreen,
        null as String?,
      ),
      (
        'Homework reminder',
        'Math worksheet due tomorrow',
        Icons.menu_book_rounded,
        AppTheme.primaryBlue,
        null,
      ),
      (
        'Health notice',
        'Annual checkup scheduled next week',
        Icons.medical_information_rounded,
        const Color(0xFFE2894A),
        null,
      ),
    ];

    final orderAlerts = orders.take(5).map((order) {
      return (
        'Order #${order.shortId} • ${order.statusLabel}',
        '${order.itemCount} items • \$${order.subtotal.toStringAsFixed(2)}',
        Icons.local_shipping_rounded,
        order.statusColor(context),
        order.id,
      );
    });

    final alerts = [...orderAlerts, ...staticAlerts];

    return DashboardTabScaffold(
      title: 'Notifications',
      trailingActions: [
        IconButton(
          tooltip: 'My Orders',
          onPressed: () => AppRoutes.push(context, AppRoutes.myOrders),
          icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue),
        ),
      ],
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder),
            ),
            leading: Icon(alert.$3, color: alert.$4),
            title: Text(alert.$1,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(alert.$2),
            onTap: alert.$5 != null
                ? () => AppRoutes.push(context, AppRoutes.orderDetail, arguments: alert.$5)
                : null,
          );
        },
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return DashboardTabScaffold(
      title: 'Profile',
      body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: UserProfileAvatar(radius: 44, user: user)),
            const SizedBox(height: 8),
            Text(
              'Tap your photo to update',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.fullName ?? 'Parent',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Center(child: Chip(label: Text(user?.role ?? 'Parent'))),
            const SizedBox(height: 24),
            const AddChildDisplaySetting(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Provider.of<ChildProvider>(context, listen: false)
                      .stopListening();
                  Provider.of<MarketplaceOrdersProvider>(context, listen: false)
                      .stopListening();
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
              ),
            ),
          ],
        ),
    );
  }
}
