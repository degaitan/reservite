import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prbd_2526_a03/core/tools/params.dart';
import 'package:prbd_2526_a03/views/pages/add_reservation.dart';
import 'package:prbd_2526_a03/views/pages/assign_tables.dart';
import 'package:prbd_2526_a03/views/pages/crud_tables.dart';
import 'package:prbd_2526_a03/views/pages/edit_tables.dart';
import 'package:prbd_2526_a03/views/pages/edit_service.dart';
import 'package:prbd_2526_a03/views/pages/find_restaurants.dart';
import 'package:prbd_2526_a03/views/pages/login.dart';
import 'package:prbd_2526_a03/views/pages/my_reservations.dart';
import 'package:prbd_2526_a03/views/pages/my_restaurants.dart';
import 'package:prbd_2526_a03/views/pages/reservation_details_manager.dart';
import 'package:prbd_2526_a03/views/pages/restaurant_details.dart';
import 'package:prbd_2526_a03/views/pages/restaurant_management_reservations.dart';
import 'package:prbd_2526_a03/views/pages/restaurant_management_services.dart';
import 'package:prbd_2526_a03/views/pages/signup.dart';


void main() async {
  await Params.init();
  await initializeDateFormatting('fr_FR', null);
  runApp(ProviderScope(
    child : MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      routes: {
        '/login' :(context) => const LoginScreen(),
        '/signup' : (context) => const SignupScreen(),
        '/home' : (context) => const MyReservationsScreen(),
        '/home_manager': (context) => const MyRestaurantsScreen(),
        '/find_restaurants' : (context) => const FindRestaurantsScreen(),
        '/restaurant_details': (context) => const RestaurantDetailsScreen(),
        '/add_reservation' : (context) => const NewReservationScreen(),
        '/restaurant_management_reservations' : (context) => const RestaurantManagementReservationsScreen(),
        '/reservation_details_manager' : (context) => const ReservationDetailsManagerScreen(),
        '/assign_tables' : (context) => const AssignTablesScreen(),
        '/manage_services' : (context) => const RestaurantManagementServicesScreen(),
        '/edit_service': (context) => const EditServiceScreen(),
        '/manage_tables' : (context) => const RestaurantManagementTablesScreen(),
      }
    ),
  )
  );
}



