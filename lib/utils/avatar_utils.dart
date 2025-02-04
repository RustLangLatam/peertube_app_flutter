import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

class AvatarUtils {
  /// Builds a channel avatar with a **square shape and rounded borders**.
  /// Uses the same style for both default and network avatars.
  static Widget buildChannelAvatar({String? avatarUrl, String? channelName}) {
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

  /// Creates a **default avatar** with the **first letter of the channel name**.
  static Widget _defaultAvatar(String? channelName) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.cyan, // Default background color
        borderRadius: BorderRadius.circular(5), // Keep square shape
      ),
      alignment: Alignment.center,
      child: Text(
        (channelName?.isNotEmpty == true ? channelName![0] : "U").toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Extracts the **best available avatar** from the `VideoDetails` object.
  /// Checks in the following order: `channel` → `account`.
  /// Returns the **full avatar URL** or `null` if no avatar is found.
  static String? getBestAvatar(Video? videoDetails, String host) {
    if (videoDetails == null) return null;

    String? avatarPath = videoDetails.channel?.avatars?.firstOrNull?.path ??
        videoDetails.account?.avatars?.firstOrNull?.path;

    return avatarPath != null ? "$host$avatarPath" : null;
  }

  /// Builds an **avatar widget** directly from `VideoDetails`, keeping a **consistent style**.
  static Widget buildAvatarFromVideoDetails(Video? videoDetails, String host) {
    String? avatarUrl = getBestAvatar(videoDetails, host);
    String? channelName = videoDetails?.channel?.name ?? "U";

    return buildChannelAvatar(avatarUrl: avatarUrl, channelName: channelName);
  }
}