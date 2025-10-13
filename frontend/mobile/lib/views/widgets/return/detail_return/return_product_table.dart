// lib/views/return/widgets/return_product_table.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/return_transaction_detail.dart';
import 'package:mobile/views/widgets/return/detail_return/return_detail_utils.dart';

class ReturnProductTable extends StatelessWidget {
  final List<ReturnDetailItem> details;

  const ReturnProductTable({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      // Tampilan jika tidak ada produk
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Tidak ada produk',
            style: TextStyle(color: Color(0xFF999999)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 20,
          headingRowHeight: 56,
          dataRowHeight: 80,
          headingRowColor: MaterialStateProperty.all(
            Color(0xFFFF6B6B).withOpacity(0.1),
          ),
          columns: [
            DataColumn(
              label: Text(
                'No',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Nama Produk',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Harga Satuan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Qty',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Alasan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Subtotal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          rows: details.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: BoxConstraints(maxWidth: 180),
                    child: Text(
                      item.productName,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    'Rp ${formatPrice(item.price)}',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6B6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: BoxConstraints(maxWidth: 200),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Color(0xFFFFEB3B).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.reason,
                      style: TextStyle(
                        color: Color(0xFF856404),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    'Rp ${formatPrice(item.totalPrice)}',
                    style: TextStyle(
                      color: Color(0xFFF44336),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
