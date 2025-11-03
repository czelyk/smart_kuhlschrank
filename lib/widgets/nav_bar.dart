import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const NavBar({Key? key, required this.selectedIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
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
    );
  }
}
