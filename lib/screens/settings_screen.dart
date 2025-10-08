import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/source_provider.dart';
import '../services/settings_service.dart';
import '../core/env.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _mqttUrlController = TextEditingController();
  final _wsUrlController = TextEditingController();
  final _defaultThresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Tải cấu hình đã lưu
    final mqttUrl = await SettingsService.getMqttUrl();
    final wsUrl = await SettingsService.getWsUrl();
    final defaultThreshold = await SettingsService.getDefaultThreshold();

    setState(() {
      _mqttUrlController.text = mqttUrl ?? Env.mqttWsUrl;
      _wsUrlController.text = wsUrl ?? Env.wsMockUrl;
      _defaultThresholdController.text = defaultThreshold.toString();
    });
  }

  @override
  void dispose() {
    _mqttUrlController.dispose();
    _wsUrlController.dispose();
    _defaultThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSource = ref.watch(sourceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Source Selection
            _buildSectionHeader('Data Source'),
            Card(
              child: Column(
                children: [
                  RadioListTile<DataSourceType>(
                    title: const Text('MQTT'),
                    subtitle: const Text('Real-time MQTT over WebSocket'),
                    value: DataSourceType.mqtt,
                    groupValue: currentSource,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(sourceProvider.notifier).state = value;
                      }
                    },
                  ),
                  RadioListTile<DataSourceType>(
                    title: const Text('WebSocket Mock'),
                    subtitle: const Text('Mock data for development'),
                    value: DataSourceType.ws,
                    groupValue: currentSource,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(sourceProvider.notifier).state = value;
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Connection URLs
            _buildSectionHeader('Connection URLs'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _mqttUrlController,
                      decoration: const InputDecoration(
                        labelText: 'MQTT WebSocket URL',
                        hintText: 'ws://172.20.10.4:9001',
                        prefixIcon: Icon(Icons.cloud),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _wsUrlController,
                      decoration: const InputDecoration(
                        labelText: 'WebSocket Mock URL',
                        hintText: 'ws://localhost:3002',
                        prefixIcon: Icon(Icons.developer_mode),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Default Settings
            _buildSectionHeader('Default Settings'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _defaultThresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Default Temperature Threshold (°C)',
                        hintText: '30.0',
                        prefixIcon: Icon(Icons.thermostat),
                        border: OutlineInputBorder(),
                        suffixText: '°C',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status & Info
            _buildSectionHeader('Status'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Current Source'),
                    subtitle: Text(currentSource == DataSourceType.mqtt
                        ? 'MQTT over WebSocket'
                        : 'WebSocket Mock'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: currentSource == DataSourceType.mqtt
                            ? Colors.blue
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currentSource == DataSourceType.mqtt ? 'MQTT' : 'MOCK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.memory),
                    title: Text('Buffer Size'),
                    subtitle: Text('Maximum telemetry samples per device'),
                    trailing: Text('500'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Offline Timeout'),
                    subtitle: Text('Mark device offline after no data'),
                    trailing: Text('5s'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetToDefaults,
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset to Defaults'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('Test Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/devices');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/alerts');
              break;
            case 3:
              // Already on settings
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _saveSettings() async {
    try {
      // Lưu URLs
      if (_mqttUrlController.text.isNotEmpty) {
        await SettingsService.saveMqttUrl(_mqttUrlController.text);
      }
      if (_wsUrlController.text.isNotEmpty) {
        await SettingsService.saveWsUrl(_wsUrlController.text);
      }

      // Lưu threshold mặc định
      final thresholdText = _defaultThresholdController.text;
      if (thresholdText.isNotEmpty) {
        final threshold = double.tryParse(thresholdText);
        if (threshold != null && threshold >= 10 && threshold <= 50) {
          await SettingsService.saveDefaultThreshold(threshold);
        }
      }

      // Lưu data source
      final currentSource = ref.read(sourceProvider);
      await SettingsService.saveDataSource(currentSource);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _mqttUrlController.text = Env.mqttWsUrl;
      _wsUrlController.text = Env.wsMockUrl;
      _defaultThresholdController.text = '30.0';
    });
    ref.read(sourceProvider.notifier).state = DataSourceType.mqtt;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _testConnection() {
    // TODO: Kiểm tra kết nối với URL hiện tại
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Testing connection...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
