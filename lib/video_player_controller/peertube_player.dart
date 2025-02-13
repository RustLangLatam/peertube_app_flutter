import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:river_player/river_player.dart';

import '../utils/video_utils.dart';
import 'peertube_player_buffer_optimizer_config.dart';
import 'peertube_video_source_info.dart';
import 'peertube_player_config.dart';
import 'peertube_player_notification_config.dart';
import 'peertube_player_cache_config.dart';

/// A service class for managing the video player controller.
class PeerTubePlayer {
  /// The internal video player controller instance.
  BetterPlayerController? _controller;

  /// Initialize the video player with the given URL and settings.
  ///
  /// This method sets up the video player with the provided [PeerTubeVideoSourceInfo]
  /// and prepares it for playback.
  ///
  /// [source] The video source information, including URL and settings.
  Future<void> initializePlayer(key, VideoDetails? videoDetails,
      {String? nodeUrl}) async {
    final source =
        PeerTubeVideoSourceInfo.extractBestVideoSource(videoDetails)!;

    final thumbnailURL = VideoUtils.getVideoThumbnailUrl(videoDetails!, nodeUrl!);

    // Determine if the video is a live stream
    final bool isLive = source.isLive;

    // Create a new video player controller instance
    _controller = BetterPlayerController(
      // Configure the video player with custom settings
      (isLive)
          ? PeerTubePlayerConfig.liveStreamConfig(thumbnailURL: thumbnailURL)
          : PeerTubePlayerConfig.defaultConfig(thumbnailURL: thumbnailURL),
    );

    // Create a data source for the video player
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, // Use a network data source
        source.url, // Set the video URL
        videoFormat: source.type,
        useAsmsSubtitles: false, // Disable ASMS subtitles
        liveStream: isLive, // Set live stream flag
        cacheConfiguration: PeerTubePlayerCacheConfig.create(source),
        bufferingConfiguration:
            PeerTubePlayerBufferOptimizerConfig.getOptimalBufferConfig(
                source.duration), // Set buffering configuration
        resolutions: source.resolutions, // Set video resolutions
        notificationConfiguration: PeerTubePlayerNotificationConfig.create(
            thumbnailURL: thumbnailURL,
            title: videoDetails.name,
            author: VideoUtils.extractNameOrDisplayName(videoDetails)));

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

  /// Check if the video has been initialized.
  ///
  /// Returns `true` if the video has been initialized, `false` otherwise.
  bool get isVideoInitialized => _controller?.isVideoInitialized() ?? false;

  /// Check if the video is currently playing.
  ///
  /// Returns `true` if the video is currently playing, `false` otherwise.
  bool get isVideoPlaying => _controller?.isPlaying() ?? false;

  /// Check if the video is initialized and currently playing.
  ///
  /// Returns `true` if the video is initialized and playing, `false` otherwise.
  bool get isVideoActive => isVideoInitialized && isVideoPlaying;

  /// Dispose of the player when no longer needed.
  ///
  /// Releases system resources used by the video player.
  void dispose() {
    _controller?.dispose();
  }
}
