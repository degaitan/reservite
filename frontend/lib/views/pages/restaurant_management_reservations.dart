import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/reservation.dart';
import '../../providers/manager_state_provider.dart';
import '../widgets/reservation_card.dart';
import '../widgets/time_travel_widget.dart';

class RestaurantManagementReservationsScreen extends ConsumerStatefulWidget {
  const RestaurantManagementReservationsScreen({super.key});

  @override
  ConsumerState<RestaurantManagementReservationsScreen> createState() =>
      _RestaurantManagementReservationsScreenState();
}

class _RestaurantManagementReservationsScreenState
    extends ConsumerState<RestaurantManagementReservationsScreen> {
  String _selectedStatus = 'all';

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
        final restaurant = managerState.currentRestaurant;

        if (restaurant == null) {
          return const Scaffold(
            body: Center(
              child: Text('Aucun restaurant sélectionné.'),
            ),
          );
        }

        final filteredReservations = _filterByStatus(
          managerState.reservations,
          _selectedStatus,
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.popUntil(
                context,
                ModalRoute.withName('/home_manager'),
              ),
            ),
            title: Text(restaurant.name),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Rafraîchir les données',
                onPressed: () =>
                    notifier.refreshReservationsForCurrentRestaurant(),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        icon: Icon(Icons.list, size: 24),
                        tooltip: 'Toutes',
                      ),
                      ButtonSegment(
                        value: 'pending',
                        icon: Icon(
                          Icons.pending,
                          size: 24,
                          color: Colors.orange,
                        ),
                        tooltip: 'En attente',
                      ),
                      ButtonSegment(
                        value: 'confirmed',
                        icon: Icon(
                          Icons.check_circle,
                          size: 24,
                          color: Colors.green,
                        ),
                        tooltip: 'Confirmées',
                      ),
                      ButtonSegment(
                        value: 'completed',
                        icon: Icon(
                          Icons.event_available,
                          size: 24,
                          color: Colors.blue,
                        ),
                        tooltip: 'Terminées',
                      ),
                      ButtonSegment(
                        value: 'cancelled',
                        icon: Icon(
                          Icons.cancel,
                          size: 24,
                          color: Colors.red,
                        ),
                        tooltip: 'Annulées',
                      ),
                    ],
                    selected: {_selectedStatus},
                    onSelectionChanged: (values) {
                      setState(() {
                        _selectedStatus = values.first;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredReservations.isEmpty
                      ? const Center(
                    child: Text('Aucune réservation à afficher.'),
                  )
                      : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: filteredReservations
                        .map(_buildReservationCard)
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 0,
            onTap: (index) {
              const addr = ['/restaurant_management_reservations', '/manage_services', '/manage_tables'];
              if (index !=  0) {
                Navigator.pushNamed(context, addr[index]);
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Réservations',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.table_restaurant),
                label: 'Tables',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return ReservationCard(
      reservation: reservation,
      clientName: reservation.clientName ?? 'Client inconnu',
      nameResto: reservation.restoName,
      cardIcon: Icons.restaurant,
      onTap: () async {
        await ref.read(managerStateProvider.notifier).selectReservation(reservation);
        if (context.mounted) {
          Navigator.pushNamed(
              context,
              '/reservation_details_manager');
        }
      },
    );
  }

  List<Reservation> _filterByStatus(
      List<Reservation> reservations,
      String status,
      ) {
    if (status == 'all') return reservations;

    return reservations
        .where((reservation) => reservation.status == status)
        .toList();
  }
}