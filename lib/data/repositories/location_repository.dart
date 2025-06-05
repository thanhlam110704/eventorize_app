import 'package:eventorize_app/data/api/location_api.dart';
import 'package:eventorize_app/data/models/location.dart';

class LocationRepository {
  final LocationApi _locationApi;

  LocationRepository(this._locationApi);

  Future<List<Province>> getProvinces() async {
    return await _locationApi.getProvinces();
  }

  Future<List<District>> getDistricts({
    required String provinceCode,
  }) async {
    return await _locationApi.getDistricts(provinceCode);
  }

  Future<List<Ward>> getWards({
    required String districtCode,
  }) async {
    return await _locationApi.getWards(districtCode);
  }
}