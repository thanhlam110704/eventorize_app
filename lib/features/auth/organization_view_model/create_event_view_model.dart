import 'package:flutter/material.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/features/auth/organization_view_model/event_list_view_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final SessionManager _sessionManager;
  final LocationRepository _locationRepository;
  final LocationCache _locationCache = GetIt.instance<LocationCache>();

  String? _timeRange;
  bool _isLoading = false;
  bool _isCreateSuccessful = false;
  bool _isDataLoaded = false;
  bool _isLoadingCity = false;
  bool _isLoadingDistrict = false;
  bool _isLoadingWard = false;
  final ErrorState errorState = ErrorState();

  String? get timeRange => _timeRange;
  bool get isLoading => _isLoading;
  bool get isCreateSuccessful => _isCreateSuccessful;
  bool get isDataLoaded => _isDataLoaded;
  bool get isLoadingCity => _isLoadingCity;
  bool get isLoadingDistrict => _isLoadingDistrict;
  bool get isLoadingWard => _isLoadingWard;
  bool get isLoadingAnyLocation => _isLoadingCity || _isLoadingDistrict || _isLoadingWard;
  String? get errorMessage => errorState.errorMessage;
  String? get errorTitle => errorState.errorTitle;

  List<Province> get provinces => _locationCache.provinces;
  List<District> get districts => _locationCache.getDistricts(getProvinceCode(selectedCity));
  List<Ward> get wards => _locationCache.getWards(getDistrictCode(selectedDistrict));

  String? selectedCountry = 'Việt Nam';
  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  CreateEventViewModel({
    required EventRepository eventRepository,
    required SessionManager sessionManager,
    required LocationRepository locationRepository,
  })  : _eventRepository = eventRepository,
        _sessionManager = sessionManager,
        _locationRepository = locationRepository {
    loadLocationData();
  }

  void setTimeRange(String? timeRange) {
    _timeRange = timeRange;
    notifyListeners();
  }

  Future<Event?> createEvent(
    BuildContext context,
    GlobalKey<FormState> formKey, {
    required String organizerId,
    required String title,
    String? description,
    String? link,
    bool isOnline = false,
    String? address,
    String? district,
    String? ward,
    String? city,
    String? country,
    File? imageFile,
  }) async {
    if (_sessionManager.user == null) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return null;
    }

    if (!formKey.currentState!.validate()) return null;

    _isLoading = true;
    _isCreateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    try {
      List<String> dates = _timeRange?.split(' - ') ?? [];
      if (dates.length != 2) {
        errorState.errorTitle = 'Lỗi';
        errorState.errorMessage = 'Thời gian diễn ra không hợp lệ';
        _isCreateSuccessful = false;
        notifyListeners();
        return null;
      }

      String? startDate = dates[0];
      String? endDate = dates[1];
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      try {
        dateFormat.parseStrict(startDate);
        dateFormat.parseStrict(endDate);
      } catch (e) {
        errorState.errorTitle = 'Lỗi';
        errorState.errorMessage = 'Định dạng thời gian không hợp lệ';
        _isCreateSuccessful = false;
        notifyListeners();
        return null;
      }

      MultipartFile? thumbnailFile;
      if (imageFile != null) {
        thumbnailFile = await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last);
      }

      final event = await _eventRepository.createEvent(
        organizerId: organizerId,
        title: title,
        description: description,
        link: link,
        startDate: startDate,
        endDate: endDate,
        isOnline: isOnline,
        address: address,
        district: district,
        ward: ward,
        city: city,
        country: country,
        thumbnailFile: thumbnailFile,
      );

      final eventListViewModel = GetIt.instance<EventListViewModel>();
      await eventListViewModel.fetchEvents(
        organizerId: _sessionManager.selectedOrganizerId!,
        page: 1,
        limit: 20,
        search: "",
      );

      _isCreateSuccessful = true;
      ErrorHandler.clearError(errorState);
      notifyListeners();
      return event;
    } catch (e) {
      ErrorHandler.handleError(e, '', errorState);
      _isCreateSuccessful = false;
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocationData() async {
    _isLoadingCity = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    if (_locationCache.provinces.isEmpty) {
      await executeApiCall(
        apiCall: () => _locationRepository.getProvinces(),
        onSuccess: (data) {
          _locationCache.setProvinces(data as List<Province>);
        },
      );
    }

    await loadDistricts();
    _isLoadingCity = false;
    notifyListeners();
  }

  Future<void> loadDistricts() async {
    if (selectedCity == null) {
      _isLoadingDistrict = false;
      notifyListeners();
      return;
    }
    _isLoadingDistrict = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final provinceCode = getProvinceCode(selectedCity);
    if (_locationCache.getDistricts(provinceCode).isEmpty) {
      await executeApiCall(
        apiCall: () => _locationRepository.getDistricts(provinceCode: provinceCode),
        onSuccess: (data) {
          _locationCache.setDistricts(provinceCode, data as List<District>);
        },
      );
    }

    await loadWards();
    _isLoadingDistrict = false;
    notifyListeners();
  }

  Future<void> loadWards() async {
    if (selectedDistrict == null) {
      _isLoadingWard = false;
      notifyListeners();
      return;
    }
    _isLoadingWard = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final districtCode = getDistrictCode(selectedDistrict);
    if (_locationCache.getWards(districtCode).isEmpty) {
      await executeApiCall(
        apiCall: () => _locationRepository.getWards(districtCode: districtCode),
        onSuccess: (data) {
          _locationCache.setWards(districtCode, data as List<Ward>);
          updateDataLoadedStatus();
        },
      );
    } else {
      updateDataLoadedStatus();
    }

    _isLoadingWard = false;
    notifyListeners();
  }

  void updateDataLoadedStatus() {
    _isDataLoaded = provinces.isNotEmpty && errorState.errorMessage == null;
    notifyListeners();
  }

  String getProvinceCode(String? provinceName) {
    if (provinceName == null) return '';
    return provinces.firstWhere(
      (p) => p.name == provinceName,
      orElse: () => Province(),
    ).code?.toString() ?? '';
  }

  String getDistrictCode(String? districtName) {
    if (districtName == null) return '';
    return districts.firstWhere(
      (d) => d.name == districtName,
      orElse: () => District(),
    ).code?.toString() ?? '';
  }

  void setCity(String? city) {
    if (city != selectedCity) {
      selectedCity = city;
      selectedDistrict = null;
      selectedWard = null;
      _isLoadingDistrict = true;
      _isLoadingWard = true;
      loadDistricts();
    }
    notifyListeners();
  }

  void setDistrict(String? district) {
    if (district != selectedDistrict) {
      selectedDistrict = district;
      selectedWard = null;
      _isLoadingWard = true;
      loadWards();
    }
    notifyListeners();
  }

  void setWard(String? ward) {
    selectedWard = ward;
    notifyListeners();
  }

  void setError(String title, String message) {
    errorState.errorTitle = title.isEmpty ? null : title;
    errorState.errorMessage = message;
    _isCreateSuccessful = false;
    notifyListeners();
  }

  Future<void> executeApiCall({
    required Future<dynamic> Function() apiCall,
    required void Function(dynamic data) onSuccess,
  }) async {
    try {
      final result = await apiCall();
      onSuccess(result);
    } catch (e) {
      ErrorHandler.handleError(e, '', errorState);
      _isCreateSuccessful = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    ErrorHandler.clearError(errorState);
    notifyListeners();
  }

  void clearCreateStatus() {
    _isCreateSuccessful = false;
    notifyListeners();
  }
}