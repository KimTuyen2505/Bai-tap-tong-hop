import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/config.dart';
import 'telemetry_buffer_provider.dart';

final onlineStatusProvider = StateNotifierProvider.family<OnlineStatusNotifier, bool, String>(
  (ref, deviceId) => OnlineStatusNotifier(ref, deviceId),
);

class OnlineStatusNotifier extends StateNotifier<bool> {
  final Ref ref;
  final String deviceId;
  Timer? _timer;

  OnlineStatusNotifier(this.ref, this.deviceId) : super(false) {
    _checkInitialStatus();
    _listen();
  }

  void _checkInitialStatus() {
    final buffer = ref.read(telemetryBufferProvider(deviceId));
    if (buffer.values.isNotEmpty) {
      final lastTelemetry = buffer.values.last;
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeSinceLastUpdate = now - lastTelemetry.ts.millisecondsSinceEpoch;
      
      // If last telemetry is within timeout period, device is online
      if (timeSinceLastUpdate < AppConfig.offlineTimeout.inMilliseconds) {
        state = true;
        // // Set timer to mark offline after timeout
        // _timer = Timer(
        //   Duration(milliseconds: AppConfig.offlineTimeout.inMilliseconds - timeSinceLastUpdate),
        //   () => state = false,
        // );
      }
    }
  }

  void _listen() {
    ref.listen<List<dynamic>>(
      telemetryBufferProvider(deviceId).select((b) => b.values),
      (prev, next) {
        _timer?.cancel();
        state = true;
        _timer = Timer(AppConfig.offlineTimeout, () => state = false);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
