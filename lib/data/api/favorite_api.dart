import 'package:dio/dio.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/data/models/favorite.dart';

class FavoriteApi {
  final DioClient _dioClient;

  FavoriteApi(this._dioClient);

  Map<String, dynamic> _buildQueryParams({
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? orderBy,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (sortBy != null) 'sort_by': sortBy,
      if (orderBy != null) 'order_by': orderBy,
    };
  }

  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? orderBy,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getFavorites,
        queryParameters: _buildQueryParams(
          page: page,
          limit: limit,
          sortBy: sortBy,
          orderBy: orderBy,
        ),
      );
      return {
        'data': (response.data['results'] as List)
            .map((json) {
              try {
                return Favorite.fromJson(json);
              } catch (e) {
                print('Error parsing favorite: $e, JSON: $json');
                rethrow;
              }
            })
            .toList(),
        'total': response.data['total_items'] as int,
        'total_page': response.data['total_page'] as int,
        'records_per_page': response.data['records_per_page'] as int,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch favorites: $errorMessage');
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  Future<Favorite> create({
    required String eventId,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiUrl.createFavorite(eventId),
      );
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to create favorite: $errorMessage');
    } catch (e) {
      throw Exception('Failed to create favorite: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dioClient.delete(ApiUrl.deleteFavorite(id));
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to delete favorite: $errorMessage');
    }
  }
}