import 'package:flutter/material.dart';

/*
Focus: To maintain app wide design consistency all
the colors that are used in this app should be declared here.
*/

class KColor {
  /*
  primary theme color
  */
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFFCCFBF1);

  /*
  price highlight colors: cheapest / average / expensive
  */
  static const Color cheap = Color(0xFF15803D);
  static const Color cheapBackground = Color(0xFFDCFCE7);
  static const Color expensive = Color(0xFFB91C1C);

  /*
  text colors
  */
  static const Color title = Color(0xFF111827);
  static const Color body = Color(0xFF374151);
  static const Color caption = Color(0xFF6B7280);

  /*
  surfaces
  */
  static const Color appBackground = Color(0xFFF3F4F6);
  static const Color card = Colors.white;
  static const Color divider = Color(0xFFE5E7EB);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);

  /*
  normal color
  */
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
}
