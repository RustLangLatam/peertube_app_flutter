import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

class ChannelsUtils {
  static const String channels = 'channels';

  static String extractVideoChannelDisplayName(VideoChannel channel) {
    /// Removes the "Default" prefix if present
    String removeDefaultPrefix(String text) {
      const prefix = "Default";
      return text.startsWith(prefix)
          ? text.substring(prefix.length).trim()
          : text;
    }

    /// Capitalizes only the first letter of the string
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    // Prioritize `displayName`, then fallback to `name`
    String? name = channel.displayName?.isNotEmpty == true
        ? channel.displayName
        : channel.name?.isNotEmpty == true
            ? channel.name
            : null;

    // If a valid name is found, clean it up and capitalize it
    if (name != null) {
      return capitalizeFirstLetter(removeDefaultPrefix(name));
    }

    // If no valid name is found, return a default placeholder
    return "Unknown Channel";
  }

  static String extractChannelDisplayName(VideoChannelSummary channel, {bool prioritizeChannel = false}) {
    /// Removes the "Default" prefix if present
    String removeDefaultPrefix(String text) {
      const prefix = "Default";
      return text.startsWith(prefix)
          ? text.substring(prefix.length).trim()
          : text;
    }

    /// Capitalizes only the first letter of the string
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    // Get `displayName` and `name`
    String? displayName = channel.displayName?.isNotEmpty == true ? channel.displayName : null;
    String? name = channel.name?.isNotEmpty == true ? channel.name : null;
    String? host = channel.host?.isNotEmpty == true ? channel.host : null;

    // Determine the final name based on `prioritizeChannel`
    String? finalName = prioritizeChannel || displayName == null ? name : displayName;

    if (finalName != null) {

      // ✅ Append `@host` if `displayName` is null or prioritizeChannel is true
      if ((displayName == null || prioritizeChannel) && host != null) {
        return finalName = "$finalName@$host";
      }

      finalName = capitalizeFirstLetter(removeDefaultPrefix(finalName));

      return finalName;
    }

    // If no valid name is found, return a default placeholder
    return "Unknown Channel";
  }
}
