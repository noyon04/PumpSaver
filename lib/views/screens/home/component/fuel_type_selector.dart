import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pump_saver/controller/search_filter/search_filter_controller.dart';
import 'package:pump_saver/models/fuel_type.dart';
import 'package:pump_saver/views/styles/b_style.dart';

class FuelTypeSelector extends ConsumerWidget {
  const FuelTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(searchFilterProvider).fuelType;

    // Plain pills rather than ChoiceChip: its animated label style clips text with bundled per-weight fonts.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FuelType.values.map((fuel) {
          final isSelected = fuel == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected ? KColor.primary : KColor.card,
              shape: StadiumBorder(side: BorderSide(color: isSelected ? KColor.primary : KColor.divider)),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => ref.read(searchFilterProvider.notifier).setFuelType(fuel),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(fuel.label, style: KTextStyle.subtitle2.copyWith(color: isSelected ? KColor.white : KColor.body)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
