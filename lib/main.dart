import 'package:child_and_student_care_and_tracking_app/core/theme/app_theme.dart';
import 'package:child_and_student_care_and_tracking_app/firebase_options.dart';
import 'package:child_and_student_care_and_tracking_app/screens/auth/register_screen.dart';
import 'package:child_and_student_care_and_tracking_app/screens/auth/role_selection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/constants/routes.dart';

void main() async {
  //for ensuring flutetr engine is loaded before firebase starts
  WidgetsFlutterBinding.ensureInitialized();

  //Initializes Firebase with the generated options(Connect to Firebase using the auto-generated options)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Student and child Care Track System',
      debugShowCheckedModeBanner: false,
      //our themes applied here
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      //the ff setting lets the system choose(or we can force one)
      themeMode: ThemeMode.system,

      //define the 'Home' page
      initialRoute: AppRoutes.roleSelection,

      //define the 'Map' of routes
      routes: AppRoutes.routes,

    );
  }
}