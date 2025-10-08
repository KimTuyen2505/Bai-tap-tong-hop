import 'package:meta/meta.dart';

@immutable
class ControlCommand {
  final bool? led;
  final double? threshold;
  final bool? motor;

  const ControlCommand({this.led, this.threshold, this.motor});

  Map<String, dynamic> toJson() => {
        if (led != null) 'led': led,
        if (threshold != null) 'threshold': threshold,
        if (motor != null) 'motor': motor,
      };
}
