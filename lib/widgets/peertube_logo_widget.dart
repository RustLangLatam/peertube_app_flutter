import 'package:flutter/material.dart';

class PeerTubeLogoWidget extends StatelessWidget {
  const PeerTubeLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, top: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5), // Rounded corners
        ),
        padding: const EdgeInsets.all(2), // Inner padding
        child: Image.asset(
          "assets/logo.png",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class PeerTubeTextWidget extends StatelessWidget {
  final String? text; // Nullable text parameter
  final bool underlined; // 🔹 Controls underline visibility (default: false)

  const PeerTubeTextWidget({super.key, this.text, this.underlined = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            text != null
                ? Flexible(
                    child: Text(
                    text!,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                    overflow:
                        TextOverflow.ellipsis, // 🔹 Adds "..." if too long
                  ))
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
                          style: TextStyle(
                              color: Colors.orange), // "Tube" in orange
                        ),
                      ],
                    ),
                  ),
            if (underlined) // ✅ Add underline only when `underlined` is true
              Positioned(
                bottom: -2, // 🔹 Adjusts underline position
                left: 0,
                child: Container(
                  width:
                      constraints.maxWidth, // 🔹 Matches text width dynamically
                  height: 4,
                  color: Colors.orange, // 🔹 Underline color
                ),
              ),
          ],
        );
      },
    );
  }
}

class PeerTubeBannerWidget extends StatelessWidget {
  const PeerTubeBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Container(
        color: Colors.transparent,
        child: Image.asset(
          "assets/peertube-banner.png",
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
