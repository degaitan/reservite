import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/security.dart';
import 'package:prbd_2526_a03/core/tools/params.dart';
import '../models/user.dart';


final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, User?>(
    () => CurrentUserNotifier(),
);

class CurrentUserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final token = Params.getValue('token');

    if (token == null) {
      return null;
    }

    return User.fromToken(token);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      var token = await Security.login(email, password);

      if (token == null) {
        throw Exception('No token returned');
      }

      Params.setValue('token', token);
      state = AsyncData(User.fromToken(token));
    }catch(e){
      state = AsyncError(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

  Future<void> resetDataBase() async {
    state = const AsyncLoading();
    try {
      await Security.resetDataBase();
      Params.clearAll();
      state = const AsyncData(null);
    } catch (e){
      state = AsyncError("Could not reset data base.\nPlease try again later.", StackTrace.current);
    }

  }

  Future<void> signup(String fullName, String email, String password, String? phone) async {
    state = const AsyncLoading();
    try{
      await Security.signup(fullName, email, password, phone);
      var token = await Security.login(email, password);
      if (token == null) {
        throw Exception('No token returned');
      }

      Params.setValue('token', token);
      state = AsyncData(User.fromToken(token));
    } catch (e){
      state = AsyncError('"Something went wrong!\nPlease try again later."', StackTrace.current);
    }
  }

  Future<void> logout() async {
    await Params.clearAll();
    state = AsyncData(null);
  }

}