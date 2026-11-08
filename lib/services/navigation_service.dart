import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(Route route) => navigatorKey.currentState!.push(route);

  static Future<dynamic> navigateToReplacement(Route route) => navigatorKey.currentState!.pushReplacement(route);

  static void popNavigate() => navigatorKey.currentState!.pop();
}

/// Fade transition
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        );
}
