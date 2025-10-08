import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry.dart';
import '../core/config.dart';

class TelemetryBuffer {
  final List<Telemetry> values;
  final int maxSize;
  
  const TelemetryBuffer({
    required this.values,
    required this.maxSize,
  });

  TelemetryBuffer copyWithAdded(Telemetry t) {
    final newList = List<Telemetry>.from(values)..add(t);
    if (newList.length > maxSize) {
      newList.removeAt(0);
    }
    return TelemetryBuffer(values: newList, maxSize: maxSize);
  }

  TelemetryBuffer copyWithCleared() {
    return TelemetryBuffer(values: [], maxSize: maxSize);
  }
}

class TelemetryBufferNotifier extends StateNotifier<TelemetryBuffer> {
  TelemetryBufferNotifier(int maxSize)
      : super(TelemetryBuffer(values: [], maxSize: maxSize));

  void add(Telemetry t) {
    state = state.copyWithAdded(t);
  }

  void clear() {
    state = state.copyWithCleared();
  }
}

final telemetryBufferProvider = StateNotifierProvider.family<TelemetryBufferNotifier, TelemetryBuffer, String>(
  (ref, deviceId) {
    return TelemetryBufferNotifier(AppConfig.telemetryBufferSize);
  },
);
