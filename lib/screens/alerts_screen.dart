import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alert_tile.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final unacknowledgedCount = alerts.where((a) => !a.acknowledged).length;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alerts'),
            if (unacknowledgedCount > 0)
              Text(
                '$unacknowledgedCount unread',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          if (unacknowledgedCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () => _acknowledgeAll(ref),
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: alerts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No alerts',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Alerts will appear here when temperature\nexceeds the threshold',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[alerts.length - 1 - index]; // Hiển thị mới nhất trước
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AlertTile(
                    alert: alert,
                    onAcknowledge: () {
                      ref.read(alertsProvider.notifier).acknowledge(alert.id);
                    },
                  ),
                );
              },
            ),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/devices');
              break;
            case 2:
              // Already on alerts
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: unacknowledgedCount > 0
                ? Badge(
                    label: Text('$unacknowledgedCount'),
                    child: const Icon(Icons.warning),
                  )
                : const Icon(Icons.warning),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  
  void _acknowledgeAll(WidgetRef ref) {
    final alerts = ref.read(alertsProvider);
    for (final alert in alerts) {
      if (!alert.acknowledged) {
        ref.read(alertsProvider.notifier).acknowledge(alert.id);
      }
    }
    
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('All alerts marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
