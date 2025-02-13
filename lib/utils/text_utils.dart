import 'package:flutter/material.dart';

class TextUtils {
  /// 📌 Builds a **single-line** text widget with truncation ("...").
  static Widget buildSingleLineText(String text, {TextStyle? style}) {
    final textStyle = style ??
        const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );

    return SizedBox(
      height: textStyle.fontSize! * 1.4, // Ensures consistent height
      child: Text(
        text,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Removes the "Default" prefix if present
  static String removeDefaultPrefix(String text) {
    const prefix = "Default";
    return text.startsWith(prefix)
        ? text.substring(prefix.length).trim()
        : text;
  }

  /// Removes the "#" prefix if present
  static String removeHashTagPrefix(String text) {
    const prefix = "#";
    return text.startsWith(prefix)
        ? text.substring(prefix.length).trim()
        : text;
  }

}
