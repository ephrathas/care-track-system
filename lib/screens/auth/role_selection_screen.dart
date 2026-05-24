import 'package:flutter/material.dart';
import '../../core/constants/auth_assets.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/auth_feature_card.dart';
import '../../widgets/auth/auth_illustration.dart';
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
                AuthIllustration(
                  assetPath: AuthAssets.welcomeHero,
                  height: 170,
                ),
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
                        'Your complete child management and educational marketplace platform.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const AuthFeatureCard(
                        imageAsset: AuthAssets.featureParent,
                        title: 'For Parents',
                        subtitle: "Track your child's progress and health",
                      ),
                      const SizedBox(height: 10),
                      const AuthFeatureCard(
                        imageAsset: AuthAssets.featureTeacher,
                        title: 'For Teachers',
                        subtitle: 'Manage students and academics easily',
                      ),
                      const SizedBox(height: 10),
                      const AuthFeatureCard(
                        imageAsset: AuthAssets.featureHealthcare,
                        title: 'For Healthcare',
                        subtitle: 'Monitor health records and vaccinations',
                      ),
                      const SizedBox(height: 10),
                      const AuthFeatureCard(
                        imageAsset: AuthAssets.featureSecure,
                        title: 'Safe & Secure',
                        subtitle: 'Your data is protected and private',
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
                const SizedBox(height: 8),
                _TrustBadges(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustBadges extends StatelessWidget {
  final bool isDark;

  const _TrustBadges({required this.isDark});

  @override
  Widget build(BuildContext context) {
    const badges = [
      'Secure & Private',
      'HIPAA Compliant',
      'Mobile Friendly',
      'Award Winning',
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: badges
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : AppTheme.textSecondary,
                ),
              ),
            ),
          )
          .toList(),
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
