import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/data/models/favorite.dart';

class FavoriteApi {
  final DioClient _dioClient;

  FavoriteApi(this._dioClient);

  Future<Favorite> getMyFavoriteEvents() async {
    final response = await _dioClient.get(ApiUrl.getMyFavoriteEvents);
    return Favorite.fromJson(response.data);
  }

  Future<Favorite> addEventFavorite({required String eventId}) async {
    final response = await _dioClient.post(ApiUrl.addEventFavorite(eventId));
    return Favorite.fromJson(response.data);
  }

  Future<Favorite> removeEventFavorite({required String eventId}) async {
    final response = await _dioClient.delete(ApiUrl.removeEventFavorite(eventId));
    return Favorite.fromJson(response.data);
  }
}