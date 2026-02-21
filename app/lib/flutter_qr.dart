import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LibraryEntryQR extends StatelessWidget {
  const LibraryEntryQR({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library Entry QR")),
      body: Center(
        child: QrImageView(
          data: "LIBRARY-ENTRY-123",   // <---- SCAN CODE CONTENT
          version: QrVersions.auto,
          size: 250,
        ),
      ),
    );
  }
}