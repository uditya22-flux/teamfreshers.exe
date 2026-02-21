import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentRegisterPage extends StatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController studentId = TextEditingController();
  final TextEditingController department = TextEditingController();
  final TextEditingController semester = TextEditingController();

  Future<void> registerStudent() async {
    if (name.text.isEmpty ||
        studentId.text.isEmpty ||
        department.text.isEmpty ||
        semester.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    // TEMP EMAIL FOR LOGIN (studentId@college.com)
    final email = "${studentId.text}@student.app";
    const defaultPassword = "123456";

    // Create account
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: defaultPassword,
    );

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Store detailed data
    await FirebaseFirestore.instance.collection("students").doc(uid).set({
      "name": name.text,
      "studentId": studentId.text,
      "department": department.text,
      "semester": semester.text,
      "email": email,
      "uid": uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration Successful")),
    );

    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE7),
      appBar: AppBar(
        title: const Text("Student Registration"),
        backgroundColor: const Color(0xFF6A1B1A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            buildField("Name", name),
            const SizedBox(height: 20),
            buildField("Student ID", studentId),
            const SizedBox(height: 20),
            buildField("Department", department),
            const SizedBox(height: 20),
            buildField("Semester", semester),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B1A),
              ),
              onPressed: registerStudent,
              child: const Text("Register"),
            )
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6)
              ]),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter $label",
            ),
          ),
        )
      ],
    );
  }
}