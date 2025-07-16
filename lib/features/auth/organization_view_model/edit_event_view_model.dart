import 'package:flutter/material.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'dart:io';

class EditEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final SessionManager _sessionManager;
  final LocationRepository _locationRepository;
  final LocationCache _locationCache = GetIt.instance<LocationCache>();
  
  Event? _event;
  String? _timeRange;
  bool _isLoading = false;
  bool _isUploadingThumbnail = false;
  bool _isUpdateSuccessful = false;
  bool _isDataLoaded = false;
  bool _isLoadingCity = false;
  bool _isLoadingDistrict = false;
  bool _isLoadingWard = false;
  final ErrorState errorState = ErrorState();

  Event? get event => _event;
  String? get timeRange => _timeRange;
  bool get isLoading => _isLoading;
  bool get isUploadingThumbnail => _isUploadingThumbnail;
  bool get isUpdateSuccessful => _isUpdateSuccessful;
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

  EditEventViewModel({
    required EventRepository eventRepository,
    required SessionManager sessionManager,
    required LocationRepository locationRepository,
  }) : _eventRepository = eventRepository,
       _sessionManager = sessionManager,
       _locationRepository = locationRepository;

  void setTimeRange(String? timeRange) {
    _timeRange = timeRange;
    notifyListeners();
  }

  Future<void> fetchEvent(String eventId) async {
    if (_sessionManager.user == null) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return;
    }

    _isLoading = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    await executeApiCall(
      apiCall: () => _eventRepository.getEventDetail(eventId),
      onSuccess: (event) {
        _event = event as Event;
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        _timeRange = '${dateFormat.format(event.startDate)} to ${dateFormat.format(event.endDate)}';
        selectedCountry = event.country ?? 'Việt Nam';
        selectedCity = event.city;
        selectedDistrict = event.district;
        selectedWard = event.ward;
        loadLocationData();
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateEvent(BuildContext context, GlobalKey<FormState> formKey, {
    required String eventId,
    String? title,
    String? description,
    String? link,
    bool? isOnline,
    String? address,
    String? district,
    String? ward,
    String? city,
    String? country,
  }) async {
    final currentContext = context;
    if (!formKey.currentState!.validate()) return;

    if (_sessionManager.user == null) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isUpdateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    List<String> dates = _timeRange?.split(' - ') ?? [];
    if (dates.length != 2) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Thời gian diễn ra không hợp lệ';
      _isUpdateSuccessful = false;
      notifyListeners();
      return;
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
      _isUpdateSuccessful = false;
      notifyListeners();
      return;
    }

    await executeApiCall(
      apiCall: () => _eventRepository.editEvent(
        eventId,
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
      ),
      onSuccess: (updatedEvent) {
        _event = updatedEvent as Event;
        _isUpdateSuccessful = true;
        ErrorHandler.clearError(errorState);
        if (currentContext.mounted) {
          currentContext.go('/event-list');
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadThumbnail(BuildContext context, File imageFile) async {
    final currentContext = context;
    if (_sessionManager.user == null) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return;
    }

    final eventId = _event?.id;
    if (eventId == null || eventId.isEmpty) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Dữ liệu không hợp lệ. Hãy thử lại.';
      _isUpdateSuccessful = false;
      notifyListeners();
      return;
    }

    _isUploadingThumbnail = true;
    _isUpdateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    await executeApiCall(
      apiCall: () async {
        final multipartFile = await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last);
        await _eventRepository.editThumbnail(id: eventId, thumbnailFile: multipartFile);
        return _eventRepository.getEventDetail(eventId);
      },
      onSuccess: (updatedEvent) {
        _event = updatedEvent as Event;
        _isUpdateSuccessful = true;
        ErrorHandler.clearError(errorState);
        if (currentContext.mounted) {
          currentContext.go('/event-list');
        }
      },
    );

    _isUploadingThumbnail = false;
    notifyListeners();
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
          selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
        },
      );
    } else {
      selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
    }

    await loadDistricts();
    _isLoadingCity = false;
    notifyListeners();
  }

  Future<void> loadDistricts() async {
    if (selectedCity == null) return;
    _isLoadingDistrict = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final provinceCode = getProvinceCode(selectedCity);
    if (_locationCache.getDistricts(provinceCode).isEmpty) {
      await executeApiCall(
        apiCall: () => _locationRepository.getDistricts(provinceCode: provinceCode),
        onSuccess: (data) {
          _locationCache.setDistricts(provinceCode, data as List<District>);
          selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
        },
      );
    } else {
      selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
    }

    await loadWards();
    _isLoadingDistrict = false;
    notifyListeners();
  }

  Future<void> loadWards() async {
    if (selectedDistrict == null) return;
    _isLoadingWard = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final districtCode = getDistrictCode(selectedDistrict);
    if (_locationCache.getWards(districtCode).isEmpty) {
      await executeApiCall(
        apiCall: () => _locationRepository.getWards(districtCode: districtCode),
        onSuccess: (data) {
          _locationCache.setWards(districtCode, data as List<Ward>);
          selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
          updateDataLoadedStatus();
        },
      );
    } else {
      selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
      updateDataLoadedStatus();
    }

    _isLoadingWard = false;
    notifyListeners();
  }

  void updateDataLoadedStatus() {
    _isDataLoaded = provinces.isNotEmpty && districts.isNotEmpty && wards.isNotEmpty && errorState.errorMessage == null;
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
    _isUpdateSuccessful = false;
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
      _isUpdateSuccessful = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    ErrorHandler.clearError(errorState);
    notifyListeners();
  }

  void clearUpdateStatus() {
    _isUpdateSuccessful = false;
    notifyListeners();
  }
}