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

/// Geocoding simulado (coordenadas fixas na região de SP) sem chamar a API.  
/// Para usar a API real: `--dart-define=MOCK_GOOGLE_MAPS=false` e chave [GOOGLE_DIRECTIONS_API_KEY].
const bool kUseMockGoogleGeocoding = bool.fromEnvironment(
  'MOCK_GOOGLE_MAPS',
  defaultValue: true,
);

class GeocodingService {
  static const _base = 'https://maps.googleapis.com/maps/api/geocode/json';

  /// Marco em São Paulo; pequena variação com base no text do endereço (só para testes visuais).
  GeocodingResult _mockGeocode(String address) {
    final t = address.trim();
    if (t.isEmpty) {
      return const GeocodingResult(
        latLng: null,
        error: 'Informe um endereço.',
      );
    }
    final h = t.hashCode;
    final dLat = (h % 1000) / 1e5;
    final dLng = ((h >> 8) % 1000) / 1e5;
    return GeocodingResult(
      latLng: LatLng(-23.55052 + dLat, -46.633308 + dLng),
    );
  }

  /// Implementação real da Google Geocoding API (só com `MOCK_GOOGLE_MAPS=false`).
  Future<GeocodingResult> _geocodeFromGoogle(String address) async {
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

  Future<GeocodingResult> geocodeAddress(String address) async {
    if (kUseMockGoogleGeocoding) {
      return _mockGeocode(address);
    }
    return _geocodeFromGoogle(address);
  }
}
