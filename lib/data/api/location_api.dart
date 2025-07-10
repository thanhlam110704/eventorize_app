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
        throw Exception('Lấy danh sách tỉnh/thành thất bại: Dữ liệu trả về trống hoặc không hợp lệ');
      }
      return (data['results'] as List)
          .map((json) => Province.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception('Lấy danh sách tỉnh/thành thất bại: $errorMessage');
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
        throw Exception('Lấy danh sách quận/huyện thất bại: Dữ liệu trả về trống hoặc không hợp lệ');
      }
      return (data['districts'] as List)
          .map((json) => District.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception('Lấy danh sách quận/huyện thất bại: $errorMessage');
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
        throw Exception('Lấy danh sách phường/xã thất bại: Dữ liệu trả về trống hoặc không hợp lệ');
      }
      return (data['wards'] as List)
          .map((json) => Ward.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception('Lấy danh sách phường/xã thất bại: $errorMessage');
    }
  }
}