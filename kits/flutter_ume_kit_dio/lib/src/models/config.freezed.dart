// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DioConfig implements DiagnosticableTreeMixin {
  bool get showCopyButton;
  bool get showFullUrl;
  bool get showResponseHeaders;
  bool get showRequestHeaders;
  String get urlKey;
  String get dataKey;
  String get responseKey;
  String get methodKey;
  String get statusKey;
  String get timestampKey;
  String get timeKey;

  /// Create a copy of DioConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DioConfigCopyWith<DioConfig> get copyWith =>
      _$DioConfigCopyWithImpl<DioConfig>(this as DioConfig, _$identity);

  /// Serializes this DioConfig to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DioConfig'))
      ..add(DiagnosticsProperty('showCopyButton', showCopyButton))
      ..add(DiagnosticsProperty('showFullUrl', showFullUrl))
      ..add(DiagnosticsProperty('showResponseHeaders', showResponseHeaders))
      ..add(DiagnosticsProperty('showRequestHeaders', showRequestHeaders))
      ..add(DiagnosticsProperty('urlKey', urlKey))
      ..add(DiagnosticsProperty('dataKey', dataKey))
      ..add(DiagnosticsProperty('responseKey', responseKey))
      ..add(DiagnosticsProperty('methodKey', methodKey))
      ..add(DiagnosticsProperty('statusKey', statusKey))
      ..add(DiagnosticsProperty('timestampKey', timestampKey))
      ..add(DiagnosticsProperty('timeKey', timeKey));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DioConfig &&
            (identical(other.showCopyButton, showCopyButton) ||
                other.showCopyButton == showCopyButton) &&
            (identical(other.showFullUrl, showFullUrl) ||
                other.showFullUrl == showFullUrl) &&
            (identical(other.showResponseHeaders, showResponseHeaders) ||
                other.showResponseHeaders == showResponseHeaders) &&
            (identical(other.showRequestHeaders, showRequestHeaders) ||
                other.showRequestHeaders == showRequestHeaders) &&
            (identical(other.urlKey, urlKey) || other.urlKey == urlKey) &&
            (identical(other.dataKey, dataKey) || other.dataKey == dataKey) &&
            (identical(other.responseKey, responseKey) ||
                other.responseKey == responseKey) &&
            (identical(other.methodKey, methodKey) ||
                other.methodKey == methodKey) &&
            (identical(other.statusKey, statusKey) ||
                other.statusKey == statusKey) &&
            (identical(other.timestampKey, timestampKey) ||
                other.timestampKey == timestampKey) &&
            (identical(other.timeKey, timeKey) || other.timeKey == timeKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      showCopyButton,
      showFullUrl,
      showResponseHeaders,
      showRequestHeaders,
      urlKey,
      dataKey,
      responseKey,
      methodKey,
      statusKey,
      timestampKey,
      timeKey);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DioConfig(showCopyButton: $showCopyButton, showFullUrl: $showFullUrl, showResponseHeaders: $showResponseHeaders, showRequestHeaders: $showRequestHeaders, urlKey: $urlKey, dataKey: $dataKey, responseKey: $responseKey, methodKey: $methodKey, statusKey: $statusKey, timestampKey: $timestampKey, timeKey: $timeKey)';
  }
}

/// @nodoc
abstract mixin class $DioConfigCopyWith<$Res> {
  factory $DioConfigCopyWith(DioConfig value, $Res Function(DioConfig) _then) =
      _$DioConfigCopyWithImpl;
  @useResult
  $Res call(
      {bool showCopyButton,
      bool showFullUrl,
      bool showResponseHeaders,
      bool showRequestHeaders,
      String urlKey,
      String dataKey,
      String responseKey,
      String methodKey,
      String statusKey,
      String timestampKey,
      String timeKey});
}

/// @nodoc
class _$DioConfigCopyWithImpl<$Res> implements $DioConfigCopyWith<$Res> {
  _$DioConfigCopyWithImpl(this._self, this._then);

  final DioConfig _self;
  final $Res Function(DioConfig) _then;

