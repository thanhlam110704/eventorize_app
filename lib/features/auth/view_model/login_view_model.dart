import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final ErrorState _errorState = ErrorState();

  LoginViewModel(this._userRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  User? get user => _errorState.user;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _executeLogin(
      () => _userRepository.login(email: email, password: password),
      'Login failed',
    );
  }

  Future<Map<String, dynamic>> googleSSOAndroid({
    required String googleId,
    required String displayName,
    required String email,
    required String picture,
  }) async {
    return await _executeLogin(
      () => _userRepository.googleSSOAndroid(
        googleId: googleId,
        displayName: displayName,
        email: email,
        picture: picture,
      ),
      'Google SSO failed',
    );
  }

  Future<Map<String, dynamic>> _executeLogin(
    Future<Map<String, dynamic>> Function() loginFn,
    String errorPrefix,
  ) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    _errorState.user = null;
    notifyListeners();

    try {
      final result = await loginFn();
      _errorState.user = result['user'] as User?;
      final token = result['token'] as String?;

      if (_errorState.user == null || token == null) {
        throw Exception('$errorPrefix: Invalid response');
      }

      return {'user': _errorState.user, 'token': token};
    } catch (e) {
      ErrorHandler.handleError(e, errorPrefix, _errorState);
      notifyListeners();
      rethrow;
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