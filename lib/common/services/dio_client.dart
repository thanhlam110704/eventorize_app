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
                : 'Đã xảy ra lỗi không xác định';
            String type = 'general/unknown';
            String title = 'Lỗi';

            switch (statusCode) {
              case 400:
                type = 'general/bad-request';
                title = 'Yêu cầu không hợp lệ';
                detail = data is Map<String, dynamic> && data['detail'] != null
                    ? data['detail'] as String
                    : 'Dữ liệu yêu cầu không hợp lệ';
                break;
              case 401:
                type = 'auth/unauthorized';
                title = 'Không được phép';
                detail = 'Vui lòng kiểm tra thông tin đăng nhập';
                break;
              case 403:
                type = 'auth/forbidden';
                title = 'Truy cập bị cấm';
                detail = 'Bạn không có quyền truy cập';
                break;
              case 404:
                type = 'general/not-found';
                title = 'Không tìm thấy';
                detail = 'Tài nguyên không tồn tại';
                break;
              case 429:
                type = 'general/too-many-requests';
                title = 'Quá nhiều yêu cầu';
                detail = 'Vui lòng thử lại sau';
                break;
              case 500:
                type = 'general/server-error';
                title = 'Lỗi máy chủ';
                detail = 'Vui lòng thử lại sau';
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
            String type = 'general/unknown';
            String title = 'Lỗi mạng';
            String detail = 'Đã xảy ra lỗi không xác định';

            if (e.type == DioExceptionType.connectionTimeout) {
              type = 'network/connection-timeout';
              title = 'Hết thời gian kết nối';
              detail = 'Vui lòng kiểm tra kết nối mạng';
            } else if (e.type == DioExceptionType.receiveTimeout) {
              type = 'network/receive-timeout';
              title = 'Hết thời gian nhận dữ liệu';
              detail = 'Vui lòng thử lại sau';
            } else {
              detail = e.message ?? 'Đã xảy ra lỗi không xác định';
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