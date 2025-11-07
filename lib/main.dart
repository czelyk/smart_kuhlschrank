import 'package:flutter/material.dart';

// --- Firebase Imports (Yeni Eklendi) ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire configure tarafından oluşturuldu
// --- Firebase Imports (Yeni Eklendi) ---

import 'screens/home_screen.dart';
import 'screens/shopping_list.dart';
import 'screens/notifications.dart';
import 'screens/account.dart';

// main fonksiyonunu Firebase'i başlatmak için güncelledik
Future<void> main() async { // 'async' ve 'Future<void>' eklendi
  // Flutter binding'lerinin başlatıldığından emin ol
  WidgetsFlutterBinding.ensureInitialized(); // Bu satır eklendi

  // Firebase'i başlat
  await Firebase.initializeApp( // Bu satır eklendi
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Uygulamayı çalıştır
  runApp(const SmartFridgeApp());
}

class SmartFridgeApp extends StatefulWidget {
  const SmartFridgeApp({super.key});

  @override
  State<SmartFridgeApp> createState() => _SmartFridgeAppState();
}

class _SmartFridgeAppState extends State<SmartFridgeApp> {
  int _selectedIndex = 0;

  // Screens are now in a static const list for better performance.
  static const List<Widget> _screens = [
    HomeScreen(),
    ShoppingListScreen(),
    NotificationsScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Buzdolabı',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.kitchen),
              label: 'Startseite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Einkaufen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Benachrichtigungen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Konto',
            ),
          ],
        ),
      ),
    );
  }
}
