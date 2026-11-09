// ignore_for_file: constant_identifier_names

class API {
  /// Published every 30 minutes by .github/workflows/fetch-fuel-data.yml.
  static const LIVE = 'https://noyon04.github.io/PumpSaver/';

  /// Stations with their current prices (Fuel Finder PFS info + fuel_prices, merged by node_id).
  static const stations = 'stations.json';
}
