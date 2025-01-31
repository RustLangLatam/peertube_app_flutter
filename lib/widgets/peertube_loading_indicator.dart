import 'package:flutter/material.dart';

/// **Unified Loading Indicator for Refresh & Pagination**
class PeerTubeLoadingIndicator extends StatelessWidget {
  final bool isPagination; // If true, it’s for pagination; else, it's for refresh.

  const PeerTubeLoadingIndicator({super.key, required this.isPagination});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: isPagination
            ? const EdgeInsets.symmetric(vertical: 15) // Pagination spacing
            : const EdgeInsets.only(top: 20), // Refresh spacing
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6600)), // PeerTube Orange
            backgroundColor: Colors.black87, // Dark background
          ),
        ),
      ),
    );
  }
}
