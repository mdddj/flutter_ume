part of '../../flutter_ume_kit_ui_plus.dart';

class ColorSucker extends StatefulWidget implements Pluggable {
  final double scale;
  final Size size;

  const ColorSucker({
    super.key,
    this.scale = 10.0,
    this.size = const Size(100, 100),
  });

  @override
  _ColorSuckerState createState() => _ColorSuckerState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'ColorSucker';

  @override
  String get displayName => 'ColorSucker';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(iconBytesWithColorSucker);
}

class _ColorSuckerState extends State<ColorSucker> {
  late Size _magnifierSize;
  double? _scale;
  BorderRadius _radius = BorderRadius.zero;
  Color _currentColor = Colors.white;
  img.Image? _snapshot;
  Offset _magnifierPosition = Offset.zero;
  double _toolBarY = 60.0;
  Matrix4 _matrix = Matrix4.identity();
  late Size _windowSize;
  bool _excuting = false;

  // 节流：记录上次更新时间，限制更新频率
  DateTime _lastUpdate = DateTime.now();
  static const _updateInterval = Duration(milliseconds: 16); // ~60fps

  @override
  void initState() {
    _windowSize = WidgetsBinding
            .instance.platformDispatcher.views.first.physicalSize /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    _magnifierSize = widget.size;
    _scale = widget.scale;
    _radius = BorderRadius.circular(_magnifierSize.longestSide);
    _matrix = Matrix4.identity()
      ..scaleByDouble(widget.scale, widget.scale, 1.0, 1.0);
    _magnifierPosition =
        _windowSize.center(Offset.zero) - _magnifierSize.center(Offset.zero);
    super.initState();
  }

  @override
  void didUpdateWidget(ColorSucker oldWidget) {
    if (oldWidget.size != widget.size) {
      _magnifierSize = widget.size;
      _radius = BorderRadius.circular(_magnifierSize.longestSide);
    }
    if (oldWidget.scale != widget.scale) {
      _scale = widget.scale;
      _matrix = Matrix4.identity()..scaleByDouble(_scale!, _scale!, 1.0, 1.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onPanUpdate(DragUpdateDetails dragDetails) {
    // 节流：限制更新频率，避免过度重建
    final now = DateTime.now();
    if (now.difference(_lastUpdate) < _updateInterval) {
      return;
    }
    _lastUpdate = now;

    _magnifierPosition =
        dragDetails.globalPosition - _magnifierSize.center(Offset.zero);
    double newX = dragDetails.globalPosition.dx;
    double newY = dragDetails.globalPosition.dy;
    final Matrix4 newMatrix = Matrix4.identity()
      ..translateByDouble(newX, newY, 0.0, 1.0)
      ..scaleByDouble(_scale!, _scale!, 1.0, 1.0)
      ..translateByDouble(-newX, -newY, 0.0, 1.0);
    _matrix = newMatrix;
    _searchPixel(dragDetails.globalPosition);
    setState(() {});
  }

  void _toolBarPanUpdate(DragUpdateDetails dragDetails) {
    _toolBarY = dragDetails.globalPosition.dy - 40;
    setState(() {});
  }

  void _onPanStart(DragStartDetails dragDetails) async {
    if (_snapshot == null && _excuting == false) {
      _excuting = true;
      await _captureScreen();
      // 截图完成后，计算当前位置的颜色
      _searchPixel(dragDetails.globalPosition);
      setState(() {});
    }
  }

  void _onPanEnd(DragEndDetails dragDetails) {
    _snapshot = null;
    _excuting = false;
  }

  void _searchPixel(Offset globalPosition) {
    _calculatePixel(globalPosition);
  }

  Future<void> _captureScreen() async {
    try {
      RenderRepaintBoundary boundary =
          rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // 使用 pixelRatio: 1.0 确保截图坐标与逻辑坐标一致
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();
      _snapshot = img.decodeImage(pngBytes);
      _excuting = false;
      image.dispose();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _calculatePixel(Offset globalPosition) {
    if (_snapshot == null) return;
    int px = globalPosition.dx.toInt();
    int py = globalPosition.dy.toInt();
    if (px < 0 || py < 0 || px >= _snapshot!.width || py >= _snapshot!.height) {
      return;
    }
    final pixel = _snapshot!.getPixel(px, py);
    // image 库返回 16 位值 (0-65535)，需要右移 8 位转换为 8 位 (0-255)
    _currentColor = Color.fromARGB(
      (pixel.a.toInt() >> 8).clamp(0, 255),
      (pixel.r.toInt() >> 8).clamp(0, 255),
      (pixel.g.toInt() >> 8).clamp(0, 255),
      (pixel.b.toInt() >> 8).clamp(0, 255),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
      _magnifierPosition =
          _windowSize.center(Offset.zero) - _magnifierSize.center(Offset.zero);
    }
    Widget toolBar = Container(
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(2, 2))
          ]),
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentColor,
                border: Border.all(width: 2.0, color: Colors.white),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2))
                ]),
          ),
          Container(
            margin: const EdgeInsets.only(left: 40, right: 16),
            child: SelectableText("#${_currentColor.hexRGB}",
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.grey,
                )),
          ),
        ],
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
            left: 0,
            top: _toolBarY,
            child: GestureDetector(
                onVerticalDragUpdate: _toolBarPanUpdate, child: toolBar)),
        Positioned(
          left: _magnifierPosition.dx,
          top: _magnifierPosition.dy,
          child: ClipRRect(
            borderRadius: _radius,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanEnd: _onPanEnd,
              onPanUpdate: _onPanUpdate,
              child: BackdropFilter(
                filter: ui.ImageFilter.matrix(_matrix.storage,
                    filterQuality: FilterQuality.none),
                child: Container(
                  height: _magnifierSize.height,
                  width: _magnifierSize.width,
                  decoration: BoxDecoration(
                      borderRadius: _radius,
                      border: Border.all(color: Colors.grey, width: 3)),
                  child: Center(
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                          color: Colors.grey, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
