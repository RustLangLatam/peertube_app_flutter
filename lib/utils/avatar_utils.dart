import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

class AvatarUtils {
  /// Builds a channel avatar with a **square shape and rounded borders**.
  /// Uses the same style for both default and network avatars.
  static Widget buildChannelAvatarFromString(
      {String? avatarUrl, String? channelName}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white, // Match background color
        borderRadius: BorderRadius.circular(6), // Rounded corners
        border: Border.all(color: Colors.grey, width: 1), // Dark border
      ),
      child: avatarUrl?.isNotEmpty == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6), // Keep square shape
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                placeholder: (_, __) => _defaultAvatar(channelName),
                errorWidget: (_, __, ___) => _defaultAvatar(channelName),
                fit: BoxFit.cover,
              ),
            )
          : _defaultAvatar(channelName),
    );
  }

  static Widget buildChannelAvatar({
    required VideoChannelSummary channel,
    required String host,
    double width = 28,
    double height = 28,
  }) {
    // Extract the avatar path from the videoDetails object
    // First, check the channel avatars, then the account avatars
    String? firstAvatarPath = channel.avatars?.firstOrNull?.path;

    // Return the full avatar URL if a path is found, otherwise return null
    final avatarPath = firstAvatarPath != null ? "$host$firstAvatarPath" : null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // Match background color
        borderRadius: BorderRadius.circular(6), // Rounded corners
        border: Border.all(color: Colors.grey, width: 1), // Dark border
      ),
      child: avatarPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6), // Keep square shape
              child: CachedNetworkImage(
                fadeOutDuration: Duration.zero,
                fadeInDuration: Duration.zero,
                imageUrl: avatarPath,
                placeholder: (_, __) => _defaultAvatar(channel.name),
                errorWidget: (_, __, ___) => _defaultAvatar(channel.name),
                fit: BoxFit.cover,
              ),
            )
          : _defaultAvatar(channel.name),
    );
  }

  /// Creates a **default avatar** with the **first letter of the channel name**.
  static Widget _defaultAvatar(String? channelName) {
    return Container(
      // width: width,
      // height: height,
      decoration: BoxDecoration(
        color: Colors.orange, // Default background color
        borderRadius: BorderRadius.circular(5), // Keep square shape
      ),
      alignment: Alignment.center,
      child: Text(
        (channelName?.isNotEmpty == true ? channelName![0] : "U").toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          // fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Extracts the **best available avatar** from the [VideoDetails] object.
  /// Checks in the following order: `channel` → `account`.
  /// Returns the **full avatar URL** or `null` if no avatar is found.
  static String? _getBestVideoAvatar(Video? videoDetails, String host) {
    // Check if videoDetails is null, return null if true
    if (videoDetails == null) return null;

    // Extract the avatar path from the videoDetails object
    // First, check the channel avatars, then the account avatars
    String? avatarPath = videoDetails.channel?.avatars?.firstOrNull?.path ??
        videoDetails.account?.avatars?.firstOrNull?.path;

    // Return the full avatar URL if a path is found, otherwise return null
    return avatarPath != null ? "$host$avatarPath" : null;
  }

  /// Builds an **avatar widget** directly from [VideoDetails], keeping a **consistent style**.
  ///
  /// This function uses [_getBestVideoAvatar] to extract the avatar URL and then passes it to [buildChannelAvatarFromString] along with the channel name.
  static Widget buildAvatarFromVideoDetails(Video? videoDetails, String host) {
    final avatarUrl = _getBestVideoAvatar(videoDetails, host);
    final channelName = videoDetails?.channel?.name ?? "U";
    return buildChannelAvatarFromString(
        avatarUrl: avatarUrl, channelName: channelName);
  }

  /// Extracts the **best available avatar** from the [VideoChannel] object.
  /// Checks in the following order: `channel` → `ownerAccount`.
  /// Returns the **full avatar URL** or `null` if no avatar is found.
  static String? _getBestChannelAvatar(
      VideoChannel? videoChannel, String host) {
    if (videoChannel == null) return null;
    final avatarPath = videoChannel.avatars?.firstOrNull?.path ??
        videoChannel.ownerAccount?.avatars?.firstOrNull?.path;
    return avatarPath != null ? "$host$avatarPath" : null;
  }

  /// Builds an **avatar widget** directly from [VideoChannel], keeping a **consistent style**.
  ///
  /// This function uses [_getBestChannelAvatar] to extract the avatar URL and then passes it to [buildChannelAvatarFromString] along with the channel name.
  static Widget buildAvatarFromVideoChannel(
      VideoChannel? videoChannel, String host) {
    final avatarUrl = _getBestChannelAvatar(videoChannel, host);
    final channelName = videoChannel?.name ?? "C";
    return buildChannelAvatarFromString(
        avatarUrl: avatarUrl, channelName: channelName);
  }
}
