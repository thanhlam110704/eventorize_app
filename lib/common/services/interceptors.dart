import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:eventorize_app/common/services/secure_storage.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';

class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true));

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath');

    if (err.error is CustomException) {
      final customError = err.error as CustomException;
      logger.e('Error type: ${customError.type} \n'
          'Status: ${customError.status} \n'
          'Title: ${customError.title} \n'
          'Detail: ${customError.detail}');
    } else {
      logger.e('Error type: ${err.type} \n'
          'Error message: ${err.message}');
    }
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
    logger.d('Status: ${response.statusCode} \n'
        'Messenge: ${response.statusMessage} \n'
        'Header: ${response.headers} \n'
        'Data: ${response.data}');
    handler.next(response);
  }
}

class AuthorizationInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await SecureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = "Bearer $token";
      }
    } catch (_) {}
    handler.next(options);
  }
}