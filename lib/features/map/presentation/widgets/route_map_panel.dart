import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/directions_service.dart';
import '../../services/location_service.dart';
import 'persistent_route_map.dart';

class RouteMapPanel extends StatefulWidget {
  const RouteMapPanel({
    super.key,
    required this.destination,
    required this.title,
  });

  final LatLng destination;
  final String title;

  @override
  State<RouteMapPanel> createState() => _RouteMapPanelState();
}

class _RouteMapPanelState extends State<RouteMapPanel> {
  static const minSheet = 0.38;
  static const maxSheet = 0.96;

  final _sheetController = DraggableScrollableController();
  final _mapKey = GlobalKey();
  final _locationService = LocationService();
  final _directionsService = DirectionsService();

  GoogleMapController? _controller;
  LatLng? _origin;
  List<LatLng> _route = const [];
  bool _loading = false;
  String? _error;
  String? _permissionMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _permissionMessage = null;
    });

    final loc = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (loc.state != LocationPermissionState.granted || loc.position == null) {
      setState(() {
        _loading = false;
        _origin = null;
        _route = const [];
        _permissionMessage = loc.message;
      });
      return;
    }

    final pos = loc.position!;
    final origin = LatLng(pos.latitude, pos.longitude);
    final result = await _directionsService.fetchRoutePolyline(
      origin: origin,
      destination: widget.destination,
    );

    if (!mounted) return;
    setState(() {
      _origin = origin;
      _route = result.points;
      _error = result.error;
      _loading = false;
      _permissionMessage = null;
    });
    await _fit();
  }

  Future<void> _fit() async {
    final c = _controller;
    final origin = _origin;
    if (c == null || origin == null) return;

    if (_route.isEmpty) {
      await c.animateCamera(
        CameraUpdate.newLatLngZoom(widget.destination, 13),
      );
      return;
    }

    final bounds = _directionsService.boundsFor(
      a: origin,
      b: widget.destination,
      polylinePoints: _route,
    );
    await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  Future<void> _toggleSheet() async {
    final target = _sheetController.size > 0.7 ? minSheet : maxSheet;
    await _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _permissionAction() async {
    if (_permissionMessage?.contains('permanentemente') ?? false) {
      await Geolocator.openAppSettings();
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final origin = _origin ?? widget.destination;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destination,
        infoWindow: InfoWindow(title: widget.title, snippet: 'Destino'),
      ),
      if (_origin != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: _origin!,
          infoWindow: const InfoWindow(title: 'Sua localização'),
        ),
    };

    final polylines = <Polyline>{
      if (_route.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('route'),
          points: _route,
          width: 6,
          color: cs.primary,
          geodesic: true,
        ),
    };

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: minSheet,
      minChildSize: minSheet,
      maxChildSize: maxSheet,
      snap: true,
      snapSizes: const [minSheet, maxSheet],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
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
                                'Mapa',
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
                        if (_permissionMessage != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _permissionMessage!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: cs.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: _permissionAction,
                                  child: Text(
                                    (_permissionMessage
                                                ?.contains('permanentemente') ??
                                            false)
                                        ? 'Configurações'
                                        : 'Tentar',
                                  ),
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
                                zoom: 13,
                              ),
                              markers: markers,
                              polylines: polylines,
                              isLoadingRoute: _loading,
                              showMyLocation: _origin != null,
                              errorMessage: _error,
                              onMapCreated: (c) {
                                _controller = c;
                                _fit();
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
    );
  }
}

