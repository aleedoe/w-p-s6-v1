// lib/views/return/widgets/transaction_search_bar.dart
import 'package:flutter/material.dart';

class TransactionSearchBar extends StatelessWidget {
  final TextEditingController controller;
  // Karena logic _searchTransactions sudah dipindahkan ke listener di initState,
  // kita tidak perlu onChanged di sini.

  const TransactionSearchBar({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          // onChanged tidak perlu lagi karena sudah di handle di listener pada state utama
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan ID transaksi...',
            hintStyle: TextStyle(color: Color(0xFF999999)),
            prefixIcon: Icon(Icons.search, color: Color(0xFFFF6B6B)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}
