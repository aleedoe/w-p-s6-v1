// ============================================
// FILE 7: lib/widgets/product/product_card.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/models/stock_detail.dart';
import 'package:mobile/views/widgets/stock/product_info.dart';
import 'product_image.dart';

/// Widget card untuk menampilkan informasi produk
class ProductCard extends StatelessWidget {
  final StockDetail product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ProductImage(images: product.images),
            const SizedBox(width: 16),
            Expanded(
              child: ProductInfo(product: product),
            ),
          ],
        ),
      ),
    );
  }
}