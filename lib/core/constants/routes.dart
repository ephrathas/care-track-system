import 'package:child_and_student_care_and_tracking_app/screens/parent/add_child_screen.dart';
import 'package:child_and_student_care_and_tracking_app/screens/parent/parent_dashboard.dart';
import 'package:flutter/material.dart';
import '../../screens/auth/auth_wrapper.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/role_selection_screen.dart';

class AppRoutes {
  // Route Names (Constants)
  static const String roleSelection = '/';
  static const String welcomeRoleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String parentHome = '/parent_home';
  static const String addChildScreen = '/add_child';

  // 🗺️ The Unified Map of Routes
  static Map<String, WidgetBuilder> get routes => {
        roleSelection: (context) => const AuthWrapper(),
        welcomeRoleSelection: (context) => const RoleSelectionScreen(),
        register: (context) => const RegisterScreen(),
        login: (context) => const LoginScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        parentHome: (context) => const ParentDashboard(),
        addChildScreen: (context)=> const AddChildScreen()
      };

  // Helper function for clean navigation
  static void push(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
}
