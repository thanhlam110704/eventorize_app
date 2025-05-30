import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/common/services/location_cache.dart';

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
        () => locationRepository.getProvinces(),
        'Failed to load provinces',
        (data) {
          _locationCache.setProvinces(data as List<Province>);
          if (selectedCity == null && provinces.isNotEmpty) {
            selectedCity = provinces[0].name;
          }
        },
      );
    } else if (selectedCity == null && provinces.isNotEmpty) {
      selectedCity = provinces[0].name;
    }

    await _loadDistricts(selectedCity);
    _isLoadingCity = false;
    notifyListeners();
  }

  Future<void> _loadDistricts(String? provinceName) async {
    if (provinceName == null) return;
    final provinceCode = _getProvinceCode(provinceName);

    _isLoadingDistrict = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    // Load districts from cache or API
    if (_locationCache.getDistricts(provinceCode).isEmpty) {
      await _executeApiCall(
        () => locationRepository.getDistricts(provinceCode: provinceCode),
        'Failed to load districts',
        (data) {
          _locationCache.setDistricts(provinceCode, data as List<District>);
          if (selectedDistrict == null && districts.isNotEmpty) {
            selectedDistrict = districts[0].name;
          }
        },
      );
    } else if (selectedDistrict == null && districts.isNotEmpty) {
      selectedDistrict = districts[0].name;
    }

    await _loadWards(selectedDistrict);
    _isLoadingDistrict = false;
    notifyListeners();
  }

  Future<void> _loadWards(String? districtName) async {
    if (districtName == null) return;
    final districtCode = _getDistrictCode(districtName);

    _isLoadingWard = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    // Load wards from cache or API
    if (_locationCache.getWards(districtCode).isEmpty) {
      await _executeApiCall(
        () => locationRepository.getWards(districtCode: districtCode),
        'Failed to load wards',
        (data) {
          _locationCache.setWards(districtCode, data as List<Ward>);
          if (selectedWard == null && wards.isNotEmpty) {
            selectedWard = wards[0].name;
          }
          if (provinces.isNotEmpty && districts.isNotEmpty && wards.isNotEmpty && _errorState.errorMessage == null) {
            _isDataLoaded = true;
          }
        },
      );
    } else if (selectedWard == null && wards.isNotEmpty) {
      selectedWard = wards[0].name;
      if (provinces.isNotEmpty && districts.isNotEmpty && wards.isNotEmpty && _errorState.errorMessage == null) {
        _isDataLoaded = true;
      }
    }

    _isLoadingWard = false;
    notifyListeners();
  }

  String _getProvinceCode(String? provinceName) {
    if (provinceName == null) return '';
    final province = provinces.firstWhere(
      (p) => p.name == provinceName,
      orElse: () => provinces.isNotEmpty ? provinces[0] : Province(),
    );
    return province.code?.toString() ?? '';
  }

  String _getDistrictCode(String? districtName) {
    if (districtName == null) return '';
    final district = districts.firstWhere(
      (d) => d.name == districtName,
      orElse: () => districts.isNotEmpty ? districts[0] : District(),
    );
    return district.code?.toString() ?? '';
  }

  void setCity(String? city) {
    if (city != selectedCity) {
      selectedCity = city;
      selectedDistrict = null;
      selectedWard = null;
      _isLoadingDistrict = true;
      _isLoadingWard = true;
      _loadDistricts(city);
    }
    notifyListeners();
  }

  void setDistrict(String? district) {
    if (district != selectedDistrict) {
      selectedDistrict = district;
      selectedWard = null;
      _isLoadingWard = true;
      _loadWards(district);
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
      () async {
        final updatedUser = await userRepository.editUser(
          userId,
          fullname: fullnameController.text,
          phone: phoneController.text,
          city: selectedCity,
          district: selectedDistrict,
          ward: selectedWard,
        );
        return updatedUser;
      },
      'Failed to update profile',
      (updatedUser) {
        try {
          final sessionManager = context.read<SessionManager>();
          sessionManager.setUser(updatedUser as User);
          user = updatedUser;
          _isUpdateSuccessful = true;
          ErrorHandler.clearError(_errorState);
        } catch (e) {
          _errorState.errorTitle = 'Error';
          _errorState.errorMessage = 'Failed to access session manager: $e';
          _isUpdateSuccessful = false;
        }
        notifyListeners();
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _executeApiCall(
    Future<dynamic> Function() apiCall,
    String errorPrefix,
    void Function(dynamic data) onSuccess,
  ) async {
    try {
      final result = await apiCall();
      onSuccess(result);
    } catch (e) {
      ErrorHandler.handleError(e, errorPrefix, _errorState);
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