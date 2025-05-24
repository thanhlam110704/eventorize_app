import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/common/services/secure_storage.dart';

class SessionManager extends ChangeNotifier {
  final UserRepository _userRepository;
  final ErrorState _errorState = ErrorState();
  User? _user;
  bool _isCheckingSession = false;
  bool _isLoading = false;

  SessionManager(this._userRepository);

  User? get user => _user;
  bool get isCheckingSession => _isCheckingSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  Future<void> checkSession() async {
    _isCheckingSession = true;
    ErrorHandler.clearError(_errorState);
    _user = null;
    notifyListeners();

    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('No token found');
      }
      _user = await _userRepository.getMe();
    } catch (e) {
      ErrorHandler.handleError(e, 'Session check failed', _errorState);
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      await _userRepository.logout();
      await SecureStorage.clearAll();
      _user = null;
    } catch (e) {
      ErrorHandler.handleError(e, 'Logout failed', _errorState);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> updateUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final refreshedUser = await _userRepository.getMe();
      _user = refreshedUser;
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to refresh user data', _errorState);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}