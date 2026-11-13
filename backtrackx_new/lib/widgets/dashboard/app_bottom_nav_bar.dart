import 'package:flutter/material.dart';

/// The 4-tab bottom navigation bar (Home, Learning, Progress, Settings).
/// This widget only renders the bar -- the parent screen decides what
/// happens on tap via [onTap], so it stays reusable once Modules 3-6
/// have their own real screens.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Learning'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
    );
  }
}
