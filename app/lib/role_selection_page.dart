import 'package:flutter/material.dart';
import 'student_register_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Circle
              Container(
                height: 110,
                width: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 50,
                  color: Color(0xFF6A1B1A),
                ),
              ),

              const SizedBox(height: 20),

              // College Name (Editable)
              const Text(
                "Cusatify",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B1A),
                ),
              ),

              const Text(
                "Select Identity",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),

              const SizedBox(height: 35),

              // Role Toggle (Student / Faculty)
              Container(
                height: 55,
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    _buildRoleOption("Student"),
                    _buildRoleOption("Faculty"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedRole == null
                        ? Colors.grey.shade400
                        : const Color(0xFF6A1B1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  onPressed: selectedRole == null
    ? null
    : () {
        if (selectedRole == "Student") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentRegisterPage(),
            ),
          );
        }

        if (selectedRole == "Faculty") {
        }
      },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_right_alt),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Role Option Widget
  Widget _buildRoleOption(String role) {
    bool isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6A1B1A) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: isSelected ? 17 : 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}