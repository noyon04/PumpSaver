import 'package:flutter/material.dart';
import 'package:pump_saver/views/styles/b_style.dart';

/// A one-line notice, e.g. "Sample data" or "Location permission denied".
class KInfoBanner extends StatelessWidget {
  const KInfoBanner({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: KColor.warningBackground, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: KColor.warningText),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: KTextStyle.caption.copyWith(color: KColor.warningText))),
        ],
      ),
    );
  }
}
