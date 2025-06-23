import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class HomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final SessionManager _sessionManager; 
  final ErrorState _errorState = ErrorState();

  HomeViewModel(this._eventRepository, this._sessionManager) {
    fetchEvents();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  User? get user => _sessionManager.user;

  List<Event> _events = [];
  List<Event> get events => _events;

  int _totalEvents = 0;
  int get totalEvents => _totalEvents;

  Future<void> fetchEvents({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
  }) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    _events = [];
    notifyListeners();

    try {
      final result = await _eventRepository.getAll(
        page: page,
        limit: limit,
        query: query,
        search: search,
        fields: fields,
        sortBy: sortBy,
        orderBy: orderBy,
      );
      _events = result['data'] as List<Event>;
      _totalEvents = result['total'] as int;
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load events', _errorState);
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