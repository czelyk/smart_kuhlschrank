import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_kuhlschrank/providers/locale_provider.dart';
import 'package:smart_kuhlschrank/services/auth_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  // Function to show the language selection dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context)!.language),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('de'));
                Navigator.pop(context);
              },
              child: const Text('Deutsch'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('en'));
                Navigator.pop(context);
              },
              child: const Text('English'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('tr'));
                Navigator.pop(context);
              },
              child: const Text('Türkçe'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final AuthService authService = AuthService();
    final User? user = authService.currentUser;

    final String userEmail = user?.email ?? l10n.error; // Use localized string for error
    final String initial =
        user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
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
            Text('Email: $userEmail', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Text(
              l10n.settings, // Localized settings title
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language), // Localized language title
              onTap: () => _showLanguageDialog(context), // Call the dialog function
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                l10n.logOut,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await authService.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
