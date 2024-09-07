import 'package:flutter/material.dart';

class BatteryChip extends StatelessWidget {
  const BatteryChip({
    super.key,
    required this.batteryLevel,
  });

  final int? batteryLevel;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Chip(
          //  elevation: 2.0,
          padding: const EdgeInsets.only(left: 2.0, right: 14.0),
          labelPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          side: BorderSide(
            strokeAlign: -1.0,
            color: batteryLevel! > 50
                ? Colors.green[600]!
                : batteryLevel! > 30
                    ? Colors.orange[600]!
                    : Colors.red,
            width: 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          visualDensity: VisualDensity.compact,
          label: Text('$batteryLevel%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
          avatar: Icon(
            batteryLevel == 100
                ? Icons.battery_full_rounded
                : batteryLevel! > 50
                    ? Icons.battery_5_bar
                    : batteryLevel! > 20
                        ? Icons.battery_3_bar
                        : Icons.battery_alert_rounded,
            color: batteryLevel! > 50
                ? Colors.green[600]
                : batteryLevel! > 30
                    ? Colors.orange[600]
                    : Colors.red,
            size: 18.0,
          )),
    );
  }
}
