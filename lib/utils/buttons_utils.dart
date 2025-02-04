import 'package:flutter/material.dart';

class ButtonsUtils {
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
  static Widget likeButton({int? likes, VoidCallback? onPressed}) {
    return _actionButton(
        Icons.thumb_up_outlined, likes?.toString() ?? "0", onPressed);
  }

  /// 📌 **Dislike Button**
  static Widget dislikeButton({int? dislikes, VoidCallback? onPressed}) {
    return _actionButton(
        Icons.thumb_down_outlined, dislikes?.toString() ?? "0", onPressed);
  }

  /// 📌 **Share Button**
  static Widget shareButton({VoidCallback? onPressed}) {
    return _actionButton(Icons.share_outlined, "", onPressed);
  }

  /// 📌 **Download Button**
  static Widget downloadButton({VoidCallback? onPressed}) {
    return _actionButton(Icons.download_outlined, "", onPressed);
  }

  /// 🔹 **Reusable Action Button**
  static Widget _actionButton(
      IconData icon, String label, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: const IconThemeData(
                size: 22,
                opacity: 0.65,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}




