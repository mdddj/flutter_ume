import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ume_plus/flutter_ume_plus.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import '../../flutter_ume_kit_dio_plus.dart';
import '../constants/extensions.dart';
import '../instances.dart';
import '../models/config.dart';

const JsonEncoder _encoder = JsonEncoder.withIndent('  ');
final _dioSettingCache = DioConfigUtil();

/// JSON 高亮工具类
class JsonHighlighter {
  static Highlighter? _highlighter;
  static bool _initialized = false;
  static bool _initializing = false;

  static Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    try {
      await Highlighter.initialize(['json']);
      final theme = await HighlighterTheme.loadLightTheme();
      _highlighter = Highlighter(language: 'json', theme: theme);
      _initialized = true;
      debugPrint("高亮初始化完成");
    } catch (e) {
      // 初始化失败时使用普通文本
      debugPrint("代码高亮初始化失败:${e}");
    }
    _initializing = false;
  }

  static TextSpan? highlight(String code) {
    if (_highlighter == null) return null;
    try {
      return _highlighter!.highlight(code);
    } catch (_) {
      return null;
    }
  }

  static bool get isReady => _initialized && _highlighter != null;
}

ButtonStyle _buttonStyle(
  BuildContext context, {
  EdgeInsetsGeometry? padding,
}) {
  return TextButton.styleFrom(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      minimumSize: Size.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999999),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary);
}

class DioPluggableState extends State<DioInspector> with StoreMixin {
  NavigatorState? get nav => widget.nav;

  ThemeData? get themeData => widget.themeData;

  ThemeMode? get themeMode => widget.themeMode;

  final ScrollController scrollController = ScrollController();
  bool _isFull = false;

  DioConfig _config = const DioConfig(); //配置

  bool _showSetting = false; //显示设置

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    InspectorInstance.httpContainer.addListener(_onResponseAdded);
    Future.microtask(() async {
      await JsonHighlighter.initialize();
      final value = await _dioSettingCache.getConfig();
      setState(() {
        _config = value;
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    InspectorInstance.httpContainer
      ..removeListener(_onResponseAdded)
      ..resetPaging();
    super.dispose();
  }

  void _onResponseAdded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listKey.currentState
          ?.insertItem(0, duration: const Duration(milliseconds: 300));
    });
  }

  Widget _clearAllButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        final httpContainer = InspectorInstance.httpContainer;
        httpContainer.removeListener(_onResponseAdded);

        final List<Response<dynamic>> requests = httpContainer.pagedRequests;
        final int initialLength = requests.length;

