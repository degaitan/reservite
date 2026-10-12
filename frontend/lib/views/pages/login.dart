import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a03/models/user.dart';
import 'package:prbd_2526_a03/providers/current_user_provider.dart';
import 'package:prbd_2526_a03/providers/simulated_time_provider.dart';

import '../widgets/time_travel_widget.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

  class _LoginScreenState extends ConsumerState<LoginScreen> {

    final _emailController = ValidatingTextEditingController(
      validator: User.validateEmailFormat,
      initialValue: '',
    );

    final _passwordController = ValidatingTextEditingController(
      validator: User.validatePasswordFormat,
      initialValue: '',
    );

    @override
    void initState() {
      super.initState();
      _emailController.onAfterValidated = () => setState(() {});
      _passwordController.onAfterValidated = () => setState(() {});

    }

    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final simulatedTime = DateTime(2024, 12, 4, 16, 0);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Connexion'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Connectez-vous',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Se connecter'),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text(
                            'Pas encore de compte ? S\'inscrire',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Raccourcis de débogage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Se connecter directement en tant que :',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _login(context, 'carol@example.com', 'Password1,'),
                            icon: const Icon(Icons.person),
                            label: const Text('Client (Carol)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _login(context, 'emma@example.com', 'Password1,'),
                            icon: const Icon(Icons.person),
                            label: const Text('Client (Emma)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _login(context, 'alice@example.com', 'Password1,'),
                            icon: const Icon(Icons.manage_accounts),
                            label: const Text('Manager (Alice)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _login(context, 'david@example.com', 'Password1,'),
                            icon: const Icon(Icons.manage_accounts),
                            label: const Text('Manager (David)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _resetDataBase();
                          await ref.read(simulatedTimeProvider.notifier).reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réinitialiser la base de données'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    void _login(BuildContext context, String email, String password) async {
      await ref.read(currentUserProvider.notifier).login(email, password);
      var securityState = ref.read(currentUserProvider);

      if(!context.mounted) return;

      securityState.when(
          data: (user) {
            if (user == null) {
              Navigator.pushReplacementNamed(context, '/login');
              return;
            }
            if (user.isManager) {
              Navigator.pushReplacementNamed(context, '/home_manager');
              return;
            }
            Navigator.pushReplacementNamed(
                context, '/home');},
          error: (error, _) =>
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Colors.red,
              ),
            ),
          loading: () {},
      );
    }
    
    _submitForm(BuildContext context){
      if(!_validateForm()) return;
      _login(context, _emailController.text, _passwordController.text);
    }
    
    bool _validateForm() {
      _emailController.validate();
      _passwordController.validate();
      return _isFormValid;
    }
    
    bool get _isFormValid =>
        _emailController.isValid == true && _passwordController.isValid == true;

    Future<void> _resetDataBase() async {
      await ref.read(currentUserProvider.notifier).resetDataBase();
      var securityState = ref.read(currentUserProvider);

      if(!context.mounted) return;

      securityState.when(
        data: (_) =>
          ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Base de données réinitialisée."),
          backgroundColor: Colors.green,
        ),
      ),

        error: (error, _) =>
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Colors.red,
              ),
            ),
        loading: () {},
      );
    }
  }
