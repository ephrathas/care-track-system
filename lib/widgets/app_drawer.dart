import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with App Logo/User Info
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white, child: Icon(Icons.person)),
            accountName: const Text("User Name"),
            accountEmail: const Text("user@email.com"),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text("My Children"),
            onTap: () {}, // Navigate to child list
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {}, // Ephratha will add logout logic here
          ),
        ],
      ),
    );
  }
}
