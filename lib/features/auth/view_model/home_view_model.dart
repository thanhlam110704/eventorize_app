import 'package:flutter/foundation.dart';
import 'package:eventorize_app/common/services/secure_storage.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final ErrorState _errorState = ErrorState();

  HomeViewModel(this._userRepository);

  bool _isLoading = false;
  bool _isCheckingSession = false;
  bool _isLoggingOut = false;

  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  User? get user => _errorState.user;

  Future<void> checkSession() async {
    _isCheckingSession = true;
    ErrorHandler.clearError(_errorState);
    _errorState.user = null;
    notifyListeners();

    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('No token found');
      }
      _errorState.user = await _userRepository.getMe();
    } catch (e) {
      ErrorHandler.handleError(e, 'Session check failed', _errorState);
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
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      await _userRepository.logout();
      await SecureStorage.clearAll();
      _errorState.user = null;
    } catch (e) {
      ErrorHandler.handleError(e, 'Logout failed', _errorState);
      rethrow;
    } finally {
      _isLoading = false;
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  void setUser(User user) {
    _errorState.user = user;
    notifyListeners();
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}