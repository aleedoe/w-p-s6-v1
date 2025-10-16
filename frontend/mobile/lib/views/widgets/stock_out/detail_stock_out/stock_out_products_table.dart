// lib/views/stock_out/widgets/stock_out_products_table.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/stock_out_detail.dart';
import '../detail_stock_out/stock_out_formatters.dart';
/// Tabel untuk menampilkan daftar produk yang keluar dari stock
/// dengan informasi harga, kuantitas, dan total harga
class StockOutProductsTable extends StatelessWidget {
  final StockOutDetailResponse? detailData;

  const StockOutProductsTable({Key? key, required this.detailData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tampilkan pesan jika tidak ada data
    if (detailData == null || detailData!.details.isEmpty) {
      return _buildEmptyState();
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
            Color(0xFF4CAF50).withOpacity(0.1),
          ),
          columns: _buildTableColumns(),
          rows: _buildTableRows(),
        ),
      ),
    );
  }

  /// Membangun kolom-kolom header tabel
  List<DataColumn> _buildTableColumns() {
    return [
      _buildDataColumn('No'),
      _buildDataColumn('Nama Produk'),
      _buildDataColumn('Harga Satuan'),
      _buildDataColumn('Qty'),
      _buildDataColumn('Total Harga'),
    ];
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4CAF50),
          fontSize: 14,
        ),
      ),
    );
  }

  /// Membangun baris-baris data tabel
  List<DataRow> _buildTableRows() {
    return detailData!.details.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return DataRow(
        cells: [
          DataCell(_buildNumberCell(index + 1)),
          DataCell(_buildProductNameCell(item.productName)),
          DataCell(_buildPriceCell(item.price)),
          DataCell(_buildQuantityCell(item.quantity)),
          DataCell(_buildTotalPriceCell(item.totalHarga)),
        ],
      );
    }).toList();
  }

  Widget _buildNumberCell(int number) {
    return Text(
      '$number',
      style: TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w600),
    );
  }

  Widget _buildProductNameCell(String productName) {
    return Container(
      constraints: BoxConstraints(maxWidth: 180),
      child: Text(
        productName,
        style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPriceCell(double price) {
    return Text(
      'Rp ${StockOutFormatters.formatPrice(price)}',
      style: TextStyle(color: Color(0xFF666666)),
    );
  }

  Widget _buildQuantityCell(int quantity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$quantity',
        style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTotalPriceCell(double totalPrice) {
    return Text(
      'Rp ${StockOutFormatters.formatPrice(totalPrice)}',
      style: TextStyle(
        color: Color(0xFF8BC34A),
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

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
