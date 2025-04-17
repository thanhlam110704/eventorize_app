import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrl {
  static String get baseUrlBE => dotenv.env['baseUrlBE'] ?? 'https://default-api.com';
  
  static String get healthCheck => '/v1/health/ping';
  static String get register => '/v1/users/register';
  static String get login => '/v1/users/login';
  static String get getMe => '/v1/users/me';
  static String get getAll => '/v1/users';
  static String getDetail(String id) => '/v1/users/$id';
  static String editUser(String id) => '/v1/users/$id';
  static String deleteUser(String id) => '/v1/users/$id';
  static String get editAvatar => '/v1/users/me/avatar';
  static String get googleSSO => '/auth/google/login';
}