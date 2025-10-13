// lib/pages/transaction_detail/controllers/transaction_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import '../../../models/transaction_detail.dart';
import '../../../repositories/transaction_repository.dart';

/// Controller untuk mengelola logika bisnis halaman detail transaksi
class TransactionDetailController {
  final int resellerId;
  final int transactionId;
  final TransactionRepository _transactionRepository;

  final isLoadingNotifier = ValueNotifier<bool>(false);
  final errorMessageNotifier = ValueNotifier<String?>(null);
  final detailDataNotifier = ValueNotifier<TransactionDetailResponse?>(null);

  // Callback untuk menampilkan snackbar
  Function(String)? onShowErrorSnackBar;
  Function(String)? onShowSuccessSnackBar;

  TransactionDetailController({
    required this.resellerId,
    required this.transactionId,
    TransactionRepository? transactionRepository,
  }) : _transactionRepository =
           transactionRepository ?? TransactionRepository();

  /// Memuat data detail transaksi dari API
  Future<void> loadDetailData() async {
    isLoadingNotifier.value = true;
    errorMessageNotifier.value = null;

    try {
      final detailData = await _transactionRepository.fetchTransactionDetail(
        resellerId: resellerId,
        transactionId: transactionId,
      );

      detailDataNotifier.value = detailData;
    } on ApiException catch (e) {
      errorMessageNotifier.value = e.message;
      onShowErrorSnackBar?.call(e.message);
    } catch (e) {
      const errorMsg = 'Terjadi kesalahan yang tidak terduga';
      errorMessageNotifier.value = errorMsg;
      onShowErrorSnackBar?.call(errorMsg);
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Refresh data detail transaksi
  Future<void> refreshDetailData() async {
    await loadDetailData();
    if (errorMessageNotifier.value == null) {
      onShowSuccessSnackBar?.call('Data berhasil diperbarui');
    }
  }

  /// Membersihkan resources
  void dispose() {
    _transactionRepository.dispose();
    isLoadingNotifier.dispose();
    errorMessageNotifier.dispose();
    detailDataNotifier.dispose();
  }
}
