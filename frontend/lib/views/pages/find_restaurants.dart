import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/core/tools/constants.dart';
import 'package:prbd_2526_a03/providers/client_state_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/time_travel_widget.dart';
import '../widgets/too_many_results_banner.dart';


class FindRestaurantsScreen extends ConsumerWidget {
  const FindRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientStateProvider);
    final notifier = ref.read(clientStateProvider.notifier);
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Rechercher un restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              notifier.refresh();
            },
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
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom, ville, description...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => notifier.refreshRestaurants(value),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  if (state.value!.restaurants.length > Constants.maxRestaurants)
                    const TooManyResultsBanner(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),

                      itemCount: state.value!.restaurants.length >
                          Constants.maxRestaurants
                          ? Constants.maxRestaurants
                          : state.value!.restaurants.length,

                      itemBuilder: (context, index) {
                        return RestaurantCard(
                          restaurant:
                          state.value!.restaurants[index],
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
        ],
      ),
      ),
    );
  }
}
