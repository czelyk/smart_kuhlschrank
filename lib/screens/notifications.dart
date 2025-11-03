import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  // Örnek veri
  final List<String> notifications = const [
    'Milch: Mindesthaltbarkeitsdatum läuft bald ab',
    'Äpfel: 2 Stück übrig',
    'Eier: Aufgebraucht',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benachrichtigungen')),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              leading: const Icon(Icons.notification_important, color: Colors.teal),
              title: Text(notifications[index]),
            ),
          );
        },
      ),
    );
  }
}
