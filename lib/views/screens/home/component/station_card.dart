import 'package:flutter/material.dart';
import 'package:pump_saver/models/nearby_station_model.dart';
import 'package:pump_saver/services/date_time_service.dart';
import 'package:pump_saver/services/navigation_service.dart';
import 'package:pump_saver/views/screens/station_details/station_details_screen.dart';
import 'package:pump_saver/views/styles/b_style.dart';

class StationCard extends StatelessWidget {
  const StationCard({super.key, required this.nearbyStation, this.isCheapest = false});
  final NearbyStationModel nearbyStation;
  final bool isCheapest;

  @override
  Widget build(BuildContext context) {
    final station = nearbyStation.station;
    final price = nearbyStation.price;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: KColor.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isCheapest ? KColor.cheap : KColor.divider, width: isCheapest ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => NavigationService.navigateTo(MaterialPageRoute(builder: (_) => StationDetailsScreen(station: station))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(station.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: KTextStyle.subtitle1.copyWith(color: KColor.title)),
                        ),
                        if (isCheapest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: KColor.cheapBackground, borderRadius: BorderRadius.circular(6)),
                            child: Text('Cheapest', style: KTextStyle.caption.copyWith(color: KColor.cheap, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(station.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: KTextStyle.bodyText2.copyWith(color: KColor.body)),
                    const SizedBox(height: 6),
                    Text(
                      '${nearbyStation.distanceMiles.toStringAsFixed(1)} mi · updated ${DateTimeService.timeAgo(price.lastUpdated)}',
                      style: KTextStyle.caption.copyWith(color: KColor.caption),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${price.price.toStringAsFixed(1)}p',
                style: KTextStyle.headline5.copyWith(color: isCheapest ? KColor.cheap : KColor.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
