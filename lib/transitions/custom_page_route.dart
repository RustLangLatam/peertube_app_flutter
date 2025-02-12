import 'package:flutter/material.dart';

import 'fade_transition.dart';
import 'scale_transition.dart';
import 'slide_transition.dart';

/// Type of transition
enum TransitionType { fade, slide, scale }

/// A helper function to select any transition type dynamically.
class CustomPageRoute {
  static PageRoute build(Widget page, TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return FadePageRoute(page: page);
      case TransitionType.slide:
        return SlidePageRoute(page: page);
      case TransitionType.scale:
        return ScalePageRoute(page: page);
    }
  }
}
