import 'dart:convert';

import 'package:prbd_2526_a03/models/customer.dart';

import 'api_client.dart';

class CustomerServices {

  static Future<Customer> getUserByName(String userName) async {
    final response = await ApiClient.post(
        'get_user_by_name',
        body: json.encode({'user_name': userName})
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get reservation details');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return Customer.fromJson(rows.first);
  }
}