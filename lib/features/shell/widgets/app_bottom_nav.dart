import 'package:flutter/material.dart';

/// Lima tab (PRD bagian 8.1). Tab kelima (Logout) tidak membuka layar.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;

  static const logoutIndex = 4;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => i == logoutIndex ? onLogout() : onTabSelected(i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'Ibadah',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Saran & Kesan',
        ),
        NavigationDestination(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}
