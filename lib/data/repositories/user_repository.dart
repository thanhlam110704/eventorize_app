import 'package:dio/dio.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/data/models/user.dart';


class UserRepository {
  final UserApi _userApi;

  UserRepository(this._userApi);

  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await _userApi.register(
      fullname: fullname,
      email: email,
      phone: phone,
      password: password,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _userApi.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _userApi.logout();
  }

  Future<Map<String, dynamic>> checkHealth() async {
    return await _userApi.checkHealth();
  }

  Future<User> getMe({String? fields}) async {
    return await _userApi.getMe(fields: fields);
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
    return await _userApi.getAll(
      page: page,
      limit: limit,
      query: query,
      search: search,
      fields: fields,
      sortBy: sortBy,
      orderBy: orderBy,
    );
  }

  Future<User> getUserDetail(String id, {String? fields}) async {
    return await _userApi.getUserDetail(id, fields: fields);
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
    return await _userApi.editUser(
      id,
      fullname: fullname,
      email: email,
      position: position,
      phone: phone,
      company: company,
      country: country,
      city: city,
      district: district,
      ward: ward,
      facebook: facebook,
      twitter: twitter,
      linkedin: linkedin,
      instagram: instagram,
    );
  }

  Future<void> deleteUser(String id) async {
    await _userApi.deleteUser(id);
  }

  Future<User> editAvatar({MultipartFile? file, String? imageUrl}) async {
    return await _userApi.editAvatar(file: file, imageUrl: imageUrl);
  }
}