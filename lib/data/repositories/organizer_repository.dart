import 'package:dio/dio.dart';
import 'package:eventorize_app/data/api/organizer_api.dart';
import 'package:eventorize_app/data/models/organizer.dart';

class OrganizerRepository {
  final OrganizerApi _organizerApi;

  OrganizerRepository(this._organizerApi);

  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
  }) async {
    return await _organizerApi.getAll(
      page: page,
      limit: limit,
      query: query,
      search: search,
      fields: fields,
      sortBy: sortBy,
      orderBy: orderBy,
    );
  }

  Future<Organizer> getDetail(String id, {String? fields}) async {
    return await _organizerApi.getDetail(id, fields: fields);
  }

  Future<Organizer> create({
    required String name,
    String? logo,
    required String email,
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
    return await _organizerApi.create(
      name: name,
      logo: logo,
      email: email,
      phone: phone,
      description: description,
      country: country,
      city: city,
      district: district,
      ward: ward,
      facebook: facebook,
      twitter: twitter,
      linkedin: linkedin,
      instagram: instagram,
      file: file,
    );
  }

  Future<Organizer> edit(
    String id, {
    String? name,
    String? logo,
    String? email,
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
    return await _organizerApi.edit(
      id,
      name: name,
      logo: logo,
      email: email,
      phone: phone,
      description: description,
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

  Future<Organizer> editLogo({
    required String id,
    MultipartFile? file,
    String? imageUrl,
  }) async {
    return await _organizerApi.editLogo(
      id: id,
      file: file,
      imageUrl: imageUrl,
    );
  }

  Future<void> delete(String id) async {
    await _organizerApi.delete(id);
  }

  Future<Map<String, dynamic>> exportOrganizers() async {
    return await _organizerApi.exportOrganizers();
  }
}