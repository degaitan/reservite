import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a03/models/reservation.dart';

import '../../models/tables.dart';
import 'api_client.dart';

class TablesService {
  static Future<List<Tables>> getTablesForReservation(int reservationId) async {
    final response = await ApiClient.post(
        'get_tables_for_reservation',
        body: json.encode({'reservation_id': reservationId}),
        anonymous: false
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch restaurants, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Tables.fromJson(rows)).toList();
  }

  static Future<List<Tables>> getAllAvailableTables(int reservationId) async {
    final response = await ApiClient.post(
      'get_all_available_tables',
      body: json.encode({
        'reservation_id': reservationId,
      }),
      anonymous: false,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch available tables, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;

    return rows.map((row) => Tables.fromJson(row)).toList();
  }

  static Future<void> assignTablesToReservation(Reservation reservation, List<int> tableIds) async {
    final response = await ApiClient.post(
      'assign_tables_to_reservation',
      body: json.encode({
        'reservation_id': reservation.id,
        'guests': reservation.numberOfGuests,
        'table_ids': tableIds
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to assign tables to reservation');
    }
  }

  static Future<List<Tables>> getTablesPerRestaurant(int restoId) async {
    final response = await ApiClient.post(
      'get_tables_per_restaurant',
      body : json.encode({'resto_id': restoId})
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get tables per restaurant');
    }
    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((row) => Tables.fromJson(row)).toList();
  }

  static Future<int> saveTable(int restoId, int tableNumber, int tableCapacity, int? tableId) async {
    final response = await ApiClient.post(
      'save_table',
      body : json.encode({
        'resto_id' : restoId,
        '_table_number' : tableNumber,
        'table_capacity' : tableCapacity,
        'table_id' : tableId
      })
    );

    if(response.statusCode != 200){
      throw Exception('Failed to save table');
    }

    final dynamic body = json.decode(response.body);
    return body is int ? body : body.first.values.first as int;
  }
}