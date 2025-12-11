import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    // Don't update if the locale is the same.
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
}
