import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a03/models/user.dart';
import 'package:prbd_2526_a03/providers/current_user_provider.dart';

import '../widgets/time_travel_widget.dart';


class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

  class _SignupScreenState extends ConsumerState<SignupScreen>{

    final _fullNameController = ValidatingTextEditingController(
      validator: User.validateFullNameFormat,
      asyncValidator: User.validateFullNameUnicity,
      initialValue: ''
    );

    final _emailController = ValidatingTextEditingController(
      validator: User.validateEmailSignup,
      asyncValidator: User.validateEmailUnicity,
      initialValue: ''
    );

    final _passwordController = ValidatingTextEditingController(
      validator: User.validatePasswordSignup,
      initialValue: ''
    );

    //late car il dépend d'un autre controller (mdp)
    late final ValidatingTextEditingController _confirmPasswordController;

    final _phoneController = ValidatingTextEditingController(
      initialValue: ''
    );

  @override
  void initState() {
    super.initState();
    _fullNameController.onAfterValidated = () => setState(() {});
    _emailController.onAfterValidated = () => setState(() {});
    _passwordController.onAfterValidated = () => setState(() {});
    _confirmPasswordController = ValidatingTextEditingController(
      validator: (value) => User.validateMatchingPassword(value, _passwordController.text)
    );
    _confirmPasswordController.onAfterValidated = () => setState(() {});
  }

  @override
  void dispose(){
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


    Future<void> _submit(BuildContext context) async {
      if(!await _validateForm()) return;
      await ref
        .read(currentUserProvider.notifier)
        .signup(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _phoneController.text.trim()
      );
      var securityState = ref.read(currentUserProvider);

      if(!context.mounted) {
        return;
      }

      securityState.when(
          data: (_) => Navigator.pushReplacementNamed(
              context, '/home'),
          error: (error, _) => null,
          loading: () {}
      );


      }

    Future<bool> _validateForm() async {
      await _fullNameController.validateAndWait();
      await _emailController.validateAndWait();
      await _passwordController.validateAndWait();
      await _confirmPasswordController.validateAndWait();
      return _isFormValid;
    }

    bool get _isFormValid =>
        _fullNameController.isValid == true &&
        _emailController.isValid == true &&
        _passwordController.isValid == true &&
        _confirmPasswordController.isValid == true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text('Inscription'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                const Text(
                  'Créez votre compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                    errorText: _fullNameController.errorText,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                    errorText: _emailController.errorText,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: _passwordController.errorText,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _confirmPasswordController.errorText,

                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                    errorText: _phoneController.errorText,

                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('S\'inscrire'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: ()  => Navigator.pushNamed(context, '/login'),
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
