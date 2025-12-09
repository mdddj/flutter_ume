import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_ume_plus/flutter_ume_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';

part 'config.g.dart';

@freezed
sealed class DioConfig with _$DioConfig {
  const DioConfig._();

  const factory DioConfig(
      {@Default(false) bool showCopyButton,
      @Default(false) bool showFullUrl,
      @Default(false) bool showResponseHeaders,
      @Default(true) bool showRequestHeaders,
      @Default('url') String urlKey,
      @Default('参数') String dataKey,
      @Default('返回') String responseKey,
      @Default('方法') String methodKey,
      @Default('状态码') String statusKey,
      @Default('请求耗时') String timestampKey,
      @Default("请求时间") String timeKey}) = _DioConfig;

  factory DioConfig.fromJson(Map<String, dynamic> json) =>
      _$DioConfigFromJson(json);
}

class DioConfigUtil with StoreMixin {
  final String _key = "_dio_config";

  ///加载配置
  Future<DioConfig> getConfig() async {
    final config = await fetchWithKey(_key);

    if (config is String) {
      try {
        return DioConfig.fromJson(jsonDecode(config));
      } catch (_) {}
    }
    return const DioConfig();
  }

  ///保存配置
  Future<void> saveConfig(DioConfig config) async {
    await storeWithKey(_key, jsonEncode(config));
  }
}
