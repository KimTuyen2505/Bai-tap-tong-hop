import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/telemetry.dart';

class DataExportService {
  static Future<String> exportToCSV(List<Telemetry> data, String deviceId) async {
    final csv = StringBuffer();
    
    // Header
    csv.writeln('Timestamp,Device ID,Temperature (°C),Humidity (%),LED Status');
    
    // Data rows
    for (final telemetry in data) {
      csv.writeln([
        telemetry.ts.toIso8601String(),
        telemetry.deviceId,
        telemetry.temperature.toStringAsFixed(2),
        telemetry.humidity.toStringAsFixed(2),
        telemetry.led ? 'ON' : 'OFF',
      ].join(','));
    }
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/telemetry_${deviceId}_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());
    
    return file.path;
  }
  
  static Future<String> exportToJSON(List<Telemetry> data, String deviceId) async {
    final jsonData = {
      'device_id': deviceId,
      'export_time': DateTime.now().toIso8601String(),
      'data_count': data.length,
      'telemetry_data': data.map((t) => t.toJson()).toList(),
    };
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/telemetry_${deviceId}_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonData));
    
    return file.path;
  }
  
  static Future<void> shareData(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'IoT Classroom Telemetry Data');
  }
  
  static Future<Map<String, dynamic>> generateReport(List<Telemetry> data, String deviceId) async {
    if (data.isEmpty) {
      return {'error': 'No data available'};
    }
    
    final temperatures = data.map((t) => t.temperature).toList();
    final humidities = data.map((t) => t.humidity).toList();
    
    final tempMin = temperatures.reduce((a, b) => a < b ? a : b);
    final tempMax = temperatures.reduce((a, b) => a > b ? a : b);
    final tempAvg = temperatures.reduce((a, b) => a + b) / temperatures.length;
    
    final humMin = humidities.reduce((a, b) => a < b ? a : b);
    final humMax = humidities.reduce((a, b) => a > b ? a : b);
    final humAvg = humidities.reduce((a, b) => a + b) / humidities.length;
    
    final ledOnCount = data.where((t) => t.led).length;
    final ledOnPercentage = (ledOnCount / data.length) * 100;
    
    return {
      'device_id': deviceId,
      'period': {
        'start': data.first.ts.toIso8601String(),
        'end': data.last.ts.toIso8601String(),
        'duration_hours': data.last.ts.difference(data.first.ts).inHours,
      },
      'temperature': {
        'min': tempMin,
        'max': tempMax,
        'average': tempAvg,
        'unit': '°C',
      },
      'humidity': {
        'min': humMin,
        'max': humMax,
        'average': humAvg,
        'unit': '%',
      },
      'led_activity': {
        'total_samples': data.length,
        'on_count': ledOnCount,
        'on_percentage': ledOnPercentage,
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }
}