import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pump_saver/controller/location/location_controller.dart';
import 'package:pump_saver/controller/stations/stations_controller.dart';

final initDataProvider = Provider<InitDataController>(InitDataController.new);

/// Everything the app needs at launch, started from the splash screen.
class InitDataController {
  final Ref ref;
  InitDataController(this.ref);

  Future<void> fetchData() => Future.wait([
        ref.read(locationProvider.notifier).fetchLocation(),
        ref.read(stationsProvider.notifier).fetchStations(),
      ]);
}
