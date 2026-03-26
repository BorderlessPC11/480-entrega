import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GeocodingResult {
  const GeocodingResult({
    required this.latLng,
    this.error,
  });

  final LatLng? latLng;
  final String? error;
}

class GeocodingService {
  static const _base = 'https://maps.googleapis.com/maps/api/geocode/json';

  Future<GeocodingResult> geocodeAddress(String address) async {
    const key = String.fromEnvironment('GOOGLE_DIRECTIONS_API_KEY');
    if (key.isEmpty) {
      return const GeocodingResult(
        latLng: null,
        error: 'Defina GOOGLE_DIRECTIONS_API_KEY via dart-define.',
      );
    }

    final uri = Uri.parse(_base).replace(
      queryParameters: {
        'address': address,
        'key': key,
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      return GeocodingResult(
        latLng: null,
        error: 'Erro de rede (${res.statusCode}) ao geocodificar endereço.',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN';
    if (status != 'OK') {
      final msg = data['error_message'] as String?;
      return GeocodingResult(
        latLng: null,
        error: msg ?? 'Geocoding API retornou status: $status',
      );
    }

    final results = (data['results'] as List<dynamic>? ?? const []);
    if (results.isEmpty) {
      return const GeocodingResult(latLng: null, error: 'Nenhum endereço encontrado.');
    }

    final geometry = (results.first as Map<String, dynamic>)['geometry']
        as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = (location?['lat'] as num?)?.toDouble();
    final lng = (location?['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      return const GeocodingResult(
        latLng: null,
        error: 'Endereço inválido (sem coordenadas).',
      );
    }

    return GeocodingResult(latLng: LatLng(lat, lng));
  }
}

