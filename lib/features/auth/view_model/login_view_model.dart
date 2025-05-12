import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/api/secure_storage_service.dart';
import 'package:eventorize_app/core/exceptions/exceptions.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  LoginViewModel(this._userRepository);

  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;
  User? get user => _user;

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _errorTitle = null;
    _user = null;
    notifyListeners();

    try {
      final result = await _userRepository.login(email: email, password: password);
      _user = result['user'] as User?;
      final token = result['token'] as String?;

      if (_user == null || token == null) {
        throw Exception('Login failed: Invalid response');
      }

      if (_user!.isVerified) {
        await SecureStorageService.saveToken(token);
        if (rememberMe) {
          await SecureStorageService.saveEmail(email);
        } else {
          await SecureStorageService.clearEmail();
        }
      }
    } on DioException catch (e) {
      if (e.error is CustomException) {
        final customError = e.error as CustomException;
        _errorTitle = 'Error ${customError.status}';
        _errorMessage = customError.detail;
      } else {
        _errorTitle = 'Error';
        _errorMessage = e.message ?? 'Failed to log in. Please try again.';
      }
      _user = null;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorTitle = 'Error';
      _errorMessage = 'An unexpected error occurred';
      _user = null;
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