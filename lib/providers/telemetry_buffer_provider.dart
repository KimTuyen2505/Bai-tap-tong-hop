import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry.dart';
import '../core/config.dart';

class TelemetryBuffer {
  final List<Telemetry> _buffer = [];
  final int maxSize;
  TelemetryBuffer({required this.maxSize});

  List<Telemetry> get values => List.unmodifiable(_buffer);

  void add(Telemetry t) {
    _buffer.add(t);
    if (_buffer.length > maxSize) {
      _buffer.removeAt(0);
    }
  }

  void clear() => _buffer.clear();
}

final telemetryBufferProvider = Provider.family<TelemetryBuffer, String>((ref, deviceId) {
  return TelemetryBuffer(maxSize: AppConfig.telemetryBufferSize);
});
