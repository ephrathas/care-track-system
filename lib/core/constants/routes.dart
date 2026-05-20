import 'package:flutter/material.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/login_screen.dart'; // Ensure this exists

class AppRoutes {
  // Route Names (Constants)
  static const String roleSelection = '/';
  static const String login = '/login';
  static const String register = '/register';

  // 🗺️ The Unified Map of Routes
  static Map<String, WidgetBuilder> get routes => {
        roleSelection: (context) => const RoleSelectionScreen(),
        register: (context) => const RegisterScreen(),
        login: (context) => const LoginScreen(), // ✅ Correctly inside the map
      };

  // Helper function for clean navigation
  static void push(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
}
