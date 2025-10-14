// lib/views/return/widgets/transaction_list_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/views/widgets/return/create_return1/create_return_provider.dart';
import 'transaction_card_widget.dart';

/// Widget untuk menampilkan daftar transaksi
/// Mengelola berbagai state: loading, error, empty, dan list normal
class TransactionListWidget extends StatelessWidget {
  final CreateReturnProvider provider;
  final Function(CompletedTransaction) onTransactionSelected;

  const TransactionListWidget({
    Key? key,
    required this.provider,
    required this.onTransactionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (provider.isLoading) {
      return _buildLoadingState();
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(context);
    }

    if (provider.filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTransactionsList(context);
  }

  /// State ketika data masih dimuat
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memuat transaksi...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// State ketika terjadi error
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: provider.loadCompletedTransactions,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// State ketika tidak ada transaksi
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Color(0xFF999999),
          ),
          const SizedBox(height: 16),
          const Text(
            'Transaksi selesai tidak ditemukan',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// State ketika ada daftar transaksi
  Widget _buildTransactionsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: provider.refreshTransactions,
      color: const Color(0xFFFF6B6B),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: provider.filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = provider.filteredTransactions[index];
          return TransactionCardWidget(
            transaction: transaction,
            onTap: () => onTransactionSelected(transaction),
          );
        },
      ),
    );
  }
}
