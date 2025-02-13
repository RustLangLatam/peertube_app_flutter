import 'package:flutter/material.dart';
import 'package:river_player/river_player.dart';

/// A utility class for configuring video player controls with
/// a PeerTube-style theme and advanced customization.
class PeerTubePlayerControlsConfig {
  /// Returns a `BetterPlayerControlsConfiguration` with custom settings.
  ///
  /// - [showControlsOnInitialize] Determines if controls should be visible on startup.
  /// - [enableFullscreen] Enables/disables fullscreen mode.
  /// - [enablePip] Enables/disables Picture-in-Picture mode.
  /// - [progressBarColor] Custom color for the played portion of the progress bar.
  /// - [bufferedColor] Custom color for the buffered portion of the progress bar.
  /// - [backgroundColor] Background color for the control overlay.
  /// - [loadingIndicatorColor] Color of the loading indicator.
  /// - [autoHideControlsDuration] Duration before controls automatically hide.
  static BetterPlayerControlsConfiguration defaultConfig({
    bool showControlsOnInitialize = false,
    bool enableFullscreen = true,
    bool enablePip = true,
    Color progressBarColor = Colors.deepOrange,
    Color bufferedColor = const Color(0xFF28A745),
    Color backgroundColor = const Color(0xFF13100E),
    Color loadingIndicatorColor = Colors.orange,
    Duration autoHideControlsDuration = const Duration(milliseconds: 300),
  }) {
    return BetterPlayerControlsConfiguration(
      showControlsOnInitialize: showControlsOnInitialize,
      controlBarColor: Colors.black54,
      textColor: Colors.white,
      iconsColor: Colors.white,
      progressBarPlayedColor: progressBarColor,
      progressBarHandleColor: Colors.white,
      progressBarBufferedColor: bufferedColor,
      progressBarBackgroundColor: Colors.white30,
      loadingColor: loadingIndicatorColor,
      liveTextColor: Colors.redAccent,
      backgroundColor: backgroundColor,
      overflowModalColor: Colors.black87,
      overflowModalTextColor: Colors.white,
      overflowMenuIconsColor: Colors.white,
      enableFullscreen: enableFullscreen,
      enablePip: enablePip,
      enableProgressText: true,
      enableProgressBar: true,
      enableProgressBarDrag: true,
      enablePlayPause: true,
      enableSkips: true,
      enableSubtitles: true,
      enableQualities: true,
      enablePlaybackSpeed: true,
      enableRetry: true,
      enableAudioTracks: true,
      controlBarHeight: 50,
      overflowMenuIcon: Icons.settings,
      subtitlesIcon: Icons.closed_caption,
      playbackSpeedIcon: Icons.speed,
      qualitiesIcon: Icons.high_quality,
      forwardSkipTimeInMilliseconds: 10000,
      backwardSkipTimeInMilliseconds: 10000,
      controlsHideTime: autoHideControlsDuration,
    );
  }

  /// Returns a minimalistic configuration with only essential controls.
  static BetterPlayerControlsConfiguration minimalConfig({
    bool enableFullscreen = true,
    bool enablePip = true,
  }) {
    return BetterPlayerControlsConfiguration(
      showControlsOnInitialize: false,
      controlBarColor: Colors.black54,
      textColor: Colors.white,
      iconsColor: Colors.white,
      progressBarPlayedColor: Colors.deepOrange,
      progressBarHandleColor: Colors.white,
      progressBarBufferedColor: Colors.grey,
      progressBarBackgroundColor: Colors.white30,
      loadingColor: Colors.orange,
      backgroundColor: Colors.black,
      enableFullscreen: enableFullscreen,
      enablePip: enablePip,
      enableProgressText: true,
      enableProgressBar: true,
      enableProgressBarDrag: true,
      enablePlayPause: true,
      enableSkips: false,
      enableSubtitles: false,
      enableQualities: false,
      enablePlaybackSpeed: false,
      enableRetry: true,
      enableAudioTracks: false,
      controlBarHeight: 40,
      overflowMenuIcon: Icons.more_vert,
      forwardSkipTimeInMilliseconds: 5000,
      backwardSkipTimeInMilliseconds: 5000,
      controlsHideTime: const Duration(seconds: 2),
    );
  }

