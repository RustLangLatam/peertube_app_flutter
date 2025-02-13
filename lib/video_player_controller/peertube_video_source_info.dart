import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:river_player/river_player.dart';

/// Represents the best available video source extracted from [VideoDetails].
/// Prioritizes `HLS` (streamingPlaylists) over `MP4` (files).
class PeerTubeVideoSourceInfo {
  final String url;

  /// Duration in milliseconds.
  int? duration;

  /// Whether the video is a live stream.
  bool isLive;

  /// Resolutions available for the video.
  final Map<String, String> resolutions;

  /// Type of the video source. Can be "hls" or "mp4".
  final BetterPlayerVideoFormat type;

  PeerTubeVideoSourceInfo._({
    required this.url,
    required this.duration,
    required this.resolutions,
    required this.type,
    this.isLive = false,
  });

  /// Extracts the best video source (HLS or MP4) from [VideoDetails].
  /// Prioritizes `streamingPlaylists` (HLS) over `files` (MP4).
  ///
  /// Returns the best available video source as a `VideoSourceInfo` object.
  /// If no valid video source is found, returns `null`.
  static PeerTubeVideoSourceInfo? extractBestVideoSource(VideoDetails? videoDetails) {
    // Check if videoDetails is null, return null if so
    if (videoDetails == null) return null;

    // 1️⃣ Try to get the HLS streaming playlist (Highest Priority)
    // HLS is prioritized over MP4 files
    if (videoDetails.streamingPlaylists?.isNotEmpty == true) {
      // Extract the first HLS streaming playlist URL
      return PeerTubeVideoSourceInfo._(
        // HLS URL
        url: videoDetails.streamingPlaylists!.first.playlistUrl!,
        // No separate resolutions needed for HLS
        resolutions: {},
        // Determine the type of video (live or hls)
        type: videoDetails.streamingPlaylists != null
            ? BetterPlayerVideoFormat.hls
            : BetterPlayerVideoFormat.other,
        // Determine if the video is a live stream
        isLive: videoDetails.isLive ?? false,
        // Video duration
        duration: videoDetails.duration,
      );
    }

    // 2️⃣ Fallback to MP4 files if HLS is not available
    if (videoDetails.files?.isNotEmpty == true) {
      // Extract resolutions and URLs from MP4 files
      Map<String, String> availableResolutions = {
        for (var file in videoDetails.files!)
          if (file.fileUrl != null)
            // Use the resolution label or "Unknown" if not available
            file.resolution?.label ?? "Unknown": file.fileUrl!,
      };

      // Get the best resolution (midpoint between lowest and highest available)
      String? bestResolution = _getMidResolution(availableResolutions.keys);

      // If no best resolution is found, return null
      if (bestResolution == null) return null;

      // Return the best MP4 video source
      return PeerTubeVideoSourceInfo._(
        // Best MP4 file URL
        url: availableResolutions[bestResolution]!,
        // Video duration
        duration: videoDetails.duration,
        // All available MP4 resolutions
        resolutions: availableResolutions,
        // Type of video (mp4)
        type: BetterPlayerVideoFormat.other,
      );
    }

    // 3️⃣ No valid video source found
    // Return null if no valid video source is found
    return null;
  }

  /// Checks if the video source is an HLS stream.
  bool isHLS() => type == BetterPlayerVideoFormat.hls;

  /// Checks if the video source is an MP4 file.
  bool isOther() => type == BetterPlayerVideoFormat.other;
}

/// Returns the highest resolution label from a list of resolution labels.
///
/// This function takes an iterable of resolution labels (e.g., "1080p", "720p") and
/// returns the label with the highest numeric value.
///
/// If the input iterable is empty, the function returns null.
String? _getHighestResolution(Iterable<String> resolutionLabels) {
  // Check if the input iterable is empty
  if (resolutionLabels.isEmpty) return null;

  // Use the reduce method to find the resolution label with the highest numeric value
  return resolutionLabels.reduce((best, current) {
    // Extract the numeric value from the current resolution label
    int bestValue = int.tryParse(best.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int currentValue =
        int.tryParse(current.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // Compare the numeric values and return the label with the higher value
    return currentValue > bestValue
        ? current // Return the current label if its value is higher
        : best; // Otherwise, return the best label found so far
  });
}

/// Returns the **mid-range** resolution label from a list of resolution labels.
///
/// If there's an odd number of resolutions, it picks the **middle one**.
/// If there's an even number, it picks the **lower of the two middle values**.
/// If the list is empty, returns `null`.
String? _getMidResolution(Iterable<String> resolutionLabels) {
  if (resolutionLabels.isEmpty) return null;

  // Convert resolution labels to numeric values
  List<int> resolutions = resolutionLabels
      .map((res) => int.tryParse(res.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .where((res) => res > 0) // Remove invalid or zero resolutions
      .toList();

  if (resolutions.isEmpty) return null;

  // Sort resolutions in ascending order
  resolutions.sort();

  // Find the middle index
  int midIndex = (resolutions.length - 1) ~/ 2;

  // Return the corresponding resolution label
  return resolutionLabels
      .firstWhere((label) => label.contains(resolutions[midIndex].toString()));
}
