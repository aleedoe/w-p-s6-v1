// lib/views/return/utils/return_detail_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Mengubah format harga (contoh: 1000000.00 menjadi 1.000.000)
String formatPrice(double price) {
  // Menggunakan NumberFormat untuk konsistensi dan dukungan lokal
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '', // Menghilangkan simbol mata uang
    decimalDigits: 0, // Menghilangkan desimal
  );
  return formatter.format(price).trim();
}

// Mengubah format tanggal (contoh: 2023-01-01T10:00:00 menjadi 01 Januari 2023, 10:00)
String formatDateFull(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    // Format khusus: Hari Bulan Penuh Tahun, HH:mm
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
    return formatter.format(date);
  } catch (e) {
    // Kembalikan string asli jika gagal di-parse
    return dateString;
  }
}

// Menentukan warna berdasarkan status return
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Color(0xFF4CAF50); // Hijau
    case 'pending':
      return Color(0xFFFF9800); // Oranye
    case 'processing':
      return Color(0xFF2196F3); // Biru
    case 'rejected':
      return Color(0xFFF44336); // Merah
    default:
      return Color(0xFF999999); // Abu-abu
  }
}
