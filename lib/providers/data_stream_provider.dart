import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/providers/device_provider.dart';
import 'package:mobile_app/providers/mqtt_control_publisher_provider.dart';
import 'dart:async';
import '../services/ws_source.dart';
import '../providers/telemetry_buffer_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/alerts_provider.dart';
import '../providers/thresholds_provider.dart';
import '../core/utils.dart';

// Provider quản lý kết nối và streaming dữ liệu
final dataStreamProvider = Provider<DataStreamService>((ref) {
  return DataStreamService(ref);
});

class DataStreamService {
  final Ref ref;
  StreamSubscription<dynamic>? _subscription;
  WsSource? _wsSource;
  
  DataStreamService(this.ref) {
    _initialize();
  }
  
  void _initialize() {
    _connect();
  }
  
  Future<void> _connect() async {
    try {
      ref.read(connectionStatusProvider.notifier).state = ConnectionStatus.connecting;
      
      _wsSource = WsSource();
      await _wsSource!.connect();
      _subscription = _wsSource!.telemetryStream.listen(_onTelemetryReceived);
      
      ref.read(connectionStatusProvider.notifier).state = ConnectionStatus.online;
      print('✅ WebSocket connected for telemetry data');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      ref.read(connectionStatusProvider.notifier).state = ConnectionStatus.offline;
    }
  }
  
  Future<void> _disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    
    _wsSource?.disconnect();
    _wsSource = null;
  }
  
  void _onTelemetryReceived(dynamic telemetry) {
    // Thêm dữ liệu vào buffer của device
    final buffer = ref.read(telemetryBufferProvider(telemetry.deviceId));
    buffer.add(telemetry);

    // Update danh sách devices tự động
    ref.read(devicesProvider.notifier).updateFromTelemetry(telemetry);
    
    // Kiểm tra cảnh báo
    final threshold = ref.read(thresholdsProvider(telemetry.deviceId));
    final alert = evaluateAlert(telemetry, threshold);
    
    if (alert != null) {
      ref.read(alertsProvider.notifier).add(alert);
    }
  }
  
  void sendControlCommand(String deviceId, String command) {
    final mqttPublisher = ref.read(mqttControlPublisherProvider);
    mqttPublisher.publishControl(deviceId, command);
  }
}
