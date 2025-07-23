import 'package:eventorize_app/data/api/favorite_api.dart';
import 'package:eventorize_app/data/models/favorite.dart';

class FavoriteRepository {
  final FavoriteApi _favoriteApi;

  FavoriteRepository(this._favoriteApi);

  Future<Favorite> getMyFavoriteEvents() async {
    return await _favoriteApi.getMyFavoriteEvents();
  }

  Future<Favorite> addEventFavorite({
    required String eventId,
  }) async {
    return await _favoriteApi.addEventFavorite(eventId: eventId);
  }

  Future<Favorite> removeEventFavorite({
    required String eventId,
  }) async {
    return await _favoriteApi.removeEventFavorite(eventId: eventId);
  }
}