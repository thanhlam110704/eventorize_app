import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/common/network/dio_client.dart';
import 'package:eventorize_app/data/api/shared_preferences_service.dart';

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
    notifyListeners();

    try {
      final result = await _userRepository.login(
        email: email,
        password: password,
      );
      _user = result['user'] as User;
      final token = result['token'] as String;

      await SharedPreferencesService.saveToken(token);
      if (rememberMe) {
        await SharedPreferencesService.saveEmail(email);
      }
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'Login failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}