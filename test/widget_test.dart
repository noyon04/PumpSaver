import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pump_saver/models/nearby_station_model.dart';
import 'package:pump_saver/models/station_model.dart';
import 'package:pump_saver/views/screens/home/component/station_card.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('StationCard shows name, price, distance and the cheapest badge', (tester) async {
    final station = StationModel(nodeId: '1', brandName: 'Sample Fuel', city: 'London', postcode: 'NW1 8AA', latitude: 51.5, longitude: -0.1);
    final nearby = NearbyStationModel(station: station, price: FuelPriceModel(fuelType: 'E10', price: 139.9), distanceMiles: 1.24);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StationCard(nearbyStation: nearby, isCheapest: true))));

    expect(find.text('Sample Fuel'), findsOneWidget);
    expect(find.text('139.9p'), findsOneWidget);
    expect(find.text('London, NW1 8AA'), findsOneWidget);
    expect(find.textContaining('1.2 mi'), findsOneWidget);
    expect(find.text('Cheapest'), findsOneWidget);
  });
}
