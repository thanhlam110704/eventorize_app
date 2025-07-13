import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/data/models/location.dart';

class LocationApi {
  final DioClient _dioClient;

  LocationApi(this._dioClient);

  Future<List<Province>> getProvinces() async {
    final response = await _dioClient.get(ApiUrl.getProvinces);
    final data = response.data as Map<String, dynamic>?;
    if (data == null || !data.containsKey('results')) {
      throw Exception('Dữ liệu trả về trống hoặc không hợp lệ');
    }
    return (data['results'] as List)
        .map((json) => Province.fromJson(json))
        .toList();
  }

  Future<List<District>> getDistricts(String provinceCode) async {
    final response = await _dioClient.get(
      ApiUrl.getDistricts,
      queryParameters: {'province_code': provinceCode},
    );
    final data = response.data as Map<String, dynamic>?;
    if (data == null || !data.containsKey('districts')) {
      throw Exception('Dữ liệu trả về trống hoặc không hợp lệ');
    }
    return (data['districts'] as List)
        .map((json) => District.fromJson(json))
        .toList();
  }

  Future<List<Ward>> getWards(String districtCode) async {
    final response = await _dioClient.get(
      ApiUrl.getWards,
      queryParameters: {'district_code': districtCode},
    );
    final data = response.data as Map<String, dynamic>?;
    if (data == null || !data.containsKey('wards')) {
      throw Exception('Dữ liệu trả về trống hoặc không hợp lệ');
    }
    return (data['wards'] as List)
        .map((json) => Ward.fromJson(json))
        .toList();
  }
}