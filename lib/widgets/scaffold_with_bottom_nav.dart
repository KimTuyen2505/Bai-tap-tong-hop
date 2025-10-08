import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context, location),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, String location) {
    int currentIndex = _calculateSelectedIndex(location);
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.devices),
          label: 'Devices',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/devices')) return 1;
    if (location.startsWith('/alerts')) return 2;
    if (location.startsWith('/analytics')) return 3;
    if (location.startsWith('/history')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/devices');
        break;
      case 2:
        context.go('/alerts');
        break;
      case 3:
        context.go('/analytics');
        break;
      case 4:
        context.go('/history');
        break;
      case 5:
        context.go('/settings');
        break;
    }
  }
}
