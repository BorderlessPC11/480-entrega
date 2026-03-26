import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
class RideMapItem {
  const RideMapItem({
    required this.id,
    required this.label,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.destinationLatLng,
    required this.scheduledAt,
  });

  final String id;
  final String label;
  final String pickupAddress;
  final String destinationAddress;
  final LatLng destinationLatLng;
  final DateTime scheduledAt;
}

