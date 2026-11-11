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
import 'package:pump_saver/services/station_cache_service.dart';

final stationsProvider = NotifierProvider<StationsController, StationsState>(StationsController.new);

/// Top-level so it can run in a background isolate: the live file is ~10 MB of JSON.
List<StationModel> parseStations(String body) =>
    (json.decode(body) as List).map((x) => StationModel.fromJson(x as Map<String, dynamic>)).toList();

class StationsController extends Notifier<StationsState> {
  @override
  StationsState build() => const StationsInitialState();

  Future<void> fetchStations() async {
    state = const StationsLoadingState();
    try {
      if (!AppMode.PRODUCTION_MODE) {
        state = StationsSuccessState(parseStations(await rootBundle.loadString(AssetPath.sampleStations)));
        return;
      }

      String? body;
      DateTime? savedAt;
      Object? failure;
      try {
        final response = await Network.getRequest(API.stations);
        if (response.statusCode == 200) {
          body = response.body;
        } else {
          failure = "Couldn't load fuel prices (${response.statusCode}).";
        }
      } catch (error) {
        failure = error;
      }

      if (body != null) {
        StationCacheService.write(body);
      } else {
        // Offline or server error: fall back to the last saved prices.
        final cached = await StationCacheService.read();
        if (cached == null) throw failure!;
        body = cached.body;
        savedAt = cached.savedAt;
      }

      state = StationsSuccessState(await compute(parseStations, body), savedAt: savedAt);
    } catch (error, stackTrace) {
      if (kDebugMode) debugPrint('$error\n$stackTrace');
      state = StationsErrorState(error is String ? error : "Couldn't load fuel prices.");
    }
  }
}
