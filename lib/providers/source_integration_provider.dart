import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mqtt_source.dart';
import '../services/ws_source.dart';
import 'source_provider.dart';
import 'mqtt_source_provider.dart';

final wsSourceProvider = Provider<WsSource>((ref) => WsSource());

final activeSourceProvider = Provider<dynamic>((ref) {
  final type = ref.watch(sourceProvider);
  if (type == DataSourceType.mqtt) {
    return ref.watch(mqttSourceProvider);
  } else {
    return ref.watch(wsSourceProvider);
  }
});
