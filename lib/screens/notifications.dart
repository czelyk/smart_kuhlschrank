import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  // Sample notification data. In a real app, this would come from a service.
  final List<String> notifications = const [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications), // Localized title
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                l10n.noNewNotifications, // Localized empty state message
                style: const TextStyle(fontSize: 18, color: Colors.grey),
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
