import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LogTextViewer extends StatefulWidget {
  final String logText;
  final TextStyle? style;
  final Color? urlColor;
  final bool enableCopy;

  const LogTextViewer({
    super.key,
    required this.logText,
    this.style,
    this.urlColor,
    this.enableCopy = true,
  });

  @override
  State<LogTextViewer> createState() => _LogTextViewerState();
}

class _LogTextViewerState extends State<LogTextViewer> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(LogTextViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logText != widget.logText) {
      for (final recognizer in _recognizers) {
        recognizer.dispose();
      }
      _recognizers.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = widget.style ??
        TextStyle(
          fontSize: 13,
          fontFamily: 'monospace',
          color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
          height: 1.5,
        );

    return SelectableText.rich(
      _buildTextSpans(widget.logText, defaultStyle),
      textAlign: TextAlign.left,
      style: defaultStyle,
      contextMenuBuilder: widget.enableCopy
          ? (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.editableText(
                editableTextState: editableTextState,
              );
            }
          : null,
    );
  }

  TextSpan _buildTextSpans(String text, TextStyle baseStyle) {
    // 更精确的 URL 正则，避免匹配到末尾的标点符号
    final urlRegex = RegExp(
      r'(https?://[^\s<>\[\]{}|\\^`]+[^\s<>\[\]{}|\\^`.,;:!?)>\]])',
      caseSensitive: false,
    );

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in urlRegex.allMatches(text)) {
      // URL 之前的普通文本
      if (match.start > lastIndex) {
        final plainText = text.substring(lastIndex, match.start);
        spans.add(_buildPlainTextSpan(plainText, baseStyle));
      }

      // URL 文本
      final url = match.group(0)!;
      final recognizer = TapGestureRecognizer()..onTap = () => _launchUrl(url);
      _recognizers.add(recognizer);

      spans.add(
        TextSpan(
          text: url,
          style: baseStyle.copyWith(
            color: widget.urlColor ?? Colors.blue.shade600,
            decoration: TextDecoration.underline,
            decorationColor: widget.urlColor ?? Colors.blue.shade600,
          ),
          recognizer: recognizer,
        ),
      );

      lastIndex = match.end;
    }

    // 剩余文本
    if (lastIndex < text.length) {
      spans.add(_buildPlainTextSpan(text.substring(lastIndex), baseStyle));
    }

    return TextSpan(children: spans);
  }

  TextSpan _buildPlainTextSpan(String text, TextStyle baseStyle) {
    // 高亮关键词
    final keywordPatterns = {
      RegExp(r'\b(error|exception|fail|failed|failure)\b',
          caseSensitive: false): Colors.red.shade600,
      RegExp(r'\b(warning|warn)\b', caseSensitive: false):
          Colors.orange.shade700,
      RegExp(r'\b(success|ok|done|completed)\b', caseSensitive: false):
          Colors.green.shade600,
      RegExp(r'\b(info|debug)\b', caseSensitive: false): Colors.blue.shade400,
    };

    final spans = <TextSpan>[];
    int lastIndex = 0;

    // 收集所有匹配
    final allMatches = <_KeywordMatch>[];
    for (final entry in keywordPatterns.entries) {
      for (final match in entry.key.allMatches(text)) {
        allMatches.add(_KeywordMatch(match.start, match.end, entry.value));
      }
    }

    // 按位置排序
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in allMatches) {
      if (match.start < lastIndex) continue; // 跳过重叠

      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: baseStyle.copyWith(
            color: match.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    if (spans.isEmpty) {
      return TextSpan(text: text);
    }

    return TextSpan(children: spans);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('Invalid URL: $url');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('Could not launch URL: $url');
      }
    } catch (e) {
      debugPrint('URL launch failed: $e');
    }
  }
}

class _KeywordMatch {
  final int start;
  final int end;
  final Color color;

  _KeywordMatch(this.start, this.end, this.color);
}

/// 带容器样式的日志查看器
class LogTextCard extends StatelessWidget {
  final String logText;
  final String? title;
  final VoidCallback? onCopy;

  const LogTextCard({
    super.key,
    required this.logText,
    this.title,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(7)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: logText));
                      onCopy?.call();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LogTextViewer(logText: logText),
          ),
        ],
      ),
    );
  }
}
