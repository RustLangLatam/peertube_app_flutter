import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:river_player/river_player.dart';

import '../utils/ui_utils.dart';
import '../utils/video_utils.dart';
import 'buffer_optimizer.dart';
import 'video_source_info.dart';

/// A service class for managing the video player controller.
class PeerTubePlayer {
  /// The internal video player controller instance.
  BetterPlayerController? _controller;

  /// Initialize the video player with the given URL and settings.
  ///
  /// This method sets up the video player with the provided [VideoSourceInfo]
  /// and prepares it for playback.
  ///
  /// [source] The video source information, including URL and settings.
  Future<void> initializePlayer(key, VideoDetails? videoDetails,
      {String? nodeUrl}) async {
    final source = VideoSourceInfo.extractBestVideoSource(videoDetails)!;

    String? thumbnailURL;

    // Determine the thumbnail URL
    if (videoDetails!.previewPath != null) {
      thumbnailURL = '$nodeUrl${videoDetails.previewPath}';
    }

    // Determine if the video is a live stream
    final bool isLive = source.isLive;

    // Create a new video player controller instance
    _controller = BetterPlayerController(
      // Configure the video player with custom settings
      BetterPlayerConfiguration(
        aspectRatio: 1.0, // Set the aspect ratio to 16:9
        fit: BoxFit.contain, // Fit the video to the container
        autoPlay: true, // Auto-play the video when ready
        looping: !isLive, // Loop the video if it's not a live stream
        controlsConfiguration: _peerTubeControls, // Use custom controls
        allowedScreenSleep: false, // Prevent screen sleep during playback
        autoDetectFullscreenDeviceOrientation: true,
        autoDetectFullscreenAspectRatio: true,
        placeholder:
            CachedNetworkImage(imageUrl: thumbnailURL!, fit: BoxFit.cover),
        showPlaceholderUntilPlay: true,
        handleLifecycle: !isLive,
      ),
    );

    // Create a data source for the video player
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network, // Use a network data source
      source.url, // Set the video URL
      videoFormat: source.type,
      useAsmsSubtitles: false, // Disable ASMS subtitles
      liveStream: isLive, // Set live stream flag
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: !isLive, // Cache video if it's not a live stream
        preCacheSize: 1 * 1024 * 1024, // Set pre-cache size to 1MB
        maxCacheSize: 250 * 1024 * 1024, // Set max cache size to 100MB
        maxCacheFileSize: 25 * 1024 * 1024, // Set max cache file size to 10MB
        key: source.isHLS()
            ? "peerTubeLiveCache_${source.url}"
            : "", // Set cache key for HLS live streams
      ),
      bufferingConfiguration: BufferOptimizer.getOptimalBufferConfig(
          source.duration ?? 0), // Set buffering configuration
      resolutions: source.resolutions, // Set video resolutions
      notificationConfiguration: thumbnailURL != null
          ? BetterPlayerNotificationConfiguration(
              showNotification: true,
              title: videoDetails.name,
              author: VideoUtils.extractDisplayName(videoDetails),
              imageUrl: thumbnailURL,
              activityName: 'PeerTubeVDev',
            )
          : const BetterPlayerNotificationConfiguration(
              showNotification: false),
    );

    // Set up the data source for the video player
    await _controller!.setupDataSource(dataSource);
    _controller!.setBetterPlayerGlobalKey(key);

    // Pre-cache the video data
    Future.microtask(() => _controller!.preCache(dataSource));
  }

  /// Get the player controller instance.
  ///
  /// Returns the internal video player controller instance.
  BetterPlayerController? get controller => _controller;

  bool get isVideoInitialized => _controller?.isVideoInitialized() ?? false;

  /// Dispose of the player when no longer needed.
  ///
  /// Releases system resources used by the video player.
  void dispose() {
    _controller?.dispose();
  }
}

/// Configuration for the video player controls
BetterPlayerControlsConfiguration _peerTubeControls =
    BetterPlayerControlsConfiguration(
  showControlsOnInitialize: false,

  controlBarColor: Colors.black54, // Semi-transparent black
  textColor: Colors.white, // White text
  iconsColor: Colors.white, // White icons
  progressBarPlayedColor: Colors.deepOrange, // YouTube-style progress bar
  progressBarHandleColor: Colors.white, // White handle
  progressBarBufferedColor: Color(0xFF28A745), // Buffered video color
  progressBarBackgroundColor: Colors.white30, // Background of progress bar
  loadingColor: Colors.orange, // Red loading indicator
  // loadingWidget: UIUtils.networkImageShimmerPlaceholder(),
  liveTextColor: Colors.redAccent,
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
  // pipMenuIcon: Icons.picture_as_pdf_sharp, // Picture-in-Picture icon
  forwardSkipTimeInMilliseconds: 10000, // Skip forward 10 sec
  backwardSkipTimeInMilliseconds: 10000, // Skip backward 10 sec
  controlsHideTime: Duration(milliseconds: 200), // Auto-hide controls after 3s
);
