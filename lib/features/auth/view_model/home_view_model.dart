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

  bool _isLoading = true; 
  bool get isLoading => _isLoading;

  bool _isInitialLoad = true; 
  bool get isInitialLoad => _isInitialLoad;

  bool _isDataLoaded = false; 
  bool get isDataLoaded => _isDataLoaded;

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

  HomeViewModel(this._eventRepository, this._sessionManager, this._locationRepository) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    _isInitialLoad = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      await _loadInitialLocationData();
      await fetchEvents(search: _selectedCity, page: 1, limit: 10);
      _updateDataLoadedStatus();
      _isInitialLoad = false;
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to initialize data', _errorState);
      _isDataLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInitialLocationData() async {
    if (_locationCache.provinces.isEmpty) {
      final provinces = await _locationRepository.getProvinces();
      _locationCache.setProvinces(provinces);
    }
    if (_selectedCity == null && provinces.isNotEmpty) {
      _selectedCity = provinces[0].name;
    }
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
      _updateDataLoadedStatus();
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load events', _errorState);
      _isDataLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocationData() async {
    _isLoading = true;
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
      _updateDataLoadedStatus();
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load provinces', _errorState);
      _isDataLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateDataLoadedStatus() {
    _isDataLoaded = provinces.isNotEmpty && _errorState.errorMessage == null;
  }

  Future<void> setCity(String? city) async {
    if (city != _selectedCity) {
      _selectedCity = city;
      notifyListeners();
      await fetchEvents(search: city); 
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}