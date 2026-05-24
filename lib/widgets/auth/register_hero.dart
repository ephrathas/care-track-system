import 'package:flutter/material.dart';
import '../../core/constants/role_styles.dart';
import '../../core/theme/app_theme.dart';
import 'kidcare_logo.dart';

class RegisterHeroIllustration extends StatelessWidget {
  final String role;

  const RegisterHeroIllustration({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final roleStyle = RoleStyles.forRole(role);
    final accent = roleStyle['accent'] as Color;
    final icon = roleStyle['icon'] as IconData;

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            right: 30,
            child: _bubble(48, accent.withOpacity(0.15)),
          ),
          Positioned(
            bottom: 20,
            left: 24,
            child: _bubble(32, AppTheme.softGreen.withOpacity(0.2)),
          ),
          Positioned(
            top: 40,
            left: 50,
            child: _bubble(20, const Color(0xFFE2894A).withOpacity(0.2)),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: roleStyle['gradient'] as LinearGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 56),
          ),
          Positioned(
            bottom: 30,
            right: 40,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppTheme.softGreen,
                size: 24,
              ),
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
}

class RegisterRoleBadge extends StatelessWidget {
  final String role;

  const RegisterRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final roleStyle = RoleStyles.forRole(role);
    final gradient = roleStyle['gradient'] as LinearGradient;
    final icon = roleStyle['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (roleStyle['accent'] as Color).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'Registering as $role',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterHeader extends StatelessWidget {
  final String role;
  final VoidCallback onBack;

  const RegisterHeader({
    super.key,
    required this.role,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
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
        const SizedBox(height: 8),
        RegisterHeroIllustration(role: role),
      ],
    );
  }
}
