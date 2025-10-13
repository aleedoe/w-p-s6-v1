// lib/pages/transaction_detail/widgets/transaction_detail_body.dart
import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../controllers/transaction_detail_controller.dart';
import 'info_card.dart';
import 'summary_stats.dart';
import 'products_table.dart';
import 'total_section.dart';

/// Widget body utama untuk menampilkan isi detail transaksi
class TransactionDetailBody extends StatelessWidget {
  final TransactionDetailController controller;
  final Transaction transaction;
  final int transactionId;

  const TransactionDetailBody({
    Key? key,
    required this.controller,
    required this.transaction,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoadingNotifier,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: controller.errorMessageNotifier,
          builder: (context, errorMessage, _) {
            if (isLoading) {
              return _buildLoadingState();
            }

            if (errorMessage != null) {
              return _buildErrorState(context, errorMessage);
            }

            return _buildContentState(context);
          },
        );
      },
    );
  }

  /// State ketika data sedang dimuat
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// State ketika terjadi error
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
          SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.loadDetailData,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
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
  }

  /// State ketika data berhasil dimuat
  Widget _buildContentState(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.detailDataNotifier,
      builder: (context, detailData, _) {
        return RefreshIndicator(
          onRefresh: controller.refreshDetailData,
          color: Color(0xFF2196F3),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu informasi transaksi
                TransactionInfoCard(transaction: transaction),
                SizedBox(height: 24),

                // Statistik ringkasan
                if (detailData != null)
                  TransactionSummaryStats(detailData: detailData)
                else
                  SizedBox.shrink(),
                SizedBox(height: 24),

                // Tabel produk
                Text(
                  'Detail Produk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 16),
                if (detailData != null)
                  TransactionProductsTable(detailData: detailData)
                else
                  SizedBox.shrink(),
                SizedBox(height: 24),

                // Bagian total
                if (detailData != null)
                  TransactionTotalSection(detailData: detailData)
                else
                  SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
