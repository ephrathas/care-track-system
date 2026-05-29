import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../constants/user_role.dart';
import 'auth_page_route.dart';

/// Central auth navigation so routes work from [AuthWrapper] and pushed screens.
class AuthNavigation {
  AuthNavigation._();

  static Future<void> openOnboarding(BuildContext context, UserRole role) {
    return Navigator.of(context).pushNamed(
      AppRoutes.onboarding,
      arguments: role.label,
    );
  }

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

  /// Slide + fade transitions for auth screens; standard route elsewhere.
  static Route<dynamic> routeFor(RouteSettings settings) {
    final builder = AppRoutes.routes[settings.name];
    if (builder == null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
    }
    if (AuthRoutes.isAuthPath(settings.name)) {
      return AuthPageRoute(builder: builder, settings: settings);
    }
    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
