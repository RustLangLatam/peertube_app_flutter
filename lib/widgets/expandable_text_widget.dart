import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildExpandableText({
  required String text,
  int maxLines = 1,
  TextStyle? textStyle,
  TextStyle? seeMoreStyle,
  String seeMoreText = 'See More',
  String seeLessText = 'See Less',
}) {
  return ExpandableTextWidget(
    text: text,
    maxLines: maxLines,
    textStyle: textStyle,
    seeMoreStyle: seeMoreStyle,
    seeMoreText: seeMoreText,
    seeLessText: seeLessText,
  );
}

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? textStyle;
  final TextStyle? seeMoreStyle;
  final String seeMoreText;
  final String seeLessText;

  const ExpandableTextWidget({
    required this.text,
    required this.maxLines,
    this.textStyle,
    this.seeMoreStyle,
    required this.seeMoreText,
    required this.seeLessText,
  });

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;
  bool isOverflowing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkOverflow(); // Check if the text overflows
  }

  @override
  Widget build(BuildContext context) {
    final textSpans = _buildTextSpans(widget.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: isExpanded
                ? textSpans
                : textSpans.take(widget.maxLines * 3).toList(),
          ),
          maxLines: isExpanded ? null : widget.maxLines,
          overflow: isExpanded ? TextOverflow.clip : TextOverflow.ellipsis,
        ),

        // Show "See More" only if the text overflows
        if (isOverflowing)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? widget.seeLessText : widget.seeMoreText,
              style: widget.seeMoreStyle ??
                  const TextStyle(
                    color: Color(0xFFF28C38),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
      ],
    );
  }

  /// Checks if the text exceeds the max lines allowed
  void _checkOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);

    // If the text overflows, set `isOverflowing` to true
    setState(() {
      isOverflowing = textPainter.didExceedMaxLines;
    });
  }

  /// Extracts URLs from the text and makes them tappable
  List<TextSpan> _buildTextSpans(String text) {
    final RegExp urlRegExp = RegExp(
      r'((https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-./?%&=]*)?)',
      caseSensitive: false,
    );

    final List<TextSpan> spans = [];
    final matches = urlRegExp.allMatches(text);
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: widget.textStyle ??
              const TextStyle(color: Colors.white, fontSize: 12),
        ));
      }

      final url = text.substring(match.start, match.end);
      final fullUrl = url.startsWith('http') ? url : 'https://$url';

      spans.add(TextSpan(
        text: url,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunchUrl(Uri.parse(fullUrl))) {
              await launchUrl(Uri.parse(fullUrl),
                  mode: LaunchMode.externalApplication);
            }
          },
      ));

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: widget.textStyle ??
            const TextStyle(color: Colors.white, fontSize: 12),
      ));
    }

    return spans;
  }
}
