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
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    _isInitialLoad = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      await fetchFavoriteEvents(page: 1, limit: 10);
      _updateDataLoadedStatus();
      _isInitialLoad = false;
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to initialize favorite events', _errorState);
      _isDataLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavoriteEvents({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      final result = await _favoriteRepository.getFavorites(page: page, limit: limit);
      _events = result['data'] as List<Event>;
      _totalEvents = result['total'] as int;
      _favoriteIdMap = {
        for (var event in _events) event.id: event.id 
      };
      _updateDataLoadedStatus();
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to load favorite events', _errorState);
      _isDataLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateDataLoadedStatus() {
    _isDataLoaded = _events.isNotEmpty && _errorState.errorMessage == null;
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }

  Future<void> refreshFavorites() async {
    await fetchFavoriteEvents(page: 1, limit: 10);
  }
}