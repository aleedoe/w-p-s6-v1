// lib/views/return/dialogs/return_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';

class ReturnConfirmationDialog extends StatelessWidget {
  final CompletedTransaction transaction;
  final int itemsToReturnCount;
  final int totalReturnItems;
  final double totalReturnPrice;
  final String Function(double) formatPrice;

  const ReturnConfirmationDialog({
    Key? key,
    required this.transaction,
    required this.itemsToReturnCount,
    required this.totalReturnItems,
    required this.totalReturnPrice,
    required this.formatPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.assignment_return, color: Color(0xFFFF6B6B)),
          SizedBox(width: 8),
          Text('Konfirmasi Return'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaksi #${transaction.idTransaction}'),
          SizedBox(height: 12),
          Text('Total produk: $itemsToReturnCount jenis'),
          Text('Total item: $totalReturnItems pcs'),
          SizedBox(height: 8),
          Text(
            'Total: Rp ${formatPrice(totalReturnPrice)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B6B),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Apakah Anda yakin ingin membuat return ini?',
            style: TextStyle(color: Color(0xFF666666)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Ya, Buat Return'),
        ),
      ],
    );
  }
}
