import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

class LicenseBadge extends StatelessWidget {
  final VideoConstantNumberLicence? licenseLabel;

  const LicenseBadge({super.key, this.licenseLabel});

  @override
  Widget build(BuildContext context) {
    if (licenseLabel == null || licenseLabel!.label!.isEmpty) {
      return const SizedBox.shrink(); // No license available
    }

    return GestureDetector(
      onTap: () => _showLicenseModal(context), // Open modal on tap
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.policy, size: 12, color: Colors.white70), // License Icon
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                licenseLabel!.label!,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Truncate with "..."
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **Show full license label in a modal**
  void _showLicenseModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            "License Information",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: Text(
            licenseLabel!.label!,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }
}
