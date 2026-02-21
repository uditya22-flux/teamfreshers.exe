import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_scanner_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int availableSeats = 0;
  bool loading = true;

  static const String validQr = "LIBRARY-ENTRY";  // <-- the only accepted QR text

  @override
  void initState() {
    super.initState();
    loadSeatCount();
  }

  Future<void> loadSeatCount() async {
    final doc = await FirebaseFirestore.instance
        .collection("library")
        .doc("info")
        .get();

    setState(() {
      availableSeats = doc.data()?["availableSeats"] ?? 0;
      loading = false;
    });
  }

  // 🔥 PROCESS A SCANNED QR CODE
  Future<void> processScan(String scanned) async {
    if (scanned != validQr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid QR Code")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final studentDoc = await FirebaseFirestore.instance
        .collection("students")
        .doc(user.uid)
        .get();

    if (!studentDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student record not found")),
      );
      return;
    }

    final student = studentDoc.data()!;
    final now = DateTime.now();

    await FirebaseFirestore.instance.collection("library_logs").add({
      "uid": user.uid,
      "name": student["name"],
      "studentId": student["studentId"],
      "department": student["department"],
      "semester": student["semester"],
      "timestamp": FieldValue.serverTimestamp(),
      "date": "${now.year}-${now.month}-${now.day}",
      "time": "${now.hour}:${now.minute}:${now.second}",
      "status": "checked_in",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Check-in recorded successfully")),
    );
  }

  // UI remains EXACTLY as you provided
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  const SizedBox(height: 20),
                  qrCard(),
                  const SizedBox(height: 20),
                  seatInfoCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF6A1B1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(70),
          bottomRight: Radius.circular(70),
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.arrow_back, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Library",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget qrCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2, size: 50, color: Colors.brown),
          const SizedBox(height: 10),
          const Text(
            "Scan QR to Check In",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            "Scan the QR code at the library entrance to mark attendance",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final scanned = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerPage()),
              );

              if (scanned != null) {
                await processScan(scanned);
              }
            },
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xFF6A1B1A),
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Open Camera to Scan",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget seatInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF6A1B1A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_seat, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Text(
            "Available Seats: $availableSeats",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}