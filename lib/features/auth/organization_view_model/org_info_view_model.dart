import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/data/models/location.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'dart:io';

class OrgInfoViewModel extends ChangeNotifier {
  final OrganizerRepository organizerRepository;
  final SessionManager sessionManager;
  final LocationRepository locationRepository;
  final LocationCache locationCache = GetIt.instance<LocationCache>();
  final ErrorState errorState = ErrorState();

  bool isLoading = false;
  bool get getIsLoading => isLoading;

  bool isDataLoaded = false;
  bool get getIsDataLoaded => isDataLoaded;

  bool isLoadingCity = false;
  bool get getIsLoadingCity => isLoadingCity;

  bool isLoadingDistrict = false;
  bool get getIsLoadingDistrict => isLoadingDistrict;

  bool isLoadingWard = false;
  bool get getIsLoadingWard => isLoadingWard;

  bool isUploadingLogo = false;
  bool get getIsUploadingLogo => isUploadingLogo;

  bool get getIsLoadingAnyLocation => isLoadingCity || isLoadingDistrict || isLoadingWard;

  bool isUpdateSuccessful = false;
  bool get getIsUpdateSuccessful => isUpdateSuccessful;

  Organizer? organizer;
  Organizer? get getOrganizer => organizer;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();
  final facebookController = TextEditingController();
  final twitterController = TextEditingController();
  final linkedinController = TextEditingController();
  final instagramController = TextEditingController();

  List<Province> get provinces => locationCache.provinces;
  List<District> get districts => locationCache.getDistricts(getProvinceCode(selectedCity));
  List<Ward> get wards => locationCache.getWards(getDistrictCode(selectedDistrict));

  String? selectedCountry = 'Việt Nam';
  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  String? get errorMessage => errorState.errorMessage;
  String? get errorTitle => errorState.errorTitle;

  OrgInfoViewModel(this.organizerRepository, this.sessionManager, this.locationRepository) {
    if (sessionManager.selectedOrganizerId != null) {
      loadOrganizer();
    }
  }

