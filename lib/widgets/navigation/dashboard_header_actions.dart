import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'dashboard_shell_scope.dart';

/// Menu + quick panel controls embedded in gradient hero headers.
class DashboardHeaderActions extends StatelessWidget {
  const DashboardHeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GlassHeaderButton(
          icon: Icons.menu_rounded,
          tooltip: 'Menu',
          onPressed: () => DashboardShellScope.of(context).openDrawer(),
        ),
        const Spacer(),
        Text(
          'KidCare',
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        _GlassHeaderButton(
          icon: Icons.auto_awesome_motion_rounded,
          tooltip: 'Quick panel',
          onPressed: () => DashboardShellScope.of(context).openEndDrawer(),
        ),
      ],
    );
  }
}

/// Slim toolbar for neutral pages (shop, lists, profile tabs).
class DashboardCompactToolbar extends StatelessWidget {
  final String? title;

  const DashboardCompactToolbar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          _NeutralHeaderButton(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            isDark: isDark,
            onPressed: () => DashboardShellScope.of(context).openDrawer(),
          ),
          if (title != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
          ] else
            const Spacer(),
          _NeutralHeaderButton(
            icon: Icons.auto_awesome_motion_rounded,
            tooltip: 'Quick panel',
            isDark: isDark,
            onPressed: () => DashboardShellScope.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }
}

/// AppBar leading slot for nested scaffolds.
class DashboardToolbarLeading extends StatelessWidget {
  const DashboardToolbarLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: _NeutralHeaderButton(
        icon: Icons.menu_rounded,
        tooltip: 'Menu',
        isDark: isDark,
        onPressed: () => DashboardShellScope.of(context).openDrawer(),
      ),
    );
  }
}

/// AppBar actions slot for nested scaffolds.
class DashboardToolbarTrailing extends StatelessWidget {
  const DashboardToolbarTrailing({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _NeutralHeaderButton(
        icon: Icons.auto_awesome_motion_rounded,
        tooltip: 'Quick panel',
        isDark: isDark,
        onPressed: () => DashboardShellScope.of(context).openEndDrawer(),
      ),
    );
  }
}

class _GlassHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _GlassHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _NeutralHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isDark;
  final VoidCallback onPressed;

  const _NeutralHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : AppTheme.inputBorder,
              ),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
          ),
        ),
      ),
    );
  }
}
