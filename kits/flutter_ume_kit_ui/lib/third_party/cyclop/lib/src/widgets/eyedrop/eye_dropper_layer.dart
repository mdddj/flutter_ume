import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

import '../../utils.dart';
import 'eye_dropper_overlay.dart';

final _captureKey = GlobalKey();

class _EyeDropperModel {
  /// based on PointerEvent.kind
  bool touchable = false;

  OverlayEntry? eyeOverlayEntry;

  img.Image? snapshot;

  /// 截图区域的全局偏移（用于坐标转换）
  Offset snapshotOffset = Offset.zero;

  Offset cursorPosition = screenSize.center(Offset.zero);

  Color hoverColor = Colors.black;

  List<Color> hoverColors = [];

  Color selectedColor = Colors.black;

  ValueChanged<Color>? onColorSelected;

  ValueChanged<Color>? onColorChanged;

  _EyeDropperModel();
}

class EyeDrop extends InheritedWidget {
  static _EyeDropperModel data = _EyeDropperModel();

  EyeDrop({required Widget child, super.key})
      : super(
          child: RepaintBoundary(
            key: _captureKey,
            child: Listener(
              onPointerMove: (details) => _onHover(
                details.position,
                details.kind == PointerDeviceKind.touch,
              ),
              onPointerHover: (details) => _onHover(
                details.position,
                details.kind == PointerDeviceKind.touch,
              ),
              onPointerUp: (details) => _onPointerUp(details.position),
              child: child,
            ),
          ),
        );

  static EyeDrop of(BuildContext context) {
    final eyeDrop = context.dependOnInheritedWidgetOfExactType<EyeDrop>();
    if (eyeDrop == null) {
      throw Exception(
          'No EyeDrop found. You must wrap your application within an EyeDrop widget.');
    }
    return eyeDrop;
  }

  static void handlePointerUp(Offset position) {
    handlePointerMove(position, data.touchable);
    if (data.onColorSelected != null) {
      data.onColorSelected!(data.hoverColors.center);
    }

    if (data.eyeOverlayEntry != null) {
      try {
        data.eyeOverlayEntry!.remove();
        data.eyeOverlayEntry = null;
        data.onColorSelected = null;
        data.onColorChanged = null;
      } catch (err) {
        debugPrint('ERROR !!! handlePointerUp $err');
      }
    }
  }

  static void handlePointerMove(Offset offset, bool touchable) {
    if (data.eyeOverlayEntry != null) data.eyeOverlayEntry!.markNeedsBuild();

    data.cursorPosition = offset;
    data.touchable = touchable;

    if (data.snapshot != null) {
      // 直接使用全局坐标（因为截图从屏幕左上角开始）
      data.hoverColor = getPixelColor(data.snapshot!, offset);
      data.hoverColors = getPixelColors(data.snapshot!, offset);
    }

    if (data.onColorChanged != null) {
      data.onColorChanged!(data.hoverColors.center);
    }
  }

  // 保留私有方法供内部 Listener 使用
  static void _onPointerUp(Offset position) => handlePointerUp(position);
  static void _onHover(Offset offset, bool touchable) =>
      handlePointerMove(offset, touchable);

  void capture(BuildContext context, ValueChanged<Color> onColorSelected,
      ValueChanged<Color>? onColorChanged) async {
    // 使用 captureKey 来截图
    final renderer = _captureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (renderer == null) {
      debugPrint('EyeDrop: renderer is null');
      return;
    }

    // 获取截图区域的全局偏移
    final translation = renderer.getTransformTo(null).getTranslation();
    data.snapshotOffset = Offset(translation.x, translation.y);

    data.onColorSelected = onColorSelected;
    data.onColorChanged = onColorChanged;
    final overlay = Overlay.of(context);

    data.snapshot = await repaintBoundaryToImage(renderer);

    if (data.snapshot == null) {
      debugPrint('EyeDrop: snapshot failed');
      return;
    }

    data.eyeOverlayEntry = OverlayEntry(
      builder: (_) => EyeDropOverlay(
        touchable: data.touchable,
        colors: data.hoverColors,
        cursorPosition: data.cursorPosition,
      ),
    );
    overlay.insert(data.eyeOverlayEntry!);
  }

  @override
  bool updateShouldNotify(EyeDrop oldWidget) {
    return true;
  }
}
