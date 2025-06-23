import 'package:eventorize_app/data/models/location.dart';

class LocationCache {
  static final LocationCache _instance = LocationCache._internal();
  factory LocationCache() => _instance;
  LocationCache._internal();

  List<Province> _provinces = [];
  final Map<String, List<District>> _districtsByProvince = {};
  final Map<String, List<Ward>> _wardsByDistrict = {};

  List<Province> get provinces => _provinces;
  List<District> getDistricts(String provinceCode) => _districtsByProvince[provinceCode] ?? [];
  List<Ward> getWards(String districtCode) => _wardsByDistrict[districtCode] ?? [];

  void setProvinces(List<Province> provinces) {
    _provinces = provinces;
  }

  void setDistricts(String provinceCode, List<District> districts) {
    _districtsByProvince[provinceCode] = districts;
  }

  void setWards(String districtCode, List<Ward> wards) {
    _wardsByDistrict[districtCode] = wards;
  }

  void clear() {
    _provinces = [];
    _districtsByProvince.clear();
    _wardsByDistrict.clear();
  }
}