import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

class BlurredBackdropImage extends StatelessWidget {
  const BlurredBackdropImage({
    super.key,
    required this.channel,
    required this.node,
  });

  final String node;
  final VideoChannel? channel;

  @override
  Widget build(BuildContext context) {
    final bannerUrl = channel?.banners?.isNotEmpty == true
        ? node + channel!.banners!.first.path!
        : null;

    return Container(
      height: 205, // ✅ Keeps the exact height
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // ✅ Uses a gradient background as a placeholder
          colors: [Color(0xFF282828), Color(0xFF1A1A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: bannerUrl != null
          ? CachedNetworkImage(
              imageUrl: bannerUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 500),
              // ✅ Smooth fade-in effect
              fadeOutDuration: Duration.zero,
              // ✅ Prevent abrupt transition from placeholder
              placeholder: (context, url) => _defaultPlaceholder(),
              errorWidget: (context, url, error) => _defaultPlaceholder(),
              imageBuilder: (context, imageProvider) {
                return AnimatedOpacity(
                  duration:
                      const Duration(milliseconds: 500), // ✅ Smooth transition
                  opacity: 1.0, // Ensures gradual appearance
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: const ColorFilter.mode(
                            Colors.black54, BlendMode.darken),
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: _blurEffect(), // ✅ Maintains the blur effect
                  ),
                );
              },
            )
          : _defaultPlaceholder(),
    );
  }

  /// 🔹 **Placeholder when the image is still loading or has an error**
  Widget _defaultPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF282828), Color(0xFF1A1A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _blurEffect(),
    );
  }

  /// 🔹 **Applies the blur effect**
  Widget _blurEffect() {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.0),
          ),
        ));
  }
}
