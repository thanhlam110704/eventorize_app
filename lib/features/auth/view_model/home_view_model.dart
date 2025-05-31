import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class HomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final SessionManager _sessionManager;
  final LocationRepository _locationRepository;
  final LocationCache _locationCache = GetIt.instance<LocationCache>(); 
  final ErrorState _errorState = ErrorState();

  HomeViewModel(this._eventRepository, this._sessionManager, this._locationRepository) {
    fetchEvents();
    loadLocationData(); 
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingCity = false; 
  bool get isLoadingCity => _isLoadingCity;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  User? get user => _sessionManager.user;

  List<Event> _events = [];
  List<Event> get events => _events;

  int _totalEvents = 0;
  int get totalEvents => _totalEvents;

  List<Province> get provinces => _locationCache.provinces;
  String? _selectedCity;
  String? get selectedCity => _selectedCity;
  set selectedCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

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

  Future<void> loadLocationData() async {
    _isLoadingCity = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      if (_locationCache.provinces.isEmpty) {
        final provinces = await _locationRepository.getProvinces();
        _locationCache.setProvinces(provinces);
      }
      if (_selectedCity == null && provinces.isNotEmpty) {
        _selectedCity = provinces[0].name; 
      }
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load provinces', _errorState);
    } finally {
      _isLoadingCity = false;
      notifyListeners();
    }
  }

  void setCity(String? city) {
    if (city != _selectedCity) {
      _selectedCity = city;
      fetchEvents(query: 'city=$city'); 
      notifyListeners();
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}