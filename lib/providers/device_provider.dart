import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry.dart';

/// Provider cho thiết bị đang được chọn
final selectedDeviceProvider = StateProvider<String?>((ref) => null);

/// Provider cho danh sách thiết bị hiện có (ban đầu rỗng)
final devicesProvider = StateNotifierProvider<DevicesNotifier, List<String>>(
  (ref) => DevicesNotifier(),
);

class DevicesNotifier extends StateNotifier<List<String>> {
  DevicesNotifier() : super([]);

  /// Cập nhật danh sách thiết bị mỗi khi có telemetry mới
  void updateFromTelemetry(Telemetry telemetry) {
    if (!state.contains(telemetry.deviceId)) {
      state = [...state, telemetry.deviceId];
    }
  }
}
