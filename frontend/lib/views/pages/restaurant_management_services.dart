import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/providers/manager_state_provider.dart';

import '../../models/reservation.dart';
import '../../models/services.dart';
import '../widgets/service_card.dart';
import '../widgets/time_travel_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RestaurantManagementServicesScreen(),
    ),
  );
}

class RestaurantManagementServicesScreen extends ConsumerWidget {
  const RestaurantManagementServicesScreen({super.key});

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
          notifier.refreshServices();
          final restaurant = managerState.currentRestaurant;
          final services = managerState.currentRestaurantServices;
          final reservations = managerState.reservations;
          final List<int> deletable = [];

          final slotDuration =
              managerState.currentRestaurant?.slotDuration ?? 1;

          final deletableServiceIds = services
              .where(
                (service) => _isServiceDeletable(
              service,
              reservations,
              slotDuration,
            ),
          )
              .map((service) => service.id)
              .toSet();

          final servicesByDay =
          <int, List<Services>>{};

          for (final service in services) {
            servicesByDay
                .putIfAbsent(
              service.dayOfWeek,
                  () => [],
            )
                .add(service);
          }

          void openEditService(Services service) {
            notifier.selectService(service);

            Navigator.pushNamed(
              context,
              '/edit_service',
            );
          }

          Future<void> deleteService(Services service) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Supprimer le service'),
                  content: Text(
                    'Etes-vous sûr de vouloir supprimer le service '
                        '${service.startTime.substring(0, 5)} - '
                        '${service.endTime.substring(0, 5)} ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Supprimer'),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true) return;

            try {
              await notifier.deleteService(service);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Service supprimé.'),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                ),
              );
            }
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.popUntil(
                  context,
                  ModalRoute.withName('/home_manager'),
                ),
              ),
              title: Text(restaurant!.name),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Rafraîchir les données',
                  onPressed: () {},
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
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      ServiceCard(
                        dayName: 'Lundi',
                        services: servicesByDay[1] ?? const [],
                        onEdit: openEditService,
                          onDelete: deleteService,
                        canDelete: (service) => deletableServiceIds.contains(service.id)
                      ),
                      ServiceCard(
                        dayName: 'Mardi',
                        services: servicesByDay[2] ?? const [],
                        onEdit: openEditService,
                          onDelete: deleteService,
                        canDelete: (service) => deletableServiceIds.contains(service.id)
                      ),
                      ServiceCard(
                        dayName: 'Mercredi',
                        services: servicesByDay[3] ?? const [],
                          onEdit: openEditService,
                          onDelete: deleteService,
                        canDelete: (service) => deletableServiceIds.contains(service.id)
                      ),
                      ServiceCard(
                        dayName: 'Jeudi',
                        services: servicesByDay[4] ?? const [],
                          onEdit: openEditService,
                          onDelete: deleteService,
                        canDelete: (service) => deletableServiceIds.contains(service.id)
                      ),
                      ServiceCard(
                        dayName: 'Vendredi',
                        services: servicesByDay[5] ?? const [],
                          onEdit: openEditService,
                          onDelete: deleteService,
                          canDelete: (service) => deletableServiceIds.contains(service.id)
                      ),
                      ServiceCard(
                        dayName: 'Samedi',
                        services: servicesByDay[6] ?? const [],
                          onEdit: openEditService,
                          onDelete: deleteService,
                        canDelete: (service) => deletableServiceIds.contains(service.id)
                      ),
                      ServiceCard(
                        dayName: 'Dimanche',
                        services: servicesByDay[7] ?? const [],
                          onEdit: openEditService,
                        onDelete: deleteService,
                        canDelete: (service) => deletableServiceIds.contains(service.id)
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'services_fab',
                      onPressed: () {},
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 1,
              onTap: (index) {
                const addr = ['/restaurant_management_reservations', '/manage_services', '/manage_tables'];
                if (index !=  1) {
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

  bool _isServiceDeletable(
      Services service,
      List<Reservation> reservations,
      int slotDuration,
      ) {
    return !reservations.any(
          (reservation) => _reservationBlocksServiceDeletion(
        service,
        reservation,
        slotDuration,
      ),
    );
  }

  bool _reservationBlocksServiceDeletion(
      Services service,
      Reservation reservation,
      int slotDuration,
      ) {
    if (reservation.status == 'completed' ||
        reservation.status == 'cancelled') {
      return false;
    }

    if (reservation.dateTime.weekday != service.dayOfWeek) {
      return false;
    }

    final serviceStart = _parseTime(service.startTime);
    final serviceEnd = _parseTime(service.endTime);

    final reservationStart = Duration(
      hours: reservation.dateTime.hour,
      minutes: reservation.dateTime.minute,
    );

    final reservationEnd = reservationStart +
        Duration(minutes: slotDuration);

    return reservationStart < serviceEnd &&
        reservationEnd > serviceStart;
  }

  Duration _parseTime(String value) {
    final parts = value.split(':');

    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
    );
  }
}
