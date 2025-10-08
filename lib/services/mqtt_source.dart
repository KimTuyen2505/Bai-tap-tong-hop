import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import '../models/telemetry.dart';
import '../models/control_command.dart';
import '../providers/device_provider.dart';

/// MQTT service cho Flutter app
class MqttSource {
  late MqttServerClient _client;
  StreamController<Telemetry>? _telemetryController;
  bool _isConnected = false;

  final Ref ref; // Riverpod ref để cập nhật providers

  MqttSource(this.ref);

  Stream<Telemetry> get telemetryStream => _telemetryController!.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      if (kIsWeb) {
        print('❌ MQTT not supported on web platform');
        throw UnsupportedError('MQTT not supported on web platform');
      }

      // Dùng host + port từ Env
      _client = MqttServerClient.withPort(
        Env.mqttHost,
        'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        Env.mqttPort,
      );

      _client.logging(on: false);
      _client.useWebSocket = true; // 👈 Bật WebSocket
      _client.websocketProtocols = ['mqtt']; // quan trọng
      _client.keepAlivePeriod = 20;
      _client.connectTimeoutPeriod = 10000;
      _client.onDisconnected = _onDisconnected;
      _client.onConnected = _onConnected;

      _telemetryController = StreamController<Telemetry>.broadcast();

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_client.clientIdentifier)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _client.connectionMessage = connMessage;

      print('🔌 Connecting to MQTT: ${Env.mqttHost}:${Env.mqttPort}');
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        print('✅ MQTT Connected successfully');
        _isConnected = true;

        _client.subscribe('iot/classroom/+/telemetry', MqttQos.atMostOnce);
        _client.updates!.listen(_onMessage);
      } else {
        throw Exception(
          'MQTT connection failed: ${_client.connectionStatus?.returnCode}',
        );
      }
    } catch (e) {
      print('❌ MQTT connection error: $e');
      _isConnected = false;
    }
  }

  void _onConnected() {
    print('🔗 MQTT client connected');
    _isConnected = true;
  }

  void _onDisconnected() {
    print('🔌 MQTT client disconnected');
    _isConnected = false;
    _telemetryController?.close();
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final event in events) {
      try {
        final rec = event.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(rec.payload.message);

        if (payload.isNotEmpty) {
          final jsonData = jsonDecode(payload) as Map<String, dynamic>;
          final telemetry = Telemetry.fromJson(jsonData);

          // Đẩy telemetry cho UI
          _telemetryController?.add(telemetry);

          // 🔥 cập nhật danh sách devices tự động
          ref.read(devicesProvider.notifier).updateFromTelemetry(telemetry);

          print(
              '📨 Telemetry from ${telemetry.deviceId}: ${telemetry.temperature}°C, ${telemetry.humidity}%');
        }
      } catch (e) {
        print('⚠️ Error parsing MQTT message: $e');
      }
    }
  }

  void publishControl(String deviceId, String cmd) {
    if (!_isConnected) {
      print('❌ MQTT not connected, cannot send control command');
      return;
    }

    try {
      final topic = 'iot/classroom/$deviceId/control';
      final payload = cmd;
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);

      _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      print('📤 Published control to $topic: $payload');
    } catch (e) {
      print('⚠️ Error publishing control: $e');
    }
  }

  void disconnect() {
    _client.disconnect();
    _isConnected = false;
  }
}
