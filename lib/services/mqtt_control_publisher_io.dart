import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../core/env.dart';

/// Mobile/Desktop MQTT publisher using mqtt_client
class MqttControlPublisher {
  late MqttServerClient _client;
  bool _isConnected = false;
  bool _isConnecting = false;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      return;
    }

    _isConnecting = true;

    try {
      final clientId = 'flutter_control_${DateTime.now().millisecondsSinceEpoch}';
      
      _client = MqttServerClient.withPort(
        Env.mqttHost,
        clientId,
        Env.mqttPort,
      );
      
      _client.logging(on: false);
      _client.keepAlivePeriod = 60;
      _client.connectTimeoutPeriod = 10000;
      
      _client.onConnected = () {
        print('✅ MQTT Control Publisher connected');
        _isConnected = true;
      };
      
      _client.onDisconnected = () {
        print('🔌 MQTT Control Publisher disconnected');
        _isConnected = false;
      };

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .keepAliveFor(60);
      _client.connectionMessage = connMessage;

      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        _isConnected = true;
      }
    } catch (e) {
      print('❌ MQTT Control Publisher connection error: $e');
      _isConnected = false;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> publishControl(String deviceId, String command) async {
    if (!_isConnected) {
      await connect();
    }

    if (!_isConnected) {
      print('❌ Cannot send control command: MQTT not connected');
      return;
    }

    try {
      final topic = 'iot/classroom/$deviceId/control';
      final builder = MqttClientPayloadBuilder();
      builder.addString(command);
      _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      print('📤 Published to $topic: $command');
    } catch (e) {
      print('❌ Error publishing control: $e');
    }
  }

  void disconnect() {
    if (_isConnected) {
      _client.disconnect();
      _isConnected = false;
    }
  }
}
