import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/data/repositories/favorite_repository.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class HomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final SessionManager _sessionManager;
  final LocationRepository _locationRepository;
  final FavoriteRepository _favoriteRepository;
  final LocationCache _locationCache = GetIt.instance<LocationCache>();
  final ErrorState _errorState = ErrorState();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isInitialLoad = true;
  bool get isInitialLoad => _isInitialLoad;

  bool _isDataLoaded = false;
  bool get isDataLoaded => _isDataLoaded;

  bool _isTogglingFavorite = false;
  bool get isTogglingFavorite => _isTogglingFavorite;

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

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  Map<String, String> _favoriteIdMap = {};
  Map<String, String> get favoriteIdMap => _favoriteIdMap;

  HomeViewModel(
    this._eventRepository,
    this._sessionManager,
    this._locationRepository,
    this._favoriteRepository,
  ) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    _isInitialLoad = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      await _loadInitialLocationData();
      await _loadFavorites();
      await fetchEvents(page: 1, limit: 10, city: _selectedCity);
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

  Future<void> _loadFavorites() async {
    try {
      final favorite = await _favoriteRepository.getMyFavoriteEvents();
      _favoriteIdMap = {
        for (var eventId in favorite.listEventId) eventId: favorite.id
      };
      notifyListeners();
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load favorites', _errorState);
      notifyListeners();
    }
  }

  Future<void> fetchEvents({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? city,
    String? fields,
    String? sortBy,
    String? orderBy,
    bool isToggleFavorite = false,
    bool isFromNavigation = false,
  }) async {
    if (!isToggleFavorite && !isFromNavigation) {
      _isLoading = true;
    } else if (isToggleFavorite) {
      _isTogglingFavorite = true;
    }
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      String? dateFilter;
      bool? isOnline;
      if (_selectedCategory == 'Today') {
        dateFilter = 'today';
      } else if (_selectedCategory == 'Tomorrow') {
        dateFilter = 'tomorrow';
      } else if (_selectedCategory == 'This Week') {
        dateFilter = 'this_week';
      } else if (_selectedCategory == 'Online') {
        isOnline = true;
      }

      final result = await _eventRepository.getAll(
        page: page,
        limit: limit,
        query: query,
        search: search,
        city: city ?? _selectedCity,
        fields: fields,
        sortBy: sortBy,
        orderBy: orderBy,
        dateFilter: dateFilter,
        isOnline: isOnline,
      );
      _events = result['data'] as List<Event>;
      _totalEvents = result['total'] as int;
      await _loadFavorites();
      _updateDataLoadedStatus();
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load events', _errorState);
      _isDataLoaded = false;
    } finally {
      if (!isToggleFavorite && !isFromNavigation) {
        _isLoading = false;
      } else if (isToggleFavorite) {
        _isTogglingFavorite = false;
      }
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
      await _loadFavorites();
      await fetchEvents(city: _selectedCity);
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
    _isDataLoaded = provinces.isNotEmpty && _events.isNotEmpty && _errorState.errorMessage == null;
  }

  Future<void> setCity(String value) async {
    if (value != _selectedCity) {
      _selectedCity = value;
      notifyListeners();
      await fetchEvents(city: value);
    }
  }

  Future<void> setCategory(String category) async {
    if (category != _selectedCategory) {
      _selectedCategory = category;
      notifyListeners();
      await fetchEvents(city: _selectedCity);
    }
  }

  Future<List<String>> fetchEventTitles(String query) async {
    try {
      final result = await _eventRepository.getAll(
        search: query.isNotEmpty ? query : null,
        limit: 10,
        fields: '_id,organizer_id,title,start_date,end_date,is_online',
      );
      final events = result['data'] as List<Event>;
      return events.map((event) => event.title).toSet().toList();
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load event titles', _errorState);
      return [];
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}