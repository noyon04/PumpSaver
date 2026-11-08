import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pump_saver/network/api.dart';
import 'package:pump_saver/views/styles/k_colors.dart';

class Network {
  static String noInternetMessage = 'Check your connection!';

  static Future<Response> getRequest(String endPoint, {bool noBaseUrl = false}) async {
    if (!await isNetworkAvailable()) throw noInternetMessage;

    final url = noBaseUrl ? endPoint : '${API.LIVE}$endPoint';
    if (kDebugMode) debugPrint('\nURL: $url');

    return get(Uri.parse(url), headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 20));
  }

  /// Returns the decoded body on success, or null after showing a toast.
  static dynamic handleResponse(Response response) {
    if (response.statusCode >= 200 && response.statusCode <= 210) {
      if (kDebugMode) debugPrint('SuccessCode: ${response.statusCode}, ${response.bodyBytes.length} bytes');
      return response.body.isNotEmpty ? json.decode(response.body) : response.body;
    }

    if (kDebugMode) debugPrint('ErrorCode: ${response.statusCode}\nErrorResponse: ${response.body}');
    toast('Something went wrong! (${response.statusCode})', bgColor: KColor.expensive);
    return null;
  }
}