  /// Returns a configuration optimized for live streaming playback.
  static BetterPlayerControlsConfiguration liveStreamConfig() {
    return BetterPlayerControlsConfiguration(
      showControlsOnInitialize: false,
      controlBarColor: Colors.black54,
      textColor: Colors.white,
      iconsColor: Colors.white,
      progressBarPlayedColor: Colors.redAccent,
      progressBarHandleColor: Colors.white,
      progressBarBufferedColor: Colors.grey,
      progressBarBackgroundColor: Colors.white30,
      loadingColor: Colors.orange,
      backgroundColor: Colors.black,
      enableFullscreen: true,
      enablePip: true,
      enableProgressText: false,
      enableProgressBar: false,
      enableProgressBarDrag: false,
      enablePlayPause: true,
      enableSkips: false,
      enableSubtitles: true,
      enableQualities: true,
      enablePlaybackSpeed: false,
      enableRetry: true,
      enableAudioTracks: true,
      controlBarHeight: 45,
      overflowMenuIcon: Icons.more_vert,
      liveTextColor: Colors.redAccent,
      controlsHideTime: const Duration(seconds: 2),
    );
  }
}

// /// Configuration for the video player controls
// BetterPlayerControlsConfiguration peerTubeControls =
//     BetterPlayerControlsConfiguration(
//   showControlsOnInitialize: false,
//
//   controlBarColor: Colors.black54, // Semi-transparent black
//   textColor: Colors.white, // White text
//   iconsColor: Colors.white, // White icons
//   progressBarPlayedColor: Colors.deepOrange, // YouTube-style progress bar
//   progressBarHandleColor: Colors.white, // White handle
//   progressBarBufferedColor: Color(0xFF28A745), // Buffered video color
//   progressBarBackgroundColor: Colors.white30, // Background of progress bar
//   loadingColor: Colors.orange, // Red loading indicator
//   // loadingWidget: UIUtils.networkImageShimmerPlaceholder(),
//   liveTextColor: Colors.redAccent,
//   backgroundColor: Color(0xFF13100E), // Clean black background
//   overflowModalColor: Colors.black87, // Dark modal background
//   overflowModalTextColor: Colors.white, // White text in modal
//   overflowMenuIconsColor: Colors.white, // White icons in menu
//   enableFullscreen: true,
//   enablePip: true, // Picture-in-Picture mode
//   enableProgressText: true, // Show playback time
//   enableProgressBar: true,
//   enableProgressBarDrag: true, // Allow dragging the progress bar
//   enablePlayPause: true,
//   enableSkips: true,
//   enableSubtitles: true, // Enable subtitles
//   enableQualities: true, // Enable quality selection
//   enablePlaybackSpeed: true, // Enable speed adjustment
//   enableRetry: true,
//   enableAudioTracks: true,
//   controlBarHeight: 50, // Increased for better usability
//   overflowMenuIcon: Icons.settings, // Use a settings icon
//   subtitlesIcon: Icons.closed_caption, // Subtitle icon
//   playbackSpeedIcon: Icons.speed, // Playback speed icon
//   qualitiesIcon: Icons.high_quality, // Quality icon
//   // pipMenuIcon: Icons.picture_as_pdf_sharp, // Picture-in-Picture icon
//   forwardSkipTimeInMilliseconds: 10000, // Skip forward 10 sec
//   backwardSkipTimeInMilliseconds: 10000, // Skip backward 10 sec
//   controlsHideTime: Duration(milliseconds: 200), // Auto-hide controls after 3s
// );
