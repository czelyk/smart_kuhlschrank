import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/content_screen.dart';
import 'screens/shopping_list.dart';
import 'screens/notifications.dart';
import 'screens/account.dart';

void main() {
  runApp(SmartFridgeApp());
}

class SmartFridgeApp extends StatefulWidget {
  @override
  _SmartFridgeAppState createState() => _SmartFridgeAppState();
}

class _SmartFridgeAppState extends State<SmartFridgeApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),        // Mein Kühlschrank
    ShoppingListScreen(),// Einkaufsliste
    NotificationsScreen(),// Benachrichtigungen
    AccountScreen(),     // Konto
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
