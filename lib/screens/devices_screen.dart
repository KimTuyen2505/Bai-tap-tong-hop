import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/device_tile.dart';
import '../providers/device_provider.dart';
import '../providers/telemetry_buffer_provider.dart';
import '../providers/thresholds_provider.dart';
import '../providers/online_status_provider.dart';
import '../providers/data_stream_provider.dart';
import '../models/control_command.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final deviceId = devices[index];
          return Consumer(
            builder: (context, ref, _) {
              final telemetryBuffer = ref.watch(telemetryBufferProvider(deviceId));
              final threshold = ref.watch(thresholdsProvider(deviceId));
              final isOnline = ref.watch(onlineStatusProvider(deviceId));

              final currentLed = telemetryBuffer.values.isNotEmpty
                  ? telemetryBuffer.values.last.led
                  : false;
              
              final currentMotor = telemetryBuffer.values.isNotEmpty
                  ? telemetryBuffer.values.last.motor
                  : false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DeviceTile(
                  deviceId: deviceId,
                  isOnline: isOnline,
                  led: currentLed,
                  onLedChanged: (value) {
                    final command = value ? "LED_ON" : "LED_OFF";
                    _sendControlCommand(ref, deviceId, command);
                  },
                  motor: currentMotor,
                  onMotorChanged: (value) {
                    final command = value ? "MOTOR_ON" : "MOTOR_OFF";
                    _sendControlCommand(ref, deviceId, command);
                  },
                  threshold: threshold,
                  onThresholdChanged: (value) {
                    ref.read(thresholdsProvider(deviceId).notifier).state = value;
                    _sendControlCommand(ref, deviceId, "THRESHOLD_$value");
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              break;
            case 2:
              context.go('/alerts');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _sendControlCommand(WidgetRef ref, String deviceId, String command) {
    final dataStream = ref.read(dataStreamProvider);
    dataStream.sendControlCommand(deviceId, command);
  }
}
