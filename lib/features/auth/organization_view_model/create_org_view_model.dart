import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:eventorize_app/features/auth/organization_view_model/select_org_view_model.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class CreateOrgViewModel extends ChangeNotifier {
  final OrganizerRepository _organizerRepository;
  final LocationRepository _locationRepository;
  final SessionManager _sessionManager;
  final LocationCache _locationCache = GetIt.instance<LocationCache>();
  final ErrorState errorState = ErrorState();

  bool _isLoading = false;
  bool _isCreateSuccessful = false;
  bool _isDataLoaded = false;
  bool _isLoadingCity = false;
  bool _isLoadingDistrict = false;
  bool _isLoadingWard = false;

  String? _name;
  String? _email;
  String? _phone;
  String? _description;
  String? _facebook;
  String? _twitter;
  String? _instagram;
  String? _linkedin;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedWard;
  MultipartFile? _selectedImage;
  File? _imageFile;

  bool get isLoading => _isLoading;
  bool get isCreateSuccessful => _isCreateSuccessful;
  bool get isDataLoaded => _isDataLoaded;
  bool get isLoadingCity => _isLoadingCity;
  bool get isLoadingDistrict => _isLoadingDistrict;
  bool get isLoadingWard => _isLoadingWard;
  bool get isLoadingAnyLocation => _isLoadingCity || _isLoadingDistrict || _isLoadingWard;
  String? get errorMessage => errorState.errorMessage;
  String? get errorTitle => errorState.errorTitle;
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get description => _description;
  String? get facebook => _facebook;
  String? get twitter => _twitter;
  String? get instagram => _instagram;
  String? get linkedin => _linkedin;
  String? get selectedCity => _selectedCity;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedWard => _selectedWard;
  File? get imageFile => _imageFile;

  List<Province> get provinces => _locationCache.provinces;
  List<District> get districts => _locationCache.getDistricts(getProvinceCode(_selectedCity));
  List<Ward> get wards => _locationCache.getWards(getDistrictCode(_selectedDistrict));

  CreateOrgViewModel({
    required OrganizerRepository organizerRepository,
    required LocationRepository locationRepository,
    required SessionManager sessionManager,
  })  : _organizerRepository = organizerRepository,
        _locationRepository = locationRepository,
        _sessionManager = sessionManager {
    loadLocationData();
  }

  void setName(String? name) {
    _name = name;
    notifyListeners();
  }

  void setEmail(String? email) {
    _email = email;
    notifyListeners();
  }

  void setPhone(String? phone) {
    _phone = phone;
    notifyListeners();
  }

  void setDescription(String? description) {
    _description = description;
    notifyListeners();
  }

  void setFacebook(String? facebook) {
    _facebook = facebook;
    notifyListeners();
  }

  void setTwitter(String? twitter) {
    _twitter = twitter;
    notifyListeners();
  }

  void setInstagram(String? instagram) {
    _instagram = instagram;
    notifyListeners();
  }

  void setLinkedin(String? linkedin) {
    _linkedin = linkedin;
    notifyListeners();
  }

  void setCity(String? city) {
    if (city != _selectedCity) {
      _selectedCity = city;
      _selectedDistrict = null;
      _selectedWard = null;
      _isLoadingDistrict = true;
      _isLoadingWard = true;
      loadDistricts();
    }
    notifyListeners();
  }

  void setDistrict(String? district) {
    if (district != _selectedDistrict) {
      _selectedDistrict = district;
      _selectedWard = null;
      _isLoadingWard = true;
      loadWards();
    }
    notifyListeners();
  }

  void setWard(String? ward) {
    _selectedWard = ward;
    notifyListeners();
  }

  void setImage(MultipartFile? image, File? imageFile) {
    _selectedImage = image;
    _imageFile = imageFile;
    notifyListeners();
  }

  Future<Organizer?> createOrganizer(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (_sessionManager.user == null) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return null;
    }

    if (!formKey.currentState!.validate()) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Hãy điền đầy đủ thông tin bắt buộc trước khi tạo';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _isCreateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    try {
      final organizer = await _organizerRepository.create(
        name: _name!,
        email: _email!,
        phone: _phone!,
        description: _description!,
        country: 'Việt Nam',
        city: _selectedCity,
        district: _selectedDistrict,
        ward: _selectedWard,
        facebook: _facebook?.isNotEmpty == true ? _facebook : null,
        twitter: _twitter?.isNotEmpty == true ? _twitter : null,
        instagram: _instagram?.isNotEmpty == true ? _instagram : null,
        linkedin: _linkedin?.isNotEmpty == true ? _linkedin : null,
        file: _selectedImage,
      );

      // Update SessionManager with the new organizer
      _sessionManager.setSelectedOrganizerDetails(
        organizerId: organizer.id,
        name: organizer.name,
        logo: organizer.logo,
        email: organizer.email,
      );

      // Refresh SelectOrgViewModel to include the new organizer
      final selectOrgViewModel = GetIt.instance<SelectOrgViewModel>();
      await selectOrgViewModel.resetAndFetchOrganizers();

      _isCreateSuccessful = true;
      ErrorHandler.clearError(errorState);
      notifyListeners();
      return organizer;
    } catch (e) {
      if (e is DioException && e.response != null) {
        ErrorHandler.handleError(
          e,
          'Lỗi khi tạo nhà tổ chức: ${e.response!.data.toString()}',
          errorState,
        );
      } else {
        ErrorHandler.handleError(e, 'Lỗi khi tạo nhà tổ chức', errorState);
      }
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
    if (_selectedCity == null) {
      _isLoadingDistrict = false;
      notifyListeners();
      return;
    }
    _isLoadingDistrict = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final provinceCode = getProvinceCode(_selectedCity);
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
    if (_selectedDistrict == null) {
      _isLoadingWard = false;
      notifyListeners();
      return;
    }
    _isLoadingWard = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final districtCode = getDistrictCode(_selectedDistrict);
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

  Future<void> executeApiCall({
    required Future<dynamic> Function() apiCall,
    required void Function(dynamic data) onSuccess,
  }) async {
    try {
      final result = await apiCall();
      onSuccess(result);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi tải dữ liệu', errorState);
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