import 'package:dio/dio.dart' show Response;

import '../../flutter_ume_kit_dio_plus.dart';

extension ResponseExtension on Response<dynamic> {
  int get startTimeMilliseconds =>
      requestOptions.extra[UMEDioInterceptor.startTime] as int;

  int get endTimeMilliseconds =>
      requestOptions.extra[UMEDioInterceptor.endTime] as int;

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(startTimeMilliseconds);

  DateTime get endTime =>
      DateTime.fromMillisecondsSinceEpoch(endTimeMilliseconds);
}
