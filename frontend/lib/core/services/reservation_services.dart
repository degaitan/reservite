import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a03/core/services/api_client.dart';
import 'package:prbd_2526_a03/models/no_slots_reason.dart';
import 'package:prbd_2526_a03/models/reservation.dart';

class ReservationServices {

  static Future<List<Reservation>> getMyReservations() async {
    final response = await ApiClient.post(
      'get_my_reservations'
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get reservations');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((row) => Reservation.fromJson(row)).toList();
  }

  static Future<Reservation> getReservationDetails(int id) async {
    final response = await ApiClient.post(
      'get_reservation_details',
      body : json.encode({'_id' : id})
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get reservation details');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return Reservation.fromJson(rows.first);

  }

  static Future<List<DateTime>> getAvailableSlotsForDate(int restoId, DateTime date, int numberOfGuests, [int? excluded]) async{
    final response = await ApiClient.post(
      'get_available_slots_for_date',
      body : json.encode({'_restaurant' : restoId,
        '_date' : date.toIso8601String(),
        '_number_of_guests' : numberOfGuests,
        '_exclude_id_for_edit' : excluded
      })
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get available slots');
    }
    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((row) => DateTime.parse(row['slot_datetime'])).toList();
  }

  static Future<NoSlotsReason> getSpecificErrorIfNoSlots(int restoId, DateTime date) async {
    final response = await ApiClient.post(
      'get_specific_error_if_no_slots',
      body: json.encode({'_restaurant' : restoId, '_date' : date.toIso8601String()})
    );
    if(response.statusCode != 200){
      throw Exception('Failed to get available slots');
    }
    final dynamic body = json.decode(response.body);
    final String value = body is String ? body : body.toString();

    return _setReason(body);

  }

  static NoSlotsReason _setReason(String value) {
    switch (value) {
      case 'closed': return NoSlotsReason.closed;
      case 'already_booked_service': return NoSlotsReason.alreadyBookedService;
      case 'no_capacity': return NoSlotsReason.noCapacity;
      default: throw Exception('Unknown no_slots_reason: $value');
    }
  }
//[] pour dire que c'est optionnel, on  appeler la méthode avec ou sans ce param, null si on veut edit
  static Future<bool> checkCapacity(int restoId, int numberOfGuests, DateTime slot, [int? excluded]) async {
    final response = await ApiClient.post(
      'check_capacity',
      body : json.encode({'_restaurant' : restoId, '_number_of_guests' : numberOfGuests, '_date' : slot.toIso8601String(), '_exclude_id_for_edit' : excluded})
    );
    if(response.statusCode != 200){
      throw Exception('Failed to check capacity');
    }

    final dynamic body = json.decode(response.body);
    return body is bool ? body : body.first.values.first as bool;
  }

  static Future<int> saveReservation(int? resaId, int restoId, DateTime date, int numberOfGuests, String status, String? specialRequest) async {
    final response = await ApiClient.post(
      'save_reservation',
      body : json.encode({
        '_id' : resaId,
        '_restaurant' : restoId,
        '_date' : date.toIso8601String(),
        '_number_of_guests' : numberOfGuests,
        '_status' : status,
        '_special_request' : specialRequest })
    );

    if(response.statusCode != 200){
      throw Exception('Failed to save reservation');
    }

    final dynamic body = json.decode(response.body);
    return body is int ? body : body.first.values.first as int;

  }

  static Future<bool> canCancel(int resaId) async {
    final response = await ApiClient.post(
      'can_cancel',
      body : json.encode({'_resa_id' : resaId})
    );
    if(response.statusCode != 200){
      throw Exception('Failed to check');
    }

    final dynamic body = json.decode(response.body);

    return body is bool ? body : body.first.values.first as bool;
  }

  static Future<void> cancelReservation(int resaId) async {
    final response = await ApiClient.post(
        'cancel_reservation',
        body : json.encode({'_resa_id' : resaId})
    );

    if(response.statusCode != 200 && response.statusCode != 204){
      // print('CANCEL FAILED: ${response.statusCode} ${response.body}');
      throw Exception('Failed to cancel the reservation');
    }
  }

  static Future<List<Reservation>> getAllReservationsForRestaurant(int restaurantId) async {
    final response = await ApiClient.post(
      'get_all_reservations_for_restaurant',
      body: json.encode({
        'restaurant_id': restaurantId
      })
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get reservations, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Reservation.fromJson(rows)).toList();
  }

  static Future<void> completeReservation(int resaID) async {
    final response = await ApiClient.post(
      'complete_reservation',
      body : json.encode({'_resa_id' : resaID})
    );

    if(response.statusCode != 200 && response.statusCode != 204){
      throw Exception('Failed to complete reservation');
    }
  }
}