// ============================================
// FILE 9: lib/widgets/product/product_info.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/models/stock_detail.dart';
import 'product_stock_badge.dart';
import 'product_price_section.dart';
import 'package:intl/intl.dart';

/// Widget untuk menampilkan informasi detail produk
class ProductInfo extends StatelessWidget {
  final StockDetail product;

  const ProductInfo({Key? key, required this.product}) : super(key: key);

  String? _formattedExpiredDate() {
    if (product.expiredDate == null) return null;
    try {
      final dateTime = DateTime.parse(product.expiredDate!);
      return DateFormat('EEE, dd MMM yyyy').format(dateTime);
    } catch (e) {
      // If parsing fails, return the original string or null
      return product.expiredDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiredDateStr = _formattedExpiredDate();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama produk dan badge stok
        _buildNameAndBadge(),
        const SizedBox(height: 4),
        // Deskripsi
        Text(
          product.description,
          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // Tanggal Kedaluwarsa (jika ada)
        if (expiredDateStr != null)
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                // color: Color(0xFFB71C1C),
              ),
              const SizedBox(width: 4),
              Text(
                "Exp: $expiredDateStr",
                style: const TextStyle(
                  fontSize: 12,
                  // color: Color(0xFFB71C1C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        if (expiredDateStr != null) const SizedBox(height: 2),
        const SizedBox(height: 8),

        // Harga dan statistik stok
        ProductPriceSection(
          price: product.price,
          totalIn: product.totalIn,
          totalOut: product.totalOut,
        ),
      ],
    );
  }

  Widget _buildNameAndBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        ProductStockBadge(quantity: product.currentStock),
      ],
    );
  }
}
