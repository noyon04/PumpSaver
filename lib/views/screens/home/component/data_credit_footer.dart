import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' show toast;
import 'package:pump_saver/network/api.dart';
import 'package:pump_saver/views/styles/b_style.dart';
import 'package:url_launcher/url_launcher.dart';

/// The attribution the Open Government Licence requires, plus the privacy policy link.
class DataCreditFooter extends StatelessWidget {
  const DataCreditFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Prices from Fuel Finder. Contains public sector information licensed under the Open Government Licence v3.0. '
          'PumpSaver is independent and not affiliated with the UK government.',
          textAlign: TextAlign.center,
          style: KTextStyle.caption.copyWith(color: KColor.caption),
        ),
        TextButton(
          onPressed: () async {
            if (!await launchUrl(Uri.parse(API.privacyPolicy), mode: LaunchMode.externalApplication)) toast("Couldn't open the privacy policy");
          },
          child: Text('Privacy policy', style: KTextStyle.caption.copyWith(color: KColor.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
