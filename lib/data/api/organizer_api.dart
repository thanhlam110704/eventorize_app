import 'package:dio/dio.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/models/organizer.dart';

class OrganizerApi {
  final DioClient _dioClient;

  OrganizerApi(this._dioClient);

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
    final response = await _dioClient.get(
      ApiUrl.getOrganizers,
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
          .map((json) => Organizer.fromJson(json))
          .toList(),
      'total': response.data['total_items'] as int,
      'total_page': response.data['total_page'] as int,
      'records_per_page': response.data['records_per_page'] as int,
    };
  }

  Future<List<Organizer>> exportOrganizers() async {
    final response = await _dioClient.get(ApiUrl.exportOrganizers);
    return (response.data as List)
        .map((json) => Organizer.fromJson(json))
        .toList();
  }

  Future<Organizer> getDetail(String id, {String? fields}) async {
    final response = await _dioClient.get(
      ApiUrl.getOrganizerDetail(id),
      queryParameters: fields != null ? {'fields': fields} : null,
    );
    return Organizer.fromJson(response.data);
  }

  Future<Organizer> getDetailPublic(String id, {String? fields}) async {
    final response = await _dioClient.get(
      ApiUrl.getOrganizerDetailPublic(id),
      queryParameters: fields != null ? {'fields': fields} : null,
    );
    return Organizer.fromJson(response.data);
  }

  Future<Organizer> create({
    required String name,
    required String email,
    String? logo,
    String? phone,
    String? description,
    String? country,
    String? city,
    String? district,
    String? ward,
    String? facebook,
    String? twitter,
    String? linkedin,
    String? instagram,
    MultipartFile? file,
  }) async {
    final data = FormData.fromMap({
      'name': name,
      'email': email,
      'logo': logo,
      'phone': phone,
      'description': description,
      'country': country,
      'city': city,
      'district': district,
      'ward': ward,
      'facebook': facebook,
      'twitter': twitter,
      'linkedin': linkedin,
      'instagram': instagram,
    });

    if (file != null) {
      data.files.add(MapEntry('file', file));
    }

    final response = await _dioClient.post(
      ApiUrl.createOrganizer,
      data: data,
    );
    return Organizer.fromJson(response.data);
  }

  Future<Organizer> edit(
    String id, {
    String? name,
    String? email,
    String? logo,
    String? phone,
    String? description,
    String? country,
    String? city,
    String? district,
    String? ward,
    String? facebook,
    String? twitter,
    String? linkedin,
    String? instagram,
  }) async {
    final response = await _dioClient.put(
      ApiUrl.editOrganizer(id),
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (logo != null) 'logo': logo,
        if (phone != null) 'phone': phone,
        if (description != null) 'description': description,
        if (country != null) 'country': country,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (ward != null) 'ward': ward,
        if (facebook != null) 'facebook': facebook,
        if (twitter != null) 'twitter': twitter,
        if (linkedin != null) 'linkedin': linkedin,
        if (instagram != null) 'instagram': instagram,
      },
    );
    return Organizer.fromJson(response.data);
  }

  Future<Organizer> editThumbnail({
    required String id,
    MultipartFile? file,
    String? imageUrl,
  }) async {
    final data = FormData();
    if (file != null) {
      data.files.add(MapEntry('file', file));
    }
    if (imageUrl != null) {
      data.fields.add(MapEntry('image_url', imageUrl));
    }

    final response = await _dioClient.put(
      ApiUrl.editOrganizerThumbnail(id),
      data: data,
    );
    return Organizer.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _dioClient.delete(ApiUrl.deleteOrganizer(id));
  }
}