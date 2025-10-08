import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo notification service
  await NotificationService.init();
  
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}
