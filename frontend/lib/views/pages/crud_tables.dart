import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/providers/manager_state_provider.dart';
import 'package:prbd_2526_a03/views/pages/edit_tables.dart';
import 'package:prbd_2526_a03/views/widgets/time_travel_widget.dart';

import '../../models/tables.dart';


class RestaurantManagementTablesScreen extends ConsumerStatefulWidget {
  const RestaurantManagementTablesScreen({super.key});

  @override
  ConsumerState<RestaurantManagementTablesScreen> createState() => _RestaurantManagementTablesScreen();
}

  class _RestaurantManagementTablesScreen extends ConsumerState<RestaurantManagementTablesScreen> {
  //pas oublier d'initier ici car le load ne se fait pas dans le build du provider
    @override
    void initState() {
      super.initState();
      Future.microtask(() =>
          ref.read(managerStateProvider.notifier).loadTables());
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(managerStateProvider);

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
      data: (state) {
          final restaurant = state.currentRestaurant;
          final tables = state.tablesPerRestaurant;


          return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title:  Text(restaurant!.name),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Rafraîchir les données',
                onPressed: () => ref.read(managerStateProvider.notifier).loadTables(),
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
            child: Stack(
              children: [
            tables.isEmpty
            ? const Center(child: Text('Aucune table à afficher. Ajoutez-en une avec le bouton +'))
                  : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: tables.map((table) => _buildCard(context, table)).toList(),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'tables_fab',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditTableScreen(table : null),
                        ),
                        ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 2,
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
      }
    );
  }

  Widget _buildCard(BuildContext context, Tables table){
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.table_restaurant, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Table ${table.tableNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${table.capacity} personnes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTableScreen(table : table),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
