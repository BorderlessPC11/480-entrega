import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsResult {
  const DirectionsResult({
    required this.points,
    this.error,
  });

  final List<LatLng> points;
  final String? error;
}

/// Rota simulada (linha reta) sem chamar a Directions API.  
/// Para usar a API real: `--dart-define=MOCK_GOOGLE_MAPS=false` e chave [GOOGLE_DIRECTIONS_API_KEY].
const bool kUseMockGoogleDirections = bool.fromEnvironment(
  'MOCK_GOOGLE_MAPS',
  defaultValue: true,
);

class DirectionsService {
  static const _directionsApiBase =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Rota aproximada (segmentos) entre origem e destino, para testar o mapa sem API.
  DirectionsResult _mockRoute(LatLng origin, LatLng destination) {
    const steps = 16;
    final points = <LatLng>[];
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      points.add(
        LatLng(
          origin.latitude + (destination.latitude - origin.latitude) * t,
          origin.longitude + (destination.longitude - origin.longitude) * t,
        ),
      );
    }
    return DirectionsResult(points: points);
  }

  /// Implementação real da Google Directions API (só com `MOCK_GOOGLE_MAPS=false`).
  Future<DirectionsResult> _fetchRouteFromGoogle(
    LatLng origin,
    LatLng destination,
  ) async {
    const key = String.fromEnvironment('GOOGLE_DIRECTIONS_API_KEY');
    if (key.isEmpty) {
      return const DirectionsResult(
        points: [],
        error: 'Defina GOOGLE_DIRECTIONS_API_KEY via --dart-define.',
      );
    }

    final params = {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': key,
    };

    final uri = Uri.parse(_directionsApiBase).replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return DirectionsResult(
        points: const [],
        error: 'Erro de rede (${response.statusCode}) ao buscar rota.',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN';
    if (status != 'OK') {
      final msg = data['error_message'] as String?;
      return DirectionsResult(
        points: const [],
        error: msg ?? 'Directions API retornou status: $status',
      );
    }

    final routes = (data['routes'] as List<dynamic>? ?? const []);
    if (routes.isEmpty) {
      return const DirectionsResult(points: [], error: 'Nenhuma rota encontrada.');
    }

    final overview = (routes.first as Map<String, dynamic>)['overview_polyline']
        as Map<String, dynamic>?;
    final encoded = overview?['points'] as String?;
    if (encoded == null || encoded.isEmpty) {
      return const DirectionsResult(
        points: [],
        error: 'Polyline da rota não foi retornada.',
      );
    }

    final decoded = PolylinePoints.decodePolyline(encoded);
    final points = decoded
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);

    if (points.isEmpty) {
      return const DirectionsResult(points: [], error: 'Falha ao decodificar polyline.');
    }

    return DirectionsResult(points: points);
  }

  Future<DirectionsResult> fetchRoutePolyline({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (kUseMockGoogleDirections) {
      return _mockRoute(origin, destination);
    }
    return _fetchRouteFromGoogle(origin, destination);
  }

  LatLngBounds boundsFor({
    required LatLng a,
    required LatLng b,
    required List<LatLng> polylinePoints,
  }) {
    final all = <LatLng>[a, b, ...polylinePoints];
    var minLat = all.first.latitude;
    var maxLat = all.first.latitude;
    var minLng = all.first.longitude;
    var maxLng = all.first.longitude;

    for (final p in all) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final sw = LatLng(minLat, minLng);
    final ne = LatLng(maxLat, maxLng);
    return LatLngBounds(southwest: sw, northeast: ne);
  }
}
