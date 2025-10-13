// lib/views/return/widgets/return_info_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/return_transaction.dart';
import 'package:mobile/views/widgets/return/detail_return/return_detail_utils.dart';

class ReturnInfoCard extends StatelessWidget {
  final ReturnTransaction returnTransaction;
  final int returnTransactionId;
  final int resellerId;

  const ReturnInfoCard({
    Key? key,
    required this.returnTransaction,
    required this.returnTransactionId,
    required this.resellerId,
  }) : super(key: key);

  // Widget pembantu untuk baris informasi tunggal
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color(0xFFFF6B6B)),
        SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(returnTransaction.status);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Judul
              Row(
                children: [
                  Icon(
                    Icons.assignment_return,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Informasi Return',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  returnTransaction.getStatusLabel(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),
          // Baris Detail
          _buildInfoRow('ID Return', '#$returnTransactionId', Icons.tag),
          SizedBox(height: 12),
          _buildInfoRow(
            'ID Transaksi Asal',
            '#${returnTransaction.idTransaction}',
            Icons.receipt_long,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Return',
            formatDateFull(returnTransaction.returnDate),
            Icons.calendar_today,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Transaksi Asal',
            formatDateFull(returnTransaction.transactionDate),
            Icons.event,
          ),
          SizedBox(height: 12),
          _buildInfoRow('ID Reseller', '#$resellerId', Icons.person),
        ],
      ),
    );
  }
}
