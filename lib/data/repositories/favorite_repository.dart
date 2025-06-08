import 'package:eventorize_app/data/api/favorite_api.dart';
import 'package:eventorize_app/data/models/favorite.dart';

class FavoriteRepository {
  final FavoriteApi _favoriteApi;

  FavoriteRepository(this._favoriteApi);

  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? orderBy,
  }) async {
    return await _favoriteApi.getAll(
      page: page,
      limit: limit,
      sortBy: sortBy,
      orderBy: orderBy,
    );
  }

  Future<Favorite> create({
    required String eventId,
  }) async {
    return await _favoriteApi.create(
      eventId: eventId,
    );
  }

  Future<void> delete(String id) async {
    await _favoriteApi.delete(id);
  }
}