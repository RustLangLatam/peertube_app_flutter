import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:peertube_toolkit/peertube_toolkit.dart';

class PeerTubeLogoWidget extends StatefulWidget {
  final bool? isLoading;

  const PeerTubeLogoWidget({super.key, this.isLoading});

  @override
  State<PeerTubeLogoWidget> createState() => _PeerTubeLogoWidgetState();
}

class _PeerTubeLogoWidgetState extends State<PeerTubeLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasCompletedInitialRotation = false; // Tracks initial 180° rotation

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 180° rotation speed
    );

    _animation = Tween<double>(begin: 0, end: 0.5) // 180 degrees (0.5 of a full turn)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      setState(() {
        _hasCompletedInitialRotation = true;
      });
      _toggleAnimation(widget.isLoading);
    });
  }

  @override
  void didUpdateWidget(covariant PeerTubeLogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toggleAnimation(widget.isLoading);
  }

  void _toggleAnimation(bool? isLoading) {
    if (_hasCompletedInitialRotation) {
      if (isLoading == true) {
        _controller.repeat(); // Start continuous rotation
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, top: 10, bottom: 10),
      child: RotationTransition(
        turns: _animation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            "assets/logo.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}


class PeerTubeTextWidget extends StatelessWidget {
  final String? text; // Nullable text parameter
  final bool underlined; // 🔹 Controls underline visibility (default: false)
  final double fontSize;

  const PeerTubeTextWidget(
      {super.key, this.text, this.underlined = false, this.fontSize = 18.0});

  /// Capitalizes only the first letter of the string
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    final removedPrefix = TextUtils.removeDefaultPrefix(text);
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
