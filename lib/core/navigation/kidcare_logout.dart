import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/healthcare_provider.dart';
import '../../providers/marketplace_orders_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/teacher_overview_provider.dart';
import '../../providers/teacher_homework_provider.dart';
import '../../providers/teacher_attendance_provider.dart';
import '../../providers/child_gamification_provider.dart';

Future<void> kidCareLogout(BuildContext context) async {
  final childProvider = Provider.of<ChildProvider>(context, listen: false);
  childProvider.stopListening();
  childProvider.stopListeningToLinkedChild();
  Provider.of<ChildGamificationProvider>(context, listen: false).unbindHomework();
  Provider.of<HealthcareProvider>(context, listen: false).stopListening();
  Provider.of<MarketplaceOrdersProvider>(context, listen: false).stopListening();
  Provider.of<MessagingProvider>(context, listen: false).stopListening();
  Provider.of<TeacherOverviewProvider>(context, listen: false).stopListening();
  Provider.of<TeacherHomeworkProvider>(context, listen: false).stopListening();
  Provider.of<TeacherAttendanceProvider>(context, listen: false).stopListening();
  await Provider.of<AuthProvider>(context, listen: false).logout();
  if (!context.mounted) return;
  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.roleSelection, (_) => false);
}
