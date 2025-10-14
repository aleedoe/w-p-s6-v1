// lib/views/return/widgets/return_item_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/views/widgets/return/create_return1/create_return_provider.dart';
import 'quantity_control_widget.dart';

/// Widget kartu item return individual
/// Menampilkan produk, quantity control, dan input alasan return
class ReturnItemCard extends StatelessWidget {
  final ReturnCartItem returnItem;
  final int index;
  final CreateReturnProvider provider;
  final VoidCallback onQuantityChanged;
  final VoidCallback onReasonChanged;

  const ReturnItemCard({
    Key? key,
    required this.returnItem,
    required this.index,
    required this.provider,
    required this.onQuantityChanged,
    required this.onReasonChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = returnItem.quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF6B6B) : const Color(0xFFEEEEEE),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildQuantityControl(),
          if (isSelected) ...[
            const SizedBox(height: 16),
            _buildReasonInput(),
            const SizedBox(height: 12),
            _buildSubtotal(),
          ],
        ],
      ),
    );
  }

  /// Header produk dengan nama dan harga
  Widget _buildProductHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.inventory_2,
            color: Color(0xFFFF6B6B),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                returnItem.product.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${_formatPrice(returnItem.product.price)} × ${returnItem.product.quantity}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Kontrol quantity (tombol +/-)
  Widget _buildQuantityControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Jumlah Return',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        QuantityControlWidget(
          quantity: returnItem.quantity,
          onDecrement: () {
            provider.updateReturnQuantity(index, returnItem.quantity - 1);
            onQuantityChanged();
          },
          onIncrement: () {
            provider.updateReturnQuantity(index, returnItem.quantity + 1);
            onQuantityChanged();
          },
        ),
      ],
    );
  }

  /// Input alasan return
  Widget _buildReasonInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alasan Return',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: (value) {
              provider.updateReturnReason(index, value);
              onReasonChanged();
            },
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Masukkan alasan return produk ini...',
              hintStyle: TextStyle(color: Color(0xFF999999)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }

  /// Subtotal harga return
  Widget _buildSubtotal() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Subtotal: Rp ${_formatPrice(returnItem.totalPrice)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ),
      ],
    );
  }

  /// Format harga dengan separator ribuan
  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
