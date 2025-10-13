// ============================================================================
// lib/pages/order_page/widgets/transaction_stats.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import 'stat_card.dart';

class TransactionStats extends StatelessWidget {
  final TransactionResponse transactionData;

  const TransactionStats({
    Key? key,
    required this.transactionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Total Order',
              value: '${transactionData.totalTransactions}',
              icon: Icons.receipt_long_outlined,
              color: Color(0xFF2196F3),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Selesai',
              value: '${transactionData.completedTransactions}',
              icon: Icons.check_circle_outline,
              color: Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Menunggu',
              value: '${transactionData.pendingTransactions}',
              icon: Icons.access_time,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }
}