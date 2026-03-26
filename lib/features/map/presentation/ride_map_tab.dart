import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/mock_rides.dart';
import '../domain/ride_map_item.dart';
import '../services/directions_service.dart';
import '../services/location_service.dart';
import 'widgets/persistent_route_map.dart';

class RideMapTab extends StatefulWidget {
  const RideMapTab({super.key});

  @override
  State<RideMapTab> createState() => _RideMapTabState();
}

class _RideMapTabState extends State<RideMapTab> {
  static const _minSheet = 0.38;
  static const _maxSheet = 0.96;
  static const _mapFallbackCenter = LatLng(-23.550520, -46.633308);

  final _rides = mockRideMapItems();
  final _locationService = LocationService();
  final _directionsService = DirectionsService();
  final _mapKey = GlobalKey();
  final _sheetController = DraggableScrollableController();

  RideMapItem? _selectedRide;
  LatLng? _driverLatLng;
  List<LatLng> _routePoints = const [];
  bool _loadingRoute = false;
  String? _routeError;
  String? _permissionMessage;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedRide = _rides.first;
    _refreshRoute();
  }

  Future<void> _refreshRoute() async {
    final ride = _selectedRide;
    if (ride == null) return;
    setState(() {
      _loadingRoute = true;
      _routeError = null;
      _permissionMessage = null;
    });

    final loc = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (loc.state != LocationPermissionState.granted || loc.position == null) {
      setState(() {
        _loadingRoute = false;
        _driverLatLng = null;
        _routePoints = const [];
        _permissionMessage = loc.message;
      });
      return;
    }

    final pos = loc.position!;
    final origin = LatLng(pos.latitude, pos.longitude);
    final result = await _directionsService.fetchRoutePolyline(
      origin: origin,
      destination: ride.destinationLatLng,
    );

    if (!mounted) return;
    setState(() {
      _driverLatLng = origin;
      _routePoints = result.points;
      _routeError = result.error;
      _loadingRoute = false;
      _permissionMessage = null;
    });
    await _fitCamera();
  }

  Future<void> _fitCamera() async {
    final ride = _selectedRide;
    final origin = _driverLatLng;
    final controller = _mapController;
    if (ride == null || origin == null || controller == null) return;

    if (_routePoints.isEmpty) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(ride.destinationLatLng, 13),
      );
      return;
    }

    final bounds = _directionsService.boundsFor(
      a: origin,
      b: ride.destinationLatLng,
      polylinePoints: _routePoints,
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );
  }

  Future<void> _handlePermissionAction() async {
    if (_permissionMessage?.contains('permanentemente') ?? false) {
      await Geolocator.openAppSettings();
      return;
    }
    await _refreshRoute();
  }

  void _selectRide(RideMapItem ride) {
    if (_selectedRide?.id == ride.id) return;
    setState(() => _selectedRide = ride);
    _refreshRoute();
  }

  Future<void> _toggleSheet() async {
    final size = _sheetController.size;
    final target = size > 0.7 ? _minSheet : _maxSheet;
    await _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = _selectedRide!;
    final cs = Theme.of(context).colorScheme;
    final origin = _driverLatLng ?? _mapFallbackCenter;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: ride.destinationLatLng,
        infoWindow: InfoWindow(title: ride.label, snippet: 'Destino'),
      ),
      if (_driverLatLng != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverLatLng!,
          infoWindow: const InfoWindow(title: 'Sua localização'),
        ),
    };

    final polylines = <Polyline>{
      if (_routePoints.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('driver_route'),
          points: _routePoints,
          width: 6,
          color: cs.primary,
          geodesic: true,
        ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.min(constraints.maxWidth, 560.0);
        return Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 320),
                    children: [
                      Text(
                        'Mapa de rotas',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selecione uma corrida para traçar o caminho.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _rides.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = _rides[index];
                            final selected = item.id == ride.id;
                            return SizedBox(
                              width: 210,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: selected
                                        ? cs.primary.withValues(alpha: 0.8)
                                        : cs.outline.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _selectRide(item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.id,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: cs.onSurface
                                                    .withValues(alpha: 0.72),
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _timeLabel(item.scheduledAt),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: cs.primary,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rowLine(
                                context: context,
                                icon: Icons.store_mall_directory_outlined,
                                title: 'Origem',
                                text: ride.pickupAddress,
                              ),
                              const SizedBox(height: 12),
                              _rowLine(
                                context: context,
                                icon: Icons.flag_outlined,
                                title: 'Destino',
                                text: ride.destinationAddress,
                              ),
                              if (_permissionMessage != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  _permissionMessage!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: cs.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: _handlePermissionAction,
                                  child: Text(
                                    (_permissionMessage?.contains('permanentemente') ??
                                            false)
                                        ? 'Abrir configurações'
                                        : 'Tentar novamente',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: _minSheet,
                  minChildSize: _minSheet,
                  maxChildSize: _maxSheet,
                  snap: true,
                  snapSizes: const [_minSheet, _maxSheet],
                  builder: (context, scrollController) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          return ListView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            children: [
                              SizedBox(
                                height: c.maxHeight,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 44,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: cs.outline.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Rota no mapa',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: _toggleSheet,
                                            icon: const Icon(Icons.swap_vert_rounded),
                                            tooltip: 'Expandir/Recolher',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(14),
                                        ),
                                        child: PersistentRouteMap(
                                          key: _mapKey,
                                          initialCameraPosition: CameraPosition(
                                            target: origin,
                                            zoom: 12.8,
                                          ),
                                          markers: markers,
                                          polylines: polylines,
                                          isLoadingRoute: _loadingRoute,
                                          showMyLocation: _driverLatLng != null,
                                          errorMessage: _routeError,
                                          onMapCreated: (controller) {
                                            _mapController = controller;
                                            _fitCamera();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _rowLine({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String text,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.75)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

