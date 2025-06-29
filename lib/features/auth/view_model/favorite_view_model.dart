import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/repositories/favorite_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/models/user.dart';

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;
  final SessionManager _sessionManager;
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

  Map<String, String> _favoriteIdMap = {};
  Map<String, String> get favoriteIdMap => _favoriteIdMap;

  FavoriteViewModel(this._favoriteRepository, this._sessionManager) {
    _sessionManager.addListener(_handleSessionChange);
    _initializeData();
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_handleSessionChange);
    super.dispose();
  }

  void _handleSessionChange() {
    if (_sessionManager.user == null) {
      _events = [];
      _favoriteIdMap = {};
      _totalEvents = 0;
      _isDataLoaded = false;
      _isLoading = false;
      notifyListeners();
    } else if (!_isInitialLoad) {
      fetchFavoriteEvents();
    }
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    _isInitialLoad = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      if (_sessionManager.user == null) {
        _events = [];
        _favoriteIdMap = {};
        _totalEvents = 0;
        _isDataLoaded = false;
      } else {
        await fetchFavoriteEvents();
      }
      _updateDataLoadedStatus();
      _isInitialLoad = false;
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi tải danh sách yêu thích ban đầu', _errorState);
      _isDataLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavoriteEvents() async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      if (_sessionManager.user == null) {
        _events = [];
        _favoriteIdMap = {};
        _totalEvents = 0;
        _isDataLoaded = false;
        return;
      }
      final favorite = await _favoriteRepository.getMyFavoriteEvents();
      _events = favorite.events ?? [];
      _favoriteIdMap = {
        for (var eventId in favorite.listEventId) eventId: favorite.id
      };
      _totalEvents = _events.length;
      _updateDataLoadedStatus();
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi tải danh sách sự kiện yêu thích', _errorState);
      _isDataLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFavoriteLocally({required Event event, required bool addFavorite, required String favoriteId}) {
    _isTogglingFavorite = true;
    notifyListeners();

    try {
      if (addFavorite) {
        if (!_events.any((e) => e.id == event.id)) {
          _events = [..._events, event];
          _favoriteIdMap[event.id] = favoriteId;
        }
      } else {
        _events = _events.where((e) => e.id != event.id).toList();
        _favoriteIdMap.remove(event.id);
      }
      _totalEvents = _events.length;
      _updateDataLoadedStatus();
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi cập nhật danh sách yêu thích', _errorState);
    } finally {
      _isTogglingFavorite = false;
      notifyListeners();
    }
  }

  void _updateDataLoadedStatus() {
    _isDataLoaded = _errorState.errorMessage == null;
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }

  Future<void> refreshFavorites() async {
    await fetchFavoriteEvents();
  }
}