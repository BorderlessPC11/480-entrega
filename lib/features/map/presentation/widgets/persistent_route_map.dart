import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PersistentRouteMap extends StatefulWidget {
  const PersistentRouteMap({
    super.key,
    required this.initialCameraPosition,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
    required this.isLoadingRoute,
    required this.showMyLocation,
    this.errorMessage,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final ValueChanged<GoogleMapController> onMapCreated;
  final bool isLoadingRoute;
  final bool showMyLocation;
  final String? errorMessage;

  @override
  State<PersistentRouteMap> createState() => _PersistentRouteMapState();
}

class _PersistentRouteMapState extends State<PersistentRouteMap>
    with AutomaticKeepAliveClientMixin<PersistentRouteMap> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: widget.initialCameraPosition,
          onMapCreated: widget.onMapCreated,
          markers: widget.markers,
          polylines: widget.polylines,
          myLocationEnabled: widget.showMyLocation,
          myLocationButtonEnabled: widget.showMyLocation,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
        ),
        if (widget.isLoadingRoute)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28)),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  widget.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

