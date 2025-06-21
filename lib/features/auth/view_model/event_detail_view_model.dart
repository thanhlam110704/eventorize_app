import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final ErrorState _errorState = ErrorState();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingRelated = false;
  bool get isLoadingRelated => _isLoadingRelated;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  Event? _event;
  Event? get event => _event;

  List<Event> _relatedEvents = [];
  List<Event> get relatedEvents => _relatedEvents;

  EventDetailViewModel({required EventRepository eventRepository})
      : _eventRepository = eventRepository;

  Future<void> fetchEventDetail(String id) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      _event = await _eventRepository.getEventDetail(id);
      await fetchRelatedEvents(id);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi lấy chi tiết sự kiện', _errorState);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRelatedEvents(String eventId) async {
    if (_event == null) return;

    _isLoadingRelated = true;
    notifyListeners();

    try {
   
      final result = await _eventRepository.getAll(
      );
      _relatedEvents = result['data'] as List<Event>;
      _relatedEvents = _relatedEvents.where((e) => e.id != eventId).toList();
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi lấy sự kiện liên quan', _errorState);
    } finally {
      _isLoadingRelated = false;
      notifyListeners();
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}