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
  int _currentPage = 1;
  int _currentLimit = 20;
  String _currentSearch = "";

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;

  EventListViewModel({
    required EventRepository eventRepository,
    required SessionManager sessionManager,
  }) : _eventRepository = eventRepository, _sessionManager = sessionManager {
    if (_sessionManager.user != null) {
      fetchEvents(organizerId: _sessionManager.selectedOrganizerId!);
    } else {
      _errorMessage = 'Vui lòng đăng nhập trước';
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
    if (_sessionManager.user == null) {
      _errorMessage = 'Vui lòng đăng nhập trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _eventRepository.getEventsByOrganizer(
        organizerId: organizerId,
        page: page,
        limit: limit,
        search: search.isNotEmpty ? search : null,
      );

      final eventList = response['data'] as List<Event>;
      _events = eventList;
      _currentPage = page;
      _currentLimit = limit;
      _currentSearch = search;
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

  Future<void> deleteEvent(String eventId) async {
    if (_sessionManager.user == null) {
      _errorMessage = 'Vui lòng đăng nhập trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final originalEvents = List<Event>.from(_events); 
    _events = _events.where((event) => event.id != eventId).toList();
    notifyListeners(); 

    try {
      await _eventRepository.deleteEvent(eventId);
      await fetchEvents(
        organizerId: _sessionManager.selectedOrganizerId!,
        page: _currentPage,
        limit: _currentLimit,
        search: _currentSearch,
      );
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _events = originalEvents;
      _errorMessage = 'Xóa sự kiện thất bại: $e';
      _errorTitle = 'Lỗi';
      await fetchEvents(
        organizerId: _sessionManager.selectedOrganizerId!,
        page: _currentPage,
        limit: _currentLimit,
        search: _currentSearch,
      );
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