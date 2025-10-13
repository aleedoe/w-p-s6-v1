// lib/pages/transaction_detail/widgets/total_section.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/transaction_detail.dart';
import 'package:mobile/views/widgets/order/detail_order/format_utils.dart';

/// Widget untuk menampilkan bagian total pembayaran transaksi
class TransactionTotalSection extends StatelessWidget {
  final TransactionDetailResponse detailData;

  const TransactionTotalSection({Key? key, required this.detailData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rp ${FormatUtils.formatPrice(detailData.totalPrice)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}
