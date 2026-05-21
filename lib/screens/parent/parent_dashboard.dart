import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.logout))],
      ),
      body: const Center(
        child: Text("Welcome! You haven't added any children yet."),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 🚀 YOUR NEXT TASK: Navigate to Add Child Form
        },
        label: const Text("Add Child"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
