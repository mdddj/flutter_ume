part of '../flutter_ume_plus.dart';

typedef ToolbarAction = void Function();

class FloatingWidget extends StatefulWidget {
  const FloatingWidget({
    super.key,
    this.contentWidget,
    this.closeAction,
    this.toolbarActions,
    this.minimalHeight = 120,
  });

  final Widget? contentWidget;
  final CloseAction? closeAction;
  final List<Tuple3<String, Widget, ToolbarAction>>? toolbarActions;
  final double minimalHeight;

  @override
  _FloatingWidgetState createState() => _FloatingWidgetState();
}

const double _dragBarHeight2 = 32;
const double _toolBarHeight = 32;

class _FloatingWidgetState extends State<FloatingWidget> with StoreMixin {
  Size _windowSize = windowSize;
  double _dy = 0;
  bool _fullScreen = false;

  double get toolBarHeight =>
      (widget.toolbarActions != null && widget.toolbarActions!.isNotEmpty)
          ? _toolBarHeight
          : 0;

  @override
  void initState() {
    fetchWithKey('floating_widget').then((value) {
      if (value != null) {
        setState(() {
          _dy = value;
        });
      }
    });
    _dy = _windowSize.height -
        widget.minimalHeight -
        _dragBarHeight2 -
        toolBarHeight;
    super.initState();
  }

  void _dragEvent(DragUpdateDetails details) {
    _dy += details.delta.dy;
    _dy = math.min(
        math.max(0, _dy),
        MediaQuery.of(context).size.height -
            widget.minimalHeight -
            _dragBarHeight2 -
            toolBarHeight -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom);
    setState(() {});
  }

  void _dragEnd(DragEndDetails details) async {
    await storeWithKey('floating_widget', _dy);
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _dy =
          MediaQuery.of(context).size.height - dotSize.height - bottomDistance;
      _windowSize = MediaQuery.of(context).size;
    }
    return SizedBox(
        width: _windowSize.width,
        height: _windowSize.height,
        child: Stack(alignment: Alignment.center, children: <Widget>[
          Positioned(
            left: 0,
            top: _fullScreen ? 0 : _dy,
            child: __ToolBarContent2(
              minimalHeight: widget.minimalHeight,
              contentWidget: widget.contentWidget,
              dragCallback: _dragEvent,
              dragEnd: _dragEnd,
              maximalAction: () {
                setState(() {
                  _fullScreen = !_fullScreen;
                });
              },
              closeAction: widget.closeAction,
              toolbarActions: widget.toolbarActions,
            ),
          )
        ]));
  }
}

class __ToolBarContent2 extends StatefulWidget {
  const __ToolBarContent2(
      {this.contentWidget,
      this.dragCallback,
      this.dragEnd,
      this.maximalAction,
      this.closeAction,
      this.toolbarActions,
      required this.minimalHeight});

  final Widget? contentWidget;
  final Function? dragCallback;
  final Function? dragEnd;
  final CloseAction? closeAction;
  final MaximalAction? maximalAction;
  final List<Tuple3<String, Widget, ToolbarAction>>? toolbarActions;
  final double minimalHeight;

  @override
  ___ToolBarContent2State createState() => ___ToolBarContent2State();
}

class ___ToolBarContent2State extends State<__ToolBarContent2> {
  bool _fullScreen = false;
  Size _windowSize = windowSize;

  double get toolBarHeight =>
      (widget.toolbarActions != null && widget.toolbarActions!.isNotEmpty)
          ? _toolBarHeight
          : 0;

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
    }
    const cornerRadius = Radius.circular(10);
    return SafeArea(
      child: Material(
        borderRadius:
            const BorderRadius.only(topLeft: cornerRadius, topRight: cornerRadius),
        elevation: 20,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: cornerRadius, topRight: cornerRadius),
            color: Color(0xffd0d0d0),
          ),
          width: MediaQuery.of(context).size.width,
          height: _fullScreen
              ? _windowSize.height
              : widget.minimalHeight + _dragBarHeight2 + toolBarHeight,
          child: Column(
            children: [
              SizedBox(
                height: _dragBarHeight2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () {
                            if (widget.closeAction != null) {
                              widget.closeAction!();
                            }
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xffff5a52),
                          )),
                      const SizedBox(
                        width: 8,
                      ),
                      InkWell(
                          onTap: () {
                            if (widget.maximalAction != null) {
                              widget.maximalAction!();
                            }
                            setState(() {
                              _fullScreen = !_fullScreen;
                            });
                          },
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: _fullScreen
                                ? const Color(0xffe6c029)
                                : const Color(0xff53c22b),
                          )),
                      Expanded(
                        child: GestureDetector(
                          onVerticalDragUpdate: _dragCallback,
                          onVerticalDragEnd: _dragEnd,
                          child: Container(
                            height: _dragBarHeight2,
                            color: const Color(0xffd0d0d0),
                            child: const Center(
                              child: Text(
                                'UME',
                                style: TextStyle(
                                    color: Color(0xff575757),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: _fullScreen
                    ? _windowSize.height -
                        _dragBarHeight2 -
                        toolBarHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom
                    : widget.minimalHeight,
                child: widget.contentWidget,
              ),
              if (widget.toolbarActions != null &&
                  widget.toolbarActions!.isNotEmpty)
                Container(
                  alignment: Alignment.centerLeft,
                  height: _toolBarHeight,
                  child: SingleChildScrollView(
                    // padding: const EdgeInsets.only(left: 80),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: widget.toolbarActions!.map((tuple) {
                        final title = tuple.item1;
                        final widget = tuple.item2;
                        final action = tuple.item3;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6, right: 6),
                          child: GestureDetector(
                            onTap: action,
                            child: Row(
                              children: [
                                widget,
                                Text(title),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _dragCallback(DragUpdateDetails details) {
    if (widget.dragCallback != null) widget.dragCallback!(details);
  }

  _dragEnd(DragEndDetails details) {
    if (widget.dragEnd != null) widget.dragEnd!(details);
  }
}
