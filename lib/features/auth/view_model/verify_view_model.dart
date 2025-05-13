import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:eventorize_app/core/exceptions/exceptions.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/models/user.dart'; 

class VerifyViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  VerifyViewModel(this._userRepository);

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _errorTitle;
  User? _user;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;
  User? get user => _user;

  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _isSuccess = false;
    _errorMessage = null;
    _errorTitle = null;
    _user = null;
    notifyListeners();

    try {
      final user = await _userRepository.verifyEmail(email: email, otp: otp);
      _user = user;
      _isSuccess = true;
    } on DioException catch (e) {
      if (e.error is CustomException) {
        final customError = e.error as CustomException;
        _errorTitle = customError.title;
        _errorMessage = customError.detail;
      } else {
        _errorTitle = 'Error';
        _errorMessage = e.message ?? 'Verification failed. Please try again.';
      }
      _isSuccess = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorTitle = 'Error';
      _errorMessage = 'An unexpected error occurred';
      _isSuccess = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail({
    required String email,
  }) async {
    _isLoading = true;
    _isSuccess = false;
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();

    try {
      await _userRepository.resendVerificationEmail(email: email);
      _isSuccess = true;
    } on DioException catch (e) {
      if (e.error is CustomException) {
        final customError = e.error as CustomException;
        _errorTitle = 'Error ${customError.status}';
        _errorMessage = customError.detail;
      } else {
        _errorTitle = 'Error';
        _errorMessage = e.message ?? 'Failed to resend code';
      }
      _isSuccess = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorTitle = 'Error';
      _errorMessage = 'An unexpected error occurred';
      _isSuccess = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }
}