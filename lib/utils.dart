import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomButtons {
  /// 📌 **Subscribe Button (PeerTube Style)**
  static Widget subscribeButton({VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF28C38), // Dark Orange
        foregroundColor: Color(0xFF13100E),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        minimumSize: const Size(100, 36),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Subscribe",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF13100E)),
        ],
      ),
    );
  }

  /// 📌 **Like Button**
  static Widget likeButton({VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.thumb_up, color: Colors.white),
    );
  }

  /// 📌 **Dislike Button**
  static Widget dislikeButton({VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.thumb_down, color: Colors.white),
    );
  }

  /// 📌 **Share Button**
  static Widget shareButton({VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.share, color: Colors.white),
    );
  }

  /// 📌 **Download Button**
  static Widget downloadButton({VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.download, color: Colors.white),
    );
  }
}


class Utils {

  static String formatViews(int? views) {
    if (views == null || views < 0) return "0 views";

    if (views < 1000) {
      return "$views views";
    } else if (views < 1000000) {
      return "${(views / 1000).toStringAsFixed(1)}K views";
    } else if (views < 1000000000) {
      return "${(views / 1000000).toStringAsFixed(1)}M views";
    } else {
      return "${(views / 1000000000).toStringAsFixed(1)}B views";
    }
  }

  // Format a DateTime object into a relative time string (e.g., "3 years ago")
  static String formatRelativeDate(DateTime? date) {
    if (date == null) {
      return 'Unknown date';
    }

    final now = DateTime.now();
    final years = _calculateYearsDifference(date.toLocal(), now);

    if (years == 0) {
      // If less than a year, use timeago for a more detailed format
      return _formatTimeAgo(date);
    } else {
      // Show the exact difference in years
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Calculate the exact difference in years between two dates
  static int _calculateYearsDifference(DateTime from, DateTime to) {
    int years = to.year - from.year;

    // Adjust if the current date is before the anniversary of the start date
    if (to.month < from.month ||
        (to.month == from.month && to.day < from.day)) {
      years--;
    }

    return years;
  }

  // Format a recent date using timeago (e.g., "6 months ago")
  static String _formatTimeAgo(DateTime date) {
    return timeago.format(date.toLocal(), locale: 'en');
  }

  // Format a DateTime object into "MM/DD/YYYY" format
  static String formatDateAsMMDDYYYY(DateTime? date) {
    if (date == null) {
      return 'Unknown date';
    }

    // Format the date as MM/DD/YYYY with leading zeros
    final month = date.month.toString().padLeft(2, '0'); // Month (01-12)
    final day = date.day.toString().padLeft(2, '0'); // Day of the month (01-31)
    final year = date.year; // Year (e.g., 2021)

    return '$month/$day/$year';
  }

  // Convert an integer (seconds) into a formatted string like "3min 21sec"
  static String formatSecondsToMinSec(int? seconds) {
    if (seconds == null || seconds < 0) {
      return 'Invalid duration';
    }

    final minutes = seconds ~/ 60; // Get the total minutes
    final remainingSeconds = seconds % 60; // Get the remaining seconds

    if (minutes == 0) {
      return '${remainingSeconds}sec'; // Only seconds
    } else if (remainingSeconds == 0) {
      return '${minutes}min'; // Only minutes
    } else {
      return '${minutes}min ${remainingSeconds}sec'; // Minutes and seconds
    }
  }

  /// Converts an integer (seconds) into a formatted string like "2:04"
  static String formatSecondsToTime(int? seconds) {
    if (seconds == null || seconds < 0) {
      return '0:00'; // Default invalid value
    }

    final minutes = seconds ~/ 60; // Get total minutes
    final remainingSeconds = seconds % 60; // Get remaining seconds

    // Format as "M:SS" (e.g., "2:04" for 2 minutes and 4 seconds)
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Build a row of buttons with dynamic labels
  static Widget buildDynamicButtonRow({
    required List<String> buttonLabels,
    Function(String)? onButtonPressed,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Color? hoverColor,
    Color? splashColor,
  }) {
    return Row(
      children: buttonLabels.map((label) {
        return Row(
          children: [
            InkWell(
              onTap: () {
                if (onButtonPressed != null) {
                  onButtonPressed(label); // Execute the action with the label
                }
              },
              hoverColor: hoverColor ?? Colors.blue.withOpacity(0.1), // Hover effect color
              splashColor: splashColor ?? Colors.blue.withOpacity(0.2), // Splash effect color
              child: Text(
                label,
                style: textStyle ?? const TextStyle(color: Colors.blue, fontSize: 12), // Text style
              ),
            ),
            // Add a comma separator after each label (except the last one)
            if (label != buttonLabels.last)
              Padding(
                padding: padding ?? const EdgeInsets.only(right: 4), // Spacing after the comma
                child: Text(
                  ', ',
                  style: textStyle ?? const TextStyle(color: Colors.blue, fontSize: 12), // Comma style
                ),
              ),
          ],
        );
      }).toList(), // Convert the map to a list of widgets
    );
  }

  /// Creates a filter button styled like PeerTube's UI.
  /// It allows toggling between options like "Recently Added" and "Trending".
  static Widget filterToggleButton(
      String label, IconData icon, bool isSelected, [VoidCallback? onPressed]) {
    return ElevatedButton.icon(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF3A2E2A) : const Color(0xFF1F1917), // Active/Inactive color
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 10, color: Colors.white70),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
      ),
    );
  }

