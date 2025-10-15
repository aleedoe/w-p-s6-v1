// lib/views/return/widgets/return_item_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';

/// Card widget for individual return item with quantity controls and reason input
class ReturnItemCard extends StatelessWidget {
  final ReturnCartItem returnItem;
  final int index;
  final Function(int quantity) onQuantityUpdate;
  final Function(String reason) onReasonUpdate;

  const ReturnItemCard({
    Key? key,
    required this.returnItem,
    required this.index,
    required this.onQuantityUpdate,
    required this.onReasonUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = returnItem.quantity > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Color(0xFFFF6B6B) : Color(0xFFEEEEEE),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(),
          SizedBox(height: 16),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),
          _buildQuantityControls(),
          if (isSelected) ...[
            SizedBox(height: 16),
            _buildReasonInput(),
            SizedBox(height: 12),
            _buildSubtotal(),
          ],
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFFF6B6B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.inventory_2, color: Color(0xFFFF6B6B), size: 24),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                returnItem.product.productName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rp ${_formatPrice(returnItem.product.price)} × ${returnItem.product.quantity}',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Jumlah Return',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        Row(
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              color: Color(0xFFF44336),
              onTap: () => onQuantityUpdate(returnItem.quantity - 1),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '${returnItem.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            _buildQuantityButton(
              icon: Icons.add,
              color: Color(0xFFFF6B6B),
              onTap: () => onQuantityUpdate(returnItem.quantity + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildReasonInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alasan Return',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: onReasonUpdate,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan return produk ini...',
              hintStyle: TextStyle(color: Color(0xFF999999)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
            style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtotal() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Subtotal: Rp ${_formatPrice(returnItem.totalPrice)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
