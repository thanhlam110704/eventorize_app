import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';

class EventListViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
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
    required String organizerId,
  }) : _eventRepository = eventRepository {
    fetchEvents(organizerId);
  }

  Future<void> fetchEvents(String organizerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await _eventRepository.getEventsByOrganizerId(organizerId);
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