import 'package:flutter/material.dart';
import 'package:river_player/river_player.dart';

class VideoPlayerControllerService {
  late BetterPlayerController _controller;
  bool _isInitialized = false;

  /// Initialize the video player with the given URL and settings
  Future<void> initializePlayer(String videoUrl, bool isLive) async {
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
        looping: !isLive,
        controlsConfiguration: _peerTubeControls, // Custom controls
      ),
    );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      useAsmsSubtitles: false,
      liveStream: isLive,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: !isLive,
        maxCacheSize: 100 * 1024 * 1024, // 100 MB
        maxCacheFileSize: 10 * 1024 * 1024, // 10 MB
        key: "peerTubeCache_$videoUrl",
      ),
      bufferingConfiguration: BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 10000,
        bufferForPlaybackMs: 2500,
        bufferForPlaybackAfterRebufferMs: 5000,
      ),
    );

    await _controller.setupDataSource(dataSource);
    _isInitialized = true;
  }

  /// Get the player controller instance
  BetterPlayerController get controller => _controller;

  /// Check if the player is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose of the player when no longer needed
  void dispose() {
    _controller.dispose();
  }
}

/// Configuration for the video player controls
const BetterPlayerControlsConfiguration _peerTubeControls =
BetterPlayerControlsConfiguration(
  showControlsOnInitialize: false,
  controlBarColor: Colors.black54, // Semi-transparent black
  textColor: Colors.white, // White text
  iconsColor: Colors.white, // White icons
  progressBarPlayedColor: Colors.redAccent, // YouTube-style progress bar
  progressBarHandleColor: Colors.white, // White handle
  progressBarBufferedColor: Colors.grey, // Buffered video color
  progressBarBackgroundColor: Colors.white30, // Background of progress bar
  loadingColor: Colors.red, // Red loading indicator
  backgroundColor: Color(0xFF13100E), // Clean black background
  overflowModalColor: Colors.black87, // Dark modal background
  overflowModalTextColor: Colors.white, // White text in modal
  overflowMenuIconsColor: Colors.white, // White icons in menu
  enableFullscreen: true,
  enablePip: true, // Picture-in-Picture mode
  enableProgressText: true, // Show playback time
  enableProgressBar: true,
  enableProgressBarDrag: true, // Allow dragging the progress bar
  enablePlayPause: true,
  enableSkips: true,
  enableSubtitles: true, // Enable subtitles
  enableQualities: true, // Enable quality selection
  enablePlaybackSpeed: true, // Enable speed adjustment
  enableRetry: true,
  enableAudioTracks: true,
  controlBarHeight: 50, // Increased for better usability
  overflowMenuIcon: Icons.settings, // Use a settings icon
  subtitlesIcon: Icons.closed_caption, // Subtitle icon
  playbackSpeedIcon: Icons.speed, // Playback speed icon
  qualitiesIcon: Icons.high_quality, // Quality icon
  forwardSkipTimeInMilliseconds: 10000, // Skip forward 10 sec
  backwardSkipTimeInMilliseconds: 10000, // Skip backward 10 sec
  controlsHideTime: Duration(milliseconds: 100), // Auto-hide controls after 3s
);