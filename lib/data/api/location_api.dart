import 'package:dio/dio.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/data/models/location.dart';

class LocationApi {
  final DioClient _dioClient;

  LocationApi(this._dioClient);

  Future<List<Province>> getProvinces() async {
    try {
      final response = await _dioClient.get(ApiUrl.getProvinces);
      final data = response.data as Map<String, dynamic>?;
      if (data == null || !data.containsKey('results')) {
        throw Exception('Failed to fetch provinces: Empty or invalid response data');
      }
      return (data['results'] as List)
          .map((json) => Province.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch provinces: $errorMessage');
    }
  }

  Future<List<District>> getDistricts(String provinceCode) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getDistricts,
        queryParameters: {'province_code': provinceCode},
      );
      final data = response.data as Map<String, dynamic>?;
      if (data == null || !data.containsKey('districts')) {
        throw Exception('Failed to fetch districts: Empty or invalid response data');
      }
      return (data['districts'] as List)
          .map((json) => District.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch districts: $errorMessage');
    }
  }

  Future<List<Ward>> getWards(String districtCode) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getWards,
        queryParameters: {'district_code': districtCode},
      );
      final data = response.data as Map<String, dynamic>?;
      if (data == null || !data.containsKey('wards')) {
        throw Exception('Failed to fetch wards: Empty or invalid response data');
      }
      return (data['wards'] as List)
          .map((json) => Ward.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch wards: $errorMessage');
    }
  }
}