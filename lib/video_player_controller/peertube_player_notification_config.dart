import 'package:river_player/river_player.dart';

/// A utility class for configuring BetterPlayer's notifications in PeerTube.
///
/// Provides a method to return a `BetterPlayerNotificationConfiguration`
/// based on video details.
class PeerTubePlayerNotificationConfig {
  /// Generates a `BetterPlayerNotificationConfiguration` dynamically.
  ///
  /// - If a [thumbnailURL] is provided, it enables notifications with metadata.
  /// - If no [thumbnailURL] is available, it disables notifications.
  ///
  /// [title]: The title of the video.
  /// [author]: The name of the channel or uploader.
  /// [activityName]: The name of the Android activity for the notification.
  static BetterPlayerNotificationConfiguration create({
    required String? thumbnailURL,
    required String? title,
    required String? author,
    String activityName = 'PeerTubeVDev',
  }) {
    return thumbnailURL != null
        ? BetterPlayerNotificationConfiguration(
      showNotification: true,
      title: title ?? "Unknown Video",
      author: author ?? "Unknown Channel",
      imageUrl: thumbnailURL,
      activityName: activityName,
    )
        : const BetterPlayerNotificationConfiguration(
      showNotification: false,
    );
  }
}
