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
        if (!isExpanded || widget.text.length > widget.maxLines * 50)
          InkWell(
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