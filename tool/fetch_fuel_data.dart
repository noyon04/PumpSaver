// Fetches every UK forecourt and its prices from the Fuel Finder API,
// merges them by node_id and writes public/stations.json for the app.
//
// Run: dart run tool/fetch_fuel_data.dart
// Needs FUEL_FINDER_CLIENT_ID and FUEL_FINDER_CLIENT_SECRET (from the Fuel Finder developer portal).
// Runs on a schedule in .github/workflows/fetch-fuel-data.yml, never in the app.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const base = 'https://www.fuel-finder.service.gov.uk';
const maxBatches = 80;

// The API allows roughly one request every 2 seconds.
const requestGap = Duration(milliseconds: 2100);

Future<void> main() async {
  final clientId = Platform.environment['FUEL_FINDER_CLIENT_ID'];
  final clientSecret = Platform.environment['FUEL_FINDER_CLIENT_SECRET'];
  if (clientId == null || clientSecret == null) {
    stderr.writeln('Set FUEL_FINDER_CLIENT_ID and FUEL_FINDER_CLIENT_SECRET.');
    exit(64);
  }

  final token = await fetchToken(clientId, clientSecret);
  final stations = await fetchAllBatches('/api/v1/pfs', token);
  final prices = await fetchAllBatches('/api/v1/pfs/fuel-prices', token);

  final pricesById = {for (final p in prices) p['node_id']: p['fuel_prices'] ?? []};
  final merged = [
    for (final s in stations)
      if ((s['location'] as Map?)?['latitude'] != null) {...s, 'fuel_prices': pricesById[s['node_id']] ?? []},
  ];

  final out = File('public/stations.json')..createSync(recursive: true);
  out.writeAsStringSync(jsonEncode(merged));
  stdout.writeln('Wrote ${merged.length} stations (${prices.length} with prices) to ${out.path}');
}

Future<String> fetchToken(String clientId, String clientSecret) async {
  final response = await http.post(
    Uri.parse('$base/api/v1/oauth/generate_access_token'),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({'client_id': clientId, 'client_secret': clientSecret}),
  );
  if (response.statusCode != 200) throw 'Token request failed: ${response.statusCode} ${response.body}';
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final data = (body['data'] as Map<String, dynamic>?) ?? body;
  return data['access_token'] as String;
}

/// Pages through `batch-number` until an empty batch or a 404.
Future<List<Map<String, dynamic>>> fetchAllBatches(String path, String token) async {
  final all = <Map<String, dynamic>>[];
  for (var batch = 1; batch <= maxBatches; batch++) {
    final response = await getWithRetry(Uri.parse('$base$path?batch-number=$batch'), token);
    if (response.statusCode == 404 && batch > 1) break;
    if (response.statusCode != 200) throw 'GET $path batch $batch failed: ${response.statusCode} ${response.body}';

    final records = extractRecords(jsonDecode(response.body));
    if (records.isEmpty) break;
    all.addAll(records);
    stdout.writeln('$path batch $batch: ${records.length} records');
    await Future.delayed(requestGap);
  }
  return all;
}

Future<http.Response> getWithRetry(Uri url, String token) async {
  for (var attempt = 0; ; attempt++) {
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode != 429 || attempt == 3) return response;
    final wait = int.tryParse(response.headers['retry-after'] ?? '') ?? 5 * (1 << attempt);
    stdout.writeln('Rate limited, waiting ${wait}s');
    await Future.delayed(Duration(seconds: wait));
  }
}

/// The response may be a bare list or a list wrapped in an object (e.g. {"data": [...]}).
List<Map<String, dynamic>> extractRecords(dynamic body, [int depth = 0]) {
  if (body is List) return body.whereType<Map<String, dynamic>>().toList();
  if (body is Map && depth < 3) {
    for (final value in body.values) {
      final records = extractRecords(value, depth + 1);
      if (records.isNotEmpty) return records;
    }
  }
  return const [];
}
