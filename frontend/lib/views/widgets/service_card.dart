import 'package:flutter/material.dart';
import '../../models/services.dart';

class ServiceCard extends StatelessWidget {
  final String dayName;
  final List<Services> services;
  final void Function(Services service)? onEdit;
  final void Function(Services service)? onDelete;
  final bool Function(Services service)? canDelete;

  const ServiceCard({
    super.key,
    required this.dayName,
    required this.services,
    this.onEdit,
    this.onDelete,
    this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.grey[100],
        child: ListTile(
          leading: const Icon(Icons.schedule, color: Colors.grey),
          title: Text(
            dayName,
            style: TextStyle(color: Colors.grey[600]),
          ),
          subtitle: const Text(
            'Aucun service',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (services.length == 1) {
      final service = services.first;

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(dayName),
          subtitle: Text(_serviceLabel(service)),
          trailing: _buildActions(service),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.schedule),
        title: Text(dayName),
        subtitle: Text(
          services.map(_serviceLabel).join(', '),
        ),
        children: services.map((service) {
          return ListTile(
            title: Text(_serviceLabel(service)),
            trailing: _buildActions(service),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions(Services service) {
    final isDeletable = canDelete?.call(service) ?? true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => onEdit?.call(service),
        ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: isDeletable ? Colors.red : Colors.grey[400],
          ),
          onPressed: isDeletable
              ? () => onDelete?.call(service)
              : null,
          tooltip: isDeletable
              ? 'Supprimer le service'
              : 'Impossible de supprimer : des réservations non annulées utilisent ce service',
        ),
      ],
    );
  }

  String _serviceLabel(Services service) {
    return formatServices(service);
  }

  String formatServices(Services? service) {
    if (service == null) {
      return 'Fermé';
    }
      return '${service.startTime.substring(0, 5)} - ${service.endTime.substring(0, 5)}';
  }
}