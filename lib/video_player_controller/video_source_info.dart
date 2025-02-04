import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

/// Represents the best available video source extracted from [VideoDetails].
/// Prioritizes `HLS` (streamingPlaylists) over `MP4` (files).
class VideoSourceInfo {
  final String url;

  /// Duration in milliseconds.
  int? duration;

  /// Resolutions available for the video.
  final Map<String, String> resolutions;

  /// Type of the video source. Can be "hls" or "mp4".
  final String type;

  VideoSourceInfo._({
    required this.url,
    required this.duration,
    required this.resolutions,
    required this.type,
  });

  /// Extracts the best video source (HLS or MP4) from [VideoDetails].
  /// Prioritizes `streamingPlaylists` (HLS) over `files` (MP4).
  ///
  /// Returns the best available video source as a `VideoSourceInfo` object.
  /// If no valid video source is found, returns `null`.
  static VideoSourceInfo? extractBestVideoSource(VideoDetails? videoDetails) {
    // Check if videoDetails is null, return null if so
    if (videoDetails == null) return null;

    // 1️⃣ Try to get the HLS streaming playlist (Highest Priority)
    // HLS is prioritized over MP4 files
    if (videoDetails.streamingPlaylists?.isNotEmpty == true) {
      // Extract the first HLS streaming playlist URL
      return VideoSourceInfo._(
        // HLS URL
        url: videoDetails.streamingPlaylists!.first.playlistUrl!,
        // No separate resolutions needed for HLS
        resolutions: {},
        // Determine the type of video (live or hls)
        type: videoDetails.isLive! ? "live" : "hls",
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

      // Get the best resolution (highest available)
      String? bestResolution = _getHighestResolution(availableResolutions.keys);

      // If no best resolution is found, return null
      if (bestResolution == null) return null;

      // Return the best MP4 video source
      return VideoSourceInfo._(
        // Best MP4 file URL
        url: availableResolutions[bestResolution]!,
        // Video duration
        duration: videoDetails.duration,
        // All available MP4 resolutions
        resolutions: availableResolutions,
        // Type of video (mp4)
        type: "mp4",
      );
    }

    // 3️⃣ No valid video source found
    // Return null if no valid video source is found
    return null;
  }

  /// Checks if the video source is a live stream.
  bool isLive() => type == "live";

  /// Checks if the video source is an HLS stream.
  bool isHLS() => type == "hls";

  /// Checks if the video source is an MP4 file.
  bool isMP4() => type == "mp4";

  bool isHlsContent() => type == "hls" || type == "live";
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