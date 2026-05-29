import 'package:flutter/material.dart';
import '../../core/constants/role_options.dart';
import '../../core/constants/role_styles.dart';
import '../../core/theme/app_theme.dart';
import 'auth_illustration.dart';

/// Tappable role row used on welcome and role-selection screens.
class RoleOptionTile extends StatelessWidget {
  final RoleOption option;
  final VoidCallback onTap;

  const RoleOptionTile({
    super.key,
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = RoleStyles.forRole(option.title);

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
              color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AuthIllustration(
                    assetPath: option.featureAsset,
                    height: 52,
                    width: 52,
                    fit: BoxFit.cover,
                    fallback: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: style['gradient'] as LinearGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        style['icon'] as IconData,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