  /// Create a copy of DioConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showCopyButton = null,
    Object? showFullUrl = null,
    Object? showResponseHeaders = null,
    Object? showRequestHeaders = null,
    Object? urlKey = null,
    Object? dataKey = null,
    Object? responseKey = null,
    Object? methodKey = null,
    Object? statusKey = null,
    Object? timestampKey = null,
    Object? timeKey = null,
  }) {
    return _then(_self.copyWith(
      showCopyButton: null == showCopyButton
          ? _self.showCopyButton
          : showCopyButton // ignore: cast_nullable_to_non_nullable
              as bool,
      showFullUrl: null == showFullUrl
          ? _self.showFullUrl
          : showFullUrl // ignore: cast_nullable_to_non_nullable
              as bool,
      showResponseHeaders: null == showResponseHeaders
          ? _self.showResponseHeaders
          : showResponseHeaders // ignore: cast_nullable_to_non_nullable
              as bool,
      showRequestHeaders: null == showRequestHeaders
          ? _self.showRequestHeaders
          : showRequestHeaders // ignore: cast_nullable_to_non_nullable
              as bool,
      urlKey: null == urlKey
          ? _self.urlKey
          : urlKey // ignore: cast_nullable_to_non_nullable
              as String,
      dataKey: null == dataKey
          ? _self.dataKey
          : dataKey // ignore: cast_nullable_to_non_nullable
              as String,
      responseKey: null == responseKey
          ? _self.responseKey
          : responseKey // ignore: cast_nullable_to_non_nullable
              as String,
      methodKey: null == methodKey
          ? _self.methodKey
          : methodKey // ignore: cast_nullable_to_non_nullable
              as String,
      statusKey: null == statusKey
          ? _self.statusKey
          : statusKey // ignore: cast_nullable_to_non_nullable
              as String,
      timestampKey: null == timestampKey
          ? _self.timestampKey
          : timestampKey // ignore: cast_nullable_to_non_nullable
              as String,
      timeKey: null == timeKey
          ? _self.timeKey
          : timeKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [DioConfig].
extension DioConfigPatterns on DioConfig {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DioConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DioConfig() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DioConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DioConfig():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DioConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DioConfig() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            bool showCopyButton,
            bool showFullUrl,
            bool showResponseHeaders,
            bool showRequestHeaders,
            String urlKey,
            String dataKey,
            String responseKey,
            String methodKey,
            String statusKey,
            String timestampKey,
            String timeKey)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DioConfig() when $default != null:
        return $default(
            _that.showCopyButton,
            _that.showFullUrl,
            _that.showResponseHeaders,
            _that.showRequestHeaders,
            _that.urlKey,
            _that.dataKey,
            _that.responseKey,
            _that.methodKey,
            _that.statusKey,
            _that.timestampKey,
            _that.timeKey);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            bool showCopyButton,
            bool showFullUrl,
            bool showResponseHeaders,
            bool showRequestHeaders,
            String urlKey,
            String dataKey,
            String responseKey,
            String methodKey,
            String statusKey,
            String timestampKey,
            String timeKey)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DioConfig():
        return $default(
            _that.showCopyButton,
            _that.showFullUrl,
            _that.showResponseHeaders,
            _that.showRequestHeaders,
            _that.urlKey,
            _that.dataKey,
            _that.responseKey,
            _that.methodKey,
            _that.statusKey,
            _that.timestampKey,
            _that.timeKey);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            bool showCopyButton,
            bool showFullUrl,
            bool showResponseHeaders,
            bool showRequestHeaders,
            String urlKey,
            String dataKey,
            String responseKey,
            String methodKey,
            String statusKey,
            String timestampKey,
            String timeKey)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DioConfig() when $default != null:
        return $default(
            _that.showCopyButton,
            _that.showFullUrl,
            _that.showResponseHeaders,
            _that.showRequestHeaders,
            _that.urlKey,
            _that.dataKey,
            _that.responseKey,
            _that.methodKey,
            _that.statusKey,
            _that.timestampKey,
            _that.timeKey);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DioConfig extends DioConfig with DiagnosticableTreeMixin {
  const _DioConfig(
      {this.showCopyButton = false,
      this.showFullUrl = false,
      this.showResponseHeaders = false,
      this.showRequestHeaders = true,
      this.urlKey = 'url',
      this.dataKey = '参数',
      this.responseKey = '返回',
      this.methodKey = '方法',
      this.statusKey = '状态码',
      this.timestampKey = '请求耗时',
      this.timeKey = "请求时间"})
      : super._();
  factory _DioConfig.fromJson(Map<String, dynamic> json) =>
      _$DioConfigFromJson(json);

  @override
  @JsonKey()
  final bool showCopyButton;
  @override
  @JsonKey()
  final bool showFullUrl;
  @override
  @JsonKey()
  final bool showResponseHeaders;
  @override
  @JsonKey()
  final bool showRequestHeaders;
  @override
  @JsonKey()
  final String urlKey;
  @override
  @JsonKey()
  final String dataKey;
  @override
  @JsonKey()
  final String responseKey;
  @override
  @JsonKey()
  final String methodKey;
  @override
  @JsonKey()
  final String statusKey;
  @override
  @JsonKey()
  final String timestampKey;
  @override
  @JsonKey()
  final String timeKey;

  /// Create a copy of DioConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DioConfigCopyWith<_DioConfig> get copyWith =>
      __$DioConfigCopyWithImpl<_DioConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DioConfigToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DioConfig'))
      ..add(DiagnosticsProperty('showCopyButton', showCopyButton))
      ..add(DiagnosticsProperty('showFullUrl', showFullUrl))
      ..add(DiagnosticsProperty('showResponseHeaders', showResponseHeaders))
      ..add(DiagnosticsProperty('showRequestHeaders', showRequestHeaders))
      ..add(DiagnosticsProperty('urlKey', urlKey))
      ..add(DiagnosticsProperty('dataKey', dataKey))
      ..add(DiagnosticsProperty('responseKey', responseKey))
      ..add(DiagnosticsProperty('methodKey', methodKey))
      ..add(DiagnosticsProperty('statusKey', statusKey))
      ..add(DiagnosticsProperty('timestampKey', timestampKey))
      ..add(DiagnosticsProperty('timeKey', timeKey));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DioConfig &&
            (identical(other.showCopyButton, showCopyButton) ||
                other.showCopyButton == showCopyButton) &&
            (identical(other.showFullUrl, showFullUrl) ||
                other.showFullUrl == showFullUrl) &&
            (identical(other.showResponseHeaders, showResponseHeaders) ||
                other.showResponseHeaders == showResponseHeaders) &&
            (identical(other.showRequestHeaders, showRequestHeaders) ||
                other.showRequestHeaders == showRequestHeaders) &&
            (identical(other.urlKey, urlKey) || other.urlKey == urlKey) &&
            (identical(other.dataKey, dataKey) || other.dataKey == dataKey) &&
            (identical(other.responseKey, responseKey) ||
                other.responseKey == responseKey) &&
            (identical(other.methodKey, methodKey) ||
                other.methodKey == methodKey) &&
            (identical(other.statusKey, statusKey) ||
                other.statusKey == statusKey) &&
            (identical(other.timestampKey, timestampKey) ||
                other.timestampKey == timestampKey) &&
            (identical(other.timeKey, timeKey) || other.timeKey == timeKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      showCopyButton,
      showFullUrl,
      showResponseHeaders,
      showRequestHeaders,
      urlKey,
      dataKey,
      responseKey,
      methodKey,
      statusKey,
      timestampKey,
      timeKey);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DioConfig(showCopyButton: $showCopyButton, showFullUrl: $showFullUrl, showResponseHeaders: $showResponseHeaders, showRequestHeaders: $showRequestHeaders, urlKey: $urlKey, dataKey: $dataKey, responseKey: $responseKey, methodKey: $methodKey, statusKey: $statusKey, timestampKey: $timestampKey, timeKey: $timeKey)';
  }
}

