import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LogTextViewer extends StatelessWidget {
  final String logText;

  const LogTextViewer({super.key, required this.logText});

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildTextSpans(logText),
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 14),
    );
  }

  // 核心：解析文本并生成带高亮的富文本
  TextSpan _buildTextSpans(String text) {
    final urlRegex = RegExp(
      r'(https?://[^\s]+|www\.[^\s]+\.[^\s]+)', // 匹配 http/https 和 www 开头的 URL
      caseSensitive: false,
      multiLine: false,
    );

    final spans = <TextSpan>[];
    int lastIndex = 0;

    // 遍历所有匹配的 URL
    for (final match in urlRegex.allMatches(text)) {
      // 添加 URL 之前的普通文本
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(text: text.substring(lastIndex, match.start)),
        );
      }

      // 添加高亮可点击的 URL
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _launchUrl(url),
        ),
      );

      lastIndex = match.end;
    }

    // 添加剩余的普通文本
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return TextSpan(children: spans);
  }

  // 启动 URL
  Future<void> _launchUrl(String url) async {
    // 补全缺少协议头的 URL
    final fullUrl = url.startsWith('http') ? url : 'https://$url';

    try {
      final canLaunch = await canLaunchUrl(Uri.parse(fullUrl));
      if (canLaunch) {
        await launchUrl(Uri.parse(fullUrl), mode: LaunchMode.externalApplication);
      } else {
        debugPrint('无法打开 URL: $fullUrl');
      }
    } catch (e) {
      debugPrint('URL 启动失败: $e');
    }
  }
}