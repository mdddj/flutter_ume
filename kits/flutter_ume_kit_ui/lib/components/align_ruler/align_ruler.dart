part of '../../flutter_ume_kit_ui_plus.dart';

class AlignRuler extends StatefulWidget implements Pluggable {
  const AlignRuler({super.key});

  @override
  _AlignRulerState createState() => _AlignRulerState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(iconBytesAlignRuler);

  @override
  String get name => 'AlignRuler';

  @override
  String get displayName => 'AlignRuler';

  @override
  void onTrigger() {}
}

class _AlignRulerState extends State<AlignRuler> {
  Size _windowSize = windowSize;
  static const Size _dotSize = Size(80, 80);
  static const TextStyle _fontStyle =
      TextStyle(color: Colors.red, fontSize: 15);
  static const TextStyle _infoStyle =
      TextStyle(fontSize: 17, color: Colors.black);
  static final BorderRadius _dotRadius =
      BorderRadius.circular(_dotSize.longestSide);
  static final Offset _dotOffset = _dotSize.center(Offset.zero);

  Offset _dotPosition = Offset.zero;
  Size _textSize = Size.zero;
  Offset _toolBarPosition = const Offset(16, 60);
  bool _switched = false;
  final InspectorSelection _selection =
      WidgetInspectorService.instance.selection;

  // 缓存装饰器避免重复创建
  static final BoxDecoration _dotDecoration = BoxDecoration(
    borderRadius: _dotRadius,
    border: Border.all(color: Colors.black, width: 2),
  );
  static final BoxDecoration _centerDotDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.red.withValues(alpha: .8),
  );

  @override
  void initState() {
    super.initState();
    _dotPosition = _windowSize.center(Offset.zero);
    _textSize = _getTextSize();
    _selection.clear();
  }

  void _onPanUpdate(DragUpdateDetails dragDetails) {
    setState(() {
      _dotPosition = dragDetails.globalPosition;
    });
  }

  void _onPanEnd(DragEndDetails dragDetails) {
    if (!_switched) return;
    // 异步执行耗时的 HitTest 操作
    _performHitTest();
  }

  Future<void> _performHitTest() async {
    final position = _dotPosition;
    final List<RenderObject> objects = HitTest.hitTest(position);
    _selection.candidates = objects;

    Offset? newOffset;
    for (final obj in objects) {
      final translation = obj.getTransformTo(null).getTranslation();
      final rect = obj.paintBounds.shift(Offset(translation.x, translation.y));
      if (rect.contains(position)) {
        final perW = rect.width / 2;
        final perH = rect.height / 2;
        final dx = position.dx <= perW + translation.x
            ? translation.x
            : translation.x + rect.width;
        final dy = position.dy <= translation.y + perH
            ? translation.y
            : translation.y + rect.height;
        newOffset = Offset(dx, dy);
        break;
      }
    }

    if (mounted && newOffset != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _dotPosition = newOffset!;
      });
    }
  }

  void _toolBarPanUpdate(DragUpdateDetails dragDetails) {
    setState(() {
      _toolBarPosition += dragDetails.delta;
    });
  }

  Size _getTextSize() {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(text: '789.5', style: _fontStyle),
    );
    textPainter.layout();
    return Size(textPainter.width, textPainter.height);
  }

  void _switchChanged(bool swi) {
    setState(() {
      _switched = swi;
      if (!_switched) {
        _selection.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (_windowSize.isEmpty) {
      _windowSize = mediaQuery.size;
      _dotPosition = _windowSize.center(Offset.zero);
    }

    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final verticalLeft = _dotPosition.dx - _textSize.width;
    final horizontalTop = _dotPosition.dy - _textSize.height;

    return SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Stack(
        children: [
          // 距离标签
          _buildDistanceLabel(
            left: _dotPosition.dx / 2 - _textSize.width / 2,
            top: horizontalTop,
            text: _dotPosition.dx.toStringAsFixed(1),
          ),
          _buildDistanceLabel(
            left: verticalLeft,
            top: _dotPosition.dy / 2 - _textSize.height / 2,
            text: _dotPosition.dy.toStringAsFixed(1),
          ),
          _buildDistanceLabel(
            left: _dotPosition.dx +
                (_windowSize.width - _dotPosition.dx) / 2 -
                _textSize.width / 2,
            top: horizontalTop,
            text: (_windowSize.width - _dotPosition.dx).toStringAsFixed(1),
          ),
          _buildDistanceLabel(
            left: verticalLeft,
            top: _dotPosition.dy +
                (_windowSize.height - _dotPosition.dy) / 2 -
                _textSize.height / 2,
            text: (_windowSize.height - _dotPosition.dy).toStringAsFixed(1),
          ),
          // 十字线 - 使用 RepaintBoundary 隔离重绘
          RepaintBoundary(
            child: CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: _CrosshairPainter(_dotPosition, _windowSize),
            ),
          ),
          // 拖动圆点
          Positioned(
            left: _dotPosition.dx - _dotOffset.dx,
            top: _dotPosition.dy - _dotOffset.dy,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                height: _dotSize.height,
                width: _dotSize.width,
                decoration: _dotDecoration,
                child: Center(
                  child: Container(
                    height: _dotSize.width / 2.5,
                    width: _dotSize.height / 2.5,
                    decoration: _centerDotDecoration,
                  ),
                ),
              ),
            ),
          ),
          // 工具栏
          Positioned(
            left: _toolBarPosition.dx,
            top: _toolBarPosition.dy,
            child: GestureDetector(
              onPanUpdate: _toolBarPanUpdate,
              child: _buildToolBar(screenWidth),
            ),
          ),
          InspectorOverlay(
            selection: _selection,
            needDescription: false,
            needEdges: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceLabel({
    required double left,
    required double top,
    required String text,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Text(text, style: _fontStyle),
    );
  }

  Widget _buildToolBar(double screenWidth) {
    final dx = _dotPosition.dx;
    final dy = _dotPosition.dy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 位置信息
          DefaultTextStyle(
            style: _infoStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'L: ${dx.toStringAsFixed(0)}  R: ${(_windowSize.width - dx).toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                Text(
                    'T: ${dy.toStringAsFixed(0)}  B: ${(_windowSize.height - dy).toStringAsFixed(0)}'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 吸附开关
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 32,
                child: Switch(
                  value: _switched,
                  onChanged: _switchChanged,
                  activeTrackColor: Colors.red.shade200,
                  activeThumbColor: Colors.red,
                ),
              ),
              Text(
                '吸附',
                style: TextStyle(
                  fontSize: 12,
                  color: _switched ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 十字线绘制器 - 使用 CustomPainter 提升性能
class _CrosshairPainter extends CustomPainter {
  final Offset position;
  final Size windowSize;

  _CrosshairPainter(this.position, this.windowSize);

  static final Paint _paint = Paint()
    ..color = const Color(0xffff0000)
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    // 垂直线
    canvas.drawLine(
      Offset(position.dx, 0),
      Offset(position.dx, windowSize.height),
      _paint,
    );
    // 水平线
    canvas.drawLine(
      Offset(0, position.dy),
      Offset(windowSize.width, position.dy),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_CrosshairPainter oldDelegate) {
    return position != oldDelegate.position;
  }
}
