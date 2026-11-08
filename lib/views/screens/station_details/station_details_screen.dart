import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' show toast;
import 'package:pump_saver/models/fuel_type.dart';
import 'package:pump_saver/models/station_model.dart';
import 'package:pump_saver/services/date_time_service.dart';
import 'package:pump_saver/views/styles/b_style.dart';
import 'package:url_launcher/url_launcher.dart';

class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({super.key, required this.station});
  final StationModel station;

  static const _days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  Future<void> _openDirections() async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${station.latitude},${station.longitude}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) toast("Couldn't open maps");
  }

  @override
  Widget build(BuildContext context) {
    final prices = [...station.fuelPrices]..sort((a, b) => a.price.compareTo(b.price));

    return Scaffold(
      backgroundColor: KColor.appBackground,
      appBar: AppBar(backgroundColor: KColor.appBackground, surfaceTintColor: KColor.transparent),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: KColor.primary, minimumSize: const Size.fromHeight(52)),
          onPressed: _openDirections,
          icon: const Icon(Icons.directions),
          label: Text('Directions', style: KTextStyle.button),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(station.displayName, style: KTextStyle.headline5.copyWith(color: KColor.title)),
          if (station.brandName != null && station.brandName != station.displayName)
            Text(station.brandName!, style: KTextStyle.bodyText2.copyWith(color: KColor.caption)),
          const SizedBox(height: 4),
          Text(station.address, style: KTextStyle.bodyText1.copyWith(color: KColor.body)),
          if (station.isMotorway || station.isSupermarket) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              if (station.isSupermarket) const Chip(label: Text('Supermarket')),
              if (station.isMotorway) const Chip(label: Text('Motorway services')),
            ]),
          ],
          _Section(
            title: 'Prices',
            children: prices
                .map((p) => _Row(
                      label: FuelType.labelFor(p.fuelType),
                      value: '${p.price.toStringAsFixed(1)}p',
                      caption: 'updated ${DateTimeService.timeAgo(p.lastUpdated)}',
                    ))
                .toList(),
          ),
          if (station.openingTimes.isNotEmpty)
            _Section(
              title: 'Opening hours',
              children: _days
                  .where(station.openingTimes.containsKey)
                  .map((d) => _Row(label: '${d[0].toUpperCase()}${d.substring(1)}', value: station.openingTimes[d]!.label))
                  .toList(),
            ),
          if (station.amenities.isNotEmpty)
            _Section(
              title: 'Facilities',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: station.amenities.map((a) => Chip(label: Text(a.replaceAll('_', ' ')))).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: KColor.card, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: KTextStyle.subtitle1.copyWith(color: KColor.title)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.caption});
  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: KTextStyle.bodyText1.copyWith(color: KColor.body)),
                if (caption != null) Text(caption!, style: KTextStyle.caption.copyWith(color: KColor.caption)),
              ],
            ),
          ),
          Text(value, style: KTextStyle.subtitle1.copyWith(color: KColor.title)),
        ],
      ),
    );
  }
}
