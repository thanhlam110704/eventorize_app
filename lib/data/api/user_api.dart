
import 'package:dio/dio.dart';
import '../../data/models/user.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import '../../common/network/dio_client.dart';

class UserApi {
  final DioClient _dioClient;

  UserApi(this._dioClient);

  Future<Map<String, dynamic>> checkHealth() async {
  final response = await _dioClient.get(ApiUrl.healthCheck);
  return response.data as Map<String, dynamic>;
}


  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiUrl.register,
      data: {
        'fullname': fullname,
        'email': email,
        'password': password,
      },
    );
    return {
      'user': User.fromJson(response.data['user']),
      'token': response.data['token'] as String,
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiUrl.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return {
      'user': User.fromJson(response.data['user']),
      'token': response.data['token'] as String,
    };
  }

  Future<User> getMe({String? fields}) async {
    final response = await _dioClient.get(
      ApiUrl.getMe,
      queryParameters: fields != null ? {'fields': fields} : null,
    );
    return User.fromJson(response.data['data']);
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
      ApiUrl.getAll,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (query != null) 'query': query,
        if (search != null) 'search': search,
        if (fields != null) 'fields': fields,
        if (sortBy != null) 'sort_by': sortBy,
        if (orderBy != null) 'order_by': orderBy,
      },
    );
    return {
      'data': (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList(),
      'total': response.data['total'] as int,
    };
  }

  Future<User> getUserDetail(String id, {String? fields}) async {
    final response = await _dioClient.get(
      ApiUrl.getDetail(id),
      queryParameters: fields != null ? {'fields': fields} : null,
    );
    return User.fromJson(response.data['data']);
  }

  Future<User> editUser(
    String id, {
    String? fullname,
    String? email,
    String? position,
    String? phone,
    String? company,
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
      ApiUrl.editUser(id),
      data: {
        if (fullname != null) 'fullname': fullname,
        if (email != null) 'email': email,
        if (position != null) 'position': position,
        if (phone != null) 'phone': phone,
        if (company != null) 'company': company,
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
    return User.fromJson(response.data['data']);
  }

  Future<void> deleteUser(String id) async {
    await _dioClient.delete(ApiUrl.deleteUser(id));
  }

  Future<User> editAvatar({MultipartFile? file, String? imageUrl}) async {
    final data = FormData.fromMap({});
    if (file != null) {
      data.files.add(MapEntry('file', file));
    }
    if (imageUrl != null) {
      data.fields.add(MapEntry('image_url', imageUrl));
    }

    final response = await _dioClient.put(
      ApiUrl.editAvatar,
      data: data,
    );
    return User.fromJson(response.data['data']);
  }
}