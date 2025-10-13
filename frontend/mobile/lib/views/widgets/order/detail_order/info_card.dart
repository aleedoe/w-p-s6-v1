// lib/pages/transaction_detail/widgets/info_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/transaction.dart';
import 'package:mobile/views/widgets/order/detail_order/format_utils.dart';
import 'package:mobile/views/widgets/order/detail_order/style_utils.dart';


/// Widget untuk menampilkan kartu informasi transaksi
class TransactionInfoCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionInfoCard({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: StyleUtils.defaultBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan judul dan status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: Color(0xFF2196F3), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Informasi Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),

          // Baris informasi
          _buildInfoRow('ID Transaksi', '#${transaction.id}', Icons.tag),
          SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Transaksi',
            FormatUtils.formatDateFull(transaction.createdAt),
            Icons.calendar_today,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'ID Reseller',
            '#${transaction.id}', // Sesuaikan dengan property yang sesuai
            Icons.person,
          ),
        ],
      ),
    );
  }

  /// Membangun badge status transaksi
  Widget _buildStatusBadge() {
    final statusColor = StyleUtils.getStatusColor(transaction.status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        transaction.getStatusLabel(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  /// Membangun baris informasi dengan ikon
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color(0xFF2196F3)),
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
}
