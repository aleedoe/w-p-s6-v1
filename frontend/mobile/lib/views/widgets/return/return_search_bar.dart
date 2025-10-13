// lib/views/return/widgets/return_search_bar.dart
import 'package:flutter/material.dart';

class ReturnSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const ReturnSearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        // Properti onChanged di TextField tetap ada, namun logika pemfilteran
        // sekarang ditangani oleh listener di _ReturnPageState
        // untuk memisahkan UI dan Logic.
        // Jika perlu, tambahkan onChanged callback di sini dan teruskan ke parent.
        // Saat ini, kita biarkan logicnya tetap di parent melalui listener.
        decoration: const InputDecoration(
          hintText: 'Cari berdasarkan ID Return atau ID Transaksi...',
          hintStyle: TextStyle(color: Color(0xFF999999)),
          prefixIcon: Icon(Icons.search, color: Color(0xFFFF6B6B)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
