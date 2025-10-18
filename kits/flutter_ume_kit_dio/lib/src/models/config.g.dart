// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DioConfigImpl _$$DioConfigImplFromJson(Map<String, dynamic> json) =>
    _$DioConfigImpl(
      showCopyButton: json['showCopyButton'] as bool? ?? false,
      showFullUrl: json['showFullUrl'] as bool? ?? false,
      urlKey: json['urlKey'] as String? ?? 'url',
      dataKey: json['dataKey'] as String? ?? '参数',
      responseKey: json['responseKey'] as String? ?? '返回',
      methodKey: json['methodKey'] as String? ?? '方法',
      statusKey: json['statusKey'] as String? ?? '状态码',
      timestampKey: json['timestampKey'] as String? ?? '请求耗时',
      timeKey: json['timeKey'] as String? ?? "请求时间",
    );

Map<String, dynamic> _$$DioConfigImplToJson(_$DioConfigImpl instance) =>
    <String, dynamic>{
      'showCopyButton': instance.showCopyButton,
      'showFullUrl': instance.showFullUrl,
      'urlKey': instance.urlKey,
      'dataKey': instance.dataKey,
      'responseKey': instance.responseKey,
      'methodKey': instance.methodKey,
      'statusKey': instance.statusKey,
      'timestampKey': instance.timestampKey,
      'timeKey': instance.timeKey,
    };
