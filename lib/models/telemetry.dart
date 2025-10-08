import 'package:meta/meta.dart';

@immutable
class Telemetry {
  final String deviceId;
  final DateTime ts;
  final double temperature;
  final double humidity;
  final bool led;
  final bool motor;

  const Telemetry({
    required this.deviceId,
    required this.ts,
    required this.temperature,
    required this.humidity,
    required this.led,
    required this.motor,
  });

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    final tsValue = json['ts'];

    DateTime parsedTs;
    if (tsValue is int) {
      parsedTs = DateTime.fromMillisecondsSinceEpoch(tsValue);
    } else if (tsValue is String) {
      parsedTs = DateTime.tryParse(tsValue) ?? DateTime.now();
    } else {
      parsedTs = DateTime.now();
    }

    final ledValue = json['led'];
    final bool ledStatus;
    if (ledValue is bool) {
      ledStatus = ledValue;
    } else if (ledValue is int) {
      ledStatus = ledValue == 1;
    } else {
      ledStatus = false;
    }

    final motorValue = json['motor'];
    final bool motorStatus;
    if (motorValue is bool) {
      motorStatus = motorValue;
    } else if (motorValue is int) {
      motorStatus = motorValue == 1;
    } else {
      motorStatus = false;
    }

    return Telemetry(
      deviceId: json['deviceId'] as String,
      ts: parsedTs,
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      led: ledStatus,
      motor: motorStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'ts': ts.toIso8601String(),
        'temperature': temperature,
        'humidity': humidity,
        'led': led,
        'motor': motor,
      };
}