/// @nodoc
abstract mixin class _$DioConfigCopyWith<$Res>
    implements $DioConfigCopyWith<$Res> {
  factory _$DioConfigCopyWith(
          _DioConfig value, $Res Function(_DioConfig) _then) =
      __$DioConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool showCopyButton,
      bool showFullUrl,
      bool showResponseHeaders,
      bool showRequestHeaders,
      String urlKey,
      String dataKey,
      String responseKey,
      String methodKey,
      String statusKey,
      String timestampKey,
      String timeKey});
}

/// @nodoc
class __$DioConfigCopyWithImpl<$Res> implements _$DioConfigCopyWith<$Res> {
  __$DioConfigCopyWithImpl(this._self, this._then);

  final _DioConfig _self;
  final $Res Function(_DioConfig) _then;

  /// Create a copy of DioConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? showCopyButton = null,
    Object? showFullUrl = null,
    Object? showResponseHeaders = null,
    Object? showRequestHeaders = null,
    Object? urlKey = null,
    Object? dataKey = null,
    Object? responseKey = null,
    Object? methodKey = null,
    Object? statusKey = null,
    Object? timestampKey = null,
    Object? timeKey = null,
  }) {
    return _then(_DioConfig(
      showCopyButton: null == showCopyButton
          ? _self.showCopyButton
          : showCopyButton // ignore: cast_nullable_to_non_nullable
              as bool,
      showFullUrl: null == showFullUrl
          ? _self.showFullUrl
          : showFullUrl // ignore: cast_nullable_to_non_nullable
              as bool,
      showResponseHeaders: null == showResponseHeaders
          ? _self.showResponseHeaders
          : showResponseHeaders // ignore: cast_nullable_to_non_nullable
              as bool,
      showRequestHeaders: null == showRequestHeaders
          ? _self.showRequestHeaders
          : showRequestHeaders // ignore: cast_nullable_to_non_nullable
              as bool,
      urlKey: null == urlKey
          ? _self.urlKey
          : urlKey // ignore: cast_nullable_to_non_nullable
              as String,
      dataKey: null == dataKey
          ? _self.dataKey
          : dataKey // ignore: cast_nullable_to_non_nullable
              as String,
      responseKey: null == responseKey
          ? _self.responseKey
          : responseKey // ignore: cast_nullable_to_non_nullable
              as String,
      methodKey: null == methodKey
          ? _self.methodKey
          : methodKey // ignore: cast_nullable_to_non_nullable
              as String,
      statusKey: null == statusKey
          ? _self.statusKey
          : statusKey // ignore: cast_nullable_to_non_nullable
              as String,
      timestampKey: null == timestampKey
          ? _self.timestampKey
          : timestampKey // ignore: cast_nullable_to_non_nullable
              as String,
      timeKey: null == timeKey
          ? _self.timeKey
          : timeKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
