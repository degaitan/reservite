import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/providers/manager_state_provider.dart';
import 'package:prbd_2526_a03/providers/reference_time_provider.dart';
import 'package:prbd_2526_a03/views/widgets/reservation_tables_card.dart';
import 'package:prbd_2526_a03/views/widgets/time_travel_widget.dart';

import '../../core/services/reservation_services.dart';

class ReservationDetailsManagerScreen extends ConsumerWidget {
  const ReservationDetailsManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          final customer = managerState.currentCustomer;
          final tables = managerState.currentTables;

          if (reservation == null || customer == null) {
            return const Scaffold(
              body: Center(
                child: Text('Réservation ou client non sélectionnés.'),
              ),
            );
          }


          final referenceTime = ref.watch(referenceTimeProvider);
          final canComplete = !reservation.dateTime.isAfter(referenceTime);

          final date = DateFormat('EEE dd/MM/yyyy', 'fr_FR')
              .format(reservation.dateTime);
          final time = DateFormat('HH:mm').format(reservation.dateTime);

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Détails de la réservation'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Rafraîchir les données',
                  onPressed: () => notifier.refreshReservationDetails(),
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
                    child: TimeTravelWidget(),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations client',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person, size: 20),
                                SizedBox(width: 8),
                                Text('Nom: ${customer.name}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email, size: 20),
                                SizedBox(width: 8),
                                Text('Email: ${customer.email}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Téléphone: ${customer.phoneNumber ?? 'Non renseigné'}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Détails de la réservation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.restaurant, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reservation.restoName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Date: $date',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 20),
                                const SizedBox(width: 8),
                                Text('Heure: $time'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.people, size: 20),
                                const SizedBox(width: 8),
                                Text('Nombre de convives: ${reservation.numberOfGuests}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.info, size: 20),
                                const SizedBox(width: 8),
                                const Text('Statut: '),
                                _statusIcon(reservation.status)
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              'Demandes spéciales',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reservation.specialRequests ?? "Aucune",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReservationTablesCard(tables: tables, reservation: reservation),
                    if (reservation.status != 'completed' && reservation.status != 'cancelled') ...[
                      if (reservation.status == 'confirmed') ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: canComplete ? () => _confirmComplete(context, ref, reservation.id) : null,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Marquer comme terminée'),
                        ),
                        if(!canComplete)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'La réservation ne peut être terminée que durant son service ou après celui-ci.',
                              style: TextStyle(fontSize: 12, color: Colors.red[600]),
                            ),
                          ),
                      ],

                      if (reservation.status == 'pending') ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/assign_tables'),
                          icon: const Icon(Icons.table_restaurant),
                          label: const Text('Confirmer et assigner tables'),
                        ),
                      ],
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _confirmCancel(context, ref, reservation.id),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Annuler'),
                        ),
                    ]],
                ),
              ),
            ),
          );
        }
    );
  }
  Future<void> _confirmCancel(BuildContext context, WidgetRef ref, int resaId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Annuler la réservation'),
          content: const Text('Êtes-vous sûr de vouloir annuler cette réservation?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Non')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Oui')),
          ]
      ),

    );

    if (confirmed != true) return;

    await ReservationServices.cancelReservation(resaId);

    if (!context.mounted) return;

    final notifier = ref.read(managerStateProvider.notifier);
    await notifier.refreshReservationsForCurrentRestaurant();
    await notifier.refreshRestaurants();

    final list = ref.read(managerStateProvider).value!.reservations;
    await notifier.selectReservation(list.firstWhere((r) => r.id == resaId));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green),
    );

  }

  Widget _statusIcon(String status){
    switch (status) {
      case 'pending':
        return Chip(
          label: const Text(
            'En attente',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFF9800),
          padding: EdgeInsets.zero,
        );
      case 'confirmed':
        return Chip(
          label: const Text(
            'Confirmée',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor:  Colors.green,
          padding: EdgeInsets.zero,
        );
      case 'cancelled':
        return Chip(
          label: const Text(
            'Annulée',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor:  Colors.red,
          padding: EdgeInsets.zero,
        );
      case 'completed':
        return Chip(
          label: const Text(
            'Terminée',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor:  Colors.blue,
          padding: EdgeInsets.zero,
        );
      default:
        return const Icon(Icons.help);
    }
  }
  Future<void> _confirmComplete(BuildContext context, WidgetRef ref, int resaId) async{
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Terminer la réservation'),
            content: const Text(
                'Voulez-vous marquer cette réservation comme terminée?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: const Text('Non')),
              TextButton(onPressed: () => Navigator.pop(context, true),
                  child: const Text('Oui')),
            ],
          ),
    );

    if(agreed!= true) return;

    await ReservationServices.completeReservation(resaId);
    if(!context.mounted) return;

    final notifier = ref.read(managerStateProvider.notifier);
    await notifier.refreshReservationsForCurrentRestaurant();
    await notifier.refreshRestaurants();

    final list = ref.read(managerStateProvider).value!.reservations;
    await notifier.selectReservation(list.firstWhere((r) => r.id == resaId));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réservation marquée comme terminée'), backgroundColor: Colors.black),
    );
  }
}
