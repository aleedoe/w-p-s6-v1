// lib/views/stock_out/widgets/stock_out_total_section.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/stock_out_detail.dart';
import './stock_out_formatters.dart';

/// Widget untuk menampilkan total nilai stock out keseluruhan
/// dengan tampilan gradient yang menarik
class StockOutTotalSection extends StatelessWidget {
  final StockOutDetailResponse detailData;

  const StockOutTotalSection({Key? key, required this.detailData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildTotalInfo(), _buildIcon()],
      ),
    );
  }

  Widget _buildTotalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Nilai Stock Out',
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'Rp ${StockOutFormatters.formatPrice(detailData.totalHargaSemua)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.inventory_2_outlined, color: Colors.white, size: 32),
    );
  }
}
