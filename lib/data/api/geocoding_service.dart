import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';
  static const _userAgent = 'EventorizeApp/1.0 (contact: your.real.email@gmail.com)';

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final query = Uri.encodeQueryComponent(address);
      final url = '$_baseUrl?q=$query&format=json&limit=1&countrycodes=VN';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'User-Agent': _userAgent},
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data is! List || data.isEmpty) {
        return null;
      }

      final result = data.first;
      final lat = double.tryParse(result['lat']?.toString() ?? '');
      final lon = double.tryParse(result['lon']?.toString() ?? '');
      if (lat == null || lon == null) {
        return null;
      }

      return LatLng(lat, lon);
    } catch (e) {
      return null;
    }
  }
}