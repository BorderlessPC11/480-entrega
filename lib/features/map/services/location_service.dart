import 'package:geolocator/geolocator.dart';

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationServiceResult {
  const LocationServiceResult({
    required this.state,
    this.position,
    this.message,
  });

  final LocationPermissionState state;
  final Position? position;
  final String? message;
}

class LocationService {
  Future<LocationServiceResult> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationServiceResult(
        state: LocationPermissionState.serviceDisabled,
        message: 'Ative o GPS para calcular a rota.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationServiceResult(
        state: LocationPermissionState.denied,
        message: 'Permissão de localização negada.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationServiceResult(
        state: LocationPermissionState.deniedForever,
        message: 'Permissão negada permanentemente. Abra as configurações do app.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LocationServiceResult(
      state: LocationPermissionState.granted,
      position: position,
    );
  }
}

