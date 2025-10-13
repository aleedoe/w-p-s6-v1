// lib/views/return/widgets/transaction_list_view.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'transaction_card.dart';

class TransactionListView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<CompletedTransaction> filteredTransactions;
  final VoidCallback onRefresh;
  final VoidCallback onLoadTransactions;
  final Function(CompletedTransaction) onTransactionTapped;

  const TransactionListView({
    Key? key,
    required this.isLoading,
    required this.errorMessage,
    required this.filteredTransactions,
    required this.onRefresh,
    required this.onLoadTransactions,
    required this.onTransactionTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Tampilan Loading
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat transaksi...',
              style: TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
          ],
        ),
      );
    } else if (errorMessage != null) {
      // Tampilan Error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onLoadTransactions,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (filteredTransactions.isEmpty) {
      // Tampilan Empty State
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              'Transaksi selesai tidak ditemukan',
              style: TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
          ],
        ),
      );
    } else {
      // Tampilan Daftar Transaksi
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: Color(0xFFFF6B6B),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24),
          itemCount: filteredTransactions.length,
          itemBuilder: (context, index) {
            final transaction = filteredTransactions[index];
            return TransactionCard(
              transaction: transaction,
              onTransactionTapped: onTransactionTapped,
            );
          },
        ),
      );
    }
  }
}
