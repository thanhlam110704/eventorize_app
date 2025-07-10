import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final SessionManager _sessionManager;
  final String _organizerId; // Add organizerId field
  final ErrorState _errorState = ErrorState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  Event? _event;
  Event? get event => _event;

  String? _title;
  String? _description;
  String? _dateRange = '2025-07-10 to 2025-07-11'; // Hard-coded date range
  String? _address;
  String? _link;
  bool _isOnline = false;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedWard;
  MultipartFile? _thumbnailFile;

  String? get selectedCity => _selectedCity;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedWard => _selectedWard;
  MultipartFile? get thumbnailFile => _thumbnailFile;
  bool get isOnline => _isOnline;

  CreateEventViewModel({
    required EventRepository eventRepository,
    required SessionManager sessionManager,
    required String organizerId, // Add organizerId parameter
  })  : _eventRepository = eventRepository,
        _sessionManager = sessionManager,
        _organizerId = organizerId;

  void updateTitle(String? title) {
    _title = title;
    notifyListeners();
  }

  void updateDescription(String? description) {
    _description = description;
    notifyListeners();
  }

  void updateDateRange(String? dateRange) {
    _dateRange = dateRange ?? '2025-07-10 to 2025-07-11';
    notifyListeners();
  }

  void updateAddress(String? address) {
    _address = address;
    notifyListeners();
  }

  void updateLink(String? link) {
    _link = link;
    notifyListeners();
  }

  void updateIsOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  void updateCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void updateDistrict(String? district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void updateWard(String? ward) {
    _selectedWard = ward;
    notifyListeners();
  }

  void setThumbnail(MultipartFile? file) {
    _thumbnailFile = file;
    notifyListeners();
  }

  Future<void> createEvent() async {
    if (!_validateForm()) {
      notifyListeners();
      return;
    }

    if (_sessionManager.user == null) {
      ErrorHandler.handleError(
        Exception('No user logged in'),
        'Vui lòng đăng nhập để tạo sự kiện',
        _errorState,
      );
      notifyListeners();
      return;
    }

    if (_organizerId.isEmpty) {
      ErrorHandler.handleError(
        Exception('Invalid organizer ID'),
        'Không tìm thấy ID nhà tổ chức',
        _errorState,
      );
      notifyListeners();
      return;
    }

    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      // Parse date range
      final dates = (_dateRange ?? '2025-07-10 to 2025-07-11').split(' to ');
      final startDate = DateTime.parse(dates[0]);
      final endDate = DateTime.parse(dates[1]);


      _event = await _eventRepository.createEvent(
        organizerId: _organizerId, 
        title: _title!,
        description: _description,
        link: _isOnline ? _link : null,
        startDate: startDate,
        endDate: endDate,
        isOnline: _isOnline,
        address: _isOnline ? null : _address,
        district: _isOnline ? null : _selectedDistrict,
        ward: _isOnline ? null : _selectedWard,
        city: _isOnline ? null : _selectedCity,
        country: 'Vietnam',
        thumbnailFile: _thumbnailFile,
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        ErrorHandler.handleError(
          e,
          'Lỗi khi tạo sự kiện: ${e.response!.data.toString()}',
          _errorState,
        );
      } else {
        ErrorHandler.handleError(e, 'Lỗi khi tạo sự kiện', _errorState);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateForm() {
    if (_title?.isNotEmpty != true || _title!.length < 5) {
      ErrorHandler.handleError(
        Exception('Invalid title'),
        'Tên sự kiện phải có ít nhất 5 ký tự',
        _errorState,
      );
      return false;
    }

    if (_dateRange?.isNotEmpty != true) {
      ErrorHandler.handleError(
        Exception('Missing date range'),
        'Thời gian không được để trống',
        _errorState,
      );
      return false;
    }

    if (_isOnline && _link?.isNotEmpty != true) {
      ErrorHandler.handleError(
        Exception('Missing link'),
        'Link sự kiện online không được để trống',
        _errorState,
      );
      return false;
    }

    if (!_isOnline && _address?.isNotEmpty != true) {
      ErrorHandler.handleError(
        Exception('Missing address'),
        'Địa chỉ không được để trống',
        _errorState,
      );
      return false;
    }

    try {
      final dates = (_dateRange ?? '2025-07-10 to 2025-07-11').split(' to ');
      final startDate = DateTime.parse(dates[0]);
      final endDate = DateTime.parse(dates[1]);
      if (startDate.isAfter(endDate)) {
        ErrorHandler.handleError(
          Exception('Invalid date range'),
          'Ngày bắt đầu không được lớn hơn ngày kết thúc',
          _errorState,
        );
        return false;
      }
    } catch (e) {
      ErrorHandler.handleError(
        e,
        'Lỗi định dạng thời gian',
        _errorState,
      );
      return false;
    }

    return true;
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}