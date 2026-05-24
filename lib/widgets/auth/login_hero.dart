import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'kidcare_logo.dart';

class LoginHeroIllustration extends StatelessWidget {
  const LoginHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            right: 30,
            child: _bubble(48, AppTheme.primaryBlue.withOpacity(0.15)),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 52),
          ),
          Positioned(
            bottom: 28,
            right: 36,
            child: _featureChip(Icons.family_restroom_rounded, AppTheme.primaryBlue),
          ),
          Positioned(
            top: 32,
            left: 36,
            child: _featureChip(Icons.school_rounded, AppTheme.softGreen),
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

  Widget _featureChip(IconData icon, Color color) {
    return Container(
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
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class LoginHeader extends StatelessWidget {
  final VoidCallback onBack;

  const LoginHeader({super.key, required this.onBack});

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
        const LoginHeroIllustration(),
      ],
    );
  }
}
