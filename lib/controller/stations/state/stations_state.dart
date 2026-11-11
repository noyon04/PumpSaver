import 'package:pump_saver/models/station_model.dart';

sealed class StationsState {
  const StationsState();
}

final class StationsInitialState extends StationsState {
  const StationsInitialState();
}

final class StationsLoadingState extends StationsState {
  const StationsLoadingState();
}

final class StationsSuccessState extends StationsState {
  final List<StationModel> stations;

  /// Set when the download failed and these are prices saved on the device earlier.
  final DateTime? savedAt;
  const StationsSuccessState(this.stations, {this.savedAt});
}

final class StationsErrorState extends StationsState {
  final String message;
  const StationsErrorState(this.message);
}
