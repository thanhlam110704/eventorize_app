import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';

class VerifyViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final ErrorState _errorState = ErrorState();

  VerifyViewModel(this._userRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get isSuccess => _errorState.isSuccess;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  User? get user => _errorState.user;

  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    await _executeVerify(
      () => _userRepository.verifyEmail(email: email, otp: otp),
      'Verification failed',
      (user) {
        _errorState.user = user;
        _errorState.isSuccess = true;
      },
    );
  }

  Future<void> resendVerificationEmail({
    required String email,
  }) async {
    await _executeVerify(
      () => _userRepository.resendVerificationEmail(email: email),
      'Failed to resend code',
      (_) => _errorState.isSuccess = true,
    );
  }

  Future<void> _executeVerify(
    Future<dynamic> Function() verifyFn,
    String errorPrefix,
    void Function(dynamic) onSuccess,
  ) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    _errorState.isSuccess = false;
    _errorState.user = null;
    notifyListeners();

    try {
      final result = await verifyFn();
      onSuccess(result);
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