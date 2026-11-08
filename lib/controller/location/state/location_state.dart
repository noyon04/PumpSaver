sealed class LocationState {
  const LocationState();
}

final class LocationInitialState extends LocationState {
  const LocationInitialState();
}

final class LocationLoadingState extends LocationState {
  const LocationLoadingState();
}

final class LocationSuccessState extends LocationState {
  final double latitude;
  final double longitude;

  /// Why the device location wasn't used, or null when it was.
  final String? fallbackReason;
  const LocationSuccessState(this.latitude, this.longitude, {this.fallbackReason});
}
