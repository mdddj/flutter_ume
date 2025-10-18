import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ume_plus/flutter_ume_plus.dart';

import '../../flutter_ume_kit_dio_plus.dart';
import '../constants/extensions.dart';
import '../instances.dart';
import '../models/config.dart';

const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

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

  @override
  void initState() {
    super.initState();
    InspectorInstance.httpContainer.addListener(_listener);
    Future.microtask(() {
      DioConfigUtil.instance.getConfig().then((value) {
        setState(() {
          _config = value;
        });
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    InspectorInstance.httpContainer
      ..removeListener(_listener) // First, remove refresh listener.
      ..resetPaging(); // Then reset the paging field.
    super.dispose();
  }

  /// Using [setState] won't cause too much performance regression,
  /// since we've implemented the list with `findChildIndexCallback`.
  void _listener() {
    Future.microtask(() {
      if (mounted &&
          !context.debugDoingBuild &&
          context.owner?.debugBuilding != true) {
        setState(() {});
      }
    });
  }

  Widget _clearAllButton(BuildContext context) {
    return FilledButton.icon(
        onPressed: InspectorInstance.httpContainer.clearRequests,
        icon: const Icon(
          Icons.cleaning_services,
          size: 12,
        ),
        style: _buttonStyle(context, padding: const EdgeInsets.all(2)),
        label: const Text('清理'));
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
    final int length = requests.length;
    if (length > 0) {
      return Scrollbar(
        controller: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, int index) {
                  final Response<dynamic> r = requests[index];
                  if (index == length - 2) {
                    InspectorInstance.httpContainer.loadNextPage();
                  }
                  return _ResponseCard(
                    key: ValueKey<int>(r.startTimeMilliseconds),
                    response: r,
                    nav: nav,
                    config: _config,
                  );
                },
                childCount: length,
              ),
            ),
          ],
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
          DioConfigUtil.instance.getConfig().then((value) {
            setState(() {
              _config = value;
              _showSetting = !_showSetting;
            });
          });
        },
        icon: const Icon(Icons.settings));
  }
}

class _ResponseCard extends StatefulWidget {
  const _ResponseCard(
      {required super.key,
      required this.response,
      this.nav,
      required this.config});

  final Response<dynamic> response;
  final NavigatorState? nav;
  final DioConfig config;

  @override
  _ResponseCardState createState() => _ResponseCardState();
}

class _ResponseCardState extends State<_ResponseCard> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

  DioConfig get config => widget.config;

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  void _switchExpand() {
    _isExpanded.value = !_isExpanded.value;
  }

  Response<dynamic> get _response => widget.response;

  RequestOptions get _request => _response.requestOptions;

  /// The start time for the [_request].
  DateTime get _startTime => _response.startTime;

  /// The end time for the [_response].
  DateTime get _endTime => _response.endTime;

  /// The duration between the request and the response.
  Duration get _duration => _endTime.difference(_startTime);

  /// Status code for the [_response].
  int get _statusCode => _response.statusCode ?? 0;

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

  String? _requestHeadersBuilder(BuildContext context) {
    final Map<String, List<String>> map = _request.headers.map(
      (key, value) => MapEntry(
        key,
        value is Iterable ? value.map((v) => v.toString()).toList() : ['$value'],
      ),
    );
    final Headers headers = Headers.fromMap(map);
    if (headers.isEmpty) {
      return null;
    }
    return '$headers';
  }

  String? get _requestQueryBuilder {
    final q = _requestUri.queryParameters;
    if (q.isNotEmpty) {
      return _encoder.convert(q);
    }
    return q.toString();
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
    final data = _response.data;
    if (data == null) {
      return null;
    }

    if (data is List<dynamic>) {
      return _encoder.convert(data);
    }

    if (_response.data is Map) {
      return _encoder.convert(_response.data);
    }
    final dataString = _response.data.toString();

    try {
      return _encoder.convert(jsonDecode(dataString));
    } catch (_) {
      return dataString;
    }
  }

  //
  String? get _responseHeadersBuilder {
    if (_response.headers.isEmpty) {
      return null;
    }
    return '${_response.headers}';
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

  Widget _detailButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.showCopyButton)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: getAll()));
              },
              style: _buttonStyle(context).copyWith(
                  backgroundColor: const MaterialStatePropertyAll(Colors.white),
                  foregroundColor:
                      const MaterialStatePropertyAll(Colors.black)),
              child: const Text(
                '复制全部',
                style: TextStyle(fontSize: 12, height: 1.2),
              ),
            ),
          ),
        TextButton(
          onPressed: _switchExpand,
          style: _buttonStyle(context),
          child: const Text(
            '详情',
            style: TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _infoContent(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _statusColor,
          ),
          child: Text(
            _statusCode.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 6),
        Text(_startTime.hms()),
        const SizedBox(width: 6),
        Text(
          _method,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Text('${_duration.inMilliseconds}ms'),
        const Spacer(),
        _detailButton(context),
      ],
    );
  }

  Widget _detailedContent(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isExpanded,
      builder: (_, bool value, __) {
        if (!value) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _TagText(
                tag: '请求头',
                content: _requestHeadersBuilder(context),
                config: config,
              ),
              if (_requestDataBuilder != null)
                _TagText(
                  tag: '请求参数(Body Json)',
                  content: _requestDataBuilder,
                  config: config,
                ),
              if (_requestUri.queryParameters.isNotEmpty)
                _TagText(
                  tag: '查询参数(Query)',
                  content: _requestQueryBuilder,
                  config: config,
                ),
              if (_formData != null)
                _TagText(
                  tag: "FormData",
                  content: _formData,
                  config: config,
                ),
              _TagText(
                tag: '返回数据',
                content: _responseDataBuilder,
                config: config,
              ),
              _TagText(
                tag: '返回头',
                content: _responseHeadersBuilder,
                config: config,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ]),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Theme.of(context).colorScheme.outlineVariant,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _infoContent(context),
              const SizedBox(height: 10),
              _TagText(
                tag: _method,
                content: _requestUrl,
                shouldStartFromNewLine: false,
                nav: widget.nav,
                fontSize: 14,
                config: config,
              ),
              _detailedContent(context),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagText extends StatelessWidget {
  const _TagText(
      {required this.tag,
      this.content,
      this.shouldStartFromNewLine = true,
      this.nav,
      this.fontSize,
      required this.config});

  final NavigatorState? nav;
  final String tag;
  final String? content;
  final bool shouldStartFromNewLine;
  final double? fontSize;
  final DioConfig config;

  bool get showCopyButton => config.showCopyButton;

  TextSpan span(BuildContext context) {
    return TextSpan(
      children: <TextSpan>[
        TextSpan(
          text: '$tag: ',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        if (showCopyButton)
          TextSpan(
              text: ' 复制 ',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: fontSize ?? 10),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Clipboard.setData(ClipboardData(text: content ?? ''));
                }),
        if (shouldStartFromNewLine) const TextSpan(text: '\n'),
        TextSpan(text: content!, style: TextStyle(fontSize: fontSize ?? 10)),
      ],
    );
  }

  Widget spanVersion(BuildContext context) {
    return SelectableText.rich(span(context));
  }

  @override
  Widget build(BuildContext context) {
    if (content == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: spanVersion(context),
    );
  }
}

extension _DateTimeExtension on DateTime {
  String hms([String separator = ':']) => '$hour$separator'
      '${'$minute'.padLeft(2, '0')}$separator'
      '${'$second'.padLeft(2, '0')}';
}
