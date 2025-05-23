import 'package:dio/dio.dart';

class CustomException implements Exception {
  final String type;
  final int status;
  final String title;
  final String detail;

  CustomException({
    required this.type,
    required this.status,
    required this.title,
    required this.detail,
  });

  factory CustomException.fromJson(Map<String, dynamic> json) {
    return CustomException(
      type: json['type'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      detail: json['detail'] as String,
    );
  }

  @override
  String toString() => detail;

  Map<String, dynamic> toJson() => {
        'type': type,
        'status': status,
        'title': title,
        'detail': detail,
      };
}

class ErrorState {
  String? errorTitle;
  String? errorMessage;
  bool isSuccess;
  dynamic user;

  ErrorState({
    this.errorTitle,
    this.errorMessage,
    this.isSuccess = false,
    this.user,
  });
}

class ErrorHandler {
  static void handleError(
    dynamic error,
    String errorPrefix,
    ErrorState state,
  ) {
    state.errorTitle = 'Error';
    state.isSuccess = false;
    if (error is DioException) {
      if (error.error is CustomException) {
        final customError = error.error as CustomException;
        state.errorTitle = 'Error ${customError.status}';
        state.errorMessage = customError.detail;
      } else {
        state.errorMessage = error.response?.data?['detail'] ?? '$errorPrefix. Please try again.';
      }
    } else {
      state.errorMessage = '$errorPrefix: ${error.toString()}';
    }
  }

  static void clearError(ErrorState state) {
    state.errorTitle = null;
    state.errorMessage = null;
  }
}