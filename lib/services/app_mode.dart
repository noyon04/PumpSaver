// ignore_for_file: constant_identifier_names

class AppMode {
  /// false = bundled sample data, true = live data from API.LIVE.
  /// Override per build: flutter run --dart-define=PRODUCTION_MODE=true
  static const PRODUCTION_MODE = bool.fromEnvironment('PRODUCTION_MODE');
}
