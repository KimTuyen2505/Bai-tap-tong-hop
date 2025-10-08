import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_entry.dart';
import '../services/notification_service.dart';

final alertsProvider = StateNotifierProvider<AlertsNotifier, List<AlertEntry>>((ref) => AlertsNotifier());

class AlertsNotifier extends StateNotifier<List<AlertEntry>> {
  AlertsNotifier() : super([]);

  void add(AlertEntry alert) {
    state = [...state, alert];
    NotificationService.showAlert('Alert', alert.message);
  }

  void acknowledge(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(acknowledged: true) else a
    ];
  }
}
