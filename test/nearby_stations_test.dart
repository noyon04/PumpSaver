import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pump_saver/controller/search_filter/state/search_filter_state.dart';
import 'package:pump_saver/controller/stations/nearby_stations_controller.dart';
import 'package:pump_saver/models/fuel_type.dart';
import 'package:pump_saver/models/station_model.dart';
import 'package:pump_saver/services/date_time_service.dart';

StationModel station(String id, double lat, double lng, Map<String, double> prices, {bool closed = false}) => StationModel.fromJson({
      'node_id': id,
      'brand_name': id,
      'temporary_closure': closed,
      'location': {'latitude': lat, 'longitude': lng},
      'fuel_prices': prices.entries.map((e) => {'fuel_type': e.key, 'price': e.value, 'price_last_updated': '2026-11-05T08:00:00.000Z'}).toList(),
    });

void main() {
  // Central London.
  const lat = 51.5074, lng = -0.1278;

  final stations = [
    station('near-expensive', 51.5080, -0.1280, {'E10': 149.9, 'B7_Standard': 155.9}),
    station('far-cheap', 51.5600, -0.1278, {'E10': 135.9}), // ~3.6 miles north
    station('closed-cheapest', 51.5075, -0.1279, {'E10': 120.0}, closed: true),
    station('out-of-range', 51.4543, -0.9781, {'E10': 110.0}), // Reading, ~37 miles
    station('no-e10', 51.5076, -0.1276, {'B7_Standard': 150.9}),
  ];

  test('cheapest first, skipping closed, out-of-range and stations without the fuel', () {
    final result = findNearbyStations(stations, lat, lng, const SearchFilterState());
    expect(result.map((n) => n.station.nodeId), ['far-cheap', 'near-expensive']);
    expect(result.first.distanceMiles, closeTo(3.6, 0.2));
  });

  test('sort by distance puts the nearest first', () {
    final result = findNearbyStations(stations, lat, lng, const SearchFilterState(sortBy: SortBy.distance));
    expect(result.map((n) => n.station.nodeId), ['near-expensive', 'far-cheap']);
  });

  // The fixture uses the docs' 'B7_Standard'; the live API sends 'B7_STANDARD'. Both must match.
  test('diesel matches B7 standard in any case', () {
    final result = findNearbyStations(stations, lat, lng, const SearchFilterState(fuelType: FuelType.diesel));
    expect(result.map((n) => n.price.price), [150.9, 155.9]);
  });

  test('bundled sample data parses with the API field names', () {
    final raw = json.decode(File('assets/sample/stations.json').readAsStringSync()) as List;
    final parsed = raw.map((x) => StationModel.fromJson(x as Map<String, dynamic>)).toList();
    expect(parsed, hasLength(raw.length));
    expect(parsed.first.priceFor('E10'), isNotNull);
    expect(parsed.first.openingTimes['monday'], isNotNull);
  });

  test('display name prefers trading name so same-brand stations differ', () {
    final s = StationModel.fromJson({
      'node_id': 'x', 'brand_name': 'Tesco', 'trading_name': 'Tesco Camden',
      'location': {'latitude': 51.5, 'longitude': -0.1},
    });
    expect(s.displayName, 'Tesco Camden');
  });

  test('live API capitals are tidied for display, postcode kept', () {
    final s = StationModel.fromJson({
      'node_id': 'x', 'brand_name': 'BP', 'trading_name': 'MFG PONTYPOOL SUPERSTORE',
      'location': {'address_line_1': 'LOWER BRIDGE STREET', 'city': 'PONTYPOOL', 'postcode': 'NP4 6JU', 'latitude': 51.7, 'longitude': -3.0},
      'opening_times': {'usual_days': {'monday': {'open': '06:00:00', 'close': '22:00:00', 'is_24_hours': false}}},
    });
    expect(s.displayName, 'MFG Pontypool Superstore');
    expect(s.displayBrand, 'BP');
    expect(s.address, 'Lower Bridge Street, Pontypool, NP4 6JU');
    expect(s.openingTimes['monday']!.label, '06:00 – 22:00');
  });

  test('real Fuel Finder data parses and finds diesel in London', () {
    final file = File('public/stations.json');
    final parsed = (json.decode(file.readAsStringSync()) as List).map((x) => StationModel.fromJson(x as Map<String, dynamic>)).toList();
    final diesel = findNearbyStations(parsed, lat, lng, const SearchFilterState(fuelType: FuelType.diesel));
    expect(parsed.length, greaterThan(5000));
    expect(diesel, isNotEmpty);
  }, skip: File('public/stations.json').existsSync() ? false : 'run tool/fetch_fuel_data.dart first');

  test('timeAgo', () {
    final now = DateTime.utc(2026, 11, 5, 12);
    expect(DateTimeService.timeAgo(now.subtract(const Duration(seconds: 20)), now: now), 'just now');
    expect(DateTimeService.timeAgo(now.subtract(const Duration(minutes: 25)), now: now), '25 min ago');
    expect(DateTimeService.timeAgo(now.subtract(const Duration(hours: 3)), now: now), '3 h ago');
    expect(DateTimeService.timeAgo(now.subtract(const Duration(days: 2)), now: now), '2 days ago');
    expect(DateTimeService.timeAgo(null), 'unknown');
  });
}
