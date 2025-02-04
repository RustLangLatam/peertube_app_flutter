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
}
