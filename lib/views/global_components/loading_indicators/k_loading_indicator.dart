import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pump_saver/views/styles/b_style.dart';

/// Placeholder cards shown while a list is loading.
class KListLoadingIndicator extends StatelessWidget {
  const KListLoadingIndicator({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: KColor.divider,
      highlightColor: KColor.white,
      child: Column(
        children: List.generate(
          itemCount,
          (_) => Container(
            height: 88,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: KColor.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
