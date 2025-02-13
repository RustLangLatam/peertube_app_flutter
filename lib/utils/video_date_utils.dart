import 'package:timeago/timeago.dart' as timeago;

class VideoDateUtils {
  /// Formats a `DateTime` into a relative time string (e.g., "3 years ago").
  static String formatRelativeDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final years = _calculateYearsDifference(date.toLocal(), now);

    return years == 0
        ? _formatTimeAgo(date)
        : '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  /// Calculates the exact difference in years between two dates.
  static int _calculateYearsDifference(DateTime from, DateTime to) {
    int years = to.year - from.year;
    if (to.month < from.month ||
        (to.month == from.month && to.day < from.day)) {
      years--;
    }
    return years;
  }

  /// Formats a recent date using timeago (e.g., "6 months ago").
  static String _formatTimeAgo(DateTime date) {
    return timeago.format(date.toLocal(), locale: 'en');
  }

  /// Formats a `DateTime` into "MM/DD/YYYY".
  static String formatDateAsMMDDYYYY(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Converts seconds into "MM:SS" format.
  static String formatSecondsToTime(int? seconds) {
    if (seconds == null || seconds < 0) return '0:00';
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  /// Convert an integer (seconds) into a formatted string like "3min 21sec"
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

  /// Converts a DateTime string to a "time ago" format
  static String formatTimeAgo(String? dateTime) {
    if (dateTime == null) return "Unknown";
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return "Unknown";

    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return "${diff.inDays ~/ 365} year(s) ago";
    if (diff.inDays > 30) return "${diff.inDays ~/ 30} month(s) ago";
    if (diff.inDays > 0) return "${diff.inDays} day(s) ago";
    if (diff.inHours > 0) return "${diff.inHours} hour(s) ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} minute(s) ago";
    return "Just now";
  }
}
