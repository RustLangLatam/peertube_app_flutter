import 'package:flutter/material.dart';

class UnsupportedFormatWidget extends StatelessWidget {
  const UnsupportedFormatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300, // Fixed width for the card
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // Dark background
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2C2C2C).withOpacity(0.8),
              const Color(0xFF1A1A1A).withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PeerTube logo or related icon
            Image.asset(
              'assets/logo.png', // Path to your PeerTube logo
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 20),

            // Main message
            const Text(
              "This video format is not supported yet.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Secondary message
            const Text(
              "Support for this format is coming soon!",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
