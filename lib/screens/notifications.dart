import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  // Sample notification data. In a real app, this would come from a service.
  final List<String> notifications = const [
    // 'Milch: Mindesthaltbarkeitsdatum läuft bald ab',
    // 'Äpfel: 2 Stück übrig',
    // 'Eier: Aufgebraucht',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen'), // Notifications
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'Keine neuen Benachrichtigungen.', // No new notifications.
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
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
