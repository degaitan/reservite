import 'dart:convert';
import '../../models/services.dart';
import 'api_client.dart';

class ServiceServices {

  static Future<List<Services>> getServices(int restaurantId) async {
    final response = await ApiClient.post(
        'get_services',
        body: json.encode({'restaurant_id': restaurantId}),
        anonymous: false
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch services, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Services.fromJson(rows)).toList();
  }

  static Future<void> setService(
      int serviceId,
      int dayOfWeek,
      String startTime,
      String endTime,
      ) async {
    final response = await ApiClient.post(
      'set_service',
      body: json.encode({
        'service_id': serviceId,
        'new_day_of_week': dayOfWeek,
        'new_start_time': startTime,
        'new_end_time': endTime,
      }),
      anonymous: false,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to update service: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<void> deleteService(int serviceId) async {
    final response = await ApiClient.post(
      'delete_service',
      body: json.encode({
        'service_id': serviceId,
      }),
      anonymous: false,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete service: ${response.statusCode} ${response.body}',
      );
    }
  }
}