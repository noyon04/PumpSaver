// ignore_for_file: constant_identifier_names

class API {
  /// Published every 30 minutes by tool/publish_from_pc.ps1.
  /// Override for testing against a local copy: --dart-define=LIVE_URL=http://localhost:8765/
  static const LIVE = String.fromEnvironment('LIVE_URL', defaultValue: 'https://noyon04.github.io/PumpSaver/');

  /// Hosted next to the data; source is docs/privacy.html.
  static const privacyPolicy = 'https://noyon04.github.io/PumpSaver/privacy.html';

  /// Stations with their current prices (Fuel Finder PFS info + fuel_prices, merged by node_id).
  static const stations = 'stations.json';
}
