import 'package:flutter/material.dart';
import 'package:prbd_2526_a03/models/reservation.dart';
import 'package:prbd_2526_a03/models/tables.dart';

class ReservationTablesCard extends StatelessWidget {
  final List<Tables>? tables;
  final Reservation reservation;

  const ReservationTablesCard({
    super.key,
    required this.tables,
    required this.reservation
  });

  @override
  Widget build(BuildContext context) {
    final reservationTables = tables ?? const <Tables>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tables assignées',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: reservationTables.isEmpty
                ? _buildEmptyMessage(context)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                reservationTables.length,
                    (index) {
                  final table = reservationTables[index];
                  final isLast = index == reservationTables.length - 1;

                  return _buildTableRow(
                    context,
                    table,
                    isLast: isLast,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(
      BuildContext context,
      Tables table, {
        required bool isLast,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          const Icon(Icons.table_restaurant, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Table ${table.tableNumber}    (${table.capacity} places)'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Aucune table assignée ${reservation.status == 'pending' ? '(en attente de confirmation)' : ''}",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}