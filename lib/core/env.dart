import 'package:flutter/foundation.dart';

class Env {
  // MQTT Broker (WebSocket)
  static const String mqttHost = '172.20.10.4'; // IP máy thật trong LAN
  static const int mqttPort = 9001;             // port WebSocket đã bật trong mosquitto.conf

  // WebSocket Mock server
  static const String wsHost = 'localhost';
  static const int wsPort = 3002;

  // Database API (HTTP backend server)
  static const String apiHost = '172.20.10.4';
  static const int apiPort = 8000;
  static String get apiBaseUrl => 'http://$apiHost:$apiPort';

  // Database credentials (used by backend server, not Flutter app)
  static const String dbHost = '172.20.10.4';
  static const int dbPort = 5432;
  static const String dbName = 'iot_classroom';
  static const String dbUser = 'postgres';
  static const String dbPassword = '1';

  // Nếu cần giữ nguyên URL đầy đủ
  static String get mqttWsUrl => 'ws://$mqttHost:$mqttPort';
  static String get wsMockUrl => 'ws://$wsHost:$wsPort';
}
