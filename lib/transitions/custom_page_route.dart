import 'package:flutter/material.dart';

import 'fade_transition.dart';
import 'scale_transition.dart';
import 'slide_transition.dart';

/// Enum representing the different types of transitions.
///
/// Each value in this enum corresponds to a specific transition type.
enum TransitionType {
  /// A fade transition, where the new page fades in.
  fade,

  /// A slide transition, where the new page slides in from the right.
  slide,

  /// A scale transition, where the new page scales up from a small size.
  scale,
}

/// A helper class for selecting and building page routes with different transition types.
///
/// This class provides a simple way to create page routes with various transition effects.
class CustomPageRoute {
  /// A map of transition types to their corresponding page route builders.
  ///
  /// Each entry in this map represents a transition type and its associated page route builder.
  static final _pageRoutes = {
    TransitionType.fade: (page) => FadePageRoute(page: page),
    TransitionType.slide: (page) => SlidePageRoute(page: page),
    TransitionType.scale: (page) => ScalePageRoute(page: page),
  };

  /// Builds a page route with the specified transition type.
  ///
  /// This method takes a widget and a transition type, and returns a page route with the corresponding transition effect.
  ///
  /// Args:
  ///   page: The widget to be used as the content of the page route.
  ///   type: The transition type to be used for the page route.
  ///
  /// Returns:
  ///   A page route with the specified transition type.
  static PageRoute build(Widget page, TransitionType type) =>
      _pageRoutes[type]!(page);

  /// Builds a page route with a fade transition.
  ///
  /// This method is a convenience wrapper around [build] that uses [TransitionType.fade] as the transition type.
  ///
  /// Args:
  ///   page: The widget to be used as the content of the page route.
  ///
  /// Returns:
  ///   A page route with a fade transition.
  static PageRoute fade(Widget page) => build(page, TransitionType.fade);

  /// Builds a page route with a slide transition.
  ///
  /// This method is a convenience wrapper around [build] that uses [TransitionType.slide] as the transition type.
  ///
  /// Args:
  ///   page: The widget to be used as the content of the page route.
  ///
  /// Returns:
  ///   A page route with a slide transition.
  static PageRoute slide(Widget page) => build(page, TransitionType.slide);

  /// Builds a page route with a scale transition.
  ///
  /// This method is a convenience wrapper around [build] that uses [TransitionType.scale] as the transition type.
  ///
  /// Args:
  ///   page: The widget to be used as the content of the page route.
  ///
  /// Returns:
  ///   A page route with a scale transition.
  static PageRoute scale(Widget page) => build(page, TransitionType.scale);
}
