// lib/views/stock_out/widgets/stock_out_info_card.dart

import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/stock_out/detail_stock_out/stock_out_formatters.dart';

/// Card untuk menampilkan informasi umum stock out
/// seperti ID, tanggal, dan ID reseller
class StockOutInfoCard extends StatelessWidget {
  final int stockOutId;
  final int resellerId;
  final String createdAt;

  const StockOutInfoCard({
    Key? key,
    required this.stockOutId,
    required this.resellerId,
    required this.createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          SizedBox(height: 20),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),
          _buildInfoRow('ID Stock Out', '#$stockOutId', Icons.tag),
          SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Stock Out',
            StockOutFormatters.formatDateFull(createdAt),
            Icons.calendar_today,
          ),
          SizedBox(height: 12),
          _buildInfoRow('ID Reseller', '#$resellerId', Icons.person),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.inventory_2_outlined, color: Color(0xFF4CAF50), size: 24),
        SizedBox(width: 8),
        Text(
          'Informasi Stock Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color(0xFF4CAF50)),
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
