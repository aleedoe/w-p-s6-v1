// lib/views/return/widgets/transaction_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/utils/date_formatter.dart';
import 'package:mobile/utils/price_formatter.dart';

class TransactionCard extends StatelessWidget {
  final CompletedTransaction transaction;
  final Function(CompletedTransaction) onTransactionTapped;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.onTransactionTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTransactionTapped(transaction),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
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
            // Header Transaksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${transaction.idTransaction}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Detail Transaksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn(
                  'Tanggal',
                  DateFormatter.format(transaction.createdAt),
                ),
                _buildDetailColumn(
                  'Jumlah Produk',
                  '${transaction.totalProducts} item',
                ),
                _buildDetailColumn(
                  'Total Harga',
                  'Rp ${PriceFormatter.format(transaction.totalPrice)}',
                  isPrice: true,
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: Color(0xFFEEEEEE)),
            SizedBox(height: 12),
            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => onTransactionTapped(transaction),
                  icon: Icon(Icons.arrow_forward_ios, size: 14),
                  label: Text('Buat Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk membuat kolom detail
  Widget _buildDetailColumn(
    String title,
    String value, {
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPrice ? Color(0xFFFF6B6B) : Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
