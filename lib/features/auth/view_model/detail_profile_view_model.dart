import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';

class DetailProfileViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final LocationRepository locationRepository;
  final ErrorState _errorState = ErrorState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDataLoaded = false;
  bool get isDataLoaded => _isDataLoaded;

  bool _isInitialLoad = true;
  bool get isInitialLoad => _isInitialLoad;

  bool _isUpdateSuccessful = false;
  bool get isUpdateSuccessful => _isUpdateSuccessful;

  bool _isLoadingCity = false;
  bool get isLoadingCity => _isLoadingCity;

  bool _isLoadingDistrict = false;
  bool get isLoadingDistrict => _isLoadingDistrict;

  bool _isLoadingWard = false;
  bool get isLoadingWard => _isLoadingWard;

  bool get isLoadingAnyLocation => _isLoadingCity || _isLoadingDistrict || _isLoadingWard;

  User? user;
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  List<Province> _provinces = [];
  List<Province> get provinces => _provinces;

  List<District> _districts = [];
  List<District> get districts => _districts;

  List<Ward> _wards = [];
  List<Ward> get wards => _wards;

  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  DetailProfileViewModel(this.userRepository, this.locationRepository);

  Future<void> loadUser(User? accountUser) async {
    _isInitialLoad = true;
    notifyListeners();

    user = accountUser;
    if (user != null) {
      fullnameController.text = user!.fullname;
      emailController.text = user!.email;
      phoneController.text = user!.phone ?? '';
      selectedCity = user!.city;
      selectedDistrict = user!.district;
      selectedWard = user!.ward;
    }
    await _loadLocationData();

    _isInitialLoad = false;
    notifyListeners();
  }

  Future<void> _loadLocationData() async {
    _isLoadingCity = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    await _executeApiCall(
      () => locationRepository.getProvinces(),
      'Failed to load provinces',
      (data) {
        _provinces = data as List<Province>;
        if (selectedCity == null && _provinces.isNotEmpty) {
          selectedCity = _provinces[0].name;
        }
        _loadDistricts(selectedCity);
      },
    );

    _isLoadingCity = false;
    notifyListeners();
  }

  Future<void> _loadDistricts(String? provinceName) async {
    if (provinceName == null) return;
    final province = _provinces.firstWhere((p) => p.name == provinceName, orElse: () => _provinces[0]);

    _isLoadingDistrict = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    await _executeApiCall(
      () => locationRepository.getDistricts(provinceCode: province.code.toString()),
      'Failed to load districts',
      (data) {
        _districts = data as List<District>;
        if (selectedDistrict == null && _districts.isNotEmpty) {
          selectedDistrict = _districts[0].name;
        }
        _loadWards(selectedDistrict);
      },
    );

    _isLoadingDistrict = false;
    notifyListeners();
  }

  Future<void> _loadWards(String? districtName) async {
    if (districtName == null) return;
    final district = _districts.firstWhere((d) => d.name == districtName, orElse: () => _districts[0]);

    _isLoadingWard = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    await _executeApiCall(
      () => locationRepository.getWards(districtCode: district.code.toString()),
      'Failed to load wards',
      (data) {
        _wards = data as List<Ward>;
        if (selectedWard == null && _wards.isNotEmpty) {
          selectedWard = _wards[0].name;
        }
        // Set _isDataLoaded only after all data is loaded
        if (_provinces.isNotEmpty && _districts.isNotEmpty && _wards.isNotEmpty && _errorState.errorMessage == null) {
          _isDataLoaded = true;
        }
      },
    );

    _isLoadingWard = false;
    notifyListeners();
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