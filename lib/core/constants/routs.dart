import 'package:flutter/material.dart';
import '../../screens/auth/role_selection_screen.dart';

class AppRoutes {
  // Route Names
  static const String roleSelection = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Map of routes
  static Map<String, WidgetBuilder> get routes => {
        roleSelection: (context) => const RoleSelectionScreen(),
        // These will be added as the team pushes their screens them
      };

  // Helper function to navigate
  static void push(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
}
