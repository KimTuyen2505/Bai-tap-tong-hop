import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/env.dart';
import '../models/telemetry.dart';
import '../models/control_command.dart';

class WsSource {
  WebSocketChannel? _channel;
  StreamController<Telemetry>? _telemetryController;
  bool _isConnected = false;

  Stream<Telemetry> get telemetryStream => _telemetryController!.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      _telemetryController = StreamController<Telemetry>.broadcast();

      print('Connecting to WebSocket: ${Env.wsMockUrl}');
      _channel = WebSocketChannel.connect(Uri.parse(Env.wsMockUrl));

      _channel!.stream.listen(
        (event) {
          try {
            final jsonData = jsonDecode(event) as Map<String, dynamic>;
            print("📩 Raw WS event: $jsonData");

            final type = jsonData['type'];

            if (type == 'telemetry') {
              final telemetryJson = jsonData['data'] as Map<String, dynamic>;
              final telemetry = Telemetry.fromJson(telemetryJson);
              _telemetryController?.add(telemetry);
              print('✅ Telemetry: ${telemetry.deviceId} - ${telemetry.temperature}°C');
            } else if (type == 'device_list') {
              final devices = (jsonData['data'] as List)
                  .map((d) => d['id'] as String)
                  .toList();
              print('📋 Device list received: $devices');

              // 👉 có thể emit telemetry ngay từ currentData nếu muốn
              for (final device in (jsonData['data'] as List)) {
                final currentData = device['currentData'];
                if (currentData != null) {
                  final telemetry = Telemetry.fromJson(currentData);
                  _telemetryController?.add(telemetry);
                }
              }
            } else {
              print('⚠️ Unknown WS message type: $type');
            }
          } catch (e) {
            print('Error parsing WS message: $e');
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _telemetryController?.close();
        },
        onError: (dynamic error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
      );

      _isConnected = true;
      print('WebSocket connected successfully');
    } catch (e) {
      print('WebSocket connection failed: $e');
      _isConnected = false;
    }
  }

  void sendControl(String deviceId, String cmd) {
    try {
      final msg = jsonEncode({
        'type': 'control',
        'deviceId': deviceId,
        'data': cmd,
      });

      if (_isConnected && _channel != null) {
        _channel!.sink.add(msg);
        print('Sent WS control command to $deviceId: $cmd');
      } else {
        print('WebSocket not connected, cannot send command');
      }
    } catch (e) {
      print('Error sending control command: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
