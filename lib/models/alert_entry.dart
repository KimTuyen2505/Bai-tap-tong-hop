import 'package:meta/meta.dart';

@immutable
class AlertEntry {
  final String id;
  final String deviceId;
  final DateTime timestamp;
  final String message;
  final bool acknowledged;

  const AlertEntry({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    required this.message,
    this.acknowledged = false,
  });

  AlertEntry copyWith({bool? acknowledged}) => AlertEntry(
        id: id,
        deviceId: deviceId,
        timestamp: timestamp,
        message: message,
        acknowledged: acknowledged ?? this.acknowledged,
      );
}
