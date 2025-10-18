import 'package:dio/dio.dart' show Response;

import 'constants.dart';

extension ResponseExtension on Response<dynamic> {
  int get startTimeMilliseconds =>
      requestOptions.extra[DIO_EXTRA_START_TIME] as int;

  int get endTimeMilliseconds =>
      requestOptions.extra[DIO_EXTRA_END_TIME] as int;

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(startTimeMilliseconds);

  DateTime get endTime =>
      DateTime.fromMillisecondsSinceEpoch(endTimeMilliseconds);
}
