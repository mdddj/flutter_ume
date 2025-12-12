part of '../flutter_ume_kit_console_plus.dart';

typedef ConsoleMessageCustomBuilder = Widget Function(
    String time, String log, int index, List<Tuple2<DateTime, String>> logs);

class Console extends StatefulWidget implements PluggableWithStream {
  final ConsoleMessageCustomBuilder? builder;

  Console({super.key, this.builder}) {
    ConsoleManager.redirectDebugPrint();
  }

  @override
  ConsoleState createState() => ConsoleState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(iconBytes);

  @override
  String get name => 'Console';

  @override
  String get displayName => 'Console';

  @override
  void onTrigger() {}

  @override
  Stream get stream => ConsoleManager.streamController.stream;

  @override
  StreamFilter get streamFilter => (e) => true;
}

enum ConsoleUIStyle {
  classic, // 经典样式
  card, // 卡片样式
  compact, // 紧凑样式
}

class ConsoleState extends State<Console>
    with WidgetsBindingObserver, StoreMixin {
  List<Tuple2<DateTime, String>> _logList = <Tuple2<DateTime, String>>[];
  StreamSubscription? _subscription;
  ScrollController? _controller;
  ShowDateTimeStyle? _showDateTimeStyle;
  ConsoleUIStyle _uiStyle = ConsoleUIStyle.classic;
  bool _showFilter = false;
  RegExp? _filterExp;

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller = null;
    _showDateTimeStyle = ShowDateTimeStyle.datetime;
    _showFilter = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _showDateTimeStyle = ShowDateTimeStyle.none;
    fetchWithKey('console_panel_datetime_style').then((value) async {
      if (value != null && value is int) {
        _showDateTimeStyle = styleById(value);
      } else {
        _showDateTimeStyle = ShowDateTimeStyle.datetime;
        await storeWithKey(
            'console_panel_datetime_style', idByStyle(_showDateTimeStyle!));
      }
      setState(() {});
    });
    fetchWithKey('console_panel_ui_style').then((value) async {
      if (value != null &&
          value is int &&
          value < ConsoleUIStyle.values.length) {
        _uiStyle = ConsoleUIStyle.values[value];
      } else {
        _uiStyle = ConsoleUIStyle.classic;
        await storeWithKey('console_panel_ui_style', _uiStyle.index);
      }
      setState(() {});
    });
    _controller = ScrollController();
    _logList = ConsoleManager.logData.toList();
    _subscription = ConsoleManager.streamController.stream.listen((onData) {
      if (mounted) {
        if (_filterExp != null) {
          _logList = ConsoleManager.logData.where((e) {
            return _filterExp!.hasMatch(e.item1.toString()) ||
                _filterExp!.hasMatch(e.item2);
          }).toList();
        } else {
          _logList = ConsoleManager.logData.toList();
        }

        setState(() {});
        _controller!.jumpTo(
            _controller!.position.maxScrollExtent + 22); // 22 is a magic number
      }
    });
  }

  void _refreshConsole() {
    if (_filterExp != null) {
      _logList = ConsoleManager.logData.where((e) {
        return _filterExp!.hasMatch(e.item1.toString()) ||
            _filterExp!.hasMatch(e.item2);
      }).toList();
    } else {
      _logList = ConsoleManager.logData.toList();
    }
  }

  double get _fontSize => 16;

  String _dateTimeString(int logIndex) {
    String result = '';
    switch (_showDateTimeStyle) {
      case ShowDateTimeStyle.datetime:
        result = _logList[_logList.length - logIndex - 1]
            .item1
            .toString()
            .padRight(26, '0');
        break;
      case ShowDateTimeStyle.time:
        result = _logList[_logList.length - logIndex - 1]
            .item1
            .toString()
            .padRight(26, '0')
            .substring(11);
        break;
      case ShowDateTimeStyle.timestamp:
        result =
            '${_logList[_logList.length - logIndex - 1].item1.millisecondsSinceEpoch}';
        break;
      case ShowDateTimeStyle.none:
        result = '';
        break;
      default:
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      contentWidget: Stack(children: [
        ListView.builder(
          controller: _controller,
          itemCount: _logList.length,
          padding: _uiStyle == ConsoleUIStyle.card
              ? const EdgeInsets.all(8)
              : EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            final dateString = _dateTimeString(index);
            final message = _logList[_logList.length - index - 1].item2;
            if (widget.builder != null) {
              return widget.builder!.call(dateString, message, index, _logList);
            }
            return _buildLogItem(dateString, message, index);
          },
        ),
        if (_showFilter)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: TextField(
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _filterExp = RegExp(value);
                } else {
                  _filterExp = null;
                }
                setState(() {});
                _refreshConsole();
              },
              style: const TextStyle(
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'RegExp',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                contentPadding: EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
      ]),
      toolbarActions: [
        Tuple3(
            _uiStyleName,
            const Icon(
              Icons.style,
              size: 20,
            ),
            _triggerUIStyle),
        Tuple3(
            'Time',
            const Icon(
              Icons.access_time,
              size: 20,
            ),
            _triggerShowDate),
        const Tuple3(
            'Clear',
            Icon(
              Icons.do_not_disturb,
              size: 20,
            ),
            ConsoleManager.clearLog),
        Tuple3(
            'Filter',
            const Icon(
              Icons.search,
              size: 20,
            ),
            _triggerFilter),
        Tuple3(
            'Share',
            const Icon(
              Icons.share,
              size: 20,
            ),
            _share),
      ],
      closeAction: UMEWidget.closeActivatedPlugin,
    );
  }

  Widget _buildLogItem(String dateString, String message, int index) {
    switch (_uiStyle) {
      case ConsoleUIStyle.card:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dateString.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(7)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '#${_logList.length - index}',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: LogTextViewer(
                    logText: message,
                    style: TextStyle(
                      fontSize: _fontSize - 2,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case ConsoleUIStyle.compact:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dateString.isNotEmpty)
                Text(
                  dateString.substring(dateString.length > 12 ? 11 : 0,
                      dateString.length > 19 ? 19 : dateString.length),
                  style: TextStyle(
                    fontSize: _fontSize - 3,
                  ),
                ),
              if (dateString.isNotEmpty) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: _fontSize - 2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

      case ConsoleUIStyle.classic:
        return Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
          child: RichText(
            text: TextSpan(style: TextStyle(color: Colors.black), children: [
              TextSpan(
                  text: dateString,
                  style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey)),
              TextSpan(
                  text: message,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w400,
                  )),
            ]),
          ),
        );
    }
  }

  void _triggerShowDate() async {
    _showDateTimeStyle = styleById((idByStyle(_showDateTimeStyle!) + 1) % 4);
    await storeWithKey(
        'console_panel_datetime_style', idByStyle(_showDateTimeStyle!));
    setState(() {});
  }

  void _triggerUIStyle() async {
    _uiStyle = ConsoleUIStyle
        .values[(_uiStyle.index + 1) % ConsoleUIStyle.values.length];
    await storeWithKey('console_panel_ui_style', _uiStyle.index);
    setState(() {});
  }

  String get _uiStyleName {
    switch (_uiStyle) {
      case ConsoleUIStyle.classic:
        return 'Classic';
      case ConsoleUIStyle.card:
        return 'Card';
      case ConsoleUIStyle.compact:
        return 'Compact';
    }
  }

  void _triggerFilter() {
    setState(() {
      _showFilter = !_showFilter;
      if (!_showFilter) {
        _filterExp = null;
      }
    });
    _refreshConsole();
  }

  Future<void> _share() async {
    if (_logList.isEmpty) {
      return;
    }
    final l = _logList.map((e) => '${e.item1.toString()} ${e.item2}').toList();
    SharePlus.instance.share(ShareParams(text: l.join("\n")));
  }
}
