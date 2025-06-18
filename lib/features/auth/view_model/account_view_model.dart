import 'package:flutter/foundation.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/user.dart';

class AccountViewModel extends ChangeNotifier {
  final SessionManager _sessionManager;
  final ErrorState _errorState = ErrorState();

  AccountViewModel(this._sessionManager);
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  User? get user => _sessionManager.user;

  Future<void> logout() async {
    ErrorHandler.clearError(_errorState);
    try {
      await _sessionManager.logout();
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi đăng xuất', _errorState);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}