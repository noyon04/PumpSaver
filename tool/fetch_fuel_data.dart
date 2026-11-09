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

  try {
    await fetchAndWrite(clientId, clientSecret);
  } catch (error) {
    // An ::error:: line becomes a GitHub annotation, readable without access to the run logs.
    final message = '$error'.replaceAll('\r', '').replaceAll('\n', '%0A');
    stdout.writeln('::error title=Fuel Finder fetch failed::${message.length > 1500 ? message.substring(0, 1500) : message}');
    exit(1);
  }
}

Future<void> fetchAndWrite(String clientId, String clientSecret) async {
  final token = await fetchToken(clientId, clientSecret);
  final stations = await fetchAllBatches('/api/v1/pfs', token);
  final prices = await fetchAllBatches('/api/v1/pfs/fuel-prices', token);

  final pricesById = {for (final p in prices) p['node_id']: (p['fuel_prices'] as List?) ?? const []};
  final merged = [
    for (final s in stations)
      if ((s['location'] as Map?)?['latitude'] != null && s['permanent_closure'] != true && (pricesById[s['node_id']]?.isNotEmpty ?? false))
        slim(s, pricesById[s['node_id']]!),
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
  if (response.statusCode != 200) throw 'Token request failed: ${describe(response)}';
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final data = (body['data'] as Map<String, dynamic>?) ?? body;
  return data['access_token'] as String;
}

/// Only the fields the app reads, so phones download about a third of the raw size.
Map<String, dynamic> slim(Map<String, dynamic> s, List prices) {
  final location = s['location'] as Map;
  return {
    'node_id': s['node_id'],
    'trading_name': s['trading_name'],
    'brand_name': s['brand_name'],
    'is_motorway_service_station': s['is_motorway_service_station'],
    'is_supermarket_service_station': s['is_supermarket_service_station'],
    'temporary_closure': s['temporary_closure'],
    'location': {for (final k in ['address_line_1', 'address_line_2', 'city', 'postcode', 'latitude', 'longitude']) k: location[k]},
    'amenities': s['amenities'],
    'opening_times': {'usual_days': (s['opening_times'] as Map?)?['usual_days']},
    'fuel_prices': [
      for (final p in prices) {'fuel_type': p['fuel_type'], 'price': p['price'], 'price_last_updated': p['price_last_updated']},
    ],
  };
}

/// Status, body and the headers that show which server or firewall answered.
String describe(http.Response response) {
  const keep = ['server', 'via', 'x-cache', 'x-amz-cf-pop', 'x-amzn-waf-action', 'cf-ray', 'x-azure-ref', 'content-type'];
  final headers = {for (final k in keep) if (response.headers[k] != null) k: response.headers[k]};
  return '${response.statusCode} headers=$headers body=${response.body}';
}

/// Pages through `batch-number` until an empty batch or a 404.
Future<List<Map<String, dynamic>>> fetchAllBatches(String path, String token) async {
  final all = <Map<String, dynamic>>[];
  for (var batch = 1; batch <= maxBatches; batch++) {
    final response = await getWithRetry(Uri.parse('$base$path?batch-number=$batch'), token);
    if (response.statusCode == 404 && batch > 1) break;
    if (response.statusCode != 200) throw 'GET $path batch $batch failed: ${describe(response)}';

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
