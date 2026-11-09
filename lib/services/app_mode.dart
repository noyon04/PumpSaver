// ignore_for_file: constant_identifier_names

class AppMode {
  /// true = live data from API.LIVE, false = bundled sample data.
  /// Use sample data with: flutter run --dart-define=PRODUCTION_MODE=false
  static const PRODUCTION_MODE = bool.fromEnvironment('PRODUCTION_MODE', defaultValue: true);
}
