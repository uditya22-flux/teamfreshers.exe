import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'student_home_page.dart';

class StudentRegisterPage extends StatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController studentId = TextEditingController();

  String? selectedDepartment;
  String? selectedSemester;

  File? profileImage;

  final List<String> departments = [
    "COMPUTER SCIENCE ENGINEERING",
    "CIVIL ENGINEERING",
    "MECHANICAL ENGINEERING",
    "FIRE AND SAFETY",
    "ELECTRICAL ENGINEERING",
    "ELECTRONICS AND COMMUNICATION ENGINEERING",
    "PHOTONICS",
    "MATHEMATICS",
    "PHYSICS",
  ];

  final List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<String> uploadImage(String uid) async {
    final storageRef = FirebaseStorage.instance.ref().child(
      "students/$uid/profile.jpg",
    );

    await storageRef.putFile(profileImage!);
    return await storageRef.getDownloadURL();
  }

  Future<void> registerStudent() async {
    if (name.text.isEmpty ||
        studentId.text.isEmpty ||
        selectedDepartment == null ||
        selectedSemester == null ||
        profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and upload image"),
        ),
      );
      return;
    }

    final email = "${studentId.text}@student.app";
    const defaultPassword = "123456";

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: defaultPassword,
    );

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final imageUrl = await uploadImage(uid);

    await FirebaseFirestore.instance.collection("students").doc(uid).set({
      "name": name.text,
      "studentId": studentId.text,
      "department": selectedDepartment,
      "semester": selectedSemester,
      "email": email,
      "uid": uid,
      "profileImage": imageUrl,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Registration Successful")));

    Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const StudentHomePage()),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B1A),
        title: const Text("Student Registration"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Profile Image
            Center(
              child: Material(
                elevation: 5,
                shadowColor: Colors.black26,
                color: Colors.white,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: pickImage,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: profileImage == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 45,
                            color: Colors.black54,
                          )
                        : Image.file(profileImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            buildTextField("Name", name),
            const SizedBox(height: 20),
            buildTextField("Student ID", studentId),
            const SizedBox(height: 20),

            // Department Dropdown
            buildDropdown(
              label: "Department",
              value: selectedDepartment,
              items: departments,
              onChanged: (value) {
                setState(() => selectedDepartment = value);
              },
            ),

            const SizedBox(height: 20),

            // Semester Dropdown
            buildDropdown(
              label: "Semester",
              value: selectedSemester,
              items: semesters,
              onChanged: (value) {
                setState(() => selectedSemester = value);
              },
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
                onPressed: registerStudent,
                child: const Text("Register", style: TextStyle(fontSize: 18)),
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
            isExpanded: true, // 🔥 prevents overflow
            decoration: const InputDecoration(border: InputBorder.none),
            hint: Text("Select $label"),

            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis, // 🔥 auto shrink
                    ),
                  ),
                )
                .toList(),

            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
