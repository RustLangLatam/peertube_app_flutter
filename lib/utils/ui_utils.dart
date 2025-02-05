import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UIUtils {
  /// 📌 Creates a filter button similar to PeerTube's UI.
  static Widget filterToggleButton(String label, IconData icon, bool isSelected,
      [VoidCallback? onPressed]) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF3A2E2A) : const Color(0xFF1F1917),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 10, color: Colors.white70),
      label: Text(
        label,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
      ),
    );
  }

  /// 📌 Creates a **label-value** row for displaying metadata (e.g., Category, Language).
  static Widget buildLabelWidgetRow({
    required String label,
    required Widget child,
    EdgeInsetsGeometry? padding,
    TextStyle? labelStyle,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style:
                labelStyle ?? const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Creates a simple row for metadata display.
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

  /// Build a row of buttons with dynamic labels
  static Widget buildDynamicButtonRow({
    required List<String> buttonLabels,
    Function(String)? onButtonPressed,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Color? hoverColor,
    Color? splashColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 4,
          runSpacing: 2,
          alignment: WrapAlignment.start,
          children: buttonLabels.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;

            return IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      if (onButtonPressed != null) {
                        onButtonPressed(label);
                      }
                    },
                    hoverColor: hoverColor ?? Colors.blue.withOpacity(0.1),
                    splashColor: splashColor ?? Colors.blue.withOpacity(0.2),
                    child: Text(
                      label,
                      style: textStyle ??
                          const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                  if (index < buttonLabels.length - 1)
                    Text(
                      ',',
                      style: textStyle ??
                          const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  static void showTemporaryBottomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF221F1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a video thumbnail with `Hero` animation, supporting both `ClipRRect` and `AspectRatio`.
  ///
  /// - [thumbnailURL]: The image URL.
  /// - [useRoundedCorners]: If `true`, applies rounded corners using `ClipRRect`, otherwise uses `AspectRatio`.
  /// - [aspectRatio]: Defines the aspect ratio for `AspectRatio` mode.
  /// - [borderRadius]: The corner radius when using `ClipRRect`.
  static Widget buildHeroVideoThumbnail({
    required String thumbnailURL,
    bool useRoundedCorners = false,
    double aspectRatio = 16 / 9,
    double borderRadius = 6.0,
  }) {
    return Hero(
      tag: "video_$thumbnailURL",
      transitionOnUserGestures: true,
      flightShuttleBuilder: _heroFlightBuilder,
      child: useRoundedCorners
          ? _buildRoundedThumbnail(thumbnailURL, borderRadius)
          : _buildAspectRatioThumbnail(thumbnailURL, aspectRatio),
    );
  }

  /// Builds a rounded thumbnail using `ClipRRect`.
  static Widget _buildRoundedThumbnail(String imageUrl, double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildCachedNetworkImage(imageUrl,
          width: double.infinity, height: 180),
    );
  }

  /// Builds an aspect ratio thumbnail using `AspectRatio`.
  static Widget _buildAspectRatioThumbnail(
      String imageUrl, double aspectRatio) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: _buildCachedNetworkImage(imageUrl, width: double.infinity),
    );
  }

  /// Loads the image with `CachedNetworkImage` and handles errors/loading states.
  static Widget _buildCachedNetworkImage(String imageUrl,
      {double? width, double? height}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => networkImageShimmerPlaceholder(),
      errorWidget: (_, __, ___) =>
          const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  /// Customizes the `Hero` animation transition effect.
  static Widget _heroFlightBuilder(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return FadeTransition(
      opacity: animation,
      child: toHeroContext.widget,
    );
  }

  /// Creates a shimmer placeholder while loading.
  static Widget networkImageShimmerPlaceholder() {
    return Container(
      color:Colors.grey[800],
      child: const Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 1.5)),
    );
  }
}
