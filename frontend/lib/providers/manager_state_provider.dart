import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/customer_services.dart';
import 'package:prbd_2526_a03/core/services/reservation_services.dart';
import 'package:prbd_2526_a03/core/services/service_services.dart';
import 'package:prbd_2526_a03/core/services/tables_service.dart';
import 'package:prbd_2526_a03/models/customer.dart';
import 'package:prbd_2526_a03/models/reservation.dart';
import 'package:prbd_2526_a03/models/tables.dart';
import 'package:prbd_2526_a03/providers/reference_time_provider.dart';
import 'package:prbd_2526_a03/providers/simulated_time_provider.dart';

import '../core/services/restaurant_services.dart';
import '../models/restaurant.dart';
import '../models/services.dart';
import 'current_user_provider.dart';

class ManagerState {
  final List<Restaurant> restaurants;
  final Restaurant? currentRestaurant;
  final Reservation? currentReservation;
  final Services? currentService;
  final List<Reservation> reservations;
  final Customer? currentCustomer;
  final List<Tables> currentTables;
  final List<Tables> availableTables;
  final List<Services> currentRestaurantServices;
  final List<Tables> tablesPerRestaurant;
  final Tables? currentTable;

  const ManagerState({
    this.restaurants = const [],
    this.reservations = const [],
    this.currentRestaurant,
    this.currentReservation,
    this.currentService,
    this.currentCustomer,
    this.currentTables = const [],
    this.availableTables = const [],
    this.currentRestaurantServices = const [],
    this.tablesPerRestaurant = const [],
    this.currentTable
  });

  ManagerState copyWith({
    List<Restaurant>? restaurants,
    List<Reservation>? reservations,
    Restaurant? currentRestaurant,
    Reservation? currentReservation,
    Services? currentService,
    Customer? currentCustomer,
    List<Tables>? currentTables,
    List<Tables>? availableTables,
    List<Services>? currentRestaurantServices,
    List<Tables>? tablesPerRestaurant,
    Tables? currentTable
  }) {
    return ManagerState(
      restaurants: restaurants ?? this.restaurants,
      reservations: reservations ?? this.reservations,
      currentRestaurant: currentRestaurant ?? this.currentRestaurant,
      currentReservation: currentReservation ?? this.currentReservation,
      currentService: currentService ?? this.currentService,
      currentCustomer: currentCustomer ?? this.currentCustomer,
      currentTables: currentTables ?? this.currentTables,
      availableTables: availableTables ?? this.availableTables,
      currentRestaurantServices:
      currentRestaurantServices ?? this.currentRestaurantServices,
      tablesPerRestaurant: tablesPerRestaurant ?? this.tablesPerRestaurant,
      currentTable: currentTable ?? this.currentTable
    );
  }
}

final managerStateProvider =
AsyncNotifierProvider<ManagerStateNotifier, ManagerState>(
  ManagerStateNotifier.new,
);

class ManagerStateNotifier extends AsyncNotifier<ManagerState> {
  @override
  Future<ManagerState> build() async {
    final referenceTime = ref.read(referenceTimeProvider);
    DateTime day = DateTime(referenceTime.year, referenceTime.month, referenceTime.day);
    final user = await ref.watch(currentUserProvider.future);

    if (user == null) {
      return const ManagerState();
    }

    if (!user.isManager) {
      throw Exception(
        'Access denied: manager role required',
      );
    }

    final restaurants =
    await RestaurantServices.getMyRestaurants();

    return ManagerState(
      restaurants: restaurants
    );
  }

