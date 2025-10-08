import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mqtt_source.dart';

final mqttSourceProvider = Provider<MqttSource>((ref) {
  return MqttSource(ref); // truyền ref
});
