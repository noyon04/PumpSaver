import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pump_saver/constants/shared_preference_constant.dart';
import 'package:pump_saver/controller/search_filter/state/search_filter_state.dart';
import 'package:pump_saver/models/fuel_type.dart';

final searchFilterProvider = NotifierProvider<SearchFilterController, SearchFilterState>(SearchFilterController.new);

class SearchFilterController extends Notifier<SearchFilterState> {
  @override
  SearchFilterState build() => SearchFilterState(
        fuelType: FuelType.fromCode(getStringAsync(FUEL_TYPE)),
        sortBy: getStringAsync(SORT_BY) == SortBy.distance.name ? SortBy.distance : SortBy.price,
      );

  void setFuelType(FuelType fuelType) {
    state = state.copyWith(fuelType: fuelType);
    setValue(FUEL_TYPE, fuelType.code);
  }

  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
    setValue(SORT_BY, sortBy.name);
  }
}
