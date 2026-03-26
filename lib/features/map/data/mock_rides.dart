import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../domain/ride_map_item.dart';

List<RideMapItem> mockRideMapItems() {
  final now = DateTime.now();
  return [
    RideMapItem(
      id: 'RIDE-1021',
      label: 'Rota Centro',
      pickupAddress: 'Rua Haddock Lobo, 599 - Cerqueira César',
      destinationAddress: 'Av. Paulista, 1578 - Bela Vista',
      destinationLatLng: const LatLng(-23.561399, -46.655881),
      scheduledAt: now.add(const Duration(minutes: 15)),
    ),
    RideMapItem(
      id: 'RIDE-1022',
      label: 'Rota Jardins',
      pickupAddress: 'Al. Santos, 350 - Jardins',
      destinationAddress: 'Rua Oscar Freire, 1000 - Jardins',
      destinationLatLng: const LatLng(-23.560840, -46.672373),
      scheduledAt: now.add(const Duration(minutes: 35)),
    ),
    RideMapItem(
      id: 'RIDE-1023',
      label: 'Rota República',
      pickupAddress: 'Av. Ipiranga, 210 - República',
      destinationAddress: 'Rua da Consolação, 1200 - Consolação',
      destinationLatLng: const LatLng(-23.548517, -46.652266),
      scheduledAt: now.add(const Duration(hours: 1)),
    ),
    RideMapItem(
      id: 'RIDE-1024',
      label: 'Rota Vila Mariana',
      pickupAddress: 'Rua Domingos de Morais, 200 - Vila Mariana',
      destinationAddress: 'Rua Vergueiro, 3185 - Vila Mariana',
      destinationLatLng: const LatLng(-23.588323, -46.634031),
      scheduledAt: now.add(const Duration(hours: 1, minutes: 20)),
    ),
  ];
}

