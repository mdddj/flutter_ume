import 'package:dio/dio.dart';

import '../instances.dart';

int get _timestamp => DateTime.now().millisecondsSinceEpoch;

/// Implement a [Interceptor] to handle dio methods.
///
/// Main idea about this interceptor:
///  - Use [RequestOptions.extra] to store our timestamps.
///  - Add [DIO_EXTRA_START_TIME] when a request was requested.
///  - Add [DIO_EXTRA_END_TIME] when a response is respond or thrown an error.
///  - Deliver the [Response] to the container.
class UMEDioInterceptor extends Interceptor {
   static String startTime = 'ume_start_time';
   static String endTime = 'ume_end_time';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[startTime] = _timestamp;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    response.requestOptions.extra[endTime] = _timestamp;
    InspectorInstance.httpContainer.addRequest(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if(err.response!=null) {
      err.response!.requestOptions.extra[endTime] = _timestamp;
      InspectorInstance.httpContainer.addRequest(err.response!);
    }
    handler.next(err);
  }
}
