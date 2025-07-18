import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class CreateOrgViewModel extends ChangeNotifier {
  final OrganizerRepository _organizerRepository;
  final SessionManager _sessionManager;
  final LocationRepository _locationRepository;
  final LocationCache _locationCache = GetIt.instance<LocationCache>();
  final ErrorState _errorState = ErrorState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingCity = false;
  bool get isLoadingCity => _isLoadingCity;

  bool _isLoadingDistrict = false;
  bool get isLoadingDistrict => _isLoadingDistrict;

  bool _isLoadingWard = false;
  bool get isLoadingWard => _isLoadingWard;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  Organizer? _organizer;
  Organizer? get organizer => _organizer;

  String? _name;
  String? _email;
  String? _phone;
  String? _description;
  String? _facebook;
  String? _twitter;
  String? _instagram;
  String? _linkedin;

  String? _selectedCity;
  String? get selectedCity => _selectedCity;

  String? _selectedDistrict;
  String? get selectedDistrict => _selectedDistrict;

  String? _selectedWard;
  String? get selectedWard => _selectedWard;

  MultipartFile? _selectedImage;
  MultipartFile? get selectedImage => _selectedImage;

  File? _imageFile;
  File? get imageFile => _imageFile;

  List<Province> get provinces => _locationCache.provinces;
  List<District> get districts => _locationCache.getDistricts(getProvinceCode(_selectedCity));
  List<Ward> get wards => _locationCache.getWards(getDistrictCode(_selectedDistrict));

  CreateOrgViewModel({
    required OrganizerRepository organizerRepository,
    required SessionManager sessionManager,
    required LocationRepository locationRepository,
  })  : _organizerRepository = organizerRepository,
        _sessionManager = sessionManager,
        _locationRepository = locationRepository {
    _loadLocationData();
  }

  void updateName(String? name) {
    _name = name;
    notifyListeners();
  }

  void updateEmail(String? email) {
    _email = email;
    notifyListeners();
  }

  void updatePhone(String? phone) {
    _phone = phone;
    notifyListeners();
  }

  void updateDescription(String? description) {
    _description = description;
    notifyListeners();
  }

  void updateFacebook(String? facebook) {
    _facebook = facebook;
    notifyListeners();
  }

  void updateTwitter(String? twitter) {
    _twitter = twitter;
    notifyListeners();
  }

  void updateInstagram(String? instagram) {
    _instagram = instagram;
    notifyListeners();
  }

  void updateLinkedin(String? linkedin) {
    _linkedin = linkedin;
    notifyListeners();
  }

  void updateCity(String? city) {
    if (city != _selectedCity) {
      _selectedCity = city;
      _selectedDistrict = null;
      _selectedWard = null;
      _isLoadingDistrict = true;
      _isLoadingWard = true;
      _loadDistricts();
    }
    notifyListeners();
  }

  void updateDistrict(String? district) {
    if (district != _selectedDistrict) {
      _selectedDistrict = district;
      _selectedWard = null;
      _isLoadingWard = true;
      _loadWards();
    }
    notifyListeners();
  }

  void updateWard(String? ward) {
    _selectedWard = ward;
    notifyListeners();
  }

  void setImage(MultipartFile? image, File? imageFile) {
    _selectedImage = image;
    _imageFile = imageFile;
    notifyListeners();
  }

  Future<void> _loadLocationData() async {
    _isLoadingCity = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    if (_locationCache.provinces.isEmpty) {
      await _executeApiCall(
        apiCall: () => _locationRepository.getProvinces(),
        errorPrefix: 'Lỗi khi tải danh sách tỉnh thành',
        onSuccess: (data) {
          _locationCache.setProvinces(data as List<Province>);
          _selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
        },
      );
    } else {
      _selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
    }

    await _loadDistricts();
    _isLoadingCity = false;
    notifyListeners();
  }

  Future<void> _loadDistricts() async {
    if (_selectedCity == null) return;
    _isLoadingDistrict = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    final provinceCode = getProvinceCode(_selectedCity);
    if (_locationCache.getDistricts(provinceCode).isEmpty) {
      await _executeApiCall(
        apiCall: () => _locationRepository.getDistricts(provinceCode: provinceCode),
        errorPrefix: 'Lỗi khi tải danh sách quận huyện',
        onSuccess: (data) {
          _locationCache.setDistricts(provinceCode, data as List<District>);
          _selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
        },
      );
    } else {
      _selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
    }

    await _loadWards();
    _isLoadingDistrict = false;
    notifyListeners();
  }

  Future<void> _loadWards() async {
    if (_selectedDistrict == null) return;
    _isLoadingWard = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    final districtCode = getDistrictCode(_selectedDistrict);
    if (_locationCache.getWards(districtCode).isEmpty) {
      await _executeApiCall(
        apiCall: () => _locationRepository.getWards(districtCode: districtCode),
        errorPrefix: 'Lỗi khi tải danh sách phường xã',
        onSuccess: (data) {
          _locationCache.setWards(districtCode, data as List<Ward>);
          _selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
        },
      );
    } else {
      _selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
    }

    _isLoadingWard = false;
    notifyListeners();
  }

  String getProvinceCode(String? provinceName) {
    if (provinceName == null) return '';
    return provinces.firstWhere(
      (p) => p.name == provinceName,
      orElse: () => provinces.isNotEmpty ? provinces[0] : Province(),
    ).code?.toString() ?? '';
  }

  String getDistrictCode(String? districtName) {
    if (districtName == null) return '';
    return districts.firstWhere(
      (d) => d.name == districtName,
      orElse: () => districts.isNotEmpty ? districts[0] : District(),
    ).code?.toString() ?? '';
  }

  Future<void> _executeApiCall({
    required Future<dynamic> Function() apiCall,
    required String errorPrefix,
    required void Function(dynamic data) onSuccess,
  }) async {
    try {
      final result = await apiCall();
      onSuccess(result);
    } catch (e) {
      ErrorHandler.handleError(e, errorPrefix, _errorState);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createOrganizer() async {
    if (!_validateForm()) {
      ErrorHandler.handleError(
        Exception('Missing required fields'),
        'Vui lòng điền đầy đủ các trường bắt buộc',
        _errorState,
      );
      notifyListeners();
      return;
    }

    if (_sessionManager.user == null) {
      ErrorHandler.handleError(
        Exception('No user logged in'),
        'Vui lòng đăng nhập để tạo nhà tổ chức',
        _errorState,
      );
      notifyListeners();
      return;
    }

    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      _organizer = await _organizerRepository.create(
        name: _name!,
        email: _email!,
        phone: _phone!,
        description: _description!,
        country: 'Vietnam',
        city: _selectedCity,
        district: _selectedDistrict,
        ward: _selectedWard,
        facebook: _facebook?.isNotEmpty == true ? _facebook : null,
        twitter: _twitter?.isNotEmpty == true ? _twitter : null,
        instagram: _instagram?.isNotEmpty == true ? _instagram : null,
        linkedin: _linkedin?.isNotEmpty == true ? _linkedin : null,
        file: _selectedImage,
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        ErrorHandler.handleError(
          e,
          'Lỗi khi tạo nhà tổ chức: ${e.response!.data.toString()}',
          _errorState,
        );
      } else {
        ErrorHandler.handleError(e, 'Lỗi khi tạo nhà tổ chức', _errorState);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateForm() {
    return _name?.isNotEmpty == true &&
        _email?.isNotEmpty == true &&
        _phone?.isNotEmpty == true &&
        _description?.isNotEmpty == true &&
        _selectedCity?.isNotEmpty == true &&
        _selectedDistrict?.isNotEmpty == true &&
        _selectedWard?.isNotEmpty == true;
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}