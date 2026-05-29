import 'package:child_and_student_care_and_tracking_app/core/theme/app_theme.dart';
import 'package:child_and_student_care_and_tracking_app/firebase_options.dart';
import 'package:child_and_student_care_and_tracking_app/providers/auth_provider.dart';
import 'package:child_and_student_care_and_tracking_app/providers/child_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/routes.dart';
import 'core/navigation/auth_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.roleSelection,
      onGenerateRoute: AuthNavigation.routeFor,
    );
  }
}
