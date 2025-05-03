import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/api/secure_storage_service.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  LoginViewModel(this._userRepository);

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _user = null;
    notifyListeners();

    try {
      final result = await _userRepository.login(email: email, password: password);
      _user = result['user'] as User?;
      final token = result['token'] as String?;

      if (_user == null) {
        throw Exception('User data is missing');
      }
      if (token == null) {
        throw Exception('Access token is missing');
      }

      await SecureStorageService.saveToken(token);
      if (rememberMe) {
        await SecureStorageService.saveEmail(email);
      } else {
        await SecureStorageService.clearEmail();
      }
    } catch (e) {
      if (e.toString().contains('Network')) {
        _errorMessage = 'Please check your internet connection';
      } else if (e.toString().contains('Invalid credentials')) {
        _errorMessage = 'Incorrect email or password';
      } else {
        _errorMessage = 'Login failed: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.getMe();
      _user = user;
    } catch (e) {
      _errorMessage = 'Session check failed: $e';
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _userRepository.logout();
      await SecureStorageService.clearAll();
      _user = null;
      _errorMessage = 'Logged out successfully';
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}