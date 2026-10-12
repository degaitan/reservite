import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../providers/manager_state_provider.dart';
import '../widgets/available_tables_list.dart';
import '../widgets/time_travel_widget.dart';

class AssignTablesScreen extends ConsumerStatefulWidget {
  const AssignTablesScreen({super.key});

  @override
  ConsumerState<AssignTablesScreen> createState() => _AssignTablesScreenState();
}

class _AssignTablesScreenState extends ConsumerState<AssignTablesScreen> {
  final Set<int> _selectedTableIds = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);
    final theme = Theme.of(context);

    return state.when(
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          body: Center(
            child: Text(error.toString()),
          ),
        ),
        data: (managerState) {
          final reservation = managerState.currentReservation;
          final availableTables = managerState.availableTables;


          if (reservation == null) {
            return const Scaffold(
              body: Center(
                child: Text('Réservation non sélectionnée.'),
              ),
            );
          }

          final selectedTables = availableTables
              .where((table) => _selectedTableIds.contains(table.id))
              .toList();

          final selectedCapacity = selectedTables.fold<int>(
            0,
                (total, table) => total + table.capacity,
          );

          final hasEnoughCapacity =
              selectedCapacity >= reservation.numberOfGuests;

          final date = DateFormat('dd/MM/yyyy', 'fr_FR')
              .format(reservation.dateTime);
          final time = DateFormat('HH:mm').format(reservation.dateTime);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Assigner des tables'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Rafraîchir les données',
                onPressed: () => notifier.refreshAvailableTablesForCurrentReservation(),
              ),
            ],
            elevation: 2,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                    child: TimeTravelWidget()
                      ),
                    ),
                  ),
                ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Réservation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${reservation.numberOfGuests} convives'),
                          Text('$date à $time'),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: hasEnoughCapacity
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            hasEnoughCapacity
                                ? Icons.check_circle
                                : Icons.warning,
                            color: hasEnoughCapacity
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Capacité totale: $selectedCapacity places',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasEnoughCapacity
                                      ? '✓ Capacité suffisante pour ${reservation.numberOfGuests} convives'
                                      : '⚠ Capacité insuffisante pour ${reservation.numberOfGuests} convives',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hasEnoughCapacity
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sélectionnez les tables disponibles',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AvailableTablesList(
                    tables: availableTables,
                    selectedTableIds: _selectedTableIds,
                    onTableSelectionChanged: (table, selected) {
                      setState(() {
                        if (selected) {
                          _selectedTableIds.add(table.id);
                        } else {
                          _selectedTableIds.remove(table.id);
                        }
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasEnoughCapacity
                          ? () async {
                        try {
                          await notifier.assignTablesToCurrentReservation(_selectedTableIds.toList());

                          if (!context.mounted) return;

                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/restaurant_management_reservations'),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirmer la réservation'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
