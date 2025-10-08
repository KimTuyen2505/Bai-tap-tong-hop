import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/optimized_telemetry_provider.dart';
import '../providers/device_provider.dart';
import '../services/data_export_service.dart';
import '../services/background_processor.dart';
import '../models/telemetry.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);

    if (devices.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No devices available')),
      );
    }

    final selectedDevice = _selectedDevice ?? devices.first;
    final stats = ref.watch(telemetryStatsProvider(selectedDevice));
    final buffer = ref.watch(optimizedTelemetryBufferProvider(selectedDevice));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.report), text: 'Reports'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value, selectedDevice),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'export_csv', child: Text('Export CSV')),
              PopupMenuItem(value: 'export_json', child: Text('Export JSON')),
              PopupMenuItem(value: 'share_report', child: Text('Share Report')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Device selector
          Container(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Device',
                border: OutlineInputBorder(),
              ),
              value: selectedDevice,
              items: devices
                  .map((device) =>
                      DropdownMenuItem(value: device, child: Text(device)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDevice = value),
            ),
          ),

          // Stats summary
          _buildStatsCard(stats),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(buffer, stats),
                _buildTrendsTab(buffer),
                _buildReportsTab(selectedDevice, buffer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(TelemetryStats stats) { /* giữ nguyên như cũ */ 
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('${stats.avgTemp.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Avg Temp', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('${stats.avgHumidity.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Avg Humidity',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('${stats.count}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Samples', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
      OptimizedTelemetryBuffer buffer, TelemetryStats stats) { /* giữ nguyên như cũ */ 
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Temperature chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Temperature Trend',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                        _buildTemperatureChart(buffer.getRecentData(50))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Humidity chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Humidity Trend',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child:
                        LineChart(_buildHumidityChart(buffer.getRecentData(50))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(OptimizedTelemetryBuffer buffer) { /* giữ nguyên như cũ */ 
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Combined chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Combined Analysis',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                        _buildCombinedChart(buffer.getRecentData(100))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: BackgroundDataProcessor.detectAnomalies(buffer.values),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final anomalies = snapshot.data ?? [];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Anomalies Detected: ${anomalies.length}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (anomalies.isEmpty)
                        const Text('No anomalies detected in the data.')
                      else
                        ...anomalies.take(5).map((anomaly) => ListTile(
                              leading: const Icon(Icons.warning,
                                  color: Colors.orange),
                              title: Text(
                                  'Temperature: ${anomaly['temperature']}°C'),
                              subtitle:
                                  Text('Deviation: ${anomaly['deviation']}σ'),
                            )),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(
      String deviceId, OptimizedTelemetryBuffer buffer) { /* giữ nguyên như cũ */ 
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future:
                DataExportService.generateReport(buffer.values, deviceId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final report = snapshot.data ?? {};
              if (report.containsKey('error')) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${report['error']}'),
                  ),
                );
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Device Report',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildReportSection('Period', report['period']),
                      _buildReportSection('Temperature', report['temperature']),
                      _buildReportSection('Humidity', report['humidity']),
                      _buildReportSection('LED Activity', report['led_activity']),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(String title, Map<String, dynamic> data) { /* giữ nguyên như cũ */ 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('${entry.key}: ${entry.value}'),
            )),
        const SizedBox(height: 12),
      ],
    );
  }

  LineChartData _buildTemperatureChart(List<dynamic> data) { /* giữ nguyên như cũ */ 
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.temperature))
              .toList(),
          color: Colors.red,
          barWidth: 2,
        ),
      ],
    );
  }

  LineChartData _buildHumidityChart(List<dynamic> data) { /* giữ nguyên như cũ */ 
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.humidity))
              .toList(),
          color: Colors.blue,
          barWidth: 2,
        ),
      ],
    );
  }

  LineChartData _buildCombinedChart(List<dynamic> data) { /* giữ nguyên như cũ */ 
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.temperature))
              .toList(),
          color: Colors.red,
          barWidth: 2,
        ),
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.humidity))
              .toList(),
          color: Colors.blue,
          barWidth: 2,
        ),
      ],
    );
  }

  void _handleMenuAction(String action, String deviceId) async {
    final buffer = ref.read(optimizedTelemetryBufferProvider(deviceId));
    switch (action) {
      case 'export_csv':
        final filePath =
            await DataExportService.exportToCSV(buffer.values, deviceId);
        await DataExportService.shareData(filePath);
        break;
      case 'export_json':
        final filePath =
            await DataExportService.exportToJSON(buffer.values, deviceId);
        await DataExportService.shareData(filePath);
        break;
      case 'share_report':
        final report =
            await DataExportService.generateReport(buffer.values, deviceId);
        print('Generated report: ${report.length} characters');
        break;
    }
  }
}