  Future<void> refreshRestaurants() async {
    final previous = state.value;

    if (previous == null) return;

    try {
      final restaurants =
      await RestaurantServices.getMyRestaurants();

      state = AsyncData(
        previous.copyWith(
          restaurants: restaurants,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> selectRestaurant(Restaurant restaurant) async {
    final previous = state.value;

    if (previous == null) return;

    state = AsyncData(
      previous.copyWith(
        currentRestaurant: restaurant,
        reservations: const [],
      ),
    );

    try {
      final reservations =
      await ReservationServices
          .getAllReservationsForRestaurant(
        restaurant.id,
      );

      final current = state.value ?? previous;

      state = AsyncData(
        current.copyWith(
          currentRestaurant: restaurant,
          reservations: reservations,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> selectReservation(Reservation reservation) async {
    final previous = state.value;

    if (previous == null) return;

    state = AsyncData(previous.copyWith(currentReservation: reservation));

    try {
      final customer = await CustomerServices.getUserByName(reservation.clientName!);
      final tables = await TablesService.getTablesForReservation(reservation.id);
      final availableTables = await TablesService.getAllAvailableTables(reservation.id);

      final current = state.value ?? previous;

      state = AsyncData(
        current.copyWith(
            currentReservation: reservation,
            currentCustomer: customer,
            currentTables: tables,
            availableTables: availableTables)
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshReservationDetails() async {
    final previous = state.value;
    if (previous == null) return;

    final reservation = previous.currentReservation;

    if (reservation == null) return;

    try {
      final customer = await CustomerServices.getUserByName(reservation.clientName!);
      final tables = await TablesService.getTablesForReservation(reservation.id);
      final availableTables = await TablesService.getAllAvailableTables(reservation.id);

      final current = state.value ?? previous;

      state = AsyncData(
          current.copyWith(
              currentReservation: reservation,
              currentCustomer: customer,
              currentTables: tables,
              availableTables: availableTables)
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshReservationsForCurrentRestaurant() async {
    final previous = state.value;

    if (previous == null) return;

    final restaurant = previous.currentRestaurant;

    if (restaurant == null) return;

    try {
      final reservations =
      await ReservationServices
          .getAllReservationsForRestaurant(
        restaurant.id,
      );

      state = AsyncData(
        previous.copyWith(
          reservations: reservations,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshServices() async {
    final previous = state.value;

    if (previous == null) return;

    final restaurant = previous.currentRestaurant;

    try {
      final data =
      await RestaurantServices.getServices(restaurant!.id);

      final current = state.value ?? previous;

      state = AsyncData(
        current.copyWith(
          currentRestaurantServices: data,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshAvailableTablesForCurrentReservation() async {
    final previous = state.value;
    if (previous == null) return;

    final reservation = previous.currentReservation;
    if (reservation == null) return;

    try {
      final availableTables = await TablesService.getAllAvailableTables(reservation.id);

      final currentTables = await TablesService.getTablesForReservation(reservation.id);

      state = AsyncData(
        previous.copyWith(
          availableTables: availableTables,
          currentTables: currentTables,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> assignTablesToCurrentReservation(List<int> tableIds) async {
    final previous = state.value;
    if (previous == null) return;

    final reservation = previous.currentReservation;
    if (reservation == null) return;

    try {
      await TablesService.assignTablesToReservation(reservation, tableIds);

      final tables = await TablesService.getTablesForReservation(reservation.id);

      final availableTables = await TablesService.getAllAvailableTables(reservation.id);

      List<Reservation> reservations = previous.reservations;

      final restaurant = previous.currentRestaurant;
      if (restaurant != null) {
        reservations = await ReservationServices.getAllReservationsForRestaurant(restaurant.id);
      }

      state = AsyncData(
        previous.copyWith(
          currentTables: tables,
          availableTables: availableTables,
          reservations: reservations,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void selectService(Services service) {
    final previous = state.value;
    if (previous == null) return;

    state = AsyncData(
      previous.copyWith(
        currentService: service,
      ),
    );
  }

  Future<void> updateCurrentService({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final previous = state.value;
    if (previous == null) return;

    final service = previous.currentService;
    final restaurant = previous.currentRestaurant;

    if (service == null || restaurant == null) return;

    try {
      await ServiceServices.setService(
        service.id,
        dayOfWeek,
        startTime,
        endTime,
      );

      final services = await RestaurantServices.getServices(restaurant.id);

      final updatedService = Services(
        id: service.id,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );

      state = AsyncData(
        previous.copyWith(
          currentService: updatedService,
          currentRestaurantServices: services,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteService(Services service) async {
    final previous = state.value;
    if (previous == null) return;

    final restaurant = previous.currentRestaurant;
    if (restaurant == null) return;

    try {
      await ServiceServices.deleteService(service.id);

      final services =
      await ServiceServices.getServices(restaurant.id);

      state = AsyncData(
        previous.copyWith(
          currentRestaurantServices: services,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> loadTables() async {
    final previous = state.value;
    if(previous==null) return;

    final restaurant = previous.currentRestaurant;
    if(restaurant == null) return;

    try {
      final tables = await TablesService.getTablesPerRestaurant(restaurant.id);
      state = AsyncData(previous.copyWith(
        tablesPerRestaurant: tables
      ));

    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }

  }

  Future<void> saveTable(int tableNumber, int tableCapacity, int? tableId) async {
    final previous = state.value;
    if(previous==null) return;

    final restaurant = previous.currentRestaurant;
    if(restaurant == null) return;

    try {
       await TablesService.saveTable(restaurant.id, tableNumber, tableCapacity, tableId);
       final tables = await TablesService.getTablesPerRestaurant(restaurant.id);
      state = AsyncData(previous.copyWith(
        tablesPerRestaurant: tables
      ));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }

  }

}