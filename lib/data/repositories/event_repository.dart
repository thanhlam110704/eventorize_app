import 'package:dio/dio.dart';
import 'package:eventorize_app/data/api/event_api.dart';
import 'package:eventorize_app/data/models/event.dart';

class EventRepository {
  final EventApi _eventApi;

  EventRepository(this._eventApi);

  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
  }) async {
    return await _eventApi.getAll(
      page: page,
      limit: limit,
      query: query,
      search: search,
      fields: fields,
      sortBy: sortBy,
      orderBy: orderBy,
    );
  }

  Future<Event> getEventDetail(String id, {String? fields}) async {
    return await _eventApi.getEventDetail(id, fields: fields);
  }

  Future<Event> createEvent({
    required String organizerId,
    required String title,
    String? description,
    String? link,
    required DateTime startDate,
    required DateTime endDate,
    required bool isOnline,
    String? address,
    String? district,
    String? ward,
    String? city,
    String? country,
    MultipartFile? thumbnailFile,
    String? thumbnailUrl,
  }) async {
    return await _eventApi.createEvent(
      organizerId: organizerId,
      title: title,
      description: description,
      link: link,
      startDate: startDate,
      endDate: endDate,
      isOnline: isOnline,
      address: address,
      district: district,
      ward: ward,
      city: city,
      country: country,
      thumbnailFile: thumbnailFile,
      thumbnailUrl: thumbnailUrl,
    );
  }

  Future<Event> editEvent(
    String id, {
    String? title,
    String? description,
    String? link,
    DateTime? startDate,
    DateTime? endDate,
    bool? isOnline,
    String? address,
    String? district,
    String? ward,
    String? city,
    String? country,
  }) async {
    return await _eventApi.editEvent(
      id,
      title: title,
      description: description,
      link: link,
      startDate: startDate,
      endDate: endDate,
      isOnline: isOnline,
      address: address,
      district: district,
      ward: ward,
      city: city,
      country: country,
    );
  }

  Future<Event> editThumbnail({
    required String id,
    MultipartFile? thumbnailFile,
    String? thumbnailUrl,
  }) async {
    return await _eventApi.editThumbnail(
      id: id,
      thumbnailFile: thumbnailFile,
      thumbnailUrl: thumbnailUrl,
    );
  }

  Future<void> deleteEvent(String id) async {
    await _eventApi.deleteEvent(id);
  }

  Future<List<Event>> getEventsByOrganizerId(String organizerId) async {
    return await _eventApi.getEventsByOrganizerId(organizerId);
  }
}