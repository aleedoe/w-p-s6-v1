// ============================================
// FILE 9: lib/widgets/product/product_info.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/models/stock_detail.dart';
import 'product_stock_badge.dart';
import 'product_price_section.dart';

/// Widget untuk menampilkan informasi detail produk
class ProductInfo extends StatelessWidget {
  final StockDetail product;

  const ProductInfo({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama produk dan badge stok
        _buildNameAndBadge(),
        const SizedBox(height: 4),
        // Deskripsi
        Text(
          product.description,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
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
