import 'package:flutter/material.dart';

class UIUtils {
  /// 📌 Creates a filter button similar to PeerTube's UI.
  static Widget filterToggleButton(String label, IconData icon, bool isSelected,
      [VoidCallback? onPressed]) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF3A2E2A) : const Color(0xFF1F1917),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 10, color: Colors.white70),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
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
            style: labelStyle ?? const TextStyle(color: Colors.grey, fontSize: 12),
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
          Text("$title: ", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                      style: textStyle ?? const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                  if (index < buttonLabels.length - 1)
                    Text(
                        ',',
                        style: textStyle ?? const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }


}
