import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pump_saver/controller/startup/init_data_controller.dart';
import 'package:pump_saver/services/navigation_service.dart';
import 'package:pump_saver/views/screens/home/home_screen.dart';
import 'package:pump_saver/views/styles/b_style.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Providers can't change state while the tree is building, so start after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => initData());
  }

  Future<void> initData() async {
    // Home shows its own loading state, so don't hold the splash for slow data.
    ref.read(initDataProvider).fetchData();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    NavigationService.navigateToReplacement(FadeRoute(page: const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColor.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_gas_station_rounded, size: 72, color: KColor.white),
            const SizedBox(height: 12),
            Text('PumpSaver', style: KTextStyle.headline4.copyWith(color: KColor.white)),
            const SizedBox(height: 4),
            Text('Cheapest fuel near you', style: KTextStyle.bodyText2.copyWith(color: KColor.primaryLight)),
          ],
        ),
      ),
    );
  }
}
