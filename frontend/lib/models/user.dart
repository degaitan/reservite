
import 'dart:convert';

import 'package:prbd_2526_a03/core/services/security.dart';

class User {
  final String token;
  final int id;
  final String email;
  final String name;
  final String role;

  const User({
    required this.token,
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isClient => role == 'client';
  bool get isManager => role == 'manager';

  static User fromToken(String token) {
    final parts = token.split('.');

    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];

    final normalizedPayload =
    base64Url.normalize(payload);

    final decodedPayload =
    utf8.decode(
      base64Url.decode(normalizedPayload),
    );

    final jsonPayload =
    json.decode(decodedPayload)
    as Map<String, dynamic>;

    return User(
      token: token,
      id: int.parse(jsonPayload['user_id'].toString()),
      email: jsonPayload['sub'],
      name: jsonPayload['name'],
      role: jsonPayload['role'],
    );
  }

  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _digitRegex = RegExp(r'\d');
  static final RegExp _upperRegex = RegExp(r'[A-Z]');
  static final RegExp _lowerRegex = RegExp(r'[a-z]');
  static final RegExp _specialRegex = RegExp(r'[,;.:!?/$%&@#]');


  static String? validateEmailFormat(String? email) {
    if(email == null || email.isEmpty){
      return 'required';
    }
    return null;
  }
  //att ici, pas de validation async pour le login, la procedure login du back se charge des ces verif en interne MAIS il faut
  //les verifs null/empty en sync

  // static Future<String?> validateEmail(String? email) async {
  //   if(email == null || email.isEmpty) {
  //     return 'required';
  //   } else {
  //     var res = await Security.checkEmail(email: email.trim());
  //     return res ? null : 'no account linked to this email';
  //   }
  // }
  //
  static String? validatePasswordFormat(String? passwd){
    if(passwd == null || passwd.isEmpty){
      return 'required';
    }
    return null;
  }

  static String? validateFullNameFormat(String? fullName){
    if(fullName == null || fullName.isEmpty){
      return 'Veuillez entrer un nom complet';
    } else if (fullName.length < 3){
      return 'Le nom complet doit contenir au moins 3 caractères';
    } else {
      return null;
    }
  }

  static Future<String?> validateFullNameUnicity(String? fullName) async{
    var res = await Security.checkFullName(fullName: fullName?.trim());
    return res ? null : 'Ce nom complet est déjà utilisé';
  }

  static String? validateEmailSignup(String? email){
    if(email == null || email.isEmpty){
      return 'Veuillez entrer un email';
    } else if(!_emailRegex.hasMatch(email)){
      return 'Veuillez entrer une adresse email valide';
    } else {
      return null;
    }
  }

  static Future<String?> validateEmailUnicity(String? email) async {
    var res = await Security.checkEmail(email: email?.trim());
    return res ? null : 'Cet email est déjà utilisé';
  }

  static String? validatePasswordSignup(String? password){
    if(password == null || password.isEmpty){
      return 'Veuillez entrer un mot de passe';
    } else if (password.length < 8){
      return 'Le mot de passe doit contenir au moins 8 caractères';
    } else if (!_digitRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins un chiffre';
    } else if (!_upperRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins une lettre majuscule';
    } else if (!_lowerRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins une lettre minuscule';
    } else if (!_specialRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    } else {
      return null;
    }
  }

  static String? validateMatchingPassword(String? value, String? password) {
    if(value == null || value.isEmpty) {
      return 'Veuillez valider le mot de passe';
    } else if(value != password) {
      return 'Les deux mots de passe doivent être identiques';
    } else {
      return null;
    }
  }




}