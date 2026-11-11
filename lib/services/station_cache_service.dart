import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps the last downloaded stations.json on the device, so the app still works with no signal.
/// Not available on web (no file system), where every method is a no-op.
class StationCacheService {
  static Future<File> _file() async => File('${(await getApplicationSupportDirectory()).path}/stations.json');

  static Future<void> write(String body) async {
    if (kIsWeb) return;
    try {
      await (await _file()).writeAsString(body, flush: true);
    } catch (error) {
      if (kDebugMode) debugPrint('Cache write failed: $error');
    }
  }

  /// The saved body and when it was saved, or null if there is none.
  static Future<({String body, DateTime savedAt})?> read() async {
    if (kIsWeb) return null;
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      return (body: await file.readAsString(), savedAt: await file.lastModified());
    } catch (error) {
      if (kDebugMode) debugPrint('Cache read failed: $error');
      return null;
    }
  }
}
