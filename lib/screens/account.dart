import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projekt/services/auth_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final User? user = _authService.currentUser;

    // Display a placeholder if the user is somehow null
    final String userEmail = user?.email ?? 'Kein Benutzer angemeldet'; // No user logged in
    final String initial = user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Konto')), // Account
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(initial, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            // We don't have a user display name yet, so we show the email.
            Text('Email: $userEmail', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            const Text(
              'Einstellungen', // Settings
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Sprache'), // Language
              onTap: () {
                // In a future step, we could implement language change logic here.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diese Funktion ist noch nicht verfügbar.')), // This feature is not yet available.
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Abmelden', // Log out
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                // The AuthGate will handle navigation after sign-out.
                await _authService.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
