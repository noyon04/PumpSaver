import 'package:pump_saver/models/station_model.dart';

/// A station with its distance from the user and its price for the selected fuel.
class NearbyStationModel {
  NearbyStationModel({required this.station, required this.price, required this.distanceMiles});

  final StationModel station;
  final FuelPriceModel price;
  final double distanceMiles;
}
