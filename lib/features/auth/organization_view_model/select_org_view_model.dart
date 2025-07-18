import 'package:flutter/foundation.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';

class SelectOrgViewModel extends ChangeNotifier {
  final OrganizerRepository _organizerRepository;
  final SessionManager _sessionManager;
  final ErrorState _errorState = ErrorState();
  List<Organizer> _organizers = [];
  bool _isLoading = false;
  String? _selectedOrganizerId;

  List<Organizer> get organizers => _organizers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  String? get selectedOrganizerId => _selectedOrganizerId;

  SelectOrgViewModel({
    required OrganizerRepository organizerRepository,
    required SessionManager sessionManager,
  })  : _organizerRepository = organizerRepository,
        _sessionManager = sessionManager {
    fetchOrganizers();
  }

  Future<void> fetchOrganizers() async {
    if (_sessionManager.user == null) {
      _errorState.errorMessage = 'Vui lòng đăng nhập để xem danh sách nhà tổ chức';
      _errorState.errorTitle = 'Lỗi xác thực';
      notifyListeners();
      return;
    }

    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      final response = await _organizerRepository.getAll();
      _organizers = response['data'] as List<Organizer>;
      ErrorHandler.clearError(_errorState);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi tải danh sách nhà tổ chức', _errorState);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectOrganizer(String? organizerId) async {
    if (organizerId == null) {
      _selectedOrganizerId = null;
      _sessionManager.clearSelectedOrganizerId();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _selectedOrganizerId = organizerId;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      final organizer = await _organizerRepository.getDetail(organizerId);
      _sessionManager.setSelectedOrganizerDetails(
        organizerId: organizerId,
        name: organizer.name,
        logo: organizer.logo,
        email: organizer.email,
      );
      ErrorHandler.clearError(_errorState);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi lấy thông tin nhà tổ chức', _errorState);
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