import 'package:flutter/material.dart';
import 'package:projekt/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import the l10n library

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  String _errorMessage = '';

  // Handles the form submission for both login and registration.
  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = '';
      });
      try {
        if (_isLogin) {
          await _authService.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
        } else {
          await _authService.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
        }
        // Navigation is handled by the AuthGate upon successful login/signup.
      } on Exception catch (e) {
        setState(() {
          // Display a user-friendly error message.
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the localization object
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? l10n.login : l10n.register, // Use localized strings
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email, // Use localized string
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? l10n.pleaseEnterEmail : null, // Use localized validation
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password, // Use localized string
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? l10n.pleaseEnterPassword : null, // Use localized validation
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_isLogin ? l10n.login : l10n.register), // Use localized strings
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = '';
                      });
                    },
                    child: Text(
                      _isLogin
                          ? '${l10n.dontHaveAccount} ${l10n.register}'
                          : '${l10n.alreadyHaveAccount} ${l10n.login}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
