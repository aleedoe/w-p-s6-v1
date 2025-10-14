// lib/views/return/widgets/return_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/return/create_return1/create_return_provider.dart';

/// Widget untuk menampilkan ringkasan return
/// Menampilkan total produk, total item, dan total harga return
class ReturnSummaryWidget extends StatelessWidget {
  final CreateReturnProvider provider;

  const ReturnSummaryWidget({Key? key, required this.provider})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryRow(
          label: 'Total Produk Return',
          value: '${provider.totalReturnProducts} jenis',
        ),
        const SizedBox(height: 8),
        _buildSummaryRow(
          label: 'Total Item Return',
          value: '${provider.totalReturnItems} pcs',
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFEEEEEE)),
        const SizedBox(height: 16),
        _buildTotalRow(),
      ],
    );
  }

  /// Baris ringkasan individual
  Widget _buildSummaryRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  /// Baris total dengan format besar
  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Return',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          'Rp ${_formatPrice(provider.totalReturnPrice)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
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
