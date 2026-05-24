import 'package:flutter/material.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/kidcare_logo.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> roles = [
      {
        'title': 'Parent',
        'subtitle': 'Track your child\'s health, growth, vaccination status, and explore the shop.',
        'icon': Icons.family_restroom_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Teacher',
        'subtitle': 'Manage daily class attendance, assign classroom tasks, and submit academic progress.',
        'icon': Icons.school_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF7ED321), Color(0xFF5CA216)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Healthcare',
        'subtitle': 'Manage professional pediatric medical records, book appointments, and issue reports.',
        'icon': Icons.medical_services_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFFE2894A), Color(0xFFBD7135)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Child',
        'subtitle': 'Engage in custom educational tasks, complete homework, and earn gamified badges.',
        'icon': Icons.child_care_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF9013FE), Color(0xFF700CB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A2744), AppTheme.darkBackground]
                : [AppTheme.authGradientTop, AppTheme.warmNeutral],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                const KidCareLogo(),
                const SizedBox(height: 14),
                _WelcomeHero(isDark: isDark),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to KidCare',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.4,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your role and get personalized tools for learning, care, and progress tracking.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _FeatureRow(
                        icon: Icons.verified_user_rounded,
                        text: 'Secure child profiles and records',
                      ),
                      const SizedBox(height: 10),
                      const _FeatureRow(
                        icon: Icons.insights_rounded,
                        text: 'Daily updates and progress insights',
                      ),
                      const SizedBox(height: 10),
                      const _FeatureRow(
                        icon: Icons.groups_rounded,
                        text: 'Parents, teachers, and healthcare in one app',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                              arguments: 'Parent',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                          child: const Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Continue as',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...roles.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RoleCard(
                      role: role,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.register,
                          arguments: role['title'],
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  final bool isDark;

  const _WelcomeHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 10, right: 26, child: _bubble(42, AppTheme.primaryBlue.withOpacity(0.16))),
          Positioned(top: 24, left: 28, child: _bubble(24, AppTheme.softGreen.withOpacity(0.2))),
          Positioned(bottom: 18, left: 24, child: _bubble(30, const Color(0xFFE2894A).withOpacity(0.22))),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 52),
          ),
          Positioned(
            bottom: 24,
            right: 26,
            child: _chip(
              Icons.school_rounded,
              isDark ? AppTheme.darkSurface : Colors.white,
              AppTheme.softGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _chip(IconData icon, Color background, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[300] : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Map<String, dynamic> role;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppTheme.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: role['gradient'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(role['icon'], color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role['subtitle'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
