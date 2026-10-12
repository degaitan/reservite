
import 'dart:convert';

import 'package:prbd_2526_a03/core/services/api_client.dart';

class TimeServices {
  static Future<DateTime?> getSimulatedTime() async {
    final response = await ApiClient.post(
      'get_simulated_time',
        anonymous: true
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get simulated time');
    }

    final dynamic body = json.decode(response.body);

    final value = body is String ? body : (body is List && body.isNotEmpty ? body.first : null);
    if (value == null) return null;
    return DateTime.parse(value);

  }

  static Future<void> saveSimulatedTime(DateTime time) async {
    final response = await ApiClient.post(
      'save_simulated_time',
          body : json.encode({'_timestamp':time.toIso8601String()}),
        anonymous: true
    );

    if(response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to set simulated time');

    }
  }
}