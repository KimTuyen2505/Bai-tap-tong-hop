import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus { online, offline, connecting }

final connectionStatusProvider = StateProvider<ConnectionStatus>((ref) => ConnectionStatus.connecting);
