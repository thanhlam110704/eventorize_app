import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
import 'dart:developer' as developer;
import 'package:eventorize_app/common/services/session_manager.dart';
import 'dart:io';

class CreateOrgViewModel extends ChangeNotifier {
  final OrganizerRepository _organizerRepository;
  final SessionManager _sessionManager;
  final ErrorState _errorState = ErrorState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  CreateOrgViewModel({
    required OrganizerRepository organizerRepository,
    required SessionManager sessionManager,
  })  : _organizerRepository = organizerRepository,
        _sessionManager = sessionManager;

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

  void setImage(MultipartFile? image, File? imageFile) {
    _selectedImage = image;
    _imageFile = imageFile;
    notifyListeners();
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
      developer.log('Server response: ${e.response!.data}');
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
        _description?.isNotEmpty == true;
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}