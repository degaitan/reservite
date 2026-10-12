import 'package:flutter/material.dart';

import '../../models/tables.dart';

class AvailableTablesList extends StatelessWidget {
  final List<Tables> tables;
  final Set<int> selectedTableIds;
  final void Function(Tables table, bool selected) onTableSelectionChanged;

  const AvailableTablesList({
    super.key,
    required this.tables,
    required this.selectedTableIds,
    required this.onTableSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return const Center(
        child: Text('Aucune table disponible pour cette réservation.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: tables.map(_buildTableCard).toList(),
    );
  }

  Widget _buildTableCard(Tables table) {
    final isSelected = selectedTableIds.contains(table.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (checked) {
          onTableSelectionChanged(table, checked ?? false);
        },
        title: Text('Table ${table.tableNumber}'),
        subtitle: Text(
          'Capacité: ${table.capacity} personnes',
        ),
        secondary: const Icon(Icons.table_restaurant),
      ),
    );
  }
}