///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 11:25
///
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../constants/extensions.dart';
import '../instances.dart';
import '../pluggable.dart';

const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

ButtonStyle _buttonStyle(
  BuildContext context, {
  EdgeInsetsGeometry? padding,
}) {
  return TextButton.styleFrom(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    minimumSize: Size.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999999),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    disabledForegroundColor: Colors.white,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

class DioPluggableState extends State<DioInspector> {
  final NavigatorState? nav;

  DioPluggableState(this.nav);

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Bind listener to refresh requests.
    InspectorInstance.httpContainer.addListener(_listener);
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
        icon: Icon(Icons.cleaning_services,size: 12,),
        style: _buttonStyle(context,padding: EdgeInsets.all(2)),
        label: Text('清理'));
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
    return Material(
      color: Colors.black38,
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.bodyMedium,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints.tightFor(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height / 1.25,
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
                      Text('请求',style: Theme.of(context).textTheme.titleMedium),
                      _clearAllButton(context)
                    ],
                  ),
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
}

class _ResponseCard extends StatefulWidget {
  const _ResponseCard({required Key? key, required this.response, this.nav})
      : super(key: key);

  final Response<dynamic> response;
  final NavigatorState? nav;

  @override
  _ResponseCardState createState() => _ResponseCardState();
}

class _ResponseCardState extends State<_ResponseCard> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

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
    return _requestUri.path;
  }

  String? _requestHeadersBuilder(BuildContext context) {
    final Map<String, List<String>> map = _request.headers.map(
      (key, value) => MapEntry(
        key,
        value is Iterable ? value.map((v) => v.toString()).toList() : [value],
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

  /// Data for the [_request].
  String? get _requestDataBuilder {
    if (_request.data is Map || _request.data is List) {
      return _encoder.convert(_request.data);
    }
    return _request.data?.toString();
  }

  /// Data for the [_response].
  String? get _responseDataBuilder {
    final data = _response.data;
    if (data == null) {
      return null;
    }

    if(data is List<dynamic>) {
      return _encoder.convert(data);
    }

    if (_response.data is Map) {
      return _encoder.convert(_response.data);
    }
    final dataString = _response.data.toString();

    try{
      return _encoder.convert(jsonDecode(dataString));
    }catch(_){
      return dataString;
    }

  }

  String? get _responseHeadersBuilder {
    if (_response.headers.isEmpty) {
      return null;
    }
    return '${_response.headers}';
  }

  Widget _detailButton(BuildContext context) {
    return TextButton(
      onPressed: _switchExpand,
      style: _buttonStyle(context),
      child: const Text(
        '详情',
        style: TextStyle(fontSize: 12, height: 1.2),
      ),
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
              // ElevatedButton(
              //     onPressed: () {
              //       widget.nav?.push(MaterialPageRoute(
              //           builder: (_) => MyJsonView(
              //               title: '数据', data: _responseDataBuilder)));
              //     },
              //     child: Text("格式化展示")),
              _TagText(
                tag: '请求头',
                content: _requestHeadersBuilder(context),
              ),
              _TagText(
                tag: '请求参数(Body Json)',
                content: _requestDataBuilder,
              ),
              if(_requestUri.queryParameters.isNotEmpty)
              _TagText(
                tag: '查询参数(Query)',
                content: _requestQueryBuilder,
              ),
              _TagText(
                tag: '返回数据',
                content: _responseDataBuilder,
              ),
              _TagText(
                tag: '返回头',
                content: _responseHeadersBuilder,
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
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ]
      ),
      child: Card(
        margin:  EdgeInsets.zero,
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
                tag: '$_method',
                content: '$_requestUrl',
                shouldStartFromNewLine: false,
                nav: widget.nav,
                fontSize: 14,
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
      {Key? key,
      required this.tag,
      this.content,
      this.shouldStartFromNewLine = true,
      this.nav, this.fontSize})
      : super(key: key);
  final NavigatorState? nav;
  final String tag;
  final String? content;
  final bool shouldStartFromNewLine;
  final double? fontSize;

  TextSpan span(BuildContext context) {
    return TextSpan(
      children: <TextSpan>[
        TextSpan(
          text: '$tag: ',
          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),
        ),
        // TextSpan(
        //     text: ' 格式化展示>> ',
        //     recognizer: TapGestureRecognizer()..onTap = () => {nav?.push(MaterialPageRoute(builder: (_) => MyJsonView(title: tag, data: content)))},
        //     style: TextStyle(color: Colors.blueGrey)),
        if (shouldStartFromNewLine) TextSpan(text: '\n'),
        TextSpan(text: content!,style: TextStyle(fontSize: fontSize ?? 10)),
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
