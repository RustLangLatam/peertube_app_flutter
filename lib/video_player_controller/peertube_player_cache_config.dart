import 'package:peertube_app_flutter/video_player_controller/video_source_info.dart';
import 'package:river_player/river_player.dart';

/// A utility class for generating optimized BetterPlayer cache configurations.
class PeerTubePlayerCacheConfig {
  /// Creates an optimized `BetterPlayerCacheConfiguration`.
  ///
  /// - Enables caching only for non-live videos.
  /// - Uses an **optimized cache size** strategy for smoother playback.
  /// - Dynamically generates a **cache key** for HLS live streams.
  ///
  /// [source]: The video source information, including URL and settings.
  /// [customKey]: (Optional) Custom cache key.
  static BetterPlayerCacheConfiguration create(
    VideoSourceInfo source, {
    String? customKey,
  }) {
    return BetterPlayerCacheConfiguration(
      useCache: !source.isLive, // Enable cache only for non-live streams
      preCacheSize: 2 * 1024 * 1024, // Optimized pre-cache size (2MB)
      maxCacheSize: 300 * 1024 * 1024, // Increased max cache size (300MB)
      maxCacheFileSize: 30 * 1024 * 1024, // Increased max file size (30MB)
      key: source.isLive
          ? "peerTubeLiveCache_${customKey ?? source.url}" // Unique key for live HLS streams
          : null, // No key needed for static videos
    );
  }
}
