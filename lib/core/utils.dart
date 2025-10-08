import '../models/telemetry.dart';
import '../providers/thresholds_provider.dart';
import '../models/alert_entry.dart';
import 'package:uuid/uuid.dart';

AlertEntry? evaluateAlert(Telemetry telemetry, double threshold) {
  if (telemetry.temperature > threshold) {
    return AlertEntry(
      id: const Uuid().v4(),
      deviceId: telemetry.deviceId,
      timestamp: telemetry.ts,
      message: 'Nhiệt độ vượt ngưỡng: ${telemetry.temperature.toStringAsFixed(1)}°C',
    );
  }
  return null;
}
