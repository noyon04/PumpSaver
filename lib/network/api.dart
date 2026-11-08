// ignore_for_file: constant_identifier_names

class API {
  /// Published every 30 minutes by .github/workflows/fetch-fuel-data.yml.
  /// Replace `<github-user>` with your GitHub username once Pages is enabled.
  static const LIVE = 'https://<github-user>.github.io/pump_saver/';

  /// Stations with their current prices (Fuel Finder PFS info + fuel_prices, merged by node_id).
  static const stations = 'stations.json';
}
