import 'package:meta/meta.dart';

@immutable
class ControlHistory {
  final int id;
  final String deviceId;
  final String command;
  final DateTime timestamp;
  final bool success;

  const ControlHistory({
    required this.id,
    required this.deviceId,
    required this.command,
    required this.timestamp,
    required this.success,
  });

  factory ControlHistory.fromJson(Map<String, dynamic> json) {
    return ControlHistory(
      id: json['id'] as int,
      deviceId: json['device_id'] as String,
      command: json['command'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_id': deviceId,
        'command': command,
        'timestamp': timestamp.toIso8601String(),
        'success': success,
      };

  String get commandDisplay {
    switch (command) {
      case 'LED_ON':
        return 'LED Turned ON';
      case 'LED_OFF':
        return 'LED Turned OFF';
      case 'MOTOR_ON':
        return 'Motor Turned ON';
      case 'MOTOR_OFF':
        return 'Motor Turned OFF';
      default:
        return command;
    }
  }
}
