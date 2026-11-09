// ignore_for_file: constant_identifier_names

class API {
  /// Published every 30 minutes by .github/workflows/fetch-fuel-data.yml.
  /// Override for testing against a local copy: --dart-define=LIVE_URL=http://localhost:8765/
  static const LIVE = String.fromEnvironment('LIVE_URL', defaultValue: 'https://noyon04.github.io/PumpSaver/');

  /// Stations with their current prices (Fuel Finder PFS info + fuel_prices, merged by node_id).
  static const stations = 'stations.json';
}
