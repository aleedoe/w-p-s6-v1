// ============================================================================
// lib/pages/order_page/widgets/transaction_table.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../utils/date_formatter.dart';
import '../utils/price_formatter.dart';
import '../utils/status_utils.dart';

class TransactionTable extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onRowTap;

  const TransactionTable({
    Key? key,
    required this.transactions,
    required this.onRowTap,
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
          Color(0xFF2196F3).withOpacity(0.1),
        ),
        columns: _buildColumns(),
        rows: _buildRows(),
      ),
    );
  }

  /// Membangun kolom tabel
  List<DataColumn> _buildColumns() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF2196F3),
      fontSize: 14,
    );

    return [
      DataColumn(label: Text('ID', style: headerStyle)),
      DataColumn(label: Text('Tanggal', style: headerStyle)),
      DataColumn(label: Text('Status', style: headerStyle)),
      DataColumn(label: Text('Produk', style: headerStyle)),
      DataColumn(label: Text('Total Harga', style: headerStyle)),
      DataColumn(label: Text('Aksi', style: headerStyle)),
    ];
  }

  /// Membangun baris tabel dari data transaksi
  List<DataRow> _buildRows() {
    return transactions.map((transaction) {
      return DataRow(
        cells: [
          _buildIdCell(transaction),
          _buildDateCell(transaction),
          _buildStatusCell(transaction),
          _buildProductCell(transaction),
          _buildPriceCell(transaction),
          _buildActionCell(transaction),
        ],
      );
    }).toList();
  }

  DataCell _buildIdCell(Transaction transaction) {
    return DataCell(
      Text(
        '#${transaction.idTransaction}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
      onTap: () => onRowTap(transaction),
    );
  }

  DataCell _buildDateCell(Transaction transaction) {
    return DataCell(
      Text(
        DateFormatter.format(transaction.createdAt),
        style: TextStyle(color: Color(0xFF666666)),
      ),
      onTap: () => onRowTap(transaction),
    );
  }

  DataCell _buildStatusCell(Transaction transaction) {
    final statusColor = StatusUtils.getStatusColor(transaction.status);
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          transaction.getStatusLabel(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ),
      onTap: () => onRowTap(transaction),
    );
  }

  DataCell _buildProductCell(Transaction transaction) {
    return DataCell(
      Text(
        '${transaction.totalProducts} item',
        style: TextStyle(color: Color(0xFF666666)),
      ),
      onTap: () => onRowTap(transaction),
    );
  }

  DataCell _buildPriceCell(Transaction transaction) {
    return DataCell(
      Text(
        'Rp ${PriceFormatter.format(transaction.totalPrice)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4CAF50),
        ),
      ),
      onTap: () => onRowTap(transaction),
    );
  }

  DataCell _buildActionCell(Transaction transaction) {
    return DataCell(
      IconButton(
        icon: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Color(0xFF2196F3),
        ),
        onPressed: () => onRowTap(transaction),
      ),
    );
  }
}