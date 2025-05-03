import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:eventorize_app/data/api/secure_storage_service.dart';

class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0, colors: true,printEmojis: true));

  @override
  void onError( DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath');
    logger.d('Error type: ${err.error} \n '
        'Error message: ${err.message}');
    handler.next(err); 
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath'); 
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('STATUSCODE: ${response.statusCode} \n '
        'STATUSMESSAGE: ${response.statusMessage} \n'
        'HEADERS: ${response.headers} \n'
        'Data: ${response.data}');
    handler.next(response); 
  }
}


class AuthorizationInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = "Bearer $token";
      }
    } catch (_) {}
    handler.next(options);
  }
}