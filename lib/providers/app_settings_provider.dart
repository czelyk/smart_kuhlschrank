import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _notificationDaysKey = 'notification_days';

  ThemeMode _themeMode = ThemeMode.system;
  int _notificationDays = 3; // Varsayılan değer: 3 gün önce uyar

  ThemeMode get themeMode => _themeMode;
  int get notificationDays => _notificationDays;

  AppSettingsProvider() {
    _loadSettings();
  }

  // Ayarları telefondan yükle
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Temayı yükle
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Bildirim gün sayısını yükle
    _notificationDays = prefs.getInt(_notificationDaysKey) ?? 3;

    notifyListeners();
  }

  // Tema modunu ayarla ve telefona kaydet
  Future<void> setThemeMode(ThemeMode? mode) async {
    if (mode == null || _themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  // Bildirim gün sayısını ayarla ve telefona kaydet
  Future<void> setNotificationDays(int days) async {
    if (_notificationDays == days) return;
    _notificationDays = days;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationDaysKey, days);
  }
}
