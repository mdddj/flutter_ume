import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiver/iterables.dart';

import '../../utils.dart';
import 'eye_dropper_layer.dart';

const _cellSize = 10;

const _gridSize = 90.0;

class EyeDropOverlay extends StatelessWidget {
  final Offset? cursorPosition;
  final bool touchable;

  final List<Color> colors;

  const EyeDropOverlay({
    required this.colors,
    this.cursorPosition,
    this.touchable = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (cursorPosition == null) return const SizedBox.shrink();

    final centerColor = colors.isEmpty ? Colors.black : colors.center;
    final magnifierTop =
        cursorPosition!.dy - (_gridSize / 2) - (touchable ? _gridSize / 2 : 0);

    return Stack(
      children: [
        // 全屏 Listener 拦截触摸事件并处理取色
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerMove: (details) => EyeDrop.handlePointerMove(
              details.position,
              details.kind == PointerDeviceKind.touch,
            ),
            onPointerUp: (details) => EyeDrop.handlePointerUp(details.position),
            child: const SizedBox.expand(),
          ),
        ),
        // 放大镜 + 信息提示
        Positioned(
          left: cursorPosition!.dx - (_gridSize / 2),
          top: magnifierTop,
          child: IgnorePointer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildZoom(centerColor),
                const SizedBox(width: 8),
                _buildInfoTip(centerColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoom(Color centerColor) {
    return Container(
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 8, color: centerColor),
      ),
      width: _gridSize,
      height: _gridSize,
      child: ClipOval(
        child: CustomPaint(
          size: const Size.square(_gridSize),
          painter: _PixelGridPainter(colors),
        ),
      ),
    );
  }

  Widget _buildInfoTip(Color centerColor) {
    final hexColor = centerColor.hexRGB.toUpperCase();
    final r = (centerColor.r * 255).round();
    final g = (centerColor.g * 255).round();
    final b = (centerColor.b * 255).round();
    final rgbStr = 'rgb($r, $g, $b)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 颜色预览 + HEX（可复制）
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: centerColor,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.white54, width: 1),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () =>
                    Clipboard.setData(ClipboardData(text: '#$hexColor')),
                child: Text(
                  '#$hexColor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // RGB（可复制）
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: rgbStr)),
            child: Text(
              rgbStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 2),
          // 坐标
          Text(
            'x: ${cursorPosition!.dx.toInt()}  y: ${cursorPosition!.dy.toInt()}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// paint a hovered pixel/colors preview
class _PixelGridPainter extends CustomPainter {
  final List<Color> colors;

  static const gridSize = 9;
  static const eyeRadius = 35.0;

  final blackStroke = Paint()
    ..color = Colors.black
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;

  _PixelGridPainter(this.colors);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    final blackLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final selectedStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // fill pixels color square
    for (final color in enumerate(colors)) {
      final fill = Paint()..color = color.value;
      final rect = Rect.fromLTWH(
        (color.index % gridSize).toDouble() * _cellSize,
        ((color.index ~/ gridSize) % gridSize).toDouble() * _cellSize,
        _cellSize.toDouble(),
        _cellSize.toDouble(),
      );
      canvas.drawRect(rect, fill);
    }

    // draw pixels borders after fills
    for (final color in enumerate(colors)) {
      final rect = Rect.fromLTWH(
        (color.index % gridSize).toDouble() * _cellSize,
        ((color.index ~/ gridSize) % gridSize).toDouble() * _cellSize,
        _cellSize.toDouble(),
        _cellSize.toDouble(),
      );
      canvas.drawRect(
          rect, color.index == colors.length ~/ 2 ? selectedStroke : stroke);

      if (color.index == colors.length ~/ 2) {
        canvas.drawRect(rect.deflate(1), blackLine);
      }
    }

    // black contrast ring
    canvas.drawCircle(
      const Offset((_gridSize) / 2, (_gridSize) / 2),
      eyeRadius,
      blackStroke,
    );
  }

  @override
  bool shouldRepaint(_PixelGridPainter oldDelegate) =>
      !listEquals(oldDelegate.colors, colors);
}
