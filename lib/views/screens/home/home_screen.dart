import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pump_saver/controller/location/location_controller.dart';
import 'package:pump_saver/controller/location/state/location_state.dart';
import 'package:pump_saver/controller/search_filter/search_filter_controller.dart';
import 'package:pump_saver/controller/search_filter/state/search_filter_state.dart';
import 'package:pump_saver/controller/startup/init_data_controller.dart';
import 'package:pump_saver/controller/stations/nearby_stations_controller.dart';
import 'package:pump_saver/controller/stations/state/stations_state.dart';
import 'package:pump_saver/controller/stations/stations_controller.dart';
import 'package:pump_saver/services/app_mode.dart';
import 'package:pump_saver/views/global_components/k_content_unavailable_component.dart';
import 'package:pump_saver/views/global_components/k_info_banner.dart';
import 'package:pump_saver/views/global_components/loading_indicators/k_loading_indicator.dart';
import 'package:pump_saver/views/screens/home/component/fuel_type_selector.dart';
import 'package:pump_saver/views/screens/home/component/station_card.dart';
import 'package:pump_saver/views/styles/b_style.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationsProvider);
    final locationState = ref.watch(locationProvider);
    final filter = ref.watch(searchFilterProvider);
    final nearby = ref.watch(nearbyStationsProvider);
    final isLoading = stationsState is StationsInitialState ||
        stationsState is StationsLoadingState ||
        locationState is LocationInitialState ||
        locationState is LocationLoadingState;

    final cheapest = nearby.isEmpty ? null : nearby.map((n) => n.price.price).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: KColor.appBackground,
      appBar: AppBar(
        backgroundColor: KColor.appBackground,
        surfaceTintColor: KColor.transparent,
        title: Text('PumpSaver', style: KTextStyle.headline5.copyWith(color: KColor.title)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(initDataProvider).fetchData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            if (!AppMode.PRODUCTION_MODE) const KInfoBanner(icon: Icons.science_outlined, text: 'Sample data: these are not real stations or prices.'),
            if (locationState is LocationSuccessState && locationState.fallbackReason != null)
              KInfoBanner(icon: Icons.location_off_outlined, text: locationState.fallbackReason!),
            const SizedBox(height: 4),
            const FuelTypeSelector(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isLoading ? 'Finding stations…' : '${nearby.length} stations within ${filter.radiusMiles.round()} miles',
                    style: KTextStyle.bodyText2.copyWith(color: KColor.caption),
                  ),
                ),
                SegmentedButton<SortBy>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  segments: const [
                    ButtonSegment(value: SortBy.price, label: Text('Price')),
                    ButtonSegment(value: SortBy.distance, label: Text('Nearest')),
                  ],
                  selected: {filter.sortBy},
                  onSelectionChanged: (s) => ref.read(searchFilterProvider.notifier).setSortBy(s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const KListLoadingIndicator()
            else if (stationsState is StationsErrorState)
              KContentUnavailableComponent(
                icon: Icons.cloud_off_outlined,
                title: stationsState.message,
                message: 'Check your connection and try again.',
                onRetry: () => ref.read(stationsProvider.notifier).fetchStations(),
              )
            else if (nearby.isEmpty)
              KContentUnavailableComponent(
                icon: Icons.search_off_outlined,
                title: 'No ${filter.fuelType.label.toLowerCase()} within ${filter.radiusMiles.round()} miles',
                message: 'Try another fuel type, or pull down to refresh.',
              )
            else
              ...nearby.map((n) => StationCard(nearbyStation: n, isCheapest: n.price.price == cheapest)),
          ],
        ),
      ),
    );
  }
}
