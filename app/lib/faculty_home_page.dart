import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_page.dart';
import 'create_event_page.dart';
import 'role_selection_page.dart';
import 'flutter_qr.dart';
import 'attendance_qr_page.dart';

class FacultyHomePage extends StatefulWidget {
  const FacultyHomePage({super.key});

  @override
  State<FacultyHomePage> createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  Map<String, dynamic>? faculty;
  String selectedSemester = "1";
  int studentCount = 0;
  bool loadingCount = false;
  List<Map<String, dynamic>> timetableEntries = [];
  bool loadingTimetable = false;

  final List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  void initState() {
    super.initState();
    loadFacultyData();
  }

  Future<void> loadFacultyData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection("faculty")
        .doc(uid)
        .get();

    if (mounted) {
      setState(() {
        faculty = doc.data();
        selectedSemester = faculty?["semester"] ?? "1";
      });
      loadStudentCount();
      loadTimetable();
    }
  }

  Future<void> loadStudentCount() async {
    setState(() => loadingCount = true);

    final query = await FirebaseFirestore.instance
        .collection("students")
        .where("semester", isEqualTo: selectedSemester)
        .get();

    if (mounted) {
      setState(() {
        studentCount = query.docs.length;
        loadingCount = false;
      });
    }
  }

  Future<void> loadTimetable() async {
    setState(() => loadingTimetable = true);

    final query = await FirebaseFirestore.instance
        .collection("faculty")
        .where("semester", isEqualTo: selectedSemester)
        .get();

    if (mounted) {
      setState(() {
        timetableEntries = query.docs
            .map((d) => d.data())
            .toList();
        loadingTimetable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4),
      body: faculty == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: const Color(0xFF6A1B1A),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      "Faculty Dashboard",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A1B1A), Color(0xFF9A2B2A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
                          (_) => false,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        profileCard(),
                        const SizedBox(height: 25),
                        semesterSelector(),
                        const SizedBox(height: 20),
                        statsSection(),
                        const SizedBox(height: 25),
                        timetableCard(),
                        const SizedBox(height: 25),
                        generateQRButton(),
                        const SizedBox(height: 14),
                        markAttendanceButton(),
                        const SizedBox(height: 14),
                        showLibraryQRButton(),
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventPage()),
          );
        },
        backgroundColor: Colors.deepOrange.shade700,
        icon: const Icon(Icons.event_available),
        label: const Text("Create Event", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget generateQRButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceQRPage(
              facultyUid: FirebaseAuth.instance.currentUser!.uid,
              facultyName: faculty!["facultyName"] ?? "Faculty",
              subject: faculty!["subject"] ?? "N/A",
              semester: faculty!["semester"] ?? "1",
            ),
          ),
        );
      },
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF6A1B1A).withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_rounded, color: Color(0xFF6A1B1A)),
            SizedBox(width: 12),
            Text("Generate Attendance QR", style: TextStyle(color: Color(0xFF6A1B1A), fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget profileCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B1A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B1A), Color(0xFF9A2B2A)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faculty!["facultyName"] ?? "",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dept: ${faculty!["facultyDepartment"] ?? ""}",
                  style: const TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  "ID: ${faculty!["facultyId"]}",
                  style: const TextStyle(color: Colors.black45, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget semesterSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, color: Color(0xFF6A1B1A), size: 20),
          const SizedBox(width: 15),
          const Text("Select Semester:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSemester,
                items: semesters.map((s) => DropdownMenuItem(value: s, child: Text("Semester $s"))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selectedSemester = val);
                    loadStudentCount();
                    loadTimetable();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statsSection() {
    return Row(
      children: [
        Expanded(
          child: statCard(
            "Total Students",
            studentCount.toString(),
            Icons.people_alt_rounded,
            const Color(0xFF6A1B1A),
            loadingCount,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: statCard(
            "My Subject",
            faculty!["subject"] ?? "N/A",
            Icons.book_rounded,
            Colors.teal.shade700,
            false,
          ),
        ),
      ],
    );
  }

  Widget statCard(String title, String value, IconData icon, Color color, bool loading) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 15),
          loading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          Text(title, style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget timetableCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_view_day_rounded, color: Color(0xFF6A1B1A)),
              const SizedBox(width: 12),
              const Text("Faculty & Subjects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          loadingTimetable
              ? const Center(child: CircularProgressIndicator())
              : timetableEntries.isEmpty
                  ? const Text("No records found", style: TextStyle(color: Colors.black26))
                  : Column(
                      children: timetableEntries.map((f) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF7F4),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF6A1B1A).withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1B1A).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Color(0xFF6A1B1A), size: 20),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f["subject"] ?? "", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                  Text("${f["facultyName"]} • ${f["facultyDepartment"]}",
                                      style: const TextStyle(color: Colors.black45, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
        ],
      ),
    );
  }

  Widget markAttendanceButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendancePage(
              semester: selectedSemester,
              facultySubject: faculty!["subject"] ?? "",
            ),
          ),
        );
      },
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6A1B1A), Color(0xFF9A2B2A)]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6A1B1A).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fact_check_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text("Mark Attendance", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget showLibraryQRButton() {
    return TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: Colors.brown.shade800),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryEntryQR()));
      },
      icon: const Icon(Icons.qr_code_2_rounded),
      label: const Text("Show Library Entry QR", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
