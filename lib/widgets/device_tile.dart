import 'package:flutter/material.dart';

class DeviceTile extends StatelessWidget {
  final String deviceId;
  final bool led;
  final ValueChanged<bool> onLedChanged;
  final bool motor;
  final ValueChanged<bool> onMotorChanged;
  final double threshold;
  final ValueChanged<double> onThresholdChanged;
  final bool isOnline;
  
  const DeviceTile({
    super.key,
    required this.deviceId,
    required this.led,
    required this.onLedChanged,
    required this.motor,
    required this.onMotorChanged,
    required this.threshold,
    required this.onThresholdChanged,
    this.isOnline = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ExpansionTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          deviceId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            color: isOnline ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // LED Control
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: led ? Colors.yellow : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'LED Control',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: led,
                        onChanged: isOnline ? onLedChanged : null,
                        activeThumbColor: Colors.yellow,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: motor ? Colors.blue : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'DC Motor Control',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: motor,
                        onChanged: isOnline ? onMotorChanged : null,
                        activeThumbColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Threshold Control
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Temperature Threshold',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${threshold.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange,
                          thumbColor: Colors.orange,
                          overlayColor: Colors.orange.withValues(alpha: 0.2),
                          valueIndicatorColor: Colors.orange,
                        ),
                        child: Slider(
                          value: threshold,
                          min: 10,
                          max: 50,
                          divisions: 40,
                          label: '${threshold.toStringAsFixed(1)}°C',
                          onChanged: isOnline ? onThresholdChanged : null,
                        ),
                      ),
                      Text(
                        'Range: 10°C - 50°C',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
