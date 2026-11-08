import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
Focus: To maintain app wide design consistency all
the text styles that are used in this app should be
declared here.

*Note: When one text needs to differ, say the color,
don't create titleStyle1. Use copyWith:
Text(title, style: KTextStyle.headline6.copyWith(color: KColor.primary)),
*/

class KTextStyle {
  static TextStyle headline4 = GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5);

  static TextStyle headline5 = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700);

  static TextStyle headline6 = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle subtitle1 = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle subtitle2 = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle bodyText1 = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle bodyText2 = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle button = GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600);

  static TextStyle caption = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400);
}
