import 'package:flutter/material.dart';

/// A smoother scale transition with easing effect.
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  ScalePageRoute({required Widget page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutExpo, // ✅ Smooth acceleration
          ),
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
  );
}

