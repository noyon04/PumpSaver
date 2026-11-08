import 'package:flutter/material.dart';
import 'package:pump_saver/views/styles/b_style.dart';

/// Empty and error states: an icon, a title, a message and an optional retry button.
class KContentUnavailableComponent extends StatelessWidget {
  const KContentUnavailableComponent({super.key, required this.icon, required this.title, this.message, this.onRetry});

  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: KColor.caption),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: KTextStyle.subtitle1.copyWith(color: KColor.title)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!, textAlign: TextAlign.center, style: KTextStyle.bodyText2.copyWith(color: KColor.caption)),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text('Try again', style: KTextStyle.button)),
          ],
        ],
      ),
    );
  }
}
