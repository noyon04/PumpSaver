import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderObserverContext context, Object? previousValue, Object? newValue) {
    if (kDebugMode) debugPrint('["didUpdateProvider": "${context.provider.name ?? context.provider.runtimeType}", "newValue": "$newValue"]');
  }
}
