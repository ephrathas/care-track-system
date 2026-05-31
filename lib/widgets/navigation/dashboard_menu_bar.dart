<<<<<<< HEAD
import 'package:flutter/material.dart';

export 'dashboard_header_actions.dart';
export 'dashboard_shell_scope.dart';

/// Legacy overlay removed — use [DashboardHeaderActions] inside hero headers.
@Deprecated('Use DashboardHeaderActions or DashboardCompactToolbar instead.')
class DashboardMenuOverlay extends StatelessWidget {
  const DashboardMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

typedef DashboardMenuBar = DashboardMenuOverlay;
=======
import 'package:flutter/material.dart';

export 'dashboard_header_actions.dart';
export 'dashboard_shell_scope.dart';

/// Legacy overlay removed — use [DashboardHeaderActions] inside hero headers.
@Deprecated('Use DashboardHeaderActions or DashboardCompactToolbar instead.')
class DashboardMenuOverlay extends StatelessWidget {
  const DashboardMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

typedef DashboardMenuBar = DashboardMenuOverlay;
>>>>>>> a82b3823ac6c9b3d962e8fbb89617fc8b0a38632
