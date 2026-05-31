import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/healthcare_provider.dart';
import '../../providers/marketplace_orders_provider.dart';

Future<void> kidCareLogout(BuildContext context) async {
  Provider.of<ChildProvider>(context, listen: false).stopListening();
  Provider.of<HealthcareProvider>(context, listen: false).stopListening();
  Provider.of<MarketplaceOrdersProvider>(context, listen: false).stopListening();
  await Provider.of<AuthProvider>(context, listen: false).logout();
  if (!context.mounted) return;
  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.roleSelection, (_) => false);
}
