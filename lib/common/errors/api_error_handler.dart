import 'package:dio/dio.dart';

class ApiErrorHandler {
  static void handleError(dynamic error) {
    if (error is DioException) {
      _handleDioException(error);
    } else {
      throw ApiException(
        message: 'An unexpected error occurred: ${error.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  static void _handleDioException(DioException error) {
    String errorMessage = 'An error occurred';
    String errorCode = 'UNKNOWN_ERROR';
    int? statusCode;

    // Ưu tiên lấy lỗi từ response.data của BE nếu có
    if (error.response?.data != null && error.response?.data is Map<String, dynamic>) {
      final errorData = error.response!.data as Map<String, dynamic>;
      errorMessage = errorData['message'] as String? ?? 'An error occurred';
      errorCode = errorData['error'] as String? ?? 'UNKNOWN_ERROR';
      statusCode = error.response?.statusCode ?? errorData['status'] as int?;
    } else {
      // Nếu không có dữ liệu từ BE, fallback về xử lý lỗi dựa trên DioException
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Request timed out. Please check your internet connection.';
          errorCode = 'TIMEOUT';
          break;

        case DioExceptionType.badResponse:
          statusCode = error.response?.statusCode;
          errorMessage = 'Server error: ${statusCode ?? 'unknown'}';
          errorCode = statusCode?.toString() ?? 'BAD_RESPONSE';
          if (statusCode == 401) {
            errorMessage = 'Unauthorized. Please log in again.';
            errorCode = 'UNAUTHORIZED';
          } else if (statusCode == 403) {
            errorMessage = 'Forbidden. You do not have permission to perform this action.';
            errorCode = 'FORBIDDEN';
          } else if (statusCode == 404) {
            errorMessage = 'Resource not found.';
            errorCode = 'NOT_FOUND';
          }
          break;

        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled.';
          errorCode = 'CANCELLED';
          break;

        case DioExceptionType.badCertificate:
          errorMessage = 'Invalid SSL certificate.';
          errorCode = 'BAD_CERTIFICATE';
          break;

        case DioExceptionType.connectionError:
          errorMessage = 'Failed to connect to the server. Please check your internet connection.';
          errorCode = 'CONNECTION_ERROR';
          break;

        case DioExceptionType.unknown:
          errorMessage = 'An unexpected error occurred: ${error.message}';
          errorCode = 'UNKNOWN_ERROR';
          break;
      }
    }

    throw ApiException(
      message: errorMessage,
      code: errorCode,
      statusCode: statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  ApiException({
    required this.message,
    required this.code,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (Code: $code${statusCode != null ? ', Status: $statusCode' : ''})';
}