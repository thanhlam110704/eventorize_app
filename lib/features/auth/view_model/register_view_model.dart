import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/common/network/dio_client.dart';

class RegisterViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  RegisterViewModel(this._userRepository);

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  Future<void> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _user = null;
    notifyListeners();

    try {
      final result = await _userRepository.register(
        fullname: fullname,
        email: email,
        phone: phone,
        password: password,
      );
      _user = result['user'] as User?;
      if (_user == null) {
        throw Exception('User data is missing');
      }
    } catch (e) {
      if (e is ApiException) {
        if (e.message.toLowerCase().contains('email')) {
          _errorMessage = 'Email đã tồn tại. Vui lòng sử dụng email khác.';
        } else if (e.message.toLowerCase().contains('phone')) {
          _errorMessage = 'Số điện thoại đã được sử dụng. Vui lòng sử dụng số khác.';
        } else if (e.message.toLowerCase().contains('timeout')) {
          _errorMessage = 'Vui lòng kiểm tra kết nối mạng của bạn.';
        } else if (e.message.toLowerCase().contains('server error')) {
          _errorMessage = 'Lỗi máy chủ. Vui lòng thử lại sau.';
        } else {
          _errorMessage = 'Đăng ký thất bại: ${e.message}';
        }
      } else {
        _errorMessage = 'Đăng ký thất bại: $e';
      }
      _user = null;
      notifyListeners();
      rethrow ;
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