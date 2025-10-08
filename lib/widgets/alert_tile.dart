import 'package:flutter/material.dart';
import '../models/alert_entry.dart';

class AlertTile extends StatelessWidget {
  final AlertEntry alert;
  final VoidCallback? onAcknowledge;
  
  const AlertTile({
    super.key, 
    required this.alert,
    this.onAcknowledge,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: alert.acknowledged ? 1 : 4,
      color: alert.acknowledged 
          ? Colors.grey[100] 
          : Colors.red[50],
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: alert.acknowledged 
                ? Colors.grey[300] 
                : Colors.red[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            alert.acknowledged 
                ? Icons.check_circle 
                : Icons.warning,
            color: alert.acknowledged 
                ? Colors.grey[600] 
                : Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          alert.message,
          style: TextStyle(
            fontWeight: alert.acknowledged 
                ? FontWeight.normal 
                : FontWeight.bold,
            color: alert.acknowledged 
                ? Colors.grey[600] 
                : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.device_hub,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  alert.deviceId,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: !alert.acknowledged && onAcknowledge != null
            ? IconButton(
                icon: const Icon(Icons.done, color: Colors.green),
                onPressed: onAcknowledge,
                tooltip: 'Mark as read',
              )
            : alert.acknowledged
                ? Icon(
                    Icons.check,
                    color: Colors.grey[600],
                  )
                : null,
        onTap: !alert.acknowledged && onAcknowledge != null
            ? onAcknowledge
            : null,
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
