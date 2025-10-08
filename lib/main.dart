import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo notification service
  await NotificationService.init();
  
  try {
    await DatabaseService.initialize();
    print('Database initialized successfully');
  } catch (e) {
    print('Database initialization failed: $e');
  }
  
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}
