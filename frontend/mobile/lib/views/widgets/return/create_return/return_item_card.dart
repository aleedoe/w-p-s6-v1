// lib/views/return/widgets/return_item_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/utils/price_formatter.dart';

class ReturnItemCard extends StatelessWidget {
  final ReturnCartItem returnItem;
  final int index;
  final Function(int, int, VoidCallback) onUpdateQuantity;
  final Function(int, String, VoidCallback) onUpdateReason;
  final VoidCallback setModalState; // Untuk memicu rebuild di StatefulBuilder

  const ReturnItemCard({
    Key? key,
    required this.returnItem,
    required this.index,
    required this.onUpdateQuantity,
    required this.onUpdateReason,
    required this.setModalState,
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
          // Product Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Color(0xFFFF6B6B),
                  size: 24,
                ),
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
                      'Rp ${PriceFormatter.format(returnItem.product.price)} × ${returnItem.product.quantity}',
                      style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: 16),

          // Quantity Controls
          Row(
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
                  // Tombol Kurang
                  GestureDetector(
                    onTap: () => onUpdateQuantity(
                      index,
                      returnItem.quantity - 1,
                      setModalState,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFFF44336),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.remove, color: Colors.white, size: 16),
                    ),
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
                  // Tombol Tambah
                  GestureDetector(
                    onTap: () => onUpdateQuantity(
                      index,
                      returnItem.quantity + 1,
                      setModalState,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Reason Input
          if (isSelected) ...[
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
                onChanged: (value) =>
                    onUpdateReason(index, value, setModalState),
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
            SizedBox(height: 12),
            // Subtotal
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Subtotal: Rp ${PriceFormatter.format(returnItem.product.price * returnItem.quantity)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