  static Widget buildLabelWidgetRow({
    required String label,
    required Widget child,
    EdgeInsetsGeometry? padding,
    TextStyle? labelStyle,
    TextStyle? childStyle,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 3), // Custom padding
      child: Row(
        children: [
          Text(
            "$label: ",
            style: labelStyle ??
                const TextStyle(
                    color: Colors.grey, fontSize: 12), // Label style
          ),
          child, // Custom widget
        ],
      ),
    );
  }

  static Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

}

class AvatarUtils {
  /// Builds a channel avatar, using a default one if no avatar is available.
  /// Adds a subtle border to match the background.
  static Widget buildChannelAvatar({String? avatarUrl, String? channelName}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1A1A1A), width: 2), // Add border
      ),
      child: avatarUrl?.isNotEmpty == true
          ? CachedNetworkImage(
        imageUrl: avatarUrl!,
        placeholder: (_, __) => _defaultAvatar(channelName),
        errorWidget: (_, __, ___) => _defaultAvatar(channelName),
        imageBuilder: (_, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
          radius: 16,
        ),
      )
          : _defaultAvatar(channelName),
    );
  }

  /// Creates a default avatar with the first letter of the channel name.
  static Widget _defaultAvatar(String? channelName) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.cyan,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 2), // Border added
      ),
      alignment: Alignment.center,
      child: Text(
        (channelName?.isNotEmpty == true ? channelName![0] : "U").toLowerCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  /// Extracts the best available avatar from the VideoDetails object.
  /// Checks in the following order: `channel` → `account`.
  /// Returns the full avatar URL or `null` if no avatar is found.
  static String? getBestAvatar(Video? videoDetails, String host) {
    if (videoDetails == null) return null;

    String? avatarPath = videoDetails.channel?.avatars?.firstOrNull?.path ??
        videoDetails.account?.avatars?.firstOrNull?.path;

    return avatarPath != null ? "$host$avatarPath" : null;
  }

  /// Builds an avatar widget directly from `VideoDetails`
  /// - Extracts the best available avatar from `VideoDetails`
  /// - Uses a default avatar if no valid avatar is found.
  static Widget buildAvatarFromVideoDetails(
      Video? videoDetails, String host) {
    String? avatarUrl = getBestAvatar(videoDetails, host);
    String? channelName = videoDetails?.channel?.name ?? "U";

    return buildChannelAvatar(avatarUrl: avatarUrl, channelName: channelName);
  }
}

Widget buildExpandableText({
  required String text,
  int maxLines = 1,
  TextStyle? textStyle,
  TextStyle? seeMoreStyle,
  String seeMoreText = 'See More',
  String seeLessText = 'See Less',
}) {
  return _ExpandableText(
    text: text,
    maxLines: maxLines,
    textStyle: textStyle,
    seeMoreStyle: seeMoreStyle,
    seeMoreText: seeMoreText,
    seeLessText: seeLessText,
  );
}

class _ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? textStyle;
  final TextStyle? seeMoreStyle;
  final String seeMoreText;
  final String seeLessText;

  const _ExpandableText({
    required this.text,
    required this.maxLines,
    this.textStyle,
    this.seeMoreStyle,
    required this.seeMoreText,
    required this.seeLessText,
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textSpans = _buildTextSpans(widget.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: isExpanded
                ? textSpans
                : textSpans.take(widget.maxLines * 3).toList(),
          ),
          maxLines: isExpanded ? null : widget.maxLines,
          overflow: isExpanded ? TextOverflow.clip : TextOverflow.ellipsis,
        ),
        if (!isExpanded || widget.text.length > widget.maxLines * 50)
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? widget.seeLessText : widget.seeMoreText,
              style: widget.seeMoreStyle ??
                  const TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }

  List<TextSpan> _buildTextSpans(String text) {
    final RegExp urlRegExp = RegExp(
      r'((https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-./?%&=]*)?)',
      caseSensitive: false,
    );

    final List<TextSpan> spans = [];
    final matches = urlRegExp.allMatches(text);
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: widget.textStyle ??
              const TextStyle(color: Colors.white, fontSize: 12),
        ));
      }

      final url = text.substring(match.start, match.end);
      final fullUrl = url.startsWith('http') ? url : 'https://$url';

      spans.add(TextSpan(
        text: url,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunchUrl(Uri.parse(fullUrl))) {
              await launchUrl(Uri.parse(fullUrl),
                  mode: LaunchMode.externalApplication);
            }
          },
      ));

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: widget.textStyle ??
            const TextStyle(color: Colors.white, fontSize: 12),
      ));
    }

    return spans;
  }
}
