import 'package:flutter/foundation.dart';

class Env {
  // MQTT Broker (WebSocket)
  static const String mqttHost = '172.20.10.4'; // IP máy thật trong LAN
  static const int mqttPort = 9001;             // port WebSocket đã bật trong mosquitto.conf

  // WebSocket Mock server
  static const String wsHost = 'localhost';
  static const int wsPort = 3002;

  // Nếu cần giữ nguyên URL đầy đủ
  static String get mqttWsUrl => 'ws://$mqttHost:$mqttPort';
  static String get wsMockUrl => 'ws://$wsHost:$wsPort';
}
