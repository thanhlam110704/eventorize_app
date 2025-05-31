import 'package:dio/dio.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/services/interceptors.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _dio.options.baseUrl = ApiUrl.baseUrlBE;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.addAll([
      LoggerInterceptor(),
      AuthorizationInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          if (e.response != null) {
            final statusCode = e.response!.statusCode;
            final data = e.response!.data;

            if (data is Map<String, dynamic>) {
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  response: e.response,
                  type: e.type,
                  error: CustomException.fromJson(data),
                ),
              );
            }

            String detail = data is Map<String, dynamic> && data['message'] != null
                ? data['message'] as String
                : 'An unknown error occurred';
            String type = 'general/unknown';
            String title = 'Error';

            switch (statusCode) {
              case 400:
                type = 'general/bad-request';
                title = 'Invalid Request';
                detail = data is Map<String, dynamic> && data['detail'] != null
                    ? data['detail'] as String
                    : 'The request data is invalid';
                break;
              case 401:
                type = 'auth/unauthorized';
                title = 'Unauthorized';
                detail = 'Please check your credentials';
                break;
              case 403:
                type = 'auth/forbidden';
                title = 'Forbidden';
                detail = 'You do not have access';
                break;
              case 404:
                type = 'general/not-found';
                title = 'Not Found';
                detail = 'The resource does not exist';
                break;
              case 429:
                type = 'general/too-many-requests';
                title = 'Too Many Requests';
                detail = 'Please try again later';
                break;
              case 500:
                type = 'general/server-error';
                title = 'Server Error';
                detail = 'Please try again later';
                break;
            }

            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                type: e.type,
                error: CustomException(
                  type: type,
                  status: statusCode ?? 500,
                  title: title,
                  detail: detail,
                ),
              ),
            );
          } else {
            // Handle network errors
            String type = 'general/unknown';
            String title = 'Network Error';
            String detail = 'An unknown error occurred';

            if (e.type == DioExceptionType.connectionTimeout) {
              type = 'network/connection-timeout';
              title = 'Connection Timeout';
              detail = 'Please check your internet connection';
            } else if (e.type == DioExceptionType.receiveTimeout) {
              type = 'network/receive-timeout';
              title = 'Receive Timeout';
              detail = 'Please try again later';
            } else {
              detail = e.message ?? 'An unknown error occurred';
            }

            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                type: e.type,
                error: CustomException(
                  type: type,
                  status: 500,
                  title: title,
                  detail: detail,
                ),
              ),
            );
          }
        },
      ),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}