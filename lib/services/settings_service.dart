import 'package:shared_preferences/shared_preferences.dart';
import '../providers/source_provider.dart';

class SettingsService {
  static const String _sourceKey = 'data_source';
  static const String _mqttUrlKey = 'mqtt_url';
  static const String _wsUrlKey = 'ws_url';
  static const String _defaultThresholdKey = 'default_threshold';
  static const String _selectedDeviceKey = 'selected_device';
  
  static Future<void> saveDataSource(DataSourceType source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sourceKey, source.name);
  }
  
  static Future<DataSourceType> getDataSource() async {
    final prefs = await SharedPreferences.getInstance();
    final sourceString = prefs.getString(_sourceKey);
    if (sourceString == 'ws') {
      return DataSourceType.ws;
    }
    return DataSourceType.mqtt; // Default
  }
  
  static Future<void> saveMqttUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mqttUrlKey, url);
  }
  
  static Future<String?> getMqttUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mqttUrlKey);
  }
  
  static Future<void> saveWsUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wsUrlKey, url);
  }
  
  static Future<String?> getWsUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_wsUrlKey);
  }
  
  static Future<void> saveDefaultThreshold(double threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_defaultThresholdKey, threshold);
  }
  
  static Future<double> getDefaultThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_defaultThresholdKey) ?? 30.0;
  }
  
  static Future<void> saveSelectedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedDeviceKey, deviceId);
  }
  
  static Future<String?> getSelectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedDeviceKey);
  }
  
  static Future<void> saveDeviceThreshold(String deviceId, double threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('threshold_$deviceId', threshold);
  }
  
  static Future<double> getDeviceThreshold(String deviceId, double defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('threshold_$deviceId') ?? defaultValue;
  }
}