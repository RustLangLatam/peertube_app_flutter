import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/utils/ui_utils.dart';
import 'package:peertube_app_flutter/utils/video_date_utils.dart';

class VideoUtils {
  /// Formats the number of views with appropriate suffix (K for thousands, M for millions).
  /// Example:
  /// - `1234` → `1.2K views`
  /// - `1000000` → `1M views`
  static Widget buildViewCount(int? views,
      {Color color = Colors.grey, double fontSize = 12}) {
    return Text(
      formatViews(views),
      style: TextStyle(color: color, fontSize: fontSize),
    );
  }

  static String formatViews(int? views) {
    if (views == null || views < 0) return "0 views";
    if (views >= 1000000) {
      return "${(views / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M views";
    } else if (views >= 1000) {
      return "${(views / 1000).toStringAsFixed(1).replaceAll('.0', '')}K views";
    } else {
      return "$views view${views == 1 ? '' : 's'}";
    }
  }

  /// Extracts the best display name for a video uploader (Channel or Account).
  static String extractDisplayName(Video video,
      {bool prioritizeChannel = true}) {
    String removeDefaultPrefix(String text) {
      const prefix = "Default";
      return text.startsWith(prefix)
          ? text.substring(prefix.length).trim()
          : text;
    }

    String? channelDisplayName = video.channel?.displayName;
    String? accountDisplayName = video.account?.displayName;

    if (prioritizeChannel) {
      return removeDefaultPrefix(channelDisplayName ??
          accountDisplayName ??
          video.channel?.name ??
          video.account?.name ??
          "Unknown");
    } else {
      return removeDefaultPrefix(accountDisplayName ??
          channelDisplayName ??
          video.account?.name ??
          video.channel?.name ??
          "Unknown");
    }
  }

  /// 📌 Builds a video title that supports **up to 2 lines**.
  static Widget buildVideoTitle(String? title,
      {Color color = Colors.white, double fontSize = 18}) {
    return Text(
      title ?? "Unknown Title",
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis, // Truncates if too long
    );
  }

  /// Builds a video item (thumbnail, title, metadata)
  static Widget buildDiscoverVideoItem(
      Video video, String node, {required VoidCallback onTap}) {
    final thumbnailURL =
    video.previewPath != null ? '$node${video.previewPath}' : '';
    return GestureDetector(
      onTap: onTap, // 🔹 Executes callback on tap
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail
            UIUtils.buildHeroVideoOverViewThumbnail(
              thumbnailURL: thumbnailURL,
            ),
            const SizedBox(height: 5),
            // Video Title
            Text(
              video.name ?? "Unknown Video",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            // Video Metadata (Views & Time Ago)
            Text(
              '${video.views} views • ${VideoDateUtils.formatTimeAgo(video.publishedAt?.toIso8601String())}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

}
