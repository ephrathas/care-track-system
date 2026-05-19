import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Controllers to capture text
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Parent';
  final List<String> _roles = ['Parent', 'Teacher', 'Child', 'Healthcare'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        // 🚀 Fixes keyboard overflow
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Join KinderCare",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Create an account to start tracking",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Full Name Field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Role Selection Dropdown
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: "Select Role",
                prefixIcon: Icon(Icons.assignment_ind_outlined),
                border: OutlineInputBorder(),
              ),
              items: _roles
                  .map((role) =>
                      DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 32),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // We will call Ephratha's logic here next
                  print("Signing up: ${_nameController.text}");
                },
                child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
