import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to KinderCare",
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 10),
            const Text("Please select your role to continue"),
            const SizedBox(height: 30),
            // Example of one card - he should repeat this for all 4 roles
            _roleCard(context, "Parent", Icons.family_restroom),
            _roleCard(context, "Teacher", Icons.school),
            _roleCard(context, "Healthcare", Icons.medical_services),
            _roleCard(context, "Child", Icons.child_care),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Task for later: Navigate to Register Screen with this role
          // Navigate to Register Screen and pass the selected role
          Navigator.pushNamed(context, '/register', arguments: title);
        },
      ),
    );
  }
}
