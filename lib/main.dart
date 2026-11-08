import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pump_saver/controller/logger/logger_controller.dart';
import 'package:pump_saver/services/navigation_service.dart';
import 'package:pump_saver/views/screens/startup/splash_screen.dart';
import 'package:pump_saver/views/styles/b_style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  // Inter is bundled in assets/google_fonts, so never download fonts at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(ProviderScope(observers: [Logger()], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PumpSaver',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: KColor.primary, primary: KColor.primary, surface: KColor.appBackground),
        scaffoldBackgroundColor: KColor.appBackground,
        fontFamily: GoogleFonts.inter().fontFamily,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: const SplashScreen(),
    );
  }
}
