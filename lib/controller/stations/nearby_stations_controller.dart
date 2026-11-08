import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pump_saver/controller/location/location_controller.dart';
import 'package:pump_saver/controller/location/state/location_state.dart';
import 'package:pump_saver/controller/search_filter/search_filter_controller.dart';
import 'package:pump_saver/controller/search_filter/state/search_filter_state.dart';
import 'package:pump_saver/controller/stations/state/stations_state.dart';
import 'package:pump_saver/controller/stations/stations_controller.dart';
import 'package:pump_saver/models/nearby_station_model.dart';
import 'package:pump_saver/models/station_model.dart';

/// Open stations near the user that sell the selected fuel, sorted by the user's choice.
/// Recomputes whenever stations, location or filters change.
final nearbyStationsProvider = Provider<List<NearbyStationModel>>((ref) {
  final stationsState = ref.watch(stationsProvider);
  final locationState = ref.watch(locationProvider);
  final filter = ref.watch(searchFilterProvider);

  if (stationsState is! StationsSuccessState || locationState is! LocationSuccessState) return const [];
  return findNearbyStations(stationsState.stations, locationState.latitude, locationState.longitude, filter);
});

const _metresPerMile = 1609.344;

List<NearbyStationModel> findNearbyStations(List<StationModel> stations, double latitude, double longitude, SearchFilterState filter) {
  final nearby = <NearbyStationModel>[];
  for (final station in stations) {
    if (station.isClosed) continue;
    final price = station.priceFor(filter.fuelType.code);
    if (price == null) continue;

    final miles = Geolocator.distanceBetween(latitude, longitude, station.latitude, station.longitude) / _metresPerMile;
    if (miles <= filter.radiusMiles) nearby.add(NearbyStationModel(station: station, price: price, distanceMiles: miles));
  }

  nearby.sort((a, b) => switch (filter.sortBy) {
        SortBy.price => a.price.price.compareTo(b.price.price) != 0 ? a.price.price.compareTo(b.price.price) : a.distanceMiles.compareTo(b.distanceMiles),
        SortBy.distance => a.distanceMiles.compareTo(b.distanceMiles),
      });
  return nearby;
}
