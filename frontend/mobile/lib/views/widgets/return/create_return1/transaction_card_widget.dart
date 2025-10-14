// lib/views/return/widgets/transaction_card_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/create_return.dart';

/// Widget untuk menampilkan kartu transaksi individual
/// Menampilkan informasi transaksi: ID, tanggal, jumlah produk, total harga
class TransactionCardWidget extends StatelessWidget {
  final CompletedTransaction transaction;
  final VoidCallback onTap;

  const TransactionCardWidget({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTransactionDetails(),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  /// Header dengan ID transaksi dan status
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '#${transaction.idTransaction}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  /// Badge status transaksi
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Selesai',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4CAF50),
        ),
      ),
    );
  }

  /// Detail transaksi: tanggal, jumlah produk, total harga
  Widget _buildTransactionDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailColumn(
          label: 'Tanggal',
          value: _formatDate(transaction.createdAt),
        ),
        _buildDetailColumn(
          label: 'Jumlah Produk',
          value: '${transaction.totalProducts} item',
        ),
        _buildDetailColumn(
          label: 'Total Harga',
          value: 'Rp ${_formatPrice(transaction.totalPrice)}',
          valueColor: const Color(0xFFFF6B6B),
        ),
      ],
    );
  }

  /// Kolom detail individual
  Widget _buildDetailColumn({
    required String label,
    required String value,
    Color valueColor = const Color(0xFF333333),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Tombol action untuk membuat return
  Widget _buildActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          label: const Text('Buat Return'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// Format tanggal ke format yang readable
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yy HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format harga dengan separator ribuan
  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
