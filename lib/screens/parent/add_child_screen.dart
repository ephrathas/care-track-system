import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/child_model.dart';
import '../../services/database_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;

  void _saveChild() async {
    setState(() => _isLoading = true);

    // Create the child object
    final child = ChildModel(
      id: '', // Firestore generates this automatically
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      parentId: FirebaseAuth.instance.currentUser!.uid,
      imageUrl: '', // We will handle photos later
    );

    await DatabaseService().addChild(child);

    if (mounted) {
      Navigator.pop(context); // Go back to dashboard after saving
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Child Added Successfully!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Child Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Child's Name")),
            TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChild,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Save Profile"),
            )
          ],
        ),
      ),
    );
  }
}
