// lib/views/return/widgets/return_table.dart
import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/return/return_helpers.dart';
import '../../../models/return_transaction.dart';
import 'status_chip.dart';
import 'return_table_data_cell.dart';

class ReturnTable extends StatelessWidget {
  final List<ReturnTransaction> filteredReturns;
  final ValueChanged<ReturnTransaction> onRowTap;

  const ReturnTable({
    Key? key,
    required this.filteredReturns,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 24,
          headingRowHeight: 56,
          dataRowHeight: 64,
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFFFF6B6B).withOpacity(0.1),
          ),
          columns: _buildColumns(),
          rows: _buildRows(),
        ),
      ),
    );
  }

  /// Membangun daftar kolom tabel.
  List<DataColumn> _buildColumns() {
    // Definisi gaya teks untuk header kolom
    const TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFFFF6B6B),
      fontSize: 14,
    );

    // Menggunakan list literal untuk kolom
    return const [
      DataColumn(label: Text('ID Return', style: headerStyle)),
      DataColumn(label: Text('ID Transaksi', style: headerStyle)),
      DataColumn(label: Text('Tgl Return', style: headerStyle)),
      DataColumn(label: Text('Status', style: headerStyle)),
      DataColumn(label: Text('Total Qty', style: headerStyle)),
      DataColumn(label: Text('Aksi', style: headerStyle)),
    ];
  }

  /// Membangun daftar baris tabel dari data return yang difilter.
  List<DataRow> _buildRows() {
    return filteredReturns.map((returnTrans) {
      return DataRow(
        cells: [
          // ID Return
          DataCell(
            Text(
              '#${returnTrans.idReturnTransaction}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            onTap: () => onRowTap(returnTrans),
          ),
          // ID Transaksi
          DataCell(
            Text(
              '#${returnTrans.idTransaction}',
              style: const TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => onRowTap(returnTrans),
          ),
          // Tgl Return
          DataCell(
            Text(
              ReturnHelpers.formatDate(returnTrans.returnDate),
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            onTap: () => onRowTap(returnTrans),
          ),
          // Status
          DataCell(
            StatusChip(
              status: returnTrans.status,
              label: returnTrans.getStatusLabel(),
            ),
            onTap: () => onRowTap(returnTrans),
          ),
          // Total Qty
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${returnTrans.totalQuantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
            onTap: () => onRowTap(returnTrans),
          ),
          // Aksi (Icon Detail)
          DataCell(
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Color(0xFFFF6B6B),
              ),
              onPressed: () => onRowTap(returnTrans),
            ),
          ),
        ],
      );
    }).toList();
  }
}
