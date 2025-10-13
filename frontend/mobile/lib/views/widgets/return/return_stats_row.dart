// lib/views/return/widgets/return_stats_row.dart
import 'package:flutter/material.dart';
import '../../../models/return_transaction.dart';
import 'stat_card.dart';

class ReturnStatsRow extends StatelessWidget {
  final ReturnTransactionResponse returnData;

  const ReturnStatsRow({Key? key, required this.returnData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Return',
            value: '${returnData.totalReturns}',
            icon: Icons.assignment_return_outlined,
            color: const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Disetujui',
            value: '${returnData.approvedReturns}',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Menunggu',
            value: '${returnData.pendingReturns}',
            icon: Icons.access_time,
            color: const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }
}
