import 'package:dio/dio.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/models/event.dart';

class EventApi {
  final DioClient _dioClient;

  EventApi(this._dioClient);

  Map<String, dynamic> _buildQueryParams({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (query != null) 'query': query,
      if (search != null) 'search': search,
      if (fields != null) 'fields': fields,
      if (sortBy != null) 'sort_by': sortBy,
      if (orderBy != null) 'order_by': orderBy,
    };
  }

  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getEvents,
        queryParameters: _buildQueryParams(
          page: page,
          limit: limit,
          query: query,
          search: search,
          fields: fields,
          sortBy: sortBy,
          orderBy: orderBy,
        ),
      );
      return {
        'data': (response.data['results'] as List)
            .map((json) => Event.fromJson(json))
            .toList(),
        'total': response.data['total_items'] as int,
        'total_page': response.data['total_page'] as int,
        'records_per_page': response.data['records_per_page'] as int,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch events: $errorMessage');
    }
  }

  Future<Event> getEventDetail(String id, {String? fields}) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getEventDetail(id),
        queryParameters: fields != null ? {'fields': fields} : null,
      );
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch event detail: $errorMessage');
    }
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
    try {
      final data = FormData.fromMap({
        'organizer_id': organizerId,
        'title': title,
        'description': description,
        'link': link,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_online': isOnline,
        'address': address,
        'district': district,
        'ward': ward,
        'city': city,
        'country': country,
        if (thumbnailUrl != null) 'thumbnail': thumbnailUrl,
      });

      if (thumbnailFile != null) {
        data.files.add(MapEntry('file', thumbnailFile));
      }

      final response = await _dioClient.post(
        ApiUrl.createEvent,
        data: data,
      );
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to create event: $errorMessage');
    }
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
    try {
      final response = await _dioClient.put(
        ApiUrl.editEvent(id),
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (link != null) 'link': link,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (isOnline != null) 'is_online': isOnline,
          if (address != null) 'address': address,
          if (district != null) 'district': district,
          if (ward != null) 'ward': ward,
          if (city != null) 'city': city,
          if (country != null) 'country': country,
        },
      );
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to update event: $errorMessage');
    }
  }

  Future<Event> editThumbnail({
    required String id,
    MultipartFile? thumbnailFile,
    String? thumbnailUrl,
  }) async {
    try {
      final data = FormData();
      if (thumbnailFile != null) {
        data.files.add(MapEntry('file', thumbnailFile));
      }
      if (thumbnailUrl != null) {
        data.fields.add(MapEntry('image_url', thumbnailUrl));
      }

      final response = await _dioClient.put(
        ApiUrl.editEventThumbnail(id),
        data: data,
      );
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to update event thumbnail: $errorMessage');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _dioClient.delete(ApiUrl.deleteEvent(id));
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to delete event: $errorMessage');
    }
  }

  Future<List<Event>> getEventsByOrganizerId(String organizerId) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getEvents,
        queryParameters: {'query': 'organizer_id=$organizerId'},
      );
      return (response.data['results'] as List)
          .map((json) => Event.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch events by organizer: $errorMessage');
    }
  }
}