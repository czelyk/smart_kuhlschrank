import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_kuhlschrank/providers/locale_provider.dart';
import 'package:smart_kuhlschrank/services/auth_service.dart';
import 'package:smart_kuhlschrank/l10n/app_localizations.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.account),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logOut,
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              authService.currentUser?.email ?? 'No User',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: localeProvider.locale,
              onChanged: (Locale? newValue) {
                if (newValue != null) {
                  localeProvider.setLocale(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('tr'),
                  child: Text('Türkçe'),
                ),
                DropdownMenuItem(
                  value: Locale('de'),
                  child: Text('Deutsch'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.teal),
            title: Text(l10n.settings),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureNotAvailable)),
              );
            },
          ),
        ],
      ),
    );
  }
}
