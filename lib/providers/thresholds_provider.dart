import 'package:flutter_riverpod/flutter_riverpod.dart';

final thresholdsProvider = StateProvider.family<double, String>((ref, deviceId) => 30.0);
