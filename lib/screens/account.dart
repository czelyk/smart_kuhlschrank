import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Örnek kullanıcı bilgileri
    final String userName = "Ahmet Hasan Çelik";
    final String email = "ahmethasancelik@example.com";

    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(userName[0], style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text('Name: $userName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: $email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            const Text(
              'Einstellungen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Sprache'),
              onTap: () {
                // Dil değişikliği işlemleri
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Abmelden'),
              onTap: () {
                // Logout işlemleri
              },
            ),
          ],
        ),
      ),
    );
  }
}
