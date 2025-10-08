import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/telemetry.dart';

// Background processing cho data analysis
class BackgroundDataProcessor {
  static Future<void> initialize() async {
    // Simple initialization - no isolates needed for web
  }
  
  static Future<Map<String, dynamic>> analyzeTrends(List<Telemetry> data) async {
    // Phân tích xu hướng nhiệt độ
    if (data.length < 10) {
      return {'type': 'trend_result', 'trend': 'insufficient_data'};
    }
    
    final temperatures = data.map((d) => d.temperature).toList();
    final recent = temperatures.sublist(temperatures.length - 10);
    final older = temperatures.sublist(0, temperatures.length - 10);
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    String trend;
    if (recentAvg > olderAvg + 2) {
      trend = 'increasing';
    } else if (recentAvg < olderAvg - 2) {
      trend = 'decreasing';
    } else {
      trend = 'stable';
    }
    
    return {
      'type': 'trend_result',
      'trend': trend,
      'change': (recentAvg - olderAvg).toStringAsFixed(2),
    };
  }
  
  static Future<List<Map<String, dynamic>>> detectAnomalies(List<Telemetry> data) async {
    // Phát hiện bất thường
    if (data.length < 20) {
      return <Map<String, dynamic>>[];
    }
    
    final temperatures = data.map((d) => d.temperature).toList();
    final mean = temperatures.reduce((a, b) => a + b) / temperatures.length;
    
    // Tính standard deviation
    final variance = temperatures.map((t) => (t - mean) * (t - mean)).reduce((a, b) => a + b) / temperatures.length;
    final stdDev = sqrt(variance);
    
    final anomalies = <Map<String, dynamic>>[];
    for (int i = 0; i < data.length; i++) {
      final temp = data[i].temperature;
      if ((temp - mean).abs() > 2 * stdDev) {
        anomalies.add({
          'index': i,
          'temperature': temp,
          'deviation': ((temp - mean) / stdDev).toStringAsFixed(2),
          'timestamp': data[i].ts.toIso8601String(),
        });
      }
    }
    
    return anomalies;
  }
  
  static void dispose() {
    // No cleanup needed for web version
  }
}