import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pump_saver/constants/asset_path.dart';
import 'package:pump_saver/controller/stations/state/stations_state.dart';
import 'package:pump_saver/models/station_model.dart';
import 'package:pump_saver/network/api.dart';
import 'package:pump_saver/network/network_utils.dart';
import 'package:pump_saver/services/app_mode.dart';

final stationsProvider = NotifierProvider<StationsController, StationsState>(StationsController.new);

class StationsController extends Notifier<StationsState> {
  @override
  StationsState build() => const StationsInitialState();

  Future<void> fetchStations() async {
    state = const StationsLoadingState();
    try {
      final responseBody = AppMode.PRODUCTION_MODE
          ? Network.handleResponse(await Network.getRequest(API.stations))
          : json.decode(await rootBundle.loadString(AssetPath.sampleStations));

      if (responseBody is List) {
        final stations = responseBody.map((x) => StationModel.fromJson(x as Map<String, dynamic>)).toList();
        state = StationsSuccessState(stations);
      } else {
        state = const StationsErrorState("Couldn't load fuel prices.");
      }
    } catch (error, stackTrace) {
      if (kDebugMode) debugPrint('$error\n$stackTrace');
      state = StationsErrorState(error is String ? error : "Couldn't load fuel prices.");
    }
  }
}
