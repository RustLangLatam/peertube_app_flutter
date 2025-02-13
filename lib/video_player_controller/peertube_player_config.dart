import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:river_player/river_player.dart';

import 'peerTube_player_controls_config.dart';

/// A utility class for configuring BetterPlayer with a PeerTube-style theme.
///
/// Provides multiple static methods to return different configurations
/// based on use cases like default playback, live streaming, and more.
class PeerTubePlayerConfig {
  /// Returns a `BetterPlayerConfiguration` with the standard settings.
  ///
  /// - [isLive] Set to `true` for live streaming configuration.
  /// - [aspectRatio] Defines the aspect ratio of the video.
  /// - [autoPlay] Determines if the video should start playing automatically.
  /// - [thumbnailURL] URL for the placeholder image before the video plays.
  static BetterPlayerConfiguration defaultConfig({
    bool isLive = false,
    double aspectRatio = 16 / 9,
    bool autoPlay = true,
    bool handleLifecycle = true,
    bool showPlaceholderUntilPlay = true,
    String? thumbnailURL,
  }) {
    return BetterPlayerConfiguration(
      aspectRatio: aspectRatio,
      fit: BoxFit.contain,
      autoPlay: autoPlay,
      looping: !isLive,
      controlsConfiguration: isLive
          ? PeerTubePlayerControlsConfig.liveStreamConfig()
          : PeerTubePlayerControlsConfig.defaultConfig(),
      allowedScreenSleep: false,
      autoDetectFullscreenDeviceOrientation: true,
      autoDetectFullscreenAspectRatio: true,
      handleLifecycle: handleLifecycle,
      expandToFill: true,
      showPlaceholderUntilPlay: showPlaceholderUntilPlay,
      systemOverlaysAfterFullScreen: [SystemUiOverlay.top],
      placeholder: thumbnailURL != null
          ? CachedNetworkImage(imageUrl: thumbnailURL, fit: BoxFit.contain)
          : null,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        // DeviceOrientation.portraitDown,
        // DeviceOrientation.landscapeLeft,
        // DeviceOrientation.landscapeRight,
      ],
      // deviceOrientationsOnFullScreen : const [
      //   DeviceOrientation.landscapeLeft,
        // DeviceOrientation.landscapeRight,
      // ],
    );
  }

  /// Returns a `BetterPlayerConfiguration` optimized for **live streaming**.
  static BetterPlayerConfiguration liveStreamConfig({
    double aspectRatio = 16 / 9,
    String? thumbnailURL,
  }) {
    return defaultConfig(
      isLive: true,
      aspectRatio: aspectRatio,
      autoPlay: true,
      handleLifecycle: false,
      showPlaceholderUntilPlay: false,
      thumbnailURL: thumbnailURL,
    );
  }

  /// Returns a `BetterPlayerConfiguration` optimized for **manual playback** (non-auto-play).
  static BetterPlayerConfiguration manualPlaybackConfig({
    double aspectRatio = 16 / 9,
    String? thumbnailURL,
  }) {
    return defaultConfig(
      isLive: false,
      aspectRatio: aspectRatio,
      autoPlay: false,
      handleLifecycle: true,
      showPlaceholderUntilPlay: true,
      thumbnailURL: thumbnailURL,
    );
  }
}
