// lib/views/return/widgets/return_item_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/utils/price_formatter.dart';

/// Card untuk setiap item yang bisa direturn
class ReturnItemCard extends StatelessWidget {
  final ReturnCartItem returnItem;
  final int index;

  /// Callback untuk mengubah jumlah item
  /// 💡 Ubah parameter ketiga jadi [StateSetter]
  final Function(int, int, StateSetter) onUpdateQuantity;

  /// Callback untuk mengubah alasan return
  /// 💡 Sama, ubah parameter terakhir jadi [StateSetter]
  final Function(int, String, StateSetter) onUpdateReason;

  /// Fungsi [setModalState] dari StatefulBuilder untuk trigger rebuild UI
  final StateSetter setModalState;

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
          // Product Header
          Row(
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
                      'Rp ${PriceFormatter.format(returnItem.product.price)} × ${returnItem.product.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // Quantity Controls
          Row(
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                  // Teks jumlah item
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '${returnItem.quantity}',
                      style: const TextStyle(
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Input Alasan Return
          if (isSelected) ...[
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
                onChanged: (value) =>
                    onUpdateReason(index, value, setModalState),
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
            const SizedBox(height: 12),

            // Subtotal
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Subtotal: Rp ${PriceFormatter.format(returnItem.product.price * returnItem.quantity)}',
                    style: const TextStyle(
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
