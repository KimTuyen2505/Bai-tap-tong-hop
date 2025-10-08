import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connection_provider.dart';

class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);
    Color color;
    String text;
    switch (status) {
      case ConnectionStatus.online:
        color = Colors.green;
        text = 'Online';
        break;
      case ConnectionStatus.offline:
        color = Colors.red;
        text = 'Offline';
        break;
      default:
        color = Colors.orange;
        text = 'Connecting...';
    }
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
