// lib/views/return/dialogs/return_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';

/// Dialog konfirmasi sebelum membuat return
/// Menampilkan ringkasan transaksi dan item yang akan di-return
class ReturnConfirmationDialog extends StatelessWidget {
  final CompletedTransaction transaction;
  final CreateReturnProvider provider;

  const ReturnConfirmationDialog({
    Key? key,
    required this.transaction,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemsToReturn = provider.returnItems
        .where((item) => item.quantity > 0)
        .toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.assignment_return, color: Color(0xFFFF6B6B)),
          const SizedBox(width: 8),
          const Text('Konfirmasi Return'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaksi #${transaction.idTransaction}'),
          const SizedBox(height: 12),
          Text('Total produk: ${itemsToReturn.length} jenis'),
          Text('Total item: ${provider.totalReturnItems} pcs'),
          const SizedBox(height: 8),
          Text(
            'Total: Rp ${_formatPrice(provider.totalReturnPrice)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Apakah Anda yakin ingin membuat return ini?',
            style: TextStyle(color: Color(0xFF666666)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Ya, Buat Return'),
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
