// ============================================
// FILE 8: lib/widgets/product/product_image.dart
// ============================================
import 'package:flutter/material.dart';

/// Widget untuk menampilkan gambar produk dengan fallback icon
class ProductImage extends StatelessWidget {
  final List<String> images;
  static const double _imageSize = 80;
  static const double _borderRadius = 12;

  const ProductImage({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _imageSize,
      height: _imageSize,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: images.isNotEmpty
          ? _buildNetworkImage()
          : _buildPlaceholderIcon(),
    );
  }

  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Image.network(
        images.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon();
        },
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(
      Icons.inventory_2,
      color: Color(0xFF4CAF50),
      size: 32,
    );
  }
}