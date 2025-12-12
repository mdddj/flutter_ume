import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

//bool get isPhoneScreen => !(screenSize.shortestSide >= 600);

Size get screenSize {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  return view.physicalSize / view.devicePixelRatio;
}

extension Screen on MediaQueryData {
  bool get isPhone => size.shortestSide < 600;
}

extension Chroma on String {
  /// converts string to [Color]
  /// fill incomplete values with 0
  /// ex: 'ff00'.toColor() => Color(0xffff0000)
  Color toColor({bool argb = false}) {
    final colorString = '0x${argb ? '' : 'ff'}$this'.padRight(10, '0');
    return Color(int.tryParse(colorString) ?? 0);
  }
}

/// shortcuts to manipulate [Color]
extension Utils on Color {
  HSLColor get hsl => HSLColor.fromColor(this);

  double get hue => hsl.hue;

  double get saturation => hsl.saturation;

  double get lightness => hsl.lightness;

  Color withHue(double value) => hsl.withHue(value).toColor();

  /// ff001232
  String get hexARGB {
    final a = (this.a * 255).round().toRadixString(16).padLeft(2, '0');
    final r = (this.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (this.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (this.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$a$r$g$b';
  }

  /// 001232
  String get hexRGB {
    final r = (this.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (this.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (this.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b';
  }

  Color withSaturation(double value) =>
      HSLColor.fromAHSL(a, hue, value, lightness).toColor();

  Color withLightness(double value) => hsl.withLightness(value).toColor();

  /// generate the gradient of a color with
  /// lightness from 0 to 1 in [stepCount] steps
  List<Color> getShades(int stepCount, {bool skipFirst = true}) =>
      List.generate(
        stepCount,
        (index) {
          return hsl
              .withLightness(1 -
                  ((index + (skipFirst ? 1 : 0)) /
                      (stepCount - (skipFirst ? -1 : 1))))
              .toColor();
        },
      );
}

extension Helper on List<Color> {
  /// return the central item of a color list or black if the list is empty
  Color get center => isEmpty ? Colors.black : this[length ~/ 2];
}

List<Color> getHueGradientColors({double? saturation, int steps = 36}) =>
    List.generate(steps, (value) => value)
        .map<Color>((v) {
          final hsl = HSLColor.fromAHSL(1, v * (360 / steps), 0.67, 0.50);
          final rgb = hsl.toColor();
          return rgb.withValues(alpha: 1);
        })
        .map((c) => saturation != null ? c.withSaturation(saturation) : c)
        .toList();

const samplingGridSize = 9;

List<Color> getPixelColors(
  img.Image image,
  Offset offset, {
  int size = samplingGridSize,
}) =>
    List.generate(
      size * size,
      (index) => getPixelColor(
        image,
        offset + _offsetFromIndex(index, samplingGridSize),
      ),
    );

Color getPixelColor(img.Image image, Offset offset) {
  if (offset.dx < 0 ||
      offset.dy < 0 ||
      offset.dx >= image.width ||
      offset.dy >= image.height) {
    return const Color(0x00000000);
  }
  final pixel = image.getPixel(offset.dx.toInt(), offset.dy.toInt());
  // image 库返回 16 位值 (0-65535)，需要右移 8 位转换为 8 位 (0-255)
  return Color.fromARGB(
    (pixel.a.toInt() >> 8).clamp(0, 255),
    (pixel.r.toInt() >> 8).clamp(0, 255),
    (pixel.g.toInt() >> 8).clamp(0, 255),
    (pixel.b.toInt() >> 8).clamp(0, 255),
  );
}

ui.Offset _offsetFromIndex(int index, int numColumns) {
  final half = numColumns ~/ 2;
  return Offset(
    (index % numColumns).toDouble() - half,
    ((index ~/ numColumns) % numColumns).toDouble() - half,
  );
}

Color abgr2Color(int value) {
  final a = (value >> 24) & 0xFF;
  final b = (value >> 16) & 0xFF;
  final g = (value >> 8) & 0xFF;
  final r = (value >> 0) & 0xFF;

  return Color.fromARGB(a, r, g, b);
}

Future<img.Image?> repaintBoundaryToImage(
  RenderRepaintBoundary renderer,
) async {
  try {
    final rawImage = await renderer.toImage(pixelRatio: 1);
    final byteData = await rawImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final pngBytes = byteData.buffer.asUint8List();
    rawImage.dispose();
    // 使用 PNG 格式解码，和 color_sucker 保持一致
    return img.decodeImage(pngBytes);
  } catch (err) {
    debugPrint('repaintBoundaryToImage error: $err');
    return null;
  }
}
