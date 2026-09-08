import 'package:flutter/material.dart';

class ScannerFrameOverlay extends StatelessWidget {
  const ScannerFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}