import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/providers/manager_state_provider.dart';

import '../../providers/current_user_provider.dart';
import '../widgets/manager_restaurant_card.dart';
import '../widgets/time_travel_widget.dart';

class MyRestaurantsScreen extends ConsumerStatefulWidget {
  const MyRestaurantsScreen({super.key});


  @override
  ConsumerState<MyRestaurantsScreen> createState() => _MyRestaurantsScreen();
}

class _MyRestaurantsScreen extends ConsumerState<MyRestaurantsScreen> {

  Future<void> _logout(BuildContext context) async{
    await ref.read(currentUserProvider.notifier).logout();
    if(!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes restaurants'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => notifier.refreshRestaurants(),
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
        child: state.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),

          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),

          data: (managerState) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: managerState.restaurants.length,
              itemBuilder: (context, index) {
                return ManagerRestaurantCard(
                  restaurant: managerState.restaurants[index],
                  onTap: () async {
                    await ref
                        .read(managerStateProvider.notifier)
                        .selectRestaurant(managerState.restaurants[index]);

                    if (context.mounted) {
                      Navigator.pushNamed(
                        context,
                        '/restaurant_management_reservations',
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
