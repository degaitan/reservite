import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Tables {
  final int id;
  final int restaurant;
  final int tableNumber;
  final int capacity;
  //limite en dessous de laquelle on peut pas descendre car il ya une resa existante
  final int? minCapacityNeeded;

  const Tables({
    required this.id,
    required this.restaurant,
    required this.tableNumber,
    required this.capacity,
    this.minCapacityNeeded
});

  factory Tables.fromJson(Map<String, dynamic> json) {
    return Tables(
      id: json['id'],
      restaurant: json['restaurant'],
      tableNumber: json['table_number'],
      capacity: json['capacity'],
      minCapacityNeeded: json['min_needed_capacity']
    );
  }
}