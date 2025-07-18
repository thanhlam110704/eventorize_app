import 'package:dio/dio.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/data/models/favorite.dart';

class FavoriteApi {
  final DioClient _dioClient;

  FavoriteApi(this._dioClient);

  Future<Favorite> getMyFavoriteEvents() async {
    try {
      final response = await _dioClient.get(ApiUrl.getMyFavoriteEvents);
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception('Lấy danh sách sự kiện yêu thích thất bại: $errorMessage');
    } catch (e) {
      throw Exception('Lấy danh sách sự kiện yêu thích thất bại: $e');
    }
  }

  Future<Favorite> addEventFavorite({required String eventId}) async {
    try {
      final response = await _dioClient.post(ApiUrl.addEventFavorite(eventId));
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception('Thêm sự kiện yêu thích thất bại: $errorMessage');
    } catch (e) {
      throw Exception('Thêm sự kiện yêu thích thất bại: $e');
    }
  }

  Future<Favorite> removeEventFavorite({required String eventId}) async {
    try {
      final response = await _dioClient.delete(ApiUrl.removeEventFavorite(eventId));
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception('Xóa sự kiện yêu thích thất bại: $errorMessage');
    } catch (e) {
      throw Exception('Xóa sự kiện yêu thích thất bại: $e');
    }
  }
}