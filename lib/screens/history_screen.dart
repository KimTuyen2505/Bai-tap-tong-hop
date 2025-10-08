import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/control_history.dart';
import '../providers/device_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _selectedDevice;
  List<ControlHistory> _history = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final history = await DatabaseService.getControlHistory(
        deviceId: _selectedDevice,
        limit: 100,
      );
      
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control History'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showClearDialog,
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: Column(
        children: [
          if (devices.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: 'Filter by Device',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: _selectedDevice,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Devices'),
                        ),
                        ...devices.map((device) => DropdownMenuItem(
                              value: device,
                              child: Text(device),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedDevice = value);
                        _loadHistory();
                      },
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_history.length} records',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (_selectedDevice != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _selectedDevice = null);
                      _loadHistory();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Filter'),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No control history',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Control commands will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return _buildHistoryCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ControlHistory item) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');
    
    IconData icon;
    Color iconColor;
    
    if (item.command.contains('LED')) {
      icon = Icons.lightbulb;
      iconColor = item.command == 'LED_ON' ? Colors.amber : Colors.grey;
    } else if (item.command.contains('MOTOR')) {
      icon = Icons.settings;
      iconColor = item.command == 'MOTOR_ON' ? Colors.blue : Colors.grey;
    } else {
      icon = Icons.power_settings_new;
      iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          item.commandDisplay,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.devices, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.deviceId,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(item.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: item.success
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : const Icon(Icons.error, color: Colors.red, size: 20),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: Text(
          _selectedDevice != null
              ? 'Clear all history for $_selectedDevice?'
              : 'Clear all control history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService.clearHistory(deviceId: _selectedDevice);
              _loadHistory();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
