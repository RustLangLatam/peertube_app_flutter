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
  final double fontSize;

  const PeerTubeTextWidget({super.key, this.text, this.underlined = false, this.fontSize = 18.0});

  /// Removes the "Default" prefix if present
  String removeDefaultPrefix(String text) {
    const prefix = "Default";
    return text.startsWith(prefix)
        ? text.substring(prefix.length).trim()
        : text;
  }

  /// Capitalizes only the first letter of the string
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    final removedPrefix = removeDefaultPrefix(text);
    return removedPrefix[0].toUpperCase() + removedPrefix.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            text != null
                ? Text(
                    capitalizeFirstLetter(text!),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                    overflow:
                        TextOverflow.ellipsis, // 🔹 Adds "..." if too long
                  )
                : RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text
                      ),
                      children: const [
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
