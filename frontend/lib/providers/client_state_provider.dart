import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/reservation_services.dart';
import 'package:prbd_2526_a03/core/services/restaurant_services.dart';
import 'package:prbd_2526_a03/models/no_slots_reason.dart';
import 'package:prbd_2526_a03/models/reservation.dart';
import 'package:prbd_2526_a03/models/restaurant.dart';
import 'package:prbd_2526_a03/models/services.dart';
import 'package:prbd_2526_a03/providers/current_user_provider.dart';
import 'package:prbd_2526_a03/providers/reference_time_provider.dart';

class ClientState {
  final List<Reservation> reservations;
  final AsyncValue<Reservation>? currentReservationDetails;
  final List<Restaurant> restaurants;
  final Restaurant? currentRestaurant;
  final List<Services>? currentRestaurantServices;
  final List<DateTime>? availableSlots;
  final NoSlotsReason? noSlotsError;


  ClientState({required this.reservations, this.currentReservationDetails, required this.restaurants,
    this.currentRestaurantServices, this.currentRestaurant, this.availableSlots, this.noSlotsError});

  ClientState copyWith({
     final List<Reservation>? reservations,
    final AsyncValue<Reservation>? currentReservationDetails,
    final List<Restaurant>? restaurants,
    final List<Services>? currentRestaurantServices,
    final Restaurant? currentRestaurant,
    final List<DateTime>? availableSlots,
    final NoSlotsReason? noSlotsError
  })
  {
    return ClientState(reservations: reservations ?? this.reservations,
                            currentReservationDetails: currentReservationDetails ?? this.currentReservationDetails,
                            restaurants: restaurants ?? this.restaurants,
                            currentRestaurantServices: currentRestaurantServices ?? this.currentRestaurantServices,
                            currentRestaurant: currentRestaurant ?? this.currentRestaurant,
                            availableSlots: availableSlots ?? this.availableSlots,
                            noSlotsError: noSlotsError ?? this.noSlotsError

    );

  }
}

final clientStateProvider =
  AsyncNotifierProvider<ClientStateNotifier, ClientState>(() => ClientStateNotifier());

class ClientStateNotifier extends AsyncNotifier<ClientState>{
  @override
  Future<ClientState> build() async {
    ref.watch(currentUserProvider);
    final list = await ReservationServices.getMyReservations();
    final restList = await RestaurantServices.getMatchingRestaurants("");
    return ClientState(reservations: list, restaurants: restList);
  }

  Future<void> refresh() async{
    state = const AsyncLoading();
    try {
      final data = await ReservationServices.getMyReservations();
      state = AsyncData(state.value!.copyWith(reservations: data));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }


  List<Restaurant> getRestaurants() {
    return state.value!.restaurants;
  }

  Restaurant getCurrentRestaurant() {
    return state.value!.currentRestaurant!;
  }

  List<Services>? getCurrentServices() {
    return state.value!.currentRestaurantServices;
  }

  Future<void> refreshRestaurants(String filter) async {
    state = AsyncData(
      state.value!.copyWith(
        restaurants: getRestaurants(),
      ),
    );
    try {
      final data = await RestaurantServices.getMatchingRestaurants(filter);
      state = AsyncData(state.value!.copyWith(restaurants: data));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }


  Future<void> selectRestaurant(Restaurant restaurant) async {
    final previous = state.value;

    if (previous == null) return;

    state = AsyncData(
      previous.copyWith(
        currentRestaurant: restaurant,
        currentRestaurantServices: const [],
      ),
    );

    await refreshServices(restaurant.id);
  }


  Future<void> refreshServices(int restaurantId) async {
    final previous = state.value;

    if (previous == null) return;

    try {
      final data =
      await RestaurantServices.getServices(restaurantId);

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

  Future<void> loadReservationDetails(int id) async {
    state = AsyncData(state.value!.copyWith(
      currentReservationDetails: AsyncLoading()
    ));
    
    try {
      final reservation = await ReservationServices.getReservationDetails(id);
      state = AsyncData(state.value!.copyWith(
        currentReservationDetails: AsyncData(reservation)
      ));
    } catch (e) {
      state = AsyncData(state.value!.copyWith(
        currentReservationDetails: AsyncError(e, StackTrace.current)
      ));
    }
  }

  Future<void> loadFirstAvailableSlots(int restaurantId, int numberOfGuests, [int? excluded]) async {
    final previous = state.value;
    //si jamais on appelle cette methode avant le build et que le state est null
    if (previous == null) return;

    //prendre l'état précédent et en faire une copie avec seulement ces attributs là qui ont changé
    state = AsyncLoading();

    final referenceTime = ref.read(referenceTimeProvider);
    DateTime day = DateTime(referenceTime.year, referenceTime.month, referenceTime.day);

    // DateTime(
    //     DateTime.now().year, DateTime.now().month, DateTime.now().day);
     const maxDays = 30;

    try {
      for(int i = 0; i < maxDays; i++){
        final slots = await ReservationServices.getAvailableSlotsForDate(restaurantId, day, numberOfGuests, excluded);
        print('day=$day slots=${slots.length}');
        if(slots.isNotEmpty) {
          state = AsyncData(previous.copyWith(
            availableSlots: slots,
            noSlotsError: null
          ));
          return;
        }

        //si on a trouvé aucune dispo, on incrémente le jour d e 1
        day = day.add(const Duration(days: 1));

      }
      //on a rien trouvé
      state = AsyncData(previous.copyWith(
        availableSlots: const []
      ));

    }catch(e, st) {
      state = AsyncError(e, st);
    }

  }

  Future<void> loadSlotsPerDay(int restaurantId, DateTime date,int numberOfGuests, [int? excluded]) async {
    final previous = state.value;
    if (previous == null) return;

    state = AsyncLoading();

    try {
      final slots = await ReservationServices.getAvailableSlotsForDate(restaurantId, date, numberOfGuests, excluded);

      if(slots.isNotEmpty){
        state = AsyncData(previous.copyWith(
          availableSlots: slots,
          noSlotsError: null
        ));
      }else{
        //on trouve rien
        final error = await ReservationServices.getSpecificErrorIfNoSlots(restaurantId, date);
        state = AsyncData(previous.copyWith(
          availableSlots: [],
          noSlotsError: error
        ));
      }
    }catch (e,st){
      state = AsyncError(e, st);
    }
  }



}