import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pump_saver/controller/location/state/location_state.dart';

final locationProvider = NotifierProvider<LocationController, LocationState>(LocationController.new);

class LocationController extends Notifier<LocationState> {
  /// Used when location is off or denied: Charing Cross, central London.
  static const double fallbackLatitude = 51.5074;
  static const double fallbackLongitude = -0.1278;

  @override
  LocationState build() => const LocationInitialState();

  Future<void> fetchLocation() async {
    state = const LocationLoadingState();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return _fallback('Location is turned off');

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return _fallback('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 15)),
      );
      state = LocationSuccessState(position.latitude, position.longitude);
    } catch (error) {
      if (kDebugMode) debugPrint('$error');
      _fallback("Couldn't get your location");
    }
  }

  void _fallback(String reason) {
    state = LocationSuccessState(fallbackLatitude, fallbackLongitude, fallbackReason: '$reason, showing central London');
  }
}
