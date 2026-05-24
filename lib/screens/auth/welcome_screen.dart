import 'package:flutter/material.dart';
import '../../core/constants/auth_assets.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/auth_feature_card.dart';
import '../../widgets/auth/auth_illustration.dart';
import '../../widgets/auth/kidcare_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                const AuthIllustration(
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
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.welcomeRoleSelection),
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
                            'Sign In',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Trusted by thousands of families and educators',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
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
