import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static int selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      elevation: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/profile');
            setState(() {
              selectedIndex = index;
            });
            break;
          case 1:
            context.go('/');
            setState(() {
              selectedIndex = index;
            });
            break;
          case 2:
            context.go('/settings');
            setState(() {
              selectedIndex = index;
            });
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.groups), label: 'Friends'),
        NavigationDestination(
            icon: Icon(Icons.person_pin_circle_rounded), label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
    );
  }
}
