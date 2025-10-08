import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/telemetry_buffer_provider.dart';
import '../providers/device_provider.dart';
import '../widgets/live_chart.dart';
import '../widgets/metric_card.dart';
import '../widgets/connection_indicator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);
    final selectedDevice = ref.watch(selectedDeviceProvider);

    final telemetryBuffer = selectedDevice != null
        ? ref.watch(telemetryBufferProvider(selectedDevice))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const ConnectionIndicator(),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Device',
                border: OutlineInputBorder(),
              ),
              value: selectedDevice ??
                  (devices.isNotEmpty ? devices.first : null),
              items: devices
                  .map(
                    (device) => DropdownMenuItem(
                      value: device,
                      child: Text(device),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  ref.read(selectedDeviceProvider.notifier).state = value,
            ),
          ),

          const SizedBox(height: 16),

          if (selectedDevice != null &&
              telemetryBuffer != null &&
              telemetryBuffer.values.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Temperature',
                          value:
                              '${telemetryBuffer.values.last.temperature.toStringAsFixed(1)}°C',
                          icon: Icons.thermostat,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MetricCard(
                          label: 'Humidity',
                          value:
                              '${telemetryBuffer.values.last.humidity.toStringAsFixed(1)}%',
                          icon: Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'LED',
                          value: telemetryBuffer.values.last.led ? 'ON' : 'OFF',
                          icon: Icons.lightbulb,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MetricCard(
                          label: 'Motor',
                          value: telemetryBuffer.values.last.motor ? 'ON' : 'OFF',
                          icon: Icons.settings,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature Trend (${telemetryBuffer.values.length} samples)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LiveChart(
                        data: telemetryBuffer.values
                            .map((t) => t.temperature)
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.device_hub, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Select a device to view data',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
