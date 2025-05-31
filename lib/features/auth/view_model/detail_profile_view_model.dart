import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'dart:io';

class DetailProfileViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final LocationRepository locationRepository;
  final LocationCache _locationCache = GetIt.instance<LocationCache>();
  final ErrorState _errorState = ErrorState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDataLoaded = false;
  bool get isDataLoaded => _isDataLoaded;

  bool _isLoadingCity = false;
  bool get isLoadingCity => _isLoadingCity;

  bool _isLoadingDistrict = false;
  bool get isLoadingDistrict => _isLoadingDistrict;

  bool _isLoadingWard = false;
  bool get isLoadingWard => _isLoadingWard;

  bool _isUploadingAvatar = false;
  bool get isUploadingAvatar => _isUploadingAvatar;

  bool get isLoadingAnyLocation => _isLoadingCity || _isLoadingDistrict || _isLoadingWard;

  bool _isUpdateSuccessful = false;
  bool get isUpdateSuccessful => _isUpdateSuccessful;

  User? user;
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  List<Province> get provinces => _locationCache.provinces;
  List<District> get districts => _locationCache.getDistricts(_getProvinceCode(selectedCity));
  List<Ward> get wards => _locationCache.getWards(_getDistrictCode(selectedDistrict));

  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  DetailProfileViewModel(this.userRepository, this.locationRepository);

  Future<void> loadUser(User? accountUser) async {
    if (accountUser == null) {
      _errorState.errorTitle = 'Error';
      _errorState.errorMessage = 'User data is missing. Please log in again.';
      _isDataLoaded = false;
      notifyListeners();
      return;
    }

    user = accountUser;
    fullnameController.text = user!.fullname;
    emailController.text = user!.email;
    phoneController.text = user!.phone ?? '';
    selectedCity = user!.city;
    selectedDistrict = user!.district;
    selectedWard = user!.ward;

    await _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    _isLoadingCity = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    if (_locationCache.provinces.isEmpty) {
      await _executeApiCall(
        apiCall: () => locationRepository.getProvinces(),
        errorPrefix: 'Failed to load provinces',
        onSuccess: (data) {
          _locationCache.setProvinces(data as List<Province>);
          selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
        },
      );
    } else {
      selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
    }

    await _loadDistricts();
    _isLoadingCity = false;
    notifyListeners();
  }

  Future<void> _loadDistricts() async {
    if (selectedCity == null) return;
    _isLoadingDistrict = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    final provinceCode = _getProvinceCode(selectedCity);
    if (_locationCache.getDistricts(provinceCode).isEmpty) {
      await _executeApiCall(
        apiCall: () => locationRepository.getDistricts(provinceCode: provinceCode),
        errorPrefix: 'Failed to load districts',
        onSuccess: (data) {
          _locationCache.setDistricts(provinceCode, data as List<District>);
          selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
        },
      );
    } else {
      selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
    }

    await _loadWards();
    _isLoadingDistrict = false;
    notifyListeners();
  }

  Future<void> _loadWards() async {
    if (selectedDistrict == null) return;
    _isLoadingWard = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    final districtCode = _getDistrictCode(selectedDistrict);
    if (_locationCache.getWards(districtCode).isEmpty) {
      await _executeApiCall(
        apiCall: () => locationRepository.getWards(districtCode: districtCode),
        errorPrefix: 'Failed to load wards',
        onSuccess: (data) {
          _locationCache.setWards(districtCode, data as List<Ward>);
          selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
          _updateDataLoadedStatus();
        },
      );
    } else {
      selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
      _updateDataLoadedStatus();
    }

    _isLoadingWard = false;
    notifyListeners();
  }

  void _updateDataLoadedStatus() {
    _isDataLoaded = provinces.isNotEmpty && districts.isNotEmpty && wards.isNotEmpty && _errorState.errorMessage == null;
  }

  String _getProvinceCode(String? provinceName) {
    if (provinceName == null) return '';
    return provinces.firstWhere(
      (p) => p.name == provinceName,
      orElse: () => provinces.isNotEmpty ? provinces[0] : Province(),
    ).code?.toString() ?? '';
  }

  String _getDistrictCode(String? districtName) {
    if (districtName == null) return '';
    return districts.firstWhere(
      (d) => d.name == districtName,
      orElse: () => districts.isNotEmpty ? districts[0] : District(),
    ).code?.toString() ?? '';
  }

  void setCity(String? city) {
    if (city != selectedCity) {
      selectedCity = city;
      selectedDistrict = null;
      selectedWard = null;
      _isLoadingDistrict = true;
      _isLoadingWard = true;
      _loadDistricts();
    }
    notifyListeners();
  }

  void setDistrict(String? district) {
    if (district != selectedDistrict) {
      selectedDistrict = district;
      selectedWard = null;
      _isLoadingWard = true;
      _loadWards();
    }
    notifyListeners();
  }

  void setWard(String? ward) {
    selectedWard = ward;
    notifyListeners();
  }

  Future<void> handleUpdate(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    final userId = user?.id;
    if (userId == null || userId.isEmpty) {
      _errorState.errorTitle = 'Error';
      _errorState.errorMessage = 'User ID is missing. Please try again.';
      _isUpdateSuccessful = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isUpdateSuccessful = false;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    await _executeApiCall(
      apiCall: () => userRepository.editUser(
        userId,
        fullname: fullnameController.text,
        phone: phoneController.text,
        city: selectedCity,
        district: selectedDistrict,
        ward: selectedWard,
      ),
      errorPrefix: 'Failed to update profile',
      onSuccess: (updatedUser) {
        try {
          context.read<SessionManager>().setUser(updatedUser as User);
          user = updatedUser;
          _isUpdateSuccessful = true;
          ErrorHandler.clearError(_errorState);
        } catch (e) {
          _errorState.errorTitle = 'Error';
          _errorState.errorMessage = 'Failed to access session manager: $e';
          _isUpdateSuccessful = false;
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadAvatar(BuildContext context, File imageFile) async {
    _isUploadingAvatar = true;
    _isUpdateSuccessful = false;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    await _executeApiCall(
      apiCall: () async {
        final multipartFile = await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last);
        return userRepository.editAvatar(file: multipartFile);
      },
      errorPrefix: 'Failed to upload avatar',
      onSuccess: (updatedUser) {
        try {
          context.read<SessionManager>().setUser(updatedUser as User);
          user = updatedUser;
          _isUpdateSuccessful = true;
          ErrorHandler.clearError(_errorState);
        } catch (e) {
          _isUpdateSuccessful = false;
          rethrow;
        }
      },
    );

    _isUploadingAvatar = false;
    notifyListeners();
  }

  Future<void> _executeApiCall({
    required Future<dynamic> Function() apiCall,
    required String errorPrefix,
    required void Function(dynamic data) onSuccess,
  }) async {
    final errorState = ErrorState();
    try {
      final result = await apiCall();
      onSuccess(result);
    } catch (e) {
      ErrorHandler.handleError(e, errorPrefix, errorState);
      _isUpdateSuccessful = false;
      notifyListeners();
      rethrow;
    }
  }


  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }

  void clearUpdateStatus() {
    _isUpdateSuccessful = false;
    notifyListeners();
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}