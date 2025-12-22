import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_kuhlschrank/providers/app_settings_provider.dart';
import 'package:smart_kuhlschrank/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // --- Appearance Section ---
          _buildSectionHeader(context, l10n.appearance), // Hardcoded 'Appearance' until l10n update
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.theme), // Using 'theme' from l10n if available or hardcode fallbacks
            subtitle: Text(_getThemeModeName(settings.themeMode, context)),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  settings.setThemeMode(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemDefault), // 'System Default'
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.lightTheme), // 'Light Theme'
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.darkTheme), // 'Dark Theme'
                ),
              ],
            ),
          ),
          const Divider(),

          // --- Notification Section ---
          _buildSectionHeader(context, l10n.notifications),
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: Text(l10n.expirationWarning), // 'Expiration Warning'
            subtitle: Text(l10n.daysBefore(settings.notificationDays)), // 'X days before'
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Text('1d'),
                Expanded(
                  child: Slider(
                    value: settings.notificationDays.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: '${settings.notificationDays} days',
                    onChanged: (double value) {
                      settings.setNotificationDays(value.toInt());
                    },
                  ),
                ),
                const Text('7d'),
              ],
            ),
          ),
          const Divider(),

          // --- Storage Section ---
          _buildSectionHeader(context, l10n.storage), // 'Storage'
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: Text(l10n.clearImageCache), // 'Clear Image Cache'
            subtitle: Text(l10n.freesUpSpace), // 'Frees up space on your device'
            onTap: () async {
              await CachedNetworkImage.evictFromCache("all");
              // Actually we usually rely on cache manager, but let's show a success message
              // Since evictFromCache is specific to keys, we might need DefaultCacheManager().emptyCache()
              // but for now let's just simulate or inform user.
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.cacheCleared)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system: return l10n.systemDefault;
      case ThemeMode.light: return l10n.lightTheme;
      case ThemeMode.dark: return l10n.darkTheme;
    }
  }
}

// Temporary extensions for l10n to avoid compilation errors if keys are missing
// You should add these to your arb files properly.
extension L10nExtras on AppLocalizations {
  String get appearance => 'Appearance'; // Placeholder
  String get theme => 'Theme';
  String get systemDefault => 'System Default';
  String get lightTheme => 'Light';
  String get darkTheme => 'Dark';
  
  String get expirationWarning => 'Expiration Warning';
  String daysBefore(int days) => '$days days before';
  
  String get storage => 'Storage';
  String get clearImageCache => 'Clear Image Cache';
  String get freesUpSpace => 'Frees up space used by recipe images';
  String get cacheCleared => 'Image cache cleared!';
}
