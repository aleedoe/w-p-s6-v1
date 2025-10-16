// ===================================================================
// lib/views/stock_out/widgets/stock_out_table.dart
// ===================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/stock_out.dart';

/// Tabel untuk menampilkan daftar stock out
class StockOutTable extends StatelessWidget {
  final List<StockOut> stockOuts;
  final Function(StockOut) onTapRow;

  const StockOutTable({
    Key? key,
    required this.stockOuts,
    required this.onTapRow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: DataTable(
        columnSpacing: 24,
        horizontalMargin: 24,
        headingRowHeight: 56,
        dataRowHeight: 64,
        headingRowColor: MaterialStateProperty.all(
          Color(0xFF4CAF50).withOpacity(0.1),
        ),
        columns: _buildColumns(),
        rows: _buildRows(),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildDataColumn('ID Stock Out'),
      _buildDataColumn('Tanggal'),
      _buildDataColumn('Total Produk'),
      _buildDataColumn('Total Qty'),
      _buildDataColumn('Aksi'),
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

  List<DataRow> _buildRows() {
    return stockOuts.map((stockOut) {
      return DataRow(
        cells: [
          _buildIdCell(stockOut),
          _buildDateCell(stockOut),
          _buildProductsCell(stockOut),
          _buildQuantityCell(stockOut),
          _buildActionCell(stockOut),
        ],
      );
    }).toList();
  }

  DataCell _buildIdCell(StockOut stockOut) {
    return DataCell(
      Text(
        '#${stockOut.idStockOut}',
        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333)),
      ),
      onTap: () => onTapRow(stockOut),
    );
  }

  DataCell _buildDateCell(StockOut stockOut) {
    return DataCell(
      Text(
        _formatDate(stockOut.createdAt),
        style: TextStyle(color: Color(0xFF666666)),
      ),
      onTap: () => onTapRow(stockOut),
    );
  }

  DataCell _buildProductsCell(StockOut stockOut) {
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${stockOut.totalProducts}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
      ),
      onTap: () => onTapRow(stockOut),
    );
  }

  DataCell _buildQuantityCell(StockOut stockOut) {
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF8BC34A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${stockOut.totalQuantity}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8BC34A),
          ),
        ),
      ),
      onTap: () => onTapRow(stockOut),
    );
  }

  DataCell _buildActionCell(StockOut stockOut) {
    return DataCell(
      IconButton(
        icon: Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF4CAF50)),
        onPressed: () => onTapRow(stockOut),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yy HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }
}
