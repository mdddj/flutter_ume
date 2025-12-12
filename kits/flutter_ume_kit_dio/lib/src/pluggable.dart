import 'package:dio/dio.dart' show Dio;
import 'package:flutter/material.dart';
import 'package:flutter_ume_plus/flutter_ume_plus.dart';

import 'models/http_interceptor.dart';
import 'widgets/icon.dart' as icon;
import 'widgets/pluggable_state.dart';

// TODO(Alex): Implement [PluggableStream] for dot features.
/// Implement a [Pluggable] to integrate with UME.
class DioInspector extends StatefulWidget implements Pluggable {
  DioInspector({
    super.key,
    required this.dio,
    this.nav,
  }) {
    dio.interceptors.add(UMEDioInterceptor());
  }

  final NavigatorState? nav;
  final Dio dio;

  @override
  DioPluggableState createState() => DioPluggableState();

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  String get name => 'DioInspector';

  @override
  String get displayName => 'DioInspector';

  @override
  void onTrigger() {}

  @override
  Widget buildWidget(BuildContext? context) => this;
}
