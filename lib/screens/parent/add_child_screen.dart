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
    // 1. Validate fields aren't empty
    if (_nameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both name and age")),
      );
      return;
    }

    // 2. Safe Parsing (Prevents app crash if user types letters in age)
    final int? age = int.tryParse(_ageController.text.trim());
    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number for age")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final child = ChildModel(
        id: '',
        name: _nameController.text.trim(),
        age: age,
        parentId: FirebaseAuth.instance.currentUser!.uid,
        imageUrl: '',
      );

      await DatabaseService().addChild(child);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Child Added Successfully!"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // 3. Stop loading if Firebase fails
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to save. Check your connection."),
              backgroundColor: Colors.red),
        );
      }
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
