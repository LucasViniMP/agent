import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingResult {
  final double latitude;
  final double longitude;
  final String displayName;

  const GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}

class MapService {
  static Future<GeocodingResult?> geocodeAddress(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return null;

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': normalized,
      'format': 'jsonv2',
      'limit': '1',
      'countrycodes': 'br',
    });

    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'MesaMestre/1.0 (delivery-map)',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Nao foi possivel localizar o endereco.');
    }

    final body = jsonDecode(response.body);
    if (body is! List || body.isEmpty) return null;

    final item = body.first as Map<String, dynamic>;
    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lon = double.tryParse(item['lon']?.toString() ?? '');

    if (lat == null || lon == null) return null;

    return GeocodingResult(
      latitude: lat,
      longitude: lon,
      displayName: item['display_name']?.toString() ?? normalized,
    );
  }
}
