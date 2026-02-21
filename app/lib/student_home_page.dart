import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B1A),
        title: const Text("Student Dashboard"),
      ),
      body: const Center(
        child: Text(
          "Welcome Student!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}