  Future<void> loadOrganizer() async {
    if (sessionManager.selectedOrganizerId == null) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Vui lòng chọn một nhà tổ chức trước';
      isDataLoaded = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    try {
      organizer = await organizerRepository.getDetail(sessionManager.selectedOrganizerId!);
      nameController.text = organizer!.name;
      emailController.text = organizer!.email;
      phoneController.text = organizer!.phone ?? '';
      descriptionController.text = organizer!.description ?? '';
      facebookController.text = organizer!.facebook ?? '';
      twitterController.text = organizer!.twitter ?? '';
      linkedinController.text = organizer!.linkedin ?? '';
      instagramController.text = organizer!.instagram ?? '';
      selectedCountry = organizer!.country ?? 'Việt Nam';
      selectedCity = organizer!.city;
      selectedDistrict = organizer!.district;
      selectedWard = organizer!.ward;

      await loadLocationData();
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi', errorState);
      isDataLoaded = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocationData() async {
    isLoadingCity = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    if (locationCache.provinces.isEmpty) {
      await executeApiCall(
        apiCall: () => locationRepository.getProvinces(),
        errorPrefix: 'Lỗi',
        onSuccess: (data) {
          locationCache.setProvinces(data as List<Province>);
          selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
        },
      );
    } else {
      selectedCity ??= provinces.isNotEmpty ? provinces[0].name : null;
    }

    await loadDistricts();
    isLoadingCity = false;
    notifyListeners();
  }

  Future<void> loadDistricts() async {
    if (selectedCity == null) return;
    isLoadingDistrict = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final provinceCode = getProvinceCode(selectedCity);
    if (locationCache.getDistricts(provinceCode).isEmpty) {
      await executeApiCall(
        apiCall: () => locationRepository.getDistricts(provinceCode: provinceCode),
        errorPrefix: 'Lỗi',
        onSuccess: (data) {
          locationCache.setDistricts(provinceCode, data as List<District>);
          selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
        },
      );
    } else {
      selectedDistrict ??= districts.isNotEmpty ? districts[0].name : null;
    }

    await loadWards();
    isLoadingDistrict = false;
    notifyListeners();
  }

  Future<void> loadWards() async {
    if (selectedDistrict == null) return;
    isLoadingWard = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final districtCode = getDistrictCode(selectedDistrict);
    if (locationCache.getWards(districtCode).isEmpty) {
      await executeApiCall(
        apiCall: () => locationRepository.getWards(districtCode: districtCode),
        errorPrefix: 'Lỗi',
        onSuccess: (data) {
          locationCache.setWards(districtCode, data as List<Ward>);
          selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
          updateDataLoadedStatus();
        },
      );
    } else {
      selectedWard ??= wards.isNotEmpty ? wards[0].name : null;
      updateDataLoadedStatus();
    }

    isLoadingWard = false;
    notifyListeners();
  }

  void updateDataLoadedStatus() {
    isDataLoaded = provinces.isNotEmpty && districts.isNotEmpty && wards.isNotEmpty && errorState.errorMessage == null;
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

  void setCity(String? city) {
    if (city != selectedCity) {
      selectedCity = city;
      selectedDistrict = null;
      selectedWard = null;
      isLoadingDistrict = true;
      isLoadingWard = true;
      loadDistricts();
    }
    notifyListeners();
  }

  void setDistrict(String? district) {
    if (district != selectedDistrict) {
      selectedDistrict = district;
      selectedWard = null;
      isLoadingWard = true;
      loadWards();
    }
    notifyListeners();
  }

  void setWard(String? ward) {
    selectedWard = ward;
    notifyListeners();
  }

  Future<void> handleUpdate(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    final organizerId = sessionManager.selectedOrganizerId;
    if (organizerId == null || organizerId.isEmpty) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Lỗi dữ liệu. Hãy thử lại.';
      isUpdateSuccessful = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    isUpdateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    await executeApiCall(
      apiCall: () => organizerRepository.edit(
        organizerId,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        description: descriptionController.text,
        country: selectedCountry,
        city: selectedCity,
        district: selectedDistrict,
        ward: selectedWard,
        facebook: facebookController.text.isEmpty ? null : facebookController.text,
        twitter: twitterController.text.isEmpty ? null : twitterController.text,
        linkedin: linkedinController.text.isEmpty ? null : linkedinController.text,
        instagram: instagramController.text.isEmpty ? null : instagramController.text,
      ),
      errorPrefix: 'Lỗi',
      onSuccess: (updatedOrganizer) {
        organizer = updatedOrganizer as Organizer;
        sessionManager.setSelectedOrganizerDetails(
          organizerId: organizerId,
          name: organizer!.name,
          logo: organizer!.logo,
          email: organizer!.email,
        );
        isUpdateSuccessful = true;
        ErrorHandler.clearError(errorState);
      },
    );

    isLoading = false;
    notifyListeners();
  }

  Future<void> uploadLogo(BuildContext context, File imageFile) async {
    isUploadingLogo = true;
    isUpdateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    final organizerId = sessionManager.selectedOrganizerId;
    if (organizerId == null || organizerId.isEmpty) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Lỗi dữ liệu. Hãy thử lại.';
      isUploadingLogo = false;
      notifyListeners();
      return;
    }

    await executeApiCall(
      apiCall: () async {
        final multipartFile = await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last);
        return organizerRepository.editThumbnail(id: organizerId, file: multipartFile);
      },
      errorPrefix: 'Lỗi',
      onSuccess: (updatedOrganizer) {
        organizer = updatedOrganizer as Organizer;
        sessionManager.setSelectedOrganizerDetails(
          organizerId: organizerId,
          name: organizer!.name,
          logo: organizer!.logo,
          email: organizer!.email,
        );
        isUpdateSuccessful = true;
        ErrorHandler.clearError(errorState);
      },
    );

    isUploadingLogo = false;
    notifyListeners();
  }

  Future<void> executeApiCall({
    required Future<dynamic> Function() apiCall,
    required String errorPrefix,
    required void Function(dynamic data) onSuccess,
  }) async {
    try {
      final result = await apiCall();
      onSuccess(result);
    } catch (e) {
      ErrorHandler.handleError(e, errorPrefix, errorState);
      isUpdateSuccessful = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    ErrorHandler.clearError(errorState);
    notifyListeners();
  }

  void clearUpdateStatus() {
    isUpdateSuccessful = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    facebookController.dispose();
    twitterController.dispose();
    linkedinController.dispose();
    instagramController.dispose();
    super.dispose();
  }
}