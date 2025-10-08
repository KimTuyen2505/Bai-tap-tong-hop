import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/control_history.dart';

class DatabaseService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[v0] Initializing database service...');
      
      if (kIsWeb) {
        print('[v0] Running on web - using HTTP API for database access');
        // For web, we'll use HTTP API calls to a backend server
        // The backend server will handle PostgreSQL connections
      } else {
        print('[v0] Running on mobile/desktop - direct database connection not yet implemented');
        // For mobile/desktop, you could use direct postgres connection
        // but for now we'll use HTTP API for all platforms
      }
      
      // Test connection by trying to fetch history
      await _testConnection();
      _isInitialized = true;
      print('[v0] Database service initialized successfully');
    } catch (e) {
      print('[v0] Database initialization error: $e');
      // Don't rethrow - allow app to continue without database
    }
  }

  static Future<void> _testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${Env.apiBaseUrl}/api/control-history?limit=1'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        print('[v0] Database API connection successful');
      } else {
        print('[v0] Database API returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Database API not available: $e');
      print('[v0] App will continue without database features');
    }
  }

  static Future<void> saveControlCommand({
    required String deviceId,
    required String command,
    bool success = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.apiBaseUrl}/api/control-history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'command': command,
          'success': success,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[v0] Saved control command: $command for $deviceId');
      } else {
        print('[v0] Failed to save command: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error saving control command: $e');
      // Don't throw - allow app to continue even if database save fails
    }
  }

  static Future<List<ControlHistory>> getControlHistory({
    String? deviceId,
    int limit = 100,
  }) async {
    try {
      final uri = deviceId != null
          ? Uri.parse('${Env.apiBaseUrl}/api/control-history?device_id=$deviceId&limit=$limit')
          : Uri.parse('${Env.apiBaseUrl}/api/control-history?limit=$limit');

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ControlHistory.fromJson(json)).toList();
      } else {
        print('[v0] Failed to fetch history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[v0] Error fetching control history: $e');
      return [];
    }
  }

  static Future<void> clearHistory({String? deviceId}) async {
    try {
      final uri = deviceId != null
          ? Uri.parse('${Env.apiBaseUrl}/api/control-history?device_id=$deviceId')
          : Uri.parse('${Env.apiBaseUrl}/api/control-history');

      final response = await http.delete(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('[v0] Cleared control history');
      } else {
        print('[v0] Failed to clear history: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error clearing history: $e');
    }
  }

  static Future<void> close() async {
    _isInitialized = false;
    print('[v0] Database service closed');
  }
}
