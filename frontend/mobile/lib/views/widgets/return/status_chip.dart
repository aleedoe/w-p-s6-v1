// lib/views/return/widgets/status_chip.dart
import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/return/return_helpers.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final String label;

  const StatusChip({Key? key, required this.status, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = ReturnHelpers.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
