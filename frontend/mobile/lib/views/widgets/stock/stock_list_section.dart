// ============================================
// FILE 6: lib/widgets/stock/stock_list_section.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/models/stock_detail.dart';
import 'product_card.dart';

/// Widget untuk menampilkan daftar produk dalam list view
class StockListSection extends StatelessWidget {
  final List<StockDetail> products;
  final Future<void> Function() onRefresh;

  const StockListSection({
    Key? key,
    required this.products,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan jumlah produk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Produk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                '${products.length} produk',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product List
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              color: const Color(0xFF4CAF50),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(product: product);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
