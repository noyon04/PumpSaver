import 'package:flutter/material.dart';

/*
Focus: To maintain app wide design consistency all
the sizes(height/width) that are used in this app should be declared
using methods of this class. Values are taken from a 375x812 design.
*/

class KSize {
  static double getWidth(BuildContext context, double width) => width / 375 * MediaQuery.sizeOf(context).width;

  static double getHeight(BuildContext context, double height) => height / 812 * MediaQuery.sizeOf(context).height;
}
