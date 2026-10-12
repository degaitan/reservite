import 'dart:convert';

import 'package:prbd_2526_a03/core/services/api_client.dart';
import 'package:prbd_2526_a03/models/restaurant.dart';
import 'package:prbd_2526_a03/models/services.dart';

class RestaurantServices {

  static Future<List<Restaurant>> getMatchingRestaurants(String filter) async {
    final response = await ApiClient.post(
        'get_matching_restaurants',
        body: json.encode({'filter': filter}),
        anonymous: false
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch restaurants, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Restaurant.fromJson(rows)).toList();
  }

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

  static Future<List<Restaurant>> getMyRestaurants()  async{
    final response = await ApiClient.post(
      'get_my_restaurants'
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch restaurants, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Restaurant.fromJson(rows)).toList();
  }

  static Future<int> getPendingCount(int restoId) async {
    final response = await ApiClient.post(
      'get_pending_count_per_restaurant',
      body : json.encode({'_resto_id' : restoId}),
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get the count');
    }

    final dynamic body = json.decode(response.body);
    if (body is int) return body;
    if (body is String) return int.parse(body);
    return 0;
  }

}