import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt/screens/login_screen.dart';
import 'package:projekt/main.dart';

/// A widget that handles the routing based on the authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is not logged in, show the login screen.
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // If the user is logged in, show the main app screen.
        return const MainAppScreen();
      },
    );
  }
}
