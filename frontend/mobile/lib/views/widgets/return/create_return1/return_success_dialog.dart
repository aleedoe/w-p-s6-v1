// lib/views/return/dialogs/return_success_dialog.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';


/// Dialog yang menampilkan pesan sukses setelah return berhasil dibuat
/// Menampilkan ID return dan status return
class ReturnSuccessDialog extends StatelessWidget {
  final CreateReturnResponse response;

  const ReturnSuccessDialog({Key? key, required this.response})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32),
          const SizedBox(width: 8),
          const Text('Berhasil!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Return berhasil dibuat'),
          const SizedBox(height: 8),
          Text('ID Return: #${response.returnTransaction.idReturnTransaction}'),
          Text('Status: ${response.returnTransaction.status}'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context, true); // Back to previous page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
