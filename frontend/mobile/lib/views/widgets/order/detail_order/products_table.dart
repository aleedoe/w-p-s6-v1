// lib/pages/transaction_detail/widgets/products_table.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/transaction_detail.dart';
import 'package:mobile/views/widgets/order/detail_order/format_utils.dart';
import 'package:mobile/views/widgets/order/detail_order/style_utils.dart';


/// Widget untuk menampilkan tabel produk dalam transaksi
class TransactionProductsTable extends StatelessWidget {
  final TransactionDetailResponse detailData;

  const TransactionProductsTable({Key? key, required this.detailData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (detailData.details.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: StyleUtils.defaultBoxShadow,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 20,
          headingRowHeight: 56,
          dataRowHeight: 72,
          headingRowColor: MaterialStateProperty.all(
            Color(0xFF2196F3).withOpacity(0.1),
          ),
          columns: _buildColumns(),
          rows: _buildRows(),
        ),
      ),
    );
  }

  /// Membangun kolom untuk tabel
  List<DataColumn> _buildColumns() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF2196F3),
      fontSize: 14,
    );

    return [
      DataColumn(label: Text('No', style: headerStyle)),
      DataColumn(label: Text('Nama Produk', style: headerStyle)),
      DataColumn(label: Text('Harga Satuan', style: headerStyle)),
      DataColumn(label: Text('Qty', style: headerStyle)),
      DataColumn(label: Text('Subtotal', style: headerStyle)),
    ];
  }

  /// Membangun baris data untuk tabel
  List<DataRow> _buildRows() {
    return detailData.details.asMap().entries.map((entry) {
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
              constraints: BoxConstraints(maxWidth: 200),
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
              'Rp ${FormatUtils.formatPrice(item.price)}',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.quantity}',
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              'Rp ${FormatUtils.formatPrice(item.totalPrice)}',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  /// Widget untuk state kosong (tidak ada produk)
  Widget _buildEmptyState() {
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
}
