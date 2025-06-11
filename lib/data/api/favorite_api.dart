import 'package:dio/dio.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/data/models/favorite.dart';

class FavoriteApi {
  final DioClient _dioClient;

  FavoriteApi(this._dioClient);

  Future<Favorite> getMyFavoriteEvents() async {
    try {
      final response = await _dioClient.get(ApiUrl.getFavorites);
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch favorite events: $errorMessage');
    } catch (e) {
      throw Exception('Failed to fetch favorite events: $e');
    }
  }

  Future<Favorite> addEventFavorite({required String eventId}) async {
    try {
      final response = await _dioClient.post(ApiUrl.addEventFavorite(eventId),);
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to create favorite: $errorMessage');
    } catch (e) {
      throw Exception('Failed to create favorite: $e');
    }
  }

  Future<Favorite> removeEventFavorite({required String eventId}) async {
    try {
      final response = await _dioClient.delete(ApiUrl.removeEventFavorite(eventId));
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to delete favorite: $errorMessage');
    } catch (e) {
      throw Exception('Failed to delete favorite: $e');
    }
  }
}