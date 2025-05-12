import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/api/secure_storage_service.dart';
import 'package:eventorize_app/core/exceptions/exceptions.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  HomeViewModel(this._userRepository);

  bool _isLoading = false;
  bool _isCheckingSession = false;
  bool _isLoggingOut = false;
  String? _errorMessage;
  String? _errorTitle;
  User? _user;

  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;
  User? get user => _user;

  Future<void> checkSession() async {
    _isCheckingSession = true;
    _errorMessage = null;
    _errorTitle = null;
    _user = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        _errorMessage = 'Please log in again.';
        return;
      }
      _user = await _userRepository.getMe();
    } on DioException catch (e) {
      if (e.error is CustomException) {
        final customError = e.error as CustomException;
        _errorTitle = 'Error ${customError.status}';
        _errorMessage = customError.detail;
      } else {
        _errorTitle = 'Error';
        _errorMessage = e.message ?? 'Failed to validate session.';
      }
      _user = null;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorTitle = 'Error';
      _errorMessage = 'Failed to validate session.';
      _user = null;
      notifyListeners();
      rethrow;
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _isLoggingOut = true;
    _errorMessage = null;
    _errorTitle = null;

    try {
      await _userRepository.logout();
      await SecureStorageService.clearAll();
      _user = null;
    } on DioException catch (e) {
      if (e.error is CustomException) {
        final customError = e.error as CustomException;
        _errorTitle = 'Error ${customError.status}';
        _errorMessage = customError.detail;
      } else {
        _errorTitle = 'Error';
        _errorMessage = e.message ?? 'Failed to log out.';
      }
      rethrow;
    } catch (e) {
      _errorTitle = 'Error';
      _errorMessage = 'Failed to log out.';
      rethrow;
    } finally {
      _isLoading = false;
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }
}