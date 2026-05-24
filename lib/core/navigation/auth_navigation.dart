import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../constants/user_role.dart';

/// Central auth navigation so routes work from [AuthWrapper] and pushed screens.
class AuthNavigation {
  AuthNavigation._();

  static Future<void> openRegister(BuildContext context, UserRole role) {
    return Navigator.of(context).pushNamed(
      AppRoutes.register,
      arguments: role.label,
    );
  }

  static Future<void> openLogin(BuildContext context) {
    return Navigator.of(context).pushNamed(AppRoutes.login);
  }

  static Future<void> openRoleSelection(BuildContext context) {
    return Navigator.of(context).pushNamed(AppRoutes.welcomeRoleSelection);
  }

  static Future<void> openForgotPassword(BuildContext context) {
    return Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }
}
