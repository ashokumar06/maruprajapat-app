import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme_config.dart';

class PostContentView extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final double lineHeight;

  const PostContentView({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    this.lineHeight = 1.45,
  });

  @override
  State<PostContentView> createState() => _PostContentViewState();
}

class _PostContentViewState extends State<PostContentView> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _linkRecognizer(String url) {
    final normalizedUrl =
        url.startsWith('http://') || url.startsWith('https://')
        ? url.trim()
        : 'https://${url.trim()}';
    final recognizer = TapGestureRecognizer()
      ..onTap = () async {
        final uri = Uri.tryParse(normalizedUrl);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  List<InlineSpan> _buildInlineSpans(String line) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'(\[[^\]]+\]\([^)]+\)|\*\*[^*]+\*\*)');
    var index = 0;

    for (final match in pattern.allMatches(line)) {
      if (match.start > index) {
        spans.add(TextSpan(text: line.substring(index, match.start)));
      }

      final token = line.substring(match.start, match.end);
      if (token.startsWith('[')) {
        final splitIndex = token.indexOf('](');
        final label = token.substring(1, splitIndex);
        final url = token.substring(splitIndex + 2, token.length - 1);
        spans.add(
          TextSpan(
            text: label,
            style:
                widget.linkStyle ??
                const TextStyle(
                  color: ThemeConfig.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
            recognizer: _linkRecognizer(url),
          ),
        );
      } else if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }

      index = match.end;
    }

    if (index < line.length) {
      spans.add(TextSpan(text: line.substring(index)));
    }

    return spans;
  }

  bool _isBulletLine(String line) {
    final trimmed = line.trimLeft();
    return trimmed.startsWith('- ') ||
        trimmed.startsWith('• ') ||
        trimmed.startsWith('* ');
  }

  String _stripBulletPrefix(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('- ') ||
        trimmed.startsWith('• ') ||
        trimmed.startsWith('* ')) {
      return trimmed.substring(2);
    }
    return line;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final baseStyle =
        widget.style ??
        const TextStyle(
          fontSize: 14,
          color: ThemeConfig.textPrimary,
          height: 1.45,
        );
    final effectiveStyle = baseStyle.copyWith(
      height: baseStyle.height ?? widget.lineHeight,
    );

    final lines = widget.text.split('\n');
    final children = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }

      if (_isBulletLine(line)) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: ThemeConfig.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: effectiveStyle,
                      children: _buildInlineSpans(_stripBulletPrefix(line)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: i == lines.length - 1 ? 0 : 4),
            child: Text.rich(
              TextSpan(
                style: effectiveStyle,
                children: _buildInlineSpans(line),
              ),
            ),
          ),
        );
      }
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
