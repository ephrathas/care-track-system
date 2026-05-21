import 'package:child_and_student_care_and_tracking_app/screens/parent/add_child_screen.dart';
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
          Navigator.pushNamed(context, '/add_child'); 
        },
        label: const Text("Add Child"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
