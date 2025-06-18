import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final ErrorState _errorState = ErrorState();

  Event? _event;
  Event? get event => _event;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  EventDetailViewModel(this._eventRepository);

  Future<void> fetchEventDetail(String id) async {
    _isLoading = true;
   ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      _event = await _eventRepository.getEventDetail(id);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi tải chi tiết sự kiện', _errorState);
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

