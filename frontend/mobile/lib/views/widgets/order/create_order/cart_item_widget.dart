import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/utils/price_formatter.dart';


class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Icon
          _buildProductIcon(),
          SizedBox(width: 12),

          // Product Info
          Expanded(child: _buildProductInfo()),

          // Quantity Controls
          _buildQuantityControls(),
        ],
      ),
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.inventory_2, color: Color(0xFF4CAF50), size: 24),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cartItem.product.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Rp ${PriceFormatter.format(cartItem.product.price)}',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls() {
    return Row(
      children: [
        // Decrement Button
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xFFF44336),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.remove, color: Colors.white, size: 16),
          ),
        ),

        // Quantity Display
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '${cartItem.quantity}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),

        // Increment Button
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }
}
