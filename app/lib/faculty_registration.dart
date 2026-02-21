import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyRegisterPage extends StatefulWidget {
  const FacultyRegisterPage({super.key});

  @override
  State<FacultyRegisterPage> createState() => _FacultyRegisterPageState();
}

class _FacultyRegisterPageState extends State<FacultyRegisterPage> {
  final TextEditingController facultyName = TextEditingController();
  final TextEditingController facultyId = TextEditingController();

  String? selectedDepartment;

  final List<String> facultyDepartments = [
    "COMPUTER SCIENCE ENGINEERING",
    "CIVIL ENGINEERING",
    "MECHANICAL ENGINEERING",
    "ELECTRICAL ENGINEERING",
    "ELECTRONICS AND COMMUNICATION ENGINEERING",
    "PHOTONICS",
    "MATHEMATICS",
    "PHYSICS",
  ];

  Future<void> registerFaculty() async {
    if (facultyName.text.isEmpty ||
        facultyId.text.isEmpty ||
        selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      final email = "${facultyId.text}@faculty.app";
      const defaultPassword = "123456";

      // Create Firebase Auth account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: defaultPassword,
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Save to Firestore
      await FirebaseFirestore.instance.collection("faculty").doc(uid).set({
        "facultyName": facultyName.text,
        "facultyId": facultyId.text,
        "facultyDepartment": selectedDepartment,
        "email": email,
        "uid": uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faculty Registration Successful")),
      );

      Navigator.pop(context); // Go back after success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B1A),
        title: const Text("Faculty Registration"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 10),

            buildTextField("Faculty Name", facultyName),
            const SizedBox(height: 20),

            buildTextField("Faculty ID", facultyId),
            const SizedBox(height: 20),

            buildDropdown(
              label: "Faculty Department",
              value: selectedDepartment,
              items: facultyDepartments,
              onChanged: (value) =>
                  setState(() => selectedDepartment = value),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: registerFaculty,
                child: const Text(
                  "Register Faculty",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter $label",
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 18, right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none),
            hint: Text("Select $label"),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}