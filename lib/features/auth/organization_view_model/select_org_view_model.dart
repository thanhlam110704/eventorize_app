import 'package:flutter/foundation.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';

class SelectOrgViewModel extends ChangeNotifier {
  final OrganizerRepository _organizerRepository;
  final SessionManager _sessionManager;
  List<Organizer> _organizers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;
  String? _selectedOrganizerId;

  List<Organizer> get organizers => _organizers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;
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
      _errorMessage = 'Vui lòng đăng nhập để xem danh sách nhà tổ chức';
      _errorTitle = 'Lỗi xác thực';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _organizerRepository.getAll();
      _organizers = response['data'] as List<Organizer>;
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách nhà tổ chức';
      _errorTitle = 'Lỗi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOrganizer(String? organizerId) {
    _selectedOrganizerId = organizerId;
    _sessionManager.setSelectedOrganizerId(organizerId); 
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }
}