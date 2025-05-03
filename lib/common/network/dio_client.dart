import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/network/interceptors.dart';

class DioClient {
  final Dio _dio;
  final CookieJar _cookieJar;
  PersistCookieJar? _persistCookieJar;

  DioClient() : _dio = Dio(), _cookieJar = CookieJar() {
    _dio.options.baseUrl = ApiUrl.baseUrlBE;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.addAll([
      CookieManager(_cookieJar),
      LoggerInterceptor(),
      AuthorizationInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          final cookies = response.headers['set-cookie'];
          if (cookies != null && _persistCookieJar != null) {
            final uri = Uri.parse(ApiUrl.baseUrlBE);
            final currentCookies = await _cookieJar.loadForRequest(uri);
            await _persistCookieJar!.saveFromResponse(uri, currentCookies);
          }
          return handler.next(response);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          String errorMessage = 'An error occurred';
          if (e.response != null) {
            final statusCode = e.response!.statusCode;
            final data = e.response!.data as Map<String, dynamic>?;

            switch (statusCode) {
              case 400:
                errorMessage = data?['message'] ?? 'Bad request';
                break;
              case 401:
                errorMessage = data?['message'] ?? 'Unauthorized: Please check your credentials';
                break;
              case 403:
                errorMessage = data?['message'] ?? 'Forbidden: You do not have permission';
                break;
              case 404:
                errorMessage = data?['message'] ?? 'Resource not found';
                break;
              case 429:
                errorMessage = data?['message'] ?? 'Too many requests. Please try again later';
                break;
              case 500:
                errorMessage = data?['message'] ?? 'Server error: Please try again later';
                break;
              default:
                errorMessage = 'Unexpected error: $statusCode';
            }
          } else if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Connection timeout: Please check your internet connection';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Receive timeout: Please try again later';
          } else {
            errorMessage = e.message ?? 'Unknown error';
          }

          
          throw ApiException(errorMessage);
        },
      ),
    ]);
    _initialize();
  }

  Future<void> _initialize() async {
    await _initPersistCookieJar();
    await _loadPersistedCookies();
  }

  Future<void> _initPersistCookieJar() async {
    final directory = await getApplicationDocumentsDirectory();
    _persistCookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/.cookies/'),
    );
    
  }

  Future<void> _loadPersistedCookies() async {
    if (_persistCookieJar == null) {
      return;
    }
    final uri = Uri.parse(ApiUrl.baseUrlBE);
    final cookies = await _persistCookieJar!.loadForRequest(uri);
    await _cookieJar.saveFromResponse(uri, cookies);
  }

  Future<void> clearJwtCookie() async {
    final uri = Uri.parse(ApiUrl.baseUrlBE);
    final cookies = await _cookieJar.loadForRequest(uri);
    final updatedCookies = cookies.where((cookie) => cookie.name != 'token').toList();
    await _cookieJar.saveFromResponse(uri, updatedCookies);
    if (_persistCookieJar != null) {
      await _persistCookieJar!.saveFromResponse(uri, updatedCookies);
    }
  }

  Future<void> clearAllCookies() async {
    await _cookieJar.deleteAll();
    if (_persistCookieJar != null) {
      await _persistCookieJar!.deleteAll();
    }
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

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}