// lib/views/return/providers/create_return_provider.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_return.dart';
import 'package:mobile/repositories/create_return_repository.dart';
import 'package:mobile/services/api_client.dart';
import 'dart:async';

/// Penyedia (provider) untuk mengelola state dan logika bisnis halaman Create Return
/// Memisahkan logika bisnis dari UI untuk meningkatkan testability dan maintainability
class CreateReturnProvider extends ChangeNotifier {
  final int resellerId;
  final CreateReturnRepository repository;

  // Controllers
  final TextEditingController searchController = TextEditingController();

  // State variables
  CompletedTransactionResponse? transactionData;
  List<CompletedTransaction> filteredTransactions = [];
  List<ReturnCartItem> returnItems = [];
  TransactionDetailForReturn? selectedTransactionDetail;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  // Stream subscription untuk cleanup
  late StreamController<String> _messageStream;

  CreateReturnProvider({required this.resellerId, required this.repository}) {
    _messageStream = StreamController<String>.broadcast();
  }

  /// Load semua transaksi yang sudah selesai dari API
  Future<void> loadCompletedTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await repository.fetchCompletedTransactions(
        resellerId: resellerId,
      );

      transactionData = data;
      filteredTransactions = data.transactions;
      _setLoading(false);
      notifyListeners();
    } on ApiException catch (e) {
      _handleApiError(e.message);
    } catch (e) {
      _handleApiError('Terjadi kesalahan yang tidak terduga');
    }
  }

  /// Refresh data transaksi
  Future<void> refreshTransactions() async {
    await loadCompletedTransactions();
    if (errorMessage == null) {
      _emitMessage('Data berhasil diperbarui');
    }
  }

  /// Load detail transaksi untuk membuat return
  Future<void> loadTransactionDetail(
    CompletedTransaction transaction,
    BuildContext context,
  ) async {
    try {
      final detail = await repository.fetchTransactionDetailForReturn(
        resellerId: resellerId,
        transactionId: transaction.idTransaction,
      );

      selectedTransactionDetail = detail;
      returnItems = detail.details
          .map((item) => ReturnCartItem(product: item, quantity: 0, reason: ''))
          .toList();

      notifyListeners();
    } on ApiException catch (e) {
      _emitMessage(e.message);
    } catch (e) {
      _emitMessage('Gagal memuat detail transaksi');
    }
  }

  /// Cari transaksi berdasarkan query
  void searchTransactions(String query) {
    if (transactionData == null) return;

    if (query.isEmpty) {
      filteredTransactions = transactionData!.transactions;
    } else {
      filteredTransactions = repository.searchTransactions(
        transactionData!.transactions,
        query,
      );
    }
    notifyListeners();
  }

  /// Tambah jumlah produk ke return cart
  void addToReturnCart(ReturnDetailItem product) {
    final index = returnItems.indexWhere(
      (item) => item.product.idProduct == product.idProduct,
    );

    if (index >= 0) {
      if (returnItems[index].quantity < product.quantity) {
        returnItems[index].quantity++;
        _emitMessage('Jumlah ${product.productName} ditambahkan');
      } else {
        _emitMessage('Tidak bisa melebihi jumlah pembelian');
      }
      notifyListeners();
    }
  }

  /// Hapus produk dari return cart
  void removeFromReturnCart(int index) {
    final productName = returnItems[index].product.productName;
    returnItems[index].quantity = 0;
    returnItems[index].reason = '';
    _emitMessage('$productName dihapus dari return');
    notifyListeners();
  }

  /// Update jumlah return untuk produk tertentu
  void updateReturnQuantity(int index, int newQuantity) {
    if (newQuantity < 0) return;

    final maxQuantity = returnItems[index].product.quantity;
    if (newQuantity > maxQuantity) {
      _emitMessage('Tidak bisa melebihi jumlah pembelian');
      return;
    }

    returnItems[index].quantity = newQuantity;
    notifyListeners();
  }

  /// Update alasan return untuk produk tertentu
  void updateReturnReason(int index, String reason) {
    returnItems[index].reason = reason;
    notifyListeners();
  }

  /// Hitung total harga return
  double get totalReturnPrice {
    return returnItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  /// Hitung total jumlah item yang di-return
  int get totalReturnItems {
    return returnItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Hitung total jumlah produk yang di-return
  int get totalReturnProducts {
    return returnItems.where((item) => item.quantity > 0).length;
  }

  /// Submit return transaction
  Future<CreateReturnResponse?> submitReturn(
    CompletedTransaction transaction,
  ) async {
    // Validasi item yang akan di-return
    final itemsToReturn = returnItems
        .where((item) => item.quantity > 0)
        .toList();

    if (itemsToReturn.isEmpty) {
      _emitMessage('Pilih minimal 1 produk untuk di-return');
      return null;
    }

    // Cek apakah semua item memiliki alasan
    for (var item in itemsToReturn) {
      if (item.reason.isEmpty) {
        _emitMessage(
          'Alasan return untuk ${item.product.productName} tidak boleh kosong',
        );
        return null;
      }
    }

    _setSubmitting(true);

    try {
      final request = CreateReturnRequest(details: itemsToReturn);
      final response = await repository.createReturnTransaction(
        resellerId: resellerId,
        transactionId: transaction.idTransaction,
        request: request,
      );

      _emitMessage(response.message);
      _setSubmitting(false);
      notifyListeners();
      return response;
    } on ApiException catch (e) {
      _handleApiError(e.message);
      _setSubmitting(false);
      return null;
    } catch (e) {
      _handleApiError('Gagal membuat return');
      _setSubmitting(false);
      return null;
    }
  }

  /// Validasi return items
  bool validateReturnItems() {
    final itemsToReturn = returnItems
        .where((item) => item.quantity > 0)
        .toList();

    if (itemsToReturn.isEmpty) {
      _emitMessage('Pilih minimal 1 produk untuk di-return');
      return false;
    }

    for (var item in itemsToReturn) {
      if (item.reason.isEmpty) {
        _emitMessage(
          'Alasan return untuk ${item.product.productName} tidak boleh kosong',
        );
        return false;
      }
    }

    return true;
  }

  /// Stream untuk mengirim pesan (success, error, info)
  Stream<String> get messageStream => _messageStream.stream;

  /// Helper methods
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners();
  }

  void _clearError() {
    errorMessage = null;
  }

  void _handleApiError(String message) {
    errorMessage = message;
    _emitMessage(message);
    notifyListeners();
  }

  void _emitMessage(String message) {
    if (!_messageStream.isClosed) {
      _messageStream.add(message);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    repository.dispose();
    _messageStream.close();
    super.dispose();
  }
}
