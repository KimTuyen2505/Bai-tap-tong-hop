import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DataSourceType { mqtt, ws }

final sourceProvider = StateProvider<DataSourceType>((ref) => DataSourceType.mqtt);
