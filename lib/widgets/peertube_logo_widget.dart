import 'package:flutter/material.dart';

class PeerTubeLogoWidget extends StatelessWidget {
  final String? text; // Nullable text parameter

  const PeerTubeLogoWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 14.0, top: 10, bottom: 10),
        child:
            // PeerTube Logo from assets
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              padding: const EdgeInsets.all(2), // Inner padding
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
              ),
        ));
  }
}

class PeerTubeTextWidget extends StatelessWidget {
  final String? text; // Nullable text parameter

  const PeerTubeTextWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return // Display either the provided text or the default "PeerTube" styling
        text != null
            ? Text(
                text!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              )
            : RichText(
                text: const TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
                children: [
                  TextSpan(text: "Peer"), // "Peer" in white
                  TextSpan(
                    text: "Tube",
                    style: TextStyle(color: Colors.orange), // "Tube" in orange
                  ),
                ],
              ));
  }
}
