import 'package:pump_saver/models/fuel_type.dart';

enum SortBy { price, distance }

/// The user's current search choices. Always available, so there's no loading state.
final class SearchFilterState {
  final FuelType fuelType;
  final SortBy sortBy;
  final double radiusMiles;

  const SearchFilterState({this.fuelType = FuelType.e10, this.sortBy = SortBy.price, this.radiusMiles = 10});

  SearchFilterState copyWith({FuelType? fuelType, SortBy? sortBy}) =>
      SearchFilterState(fuelType: fuelType ?? this.fuelType, sortBy: sortBy ?? this.sortBy, radiusMiles: radiusMiles);
}
