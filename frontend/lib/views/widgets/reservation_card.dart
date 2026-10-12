import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/reservation.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final String clientName;
  final String nameResto;
  final IconData cardIcon;
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.clientName,
    required this.nameResto,
    required this.cardIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE dd/MM/yyyy', 'fr_FR')
        .format(reservation.dateTime);
    final time = DateFormat('HH:mm').format(reservation.dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _statusIcon(reservation.status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(cardIcon, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            nameResto,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$date à $time',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${reservation.numberOfGuests} convives',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Tooltip(
          message: 'En attente',
          child: Icon(Icons.pending, size: 32, color: Colors.orange),
        );
      case 'confirmed':
        return const Tooltip(
          message: 'Confirmée',
          child: Icon(Icons.check_circle, size: 32, color: Colors.green),
        );
      case 'cancelled':
        return const Tooltip(
          message: 'Annulée',
          child: Icon(Icons.cancel, size: 32, color: Colors.red),
        );
      case 'completed':
        return const Tooltip(
          message: 'Terminée',
          child: Icon(Icons.event_available, size: 32, color: Colors.blue),
        );
      default:
        return const Icon(Icons.help, size: 32);
    }
  }
}