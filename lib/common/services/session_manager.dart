import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/common/services/secure_storage.dart';
import 'package:eventorize_app/features/auth/organization_view_model/select_org_view_model.dart';
import 'package:get_it/get_it.dart';

class SessionManager extends ChangeNotifier {
  final UserRepository _userRepository;
  final ErrorState _errorState = ErrorState();
  User? _user;
  bool _isCheckingSession = false;
  bool _isLoading = false;
  String? _selectedOrganizerId;
  String? _selectedOrganizerName;
  String? _selectedOrganizerLogo;
  String? _selectedOrganizerEmail;

  SessionManager(this._userRepository);

  User? get user => _user;
  bool get isCheckingSession => _isCheckingSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  String? get selectedOrganizerId => _selectedOrganizerId;
  String? get selectedOrganizerName => _selectedOrganizerName;
  String? get selectedOrganizerLogo => _selectedOrganizerLogo;
  String? get selectedOrganizerEmail => _selectedOrganizerEmail;

  Future<void> checkSession() async {
    _isCheckingSession = true;
    ErrorHandler.clearError(_errorState);
    _user = null;
    notifyListeners();

    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token');
      }
      _user = await _userRepository.getMe();
     
      final selectOrgViewModel = GetIt.instance<SelectOrgViewModel>();
      await selectOrgViewModel.resetAndFetchOrganizers();
    } catch (e) {
      ErrorHandler.handleError(e, 'Kiểm tra phiên thất bại', _errorState);
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;
    try {
      _user = await _userRepository.getMe();
      notifyListeners();
    } catch (e) {
      ErrorHandler.handleError(e, 'Làm mới thông tin người dùng thất bại', _errorState);
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    try {
      await SecureStorage.clearToken();
      _user = null;
      _selectedOrganizerId = null;
      _selectedOrganizerName = null;
      _selectedOrganizerLogo = null;
      _selectedOrganizerEmail = null;
      // Reset SelectOrgViewModel state on logout
      final selectOrgViewModel = GetIt.instance<SelectOrgViewModel>();
      selectOrgViewModel.resetState();
      notifyListeners();
    } catch (e) {
      ErrorHandler.handleError(e, 'Đăng xuất thất bại', _errorState);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserFromToken(String token) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      await SecureStorage.saveToken(token);
      _user = await _userRepository.getMe();
      // Notify SelectOrgViewModel to fetch organizers for the new user
      final selectOrgViewModel = GetIt.instance<SelectOrgViewModel>();
      await selectOrgViewModel.resetAndFetchOrganizers();
    } catch (e) {
      ErrorHandler.handleError(e, 'Thiết lập người dùng từ token thất bại', _errorState);
      _user = null;
      await SecureStorage.clearToken();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setSelectedOrganizerId(String? organizerId) {
    _selectedOrganizerId = organizerId;
    notifyListeners();
  }

  void setSelectedOrganizerDetails({
    String? organizerId,
    String? name,
    String? logo,
    String? email,
  }) {
    _selectedOrganizerId = organizerId;
    _selectedOrganizerName = name;
    _selectedOrganizerLogo = logo;
    _selectedOrganizerEmail = email;
    notifyListeners();
  }

  void clearSelectedOrganizerId() {
    _selectedOrganizerId = null;
    _selectedOrganizerName = null;
    _selectedOrganizerLogo = null;
    _selectedOrganizerEmail = null;
    notifyListeners();
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}