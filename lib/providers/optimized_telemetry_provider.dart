import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/telemetry.dart';
import '../core/config.dart';

// Tối ưu TelemetryBuffer với efficient operations
class OptimizedTelemetryBuffer {
  final List<Telemetry> _buffer = [];
  final int maxSize;
  late DateTime _lastUpdate;
  
  OptimizedTelemetryBuffer({required this.maxSize}) {
    _lastUpdate = DateTime.now();
  }

  List<Telemetry> get values => List.unmodifiable(_buffer);
  
  // Chỉ lấy dữ liệu gần đây nhất cho chart
  List<Telemetry> getRecentData(int maxCount) {
    if (_buffer.length <= maxCount) return values;
    return _buffer.sublist(_buffer.length - maxCount);
  }
  
  // Lấy dữ liệu trong khoảng thời gian
  List<Telemetry> getDataInRange(Duration range) {
    final cutoff = DateTime.now().subtract(range);
    return _buffer.where((t) => t.ts.isAfter(cutoff)).toList();
  }

  void add(Telemetry telemetry) {
    _buffer.add(telemetry);
    
    // Batch remove để tối ưu performance
    if (_buffer.length > maxSize * 1.2) {
      final removeCount = (_buffer.length - maxSize).clamp(1, maxSize ~/ 4);
      _buffer.removeRange(0, removeCount);
    }
    
    _lastUpdate = DateTime.now();
  }

  void clear() {
    _buffer.clear();
    _lastUpdate = DateTime.now();
  }
  
  // Statistics cho dashboard
  TelemetryStats getStats() {
    if (_buffer.isEmpty) {
      return TelemetryStats.empty();
    }
    
    final temps = _buffer.map((t) => t.temperature).toList();
    final humidities = _buffer.map((t) => t.humidity).toList();
    
    return TelemetryStats(
      count: _buffer.length,
      minTemp: temps.reduce((a, b) => a < b ? a : b),
      maxTemp: temps.reduce((a, b) => a > b ? a : b),
      avgTemp: temps.reduce((a, b) => a + b) / temps.length,
      minHumidity: humidities.reduce((a, b) => a < b ? a : b),
      maxHumidity: humidities.reduce((a, b) => a > b ? a : b),
      avgHumidity: humidities.reduce((a, b) => a + b) / humidities.length,
      lastUpdate: _lastUpdate,
    );
  }
}

class TelemetryStats {
  final int count;
  final double minTemp;
  final double maxTemp;
  final double avgTemp;
  final double minHumidity;
  final double maxHumidity;
  final double avgHumidity;
  final DateTime lastUpdate;

  TelemetryStats({
    required this.count,
    required this.minTemp,
    required this.maxTemp,
    required this.avgTemp,
    required this.minHumidity,
    required this.maxHumidity,
    required this.avgHumidity,
    required this.lastUpdate,
  });
  
  factory TelemetryStats.empty() => TelemetryStats(
    count: 0,
    minTemp: 0,
    maxTemp: 0,
    avgTemp: 0,
    minHumidity: 0,
    maxHumidity: 0,
    avgHumidity: 0,
    lastUpdate: DateTime.now(),
  );
}

final optimizedTelemetryBufferProvider = Provider.family<OptimizedTelemetryBuffer, String>((ref, deviceId) {
  return OptimizedTelemetryBuffer(maxSize: AppConfig.telemetryBufferSize);
});

final telemetryStatsProvider = Provider.family<TelemetryStats, String>((ref, deviceId) {
  final buffer = ref.watch(optimizedTelemetryBufferProvider(deviceId));
  return buffer.getStats();
});