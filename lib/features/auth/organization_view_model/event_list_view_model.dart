import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class EventListViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final SessionManager _sessionManager;
  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;

  EventListViewModel({
    required EventRepository eventRepository,
    required SessionManager sessionManager,
  }) : _eventRepository = eventRepository, _sessionManager = sessionManager {
    if (_sessionManager.selectedOrganizerId != null) {
      fetchEvents(organizerId: _sessionManager.selectedOrganizerId!);
    } else {
      _errorMessage = 'Vui lòng chọn một nhà tổ chức trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
    }
  }

  Future<void> fetchEvents({
    required String organizerId,
    int page = 1,
    int limit = 20,
    String search = "",
  }) async {
    if (_sessionManager.selectedOrganizerId == null) {
      _errorMessage = 'Vui lòng chọn một nhà tổ chức trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _eventRepository.getAll(
        search: organizerId,
        page: page,
        limit: limit,
      );

      final eventList = response['data'] as List<Event>;
      _events = eventList;
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách sự kiện: $e';
      _errorTitle = 'Lỗi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }
}