import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mqtt_control_publisher.dart';

final mqttControlPublisherProvider = Provider<MqttControlPublisher>((ref) {
  final publisher = MqttControlPublisher();
  // Auto-connect when provider is created
  publisher.connect();
  return publisher;
});
