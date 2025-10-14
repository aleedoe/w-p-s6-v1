// lib/views/return/dialogs/return_success_dialog.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';

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
          Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32),
          SizedBox(width: 8),
          Text('Berhasil!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Return berhasil dibuat'),
          SizedBox(height: 8),
          Text('ID Return: #${response.returnTransaction.idReturnTransaction}'),
          Text('Status: ${response.returnTransaction.status}'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            // Pop kembali ke halaman sebelumnya akan dilakukan di CreateReturnPage
            // setelah dialog ini tertutup.
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('OK'),
        ),
      ],
    );
  }
}
