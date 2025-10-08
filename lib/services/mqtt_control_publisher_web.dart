import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import '../core/env.dart';

/// Web-specific MQTT publisher using native browser WebSocket
class MqttControlPublisher {
  html.WebSocket? _ws;
  bool _isConnected = false;
  bool _isConnecting = false;
  final _connectCompleter = Completer<void>();

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      print('[v0] Already connected or connecting, skipping...');
      return;
    }

    _isConnecting = true;

    try {
      final wsUrl = 'ws://${Env.mqttHost}:${Env.mqttPort}';
      print('[v0] Connecting to WebSocket: $wsUrl');
      print('🌐 MQTT Control Publisher (Web): $wsUrl');

      _ws = html.WebSocket(wsUrl, 'mqtt');

      _ws!.onOpen.listen((event) {
        print('[v0] WebSocket opened');
        _sendMqttConnect();
      });

      _ws!.onMessage.listen((event) {
        print('[v0] WebSocket message received: ${event.data}');
        // Check if this is a CONNACK message
        if (event.data is String) {
          // Handle text message
        } else if (event.data is html.Blob) {
          // Handle binary CONNACK
          final reader = html.FileReader();
          reader.onLoadEnd.listen((_) {
            final bytes = reader.result as List<int>;
            print('[v0] Received bytes: $bytes');
            // CONNACK packet: [0x20, remaining_length, ...]
            if (bytes.isNotEmpty && bytes[0] == 0x20) {
              print('✅ MQTT Control Publisher connected');
              _isConnected = true;
              if (!_connectCompleter.isCompleted) {
                _connectCompleter.complete();
              }
            }
          });
          reader.readAsArrayBuffer(event.data as html.Blob);
        }
      });

      _ws!.onError.listen((event) {
        print('[v0] WebSocket error: $event');
        print('❌ MQTT Control Publisher connection error');
        _isConnected = false;
        _isConnecting = false;
        if (!_connectCompleter.isCompleted) {
          _connectCompleter.completeError('WebSocket error');
        }
      });

      _ws!.onClose.listen((event) {
        print('[v0] WebSocket closed: ${event.code} - ${event.reason}');
        print('🔌 MQTT Control Publisher disconnected');
        _isConnected = false;
        _isConnecting = false;
      });

      // Wait for connection with timeout
      await _connectCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );
    } catch (e, stackTrace) {
      print('[v0] Exception during connection: $e');
      print('[v0] Stack trace: $stackTrace');
      print('❌ MQTT Control Publisher connection error: $e');
      _isConnected = false;
    } finally {
      _isConnecting = false;
    }
  }

  void _sendMqttConnect() {
    print('[v0] Sending MQTT CONNECT packet');
    
    // Build MQTT CONNECT packet (MQTT 3.1.1)
    final clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
    final clientIdBytes = utf8.encode(clientId);
    
    // Fixed header: CONNECT (0x10)
    final packet = <int>[
      0x10, // CONNECT packet type
    ];
    
    // Variable header
    final variableHeader = <int>[
      0x00, 0x04, // Protocol name length
      0x4D, 0x51, 0x54, 0x54, // "MQTT"
      0x04, // Protocol level (MQTT 3.1.1)
      0x02, // Connect flags (Clean Session)
      0x00, 0x3C, // Keep alive (60 seconds)
    ];
    
    // Payload: Client ID
    final payload = <int>[
      (clientIdBytes.length >> 8) & 0xFF, // Client ID length MSB
      clientIdBytes.length & 0xFF, // Client ID length LSB
      ...clientIdBytes,
    ];
    
    // Calculate remaining length
    final remainingLength = variableHeader.length + payload.length;
    packet.add(remainingLength);
    packet.addAll(variableHeader);
    packet.addAll(payload);
    
    print('[v0] Sending CONNECT packet: ${packet.length} bytes');
    _ws!.sendTypedData(Uint8List.fromList(packet));
  }

  Future<void> publishControl(String deviceId, String command) async {
    print('[v0] publishControl called - deviceId: $deviceId, command: $command');
    print('[v0] Current connection state: $_isConnected');
    
    if (!_isConnected) {
      print('⚠️ MQTT not connected, attempting to connect...');
      await connect();
    }

    if (!_isConnected) {
      print('❌ Cannot send control command: MQTT not connected');
      return;
    }

    try {
      final topic = 'iot/classroom/$deviceId/control';
      print('[v0] Publishing to topic: $topic');
      
      // Build MQTT PUBLISH packet
      final topicBytes = utf8.encode(topic);
      final payloadBytes = utf8.encode(command);
      
      // Fixed header: PUBLISH (0x30) with QoS 0
      final packet = <int>[
        0x30, // PUBLISH packet type, QoS 0
      ];
      
      // Variable header: Topic name
      final variableHeader = <int>[
        (topicBytes.length >> 8) & 0xFF, // Topic length MSB
        topicBytes.length & 0xFF, // Topic length LSB
        ...topicBytes,
      ];
      
      // Calculate remaining length
      final remainingLength = variableHeader.length + payloadBytes.length;
      packet.add(remainingLength);
      packet.addAll(variableHeader);
      packet.addAll(payloadBytes);
      
      print('[v0] Sending PUBLISH packet: ${packet.length} bytes');
      _ws!.sendTypedData(Uint8List.fromList(packet));
      print('📤 Published to $topic: $command');
    } catch (e, stackTrace) {
      print('[v0] Error in publishControl: $e');
      print('[v0] Stack trace: $stackTrace');
      print('❌ Error publishing control: $e');
    }
  }

  void disconnect() {
    if (_ws != null) {
      _ws!.close();
      _ws = null;
      _isConnected = false;
    }
  }
}
