import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/restaurant.dart';
import '../../providers/client_state_provider.dart';

class RestaurantCard extends ConsumerWidget {
  final Restaurant restaurant;


  const RestaurantCard({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientStateProvider);
    final notifier = ref.read(clientStateProvider.notifier);
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
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  restaurant.latestReservation != null ? '${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(restaurant.latestReservation!)} à ${DateFormat('HH:mm').format(restaurant.latestReservation!)}' : "",
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await notifier.selectRestaurant(restaurant);
          if (context.mounted) {
            Navigator.pushNamed(context, '/restaurant_details');
          }
        },
      ),
    );
  }
}