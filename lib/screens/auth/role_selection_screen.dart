import 'package:flutter/material.dart';
import '../../core/constants/role_options.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/kidcare_logo.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: isDark ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const KidCareLogo(iconSize: 20, fontSize: 18),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  'Choose Your Role',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  'Select how you will use KidCare. You can personalize your dashboard after sign up.',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: RoleOptions.all.length,
                  itemBuilder: (context, index) {
                    final role = RoleOptions.all[index];
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
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
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
              ),
            ],
          ),
        ),
      ),
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
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: role['gradient'] as LinearGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(role['icon'] as IconData, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
