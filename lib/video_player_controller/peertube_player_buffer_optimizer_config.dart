import 'package:river_player/river_player.dart';

/// A utility class for optimizing video buffering configurations based on video duration.
class PeerTubePlayerBufferOptimizerConfig {
  /// Returns an optimized `BetterPlayerBufferingConfiguration` based on video duration.
  ///
  /// This method uses adaptive calculations to determine the optimal buffering configuration
  /// for a given video duration. The calculations are based on the following rules:
  ///
  /// * Short videos (< 2 min): Small buffers for fast startup.
  /// * Medium videos (2 - 10 min): Balanced buffering strategy.
  /// * Long videos (> 10 min): Large buffers to ensure smooth playback.
  ///
  /// The result is a more efficient and stable video playback experience with automatic adjustments.
  ///
  /// @param videoDurationSeconds The duration of the video in seconds.
  /// @return An optimized `BetterPlayerBufferingConfiguration` for the given video duration.
  static BetterPlayerBufferingConfiguration getOptimalBufferConfig(
      int? videoDurationSeconds) {
    videoDurationSeconds ??= 0;

    // Check if the video duration is valid (i.e., greater than 0)
    if (videoDurationSeconds <= 0) {
      // If the duration is invalid, return a default buffering configuration
      return const BetterPlayerBufferingConfiguration();
    }

    // Calculate the minimum buffer size based on the video duration
    // The minimum buffer size is capped between 10s and 40s
    int minBufferMs =
        (videoDurationSeconds * 500).clamp(10000, 40000); // 10s - 40s

    // Calculate the maximum buffer size based on the video duration
    // The maximum buffer size is capped between 1min and 6.5min
    int maxBufferMs =
        (videoDurationSeconds * 2000).clamp(60000, 6553600); // 1min - 6.5min

    // Calculate the buffer size for playback based on the video duration
    // The buffer size for playback is capped between 2s and 5s
    int bufferForPlaybackMs =
        (videoDurationSeconds * 100).clamp(2000, 5000); // 2s - 5s

    // Calculate the buffer size for playback after rebuffering based on the video duration
    // The buffer size for playback after rebuffering is capped between 4s and 10s
    int bufferForPlaybackAfterRebufferMs =
        (videoDurationSeconds * 200).clamp(4000, 10000); // 4s - 10s

    // Return an optimized `BetterPlayerBufferingConfiguration` based on the calculated buffer sizes
    return BetterPlayerBufferingConfiguration(
      minBufferMs: minBufferMs,
      maxBufferMs: maxBufferMs,
      bufferForPlaybackMs: bufferForPlaybackMs,
      bufferForPlaybackAfterRebufferMs: bufferForPlaybackAfterRebufferMs,
    );
  }
}
