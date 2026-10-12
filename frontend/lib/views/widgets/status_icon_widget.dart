import 'package:flutter/material.dart';

Widget _statusIcon(String status) {
  switch (status) {
    case 'pending':
      return Tooltip(message: 'En attente', child: const Icon(Icons.pending, size: 32, color: Colors.orange));
    case 'confirmed':
      return Tooltip(message: 'Confirmée', child: const Icon(Icons.check_circle, size: 32, color: Colors.green));
    case 'cancelled':
      return Tooltip(message: 'Annulée', child: const Icon(Icons.cancel, size: 32, color: Colors.red));
    case 'completed':
      return Tooltip(message: 'Terminée', child: const Icon(Icons.event_available, size: 32, color: Colors.blue));
    default:
      return const Icon(Icons.help);
  }
}