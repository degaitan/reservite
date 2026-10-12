import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/providers/manager_state_provider.dart';

import '../../core/services/reservation_services.dart';
import '../../core/services/restaurant_services.dart';
import '../../models/restaurant.dart';
import '../../providers/client_state_provider.dart';
import '../../providers/reference_time_provider.dart';

class ManagerRestaurantCard extends ConsumerWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;


  const ManagerRestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(managerStateProvider.notifier);
    String currencyLogo = '';
    if (restaurant.priceRange != null) {
      currencyLogo =
          '€' * restaurant.priceRange!;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const Icon(Icons.restaurant, size: 40),
        title: Text(this.restaurant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(restaurant.city),
                const SizedBox(width: 12),
                const Icon(Icons.star,
                    size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  restaurant.rating.toString(),
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Text(
                  currencyLogo,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (restaurant.latestReservation != null) ...[
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                    'Dernière réservation: ${_formatRelative(restaurant.latestReservation!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            ],
            const SizedBox(height: 4),
            FutureBuilder<int>(
              future: RestaurantServices.getPendingCount(restaurant.id),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return Row(
                  children: [
                    const Icon(Icons.pending, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$count demande${count > 1 ? 's' : ''} en attente',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await notifier.selectRestaurant(restaurant);
          if (context.mounted) {
            Navigator.pushNamed(context, '/restaurant_management_reservations');
          }
        },
      ),
    );
  }
  String _formatRelative(DateTime last) {
    return DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(last);
  }
}