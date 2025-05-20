import 'package:dio/dio.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/common/services/secure_storage.dart';

class UserApi {
  final DioClient _dioClient;

  UserApi(this._dioClient);

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

  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dioClient.get(ApiUrl.healthCheck);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiUrl.register,
      data: {
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    final data = response.data as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Registration failed: Empty response data');
    }
    final token = data['access_token'] as String? ??
        (throw Exception('Registration failed: Missing token'));
    await SecureStorage.saveToken(token);

    return {
      'user': User.fromJson(data),
      'token': token,
    };
  }

  Future<Map<String, dynamic>> googleSSOAndroid({
    required String googleId,
    required String displayName,
    required String email,
    required String picture,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiUrl.googleSSOAndroid,
        data: {
          'id': googleId,
          'display_name': displayName,
          'email': email,
          'picture': picture,
        },
      );
      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Google SSO failed: Empty response data');
      }
      final token = data['access_token'] as String? ??
          (throw Exception('Google SSO failed: Missing token'));
      await SecureStorage.saveToken(token);

      return {
        'user': User.fromJson(data),
        'token': token,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Google SSO failed: $errorMessage');
    }
  }

  Future<User> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiUrl.verifyEmail,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final userData = response.data as Map<String, dynamic>?;
      if (userData == null) {
        throw Exception('Verification failed: Empty response data');
      }

      final user = User.fromJson(userData);
      if (!user.isVerified) {
        throw Exception('Verification failed: User is not verified');
      }

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Verification endpoint not found. Please check the API URL.');
      }
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Verification failed: $errorMessage');
    }
  }

  Future<void> resendVerificationEmail({
    required String email,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiUrl.resendVerificationEmail,
        data: {
          'email': email,
        },
      );
      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['status'] != 'success') {
        throw Exception('Resend verification email failed: Server error');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception('Resend verification email failed: $errorMessage');
    }
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
    final data = response.data as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Login failed: Empty response data');
    }
    final token = data['access_token'] as String? ??
        (throw Exception('Login failed: Missing token'));
    await SecureStorage.saveToken(token);
    return {
      'user': User.fromJson(data),
      'token': token,
    };
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
  }

  Future<User> getMe({String? fields}) async {
    final response = await _dioClient.get(
      ApiUrl.getMe,
      queryParameters: fields != null ? {'fields': fields} : null,
    );
    return User.fromJson(response.data);
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
    final data = FormData();
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