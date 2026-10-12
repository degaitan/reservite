import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/models/reservation.dart';
import 'package:prbd_2526_a03/views/pages/reservation_details.dart';

import '../../providers/client_state_provider.dart';
import '../../providers/current_user_provider.dart';
import '../widgets/time_travel_widget.dart';

class MyReservationsScreen extends ConsumerStatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  ConsumerState<MyReservationsScreen> createState() => _MyReservationsScreen();
}

class _MyReservationsScreen extends ConsumerState<MyReservationsScreen> {

  String _selectedStatus = 'pending';

  Future<void> _logout(BuildContext context) async{
    await ref.read(currentUserProvider.notifier).logout();
    if(!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(clientStateProvider);
    final notifier = ref.read(clientStateProvider.notifier);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/find_restaurants'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => notifier.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => _logout(context),
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
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: {_selectedStatus},
                onSelectionChanged: (filteredList) => setState(() => _selectedStatus = filteredList.first),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: asyncState.when(data: (unfilteredList) {
                final filteredList = _filterByStatus(unfilteredList.reservations, _selectedStatus);
                return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: filteredList.map(_buildCard).toList(),
                );
              },
                  loading : () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child : Text('$e')),
            ),
            ),
      ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/find_restaurants'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }

  Widget _buildCard(Reservation r){
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          ref.read(clientStateProvider.notifier).loadReservationDetails(r.id);
          Navigator.push(
            context,
            MaterialPageRoute(
            builder: (_) => ReservationDetailsScreen(id: r.id),
          ),);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _statusIcon(r.status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      r.restoName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          r.city!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                            '${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(r.dateTime)} à ${DateFormat('HH:mm').format(r.dateTime)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${r.numberOfGuests} convives',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

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

  List<Reservation> _filterByStatus(List<Reservation> unfilteredList, String status){
    if(status == 'all') return unfilteredList;
    return unfilteredList.where((r) => r.status==status).toList();
  }
}
