import 'package:flutter/foundation.dart';
import 'package:eventorize_app/common/services/secure_storage.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final ErrorState _errorState = ErrorState();

  RegisterViewModel(this._userRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  User? get user => _errorState.user;

  Future<void> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    _errorState.user = null;
    notifyListeners();

    try {
      final result = await _userRepository.register(
        fullname: fullname,
        email: email,
        phone: phone,
        password: password,
      );
      _errorState.user = result['user'] as User?;
      final token = result['token'] as String?;
      if (_errorState.user == null || token == null) {
        throw Exception('Đăng ký thất bại: Phản hồi không hợp lệ');
      }
      await SecureStorage.saveToken(token);
    } catch (e) {
      ErrorHandler.handleError(e, 'Đăng ký thất bại', _errorState);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> googleSSOAndroid({
    required String googleId,
    required String displayName,
    required String email,
    required String picture,
  }) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    _errorState.user = null;
    notifyListeners();

    try {
      final result = await _userRepository.googleSSOAndroid(
        googleId: googleId,
        displayName: displayName,
        email: email,
        picture: picture,
      );
      _errorState.user = result['user'] as User?;
      final token = result['token'] as String?;
      if (_errorState.user == null || token == null) {
        throw Exception('Đăng ký thất bại với Google: Phản hồi không hợp lệ');
      }
      await SecureStorage.saveToken(token);
    } catch (e) {
      ErrorHandler.handleError(e, 'Đăng ký thất bại với Google', _errorState);
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