        for (int i = 0; i < initialLength; i++) {
          final Response<dynamic> response = requests[i];
          _listKey.currentState?.removeItem(
            0,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: _ResponseCard(
                key: ValueKey<int>(response.startTimeMilliseconds),
                response: response,
                nav: nav,
                config: _config,
              ),
            ),
            duration: const Duration(milliseconds: 300),
          );
        }

        httpContainer.clearRequests();
        httpContainer.addListener(_onResponseAdded);
      },
      icon: const Icon(
        Icons.cleaning_services,
        size: 12,
      ),
      style: _buttonStyle(context, padding: const EdgeInsets.all(2)),
      label: const Text('清理'),
    );
  }

  Widget _fullButton() {
    return IconButton(
        onPressed: () {
          setState(() {
            _isFull = !_isFull;
          });
        },
        icon: const Icon(Icons.fullscreen));
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget _itemList(BuildContext context) {
    final List<Response<dynamic>> requests =
        InspectorInstance.httpContainer.pagedRequests;
    if (requests.isNotEmpty) {
      return Scrollbar(
        controller: scrollController,
        child: AnimatedList(
          key: _listKey,
          controller: scrollController,
          initialItemCount: requests.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index, animation) {
            // 边界检查，防止 AnimatedList 内部状态与数据源不同步
            if (index < 0 || index >= requests.length) {
              return const SizedBox.shrink();
            }
            final Response<dynamic> r = requests[index];
            if (index == requests.length - 2) {
              InspectorInstance.httpContainer.loadNextPage();
            }
            return SizeTransition(
              sizeFactor: animation,
              child: _ResponseCard(
                key: ValueKey<int>(r.startTimeMilliseconds),
                response: r,
                nav: nav,
                config: _config,
              ),
            );
          },
        ),
      );
    }
    return const Center(
      child: Text(
        'Come back later...\n🧐',
        style: TextStyle(fontSize: 28),
        textAlign: TextAlign.center,
      ),
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: themeMode,
      theme: themeData ??
          FlexThemeData.light(useMaterial3: true, scheme: FlexScheme.redM3),
      home: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.bodyMedium,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            padding: _isFull
                ? EdgeInsets.only(top: MediaQuery.of(context).padding.top)
                : EdgeInsets.zero,
            duration: const Duration(milliseconds: 266),
            constraints: BoxConstraints.tightFor(
              width: double.maxFinite,
              height: _isFull
                  ? MediaQuery.of(context).size.height
                  : (MediaQuery.of(context).size.height / 1.5),
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('请求',
                          style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _settingButton(),
                          _fullButton(),
                          _clearAllButton(context)
                        ],
                      )
                    ],
                  ),
                ),
                SettingWidget(
                  show: _showSetting,
                  config: _config,
                  onChanged: (v) {
                    setState(() {
                      _config = v;
                    });
                  },
                ),
                Expanded(
                  child: ColoredBox(
                    color: Theme.of(context).canvasColor,
                    child: _itemList(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingButton() {
    return IconButton(
        onPressed: () {
          _dioSettingCache.getConfig().then((value) {
            setState(() {
              _config = value;
              _showSetting = !_showSetting;
            });
          });
        },
        icon: const Icon(Icons.settings));
  }
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({
    required Key key,
    required this.response,
    this.nav,
    required this.config,
  }) : super(key: key);

  final Response<dynamic> response;
  final NavigatorState? nav;
  final DioConfig config;

  @override
  Widget build(BuildContext context) {
    final RequestOptions request = response.requestOptions;
    final DateTime startTime = response.startTime;
    final DateTime endTime = response.endTime;
    final Duration duration = endTime.difference(startTime);
    final int? statusCode = response.statusCode;

    final Color statusColor = _getStatusColor(statusCode);
    final String method = request.method;
    final String url =
        config.showFullUrl ? request.uri.toString() : request.uri.path;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            side: BorderSide.none),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            side: BorderSide.none),
        title: _buildTitle(
          context,
          statusCode,
          statusColor,
          method,
          startTime,
          duration,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            url,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        children: [
          _RequestDetails(
            response: response,
            config: config,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    int? statusCode,
    Color statusColor,
    String method,
    DateTime startTime,
    Duration duration,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusCode.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          method,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          startTime.hms(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          '${duration.inMilliseconds}ms',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Color _getStatusColor(int? statusCode) {
    if (statusCode == null) {
      return Colors.grey;
    }
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green.shade600;
    }
    if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange.shade600;
    }
    if (statusCode >= 400 && statusCode < 500) {
      return Colors.purple.shade600;
    }
    if (statusCode >= 500 && statusCode < 600) {
      return Colors.red.shade600;
    }
    return Colors.blueAccent.shade400;
  }
}

class _RequestDetails extends StatelessWidget {
  const _RequestDetails({
    required this.response,
    required this.config,
  });

  final Response<dynamic> response;
  final DioConfig config;

  RequestOptions get _request => response.requestOptions;

  /// The start time for the [_request].
  DateTime get _startTime => response.startTime;

  /// The end time for the [_response].
  DateTime get _endTime => response.endTime;

  /// The duration between the request and the response.
  Duration get _duration => _endTime.difference(_startTime);

  /// Status code for the [_response].
  int get _statusCode => response.statusCode ?? 0;

  /// Colors matching status.
  Color get _statusColor {
    if (_statusCode >= 200 && _statusCode < 300) {
      return Colors.lightGreen;
    }
    if (_statusCode >= 300 && _statusCode < 400) {
      return Colors.orangeAccent;
    }
    if (_statusCode >= 400 && _statusCode < 500) {
      return Colors.purple;
    }
    if (_statusCode >= 500 && _statusCode < 600) {
      return Colors.red;
    }
    return Colors.blueAccent;
  }

  /// The method that the [_request] used.
  String get _method => _request.method;

  /// The [Uri] that the [_request] requested.
  Uri get _requestUri {
    return _request.uri;
  }

  String get _requestUrl {
    return config.showFullUrl ? _requestUri.toString() : _requestUri.path;
  }

  dynamic tryParseMap(String? data) {
    if (data != null) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  ///form data 参数
  String? get _formData {
    if (_request.data is FormData) {
      var stringMap = <String, dynamic>{};
      final data = _request.data as FormData;
      for (var element in data.fields) {
        stringMap[element.key] = element.value;
      }
      for (var element in data.files) {
        final file = element.value;
        stringMap['(file)${element.value.filename}'] = <String, dynamic>{
          "filename": file.filename,
          "contentType": '${file.contentType}',
          "length": file.length,
          "headers": file.headers,
          "field": element.key
        };
      }

      return _encoder.convert(stringMap);
    }
    return null;
  }

  /// Data for the [_request].
  String? get _requestDataBuilder {
    if (_request.data is Map || _request.data is List) {
      return _encoder.convert(_request.data);
    }
    if (_request.data is FormData) {
      return null;
    }
    return _request.data?.toString();
  }

  /// Data for the [_response].
  String? get _responseDataBuilder {
    final data = response.data;
    if (data == null) {
      return null;
    }

    if (data is List<dynamic>) {
      return _encoder.convert(data);
    }

    if (response.data is Map) {
      return _encoder.convert(response.data);
    }
    final dataString = response.data.toString();

    try {
      return _encoder.convert(jsonDecode(dataString));
    } catch (_) {
      return dataString;
    }
  }

  String? get _requestQueryBuilder {
    final q = _requestUri.queryParameters;
    if (q.isNotEmpty) {
      return _encoder.convert(q);
    }
    return q.toString();
  }

  ///获取全部的数据
  String getAll() {
    return _encoder.convert({
      config.urlKey: _requestUrl,
      config.methodKey: _method,
      config.timestampKey: _duration.inMilliseconds,
      config.timeKey: (_startTime.toIso8601String()),
      config.dataKey: tryParseMap(
          _formData ?? (_requestDataBuilder ?? _requestQueryBuilder)),
      config.statusKey: _statusCode,
      config.responseKey: tryParseMap(_responseDataBuilder)
    });
  }

  @override
  Widget build(BuildContext context) {
    final uri = response.realUri.toString();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.showCopyButton)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uri));
                    },
                    child: Text("拷贝 uri")),
                OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: getAll()));
                    },
                    child: Text("拷贝全部"))
              ],
            ),
          if (config.showRequestHeaders)
            _buildDetailItem(
              context,
              'Request Headers',
              _getRequestHeaders(),
              isJson: true,
            ),
          if (_getRequestBody() != null)
            _buildDetailItem(
              context,
              'Request Body',
              _getRequestBody(),
              isJson: true,
            ),
          if (config.showResponseHeaders)
            _buildDetailItem(
              context,
              'Response Headers',
              _getResponseHeaders(),
              isJson: true,
            ),
          _buildDetailItem(
            context,
            'Response Body',
            _getResponseBody(),
            isJson: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String title,
    String? content, {
    bool isJson = false,
  }) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    // 尝试 JSON 高亮
    TextSpan? highlightedSpan;
    if (isJson && JsonHighlighter.isReady) {
      highlightedSpan = JsonHighlighter.highlight(content);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (config.showCopyButton)
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: highlightedSpan != null
              ? SelectableText.rich(highlightedSpan)
              : SelectableText(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String? _getRequestHeaders() {
    final headers = response.requestOptions.headers;
    if (headers.isEmpty) {
      return null;
    }
    return const JsonEncoder.withIndent('  ').convert(headers);
  }

  String? _getRequestBody() {
    final data = response.requestOptions.data;
    if (data == null) {
      return null;
    }
    if (data is FormData) {
      final fields =
          data.fields.map((e) => '"${e.key}": "${e.value}"').join(',\n');
      final files = data.files
          .map((e) => '"${e.key}": "File: ${e.value.filename}"')
          .join(',\n');
      return '{\n$fields,\n$files\n}';
    }
    if (data is Map || data is List) {
      return const JsonEncoder.withIndent('  ').convert(data);
    }
    return data.toString();
  }

  String? _getResponseHeaders() {
    final headers = response.headers.map;
    if (headers.isEmpty) {
      return null;
    }
    return const JsonEncoder.withIndent('  ').convert(
      headers.map((key, value) => MapEntry(key, value.join(', '))),
    );
  }

  String? _getResponseBody() {
    final data = response.data;
    if (data == null) {
      return null;
    }
    if (data is Map || data is List) {
      return const JsonEncoder.withIndent('  ').convert(data);
    }
    try {
      return const JsonEncoder.withIndent('  ')
          .convert(jsonDecode(data.toString()));
    } catch (_) {
      return data.toString();
    }
  }
}

extension _DateTimeExtension on DateTime {
  String hms([String separator = ':']) => '$hour$separator'
      '${'$minute'.padLeft(2, '0')}$separator'
      '${'$second'.padLeft(2, '0')}';
}
