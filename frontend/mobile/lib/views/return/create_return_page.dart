// lib/views/return/create_return_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/views/widgets/return/create_return2/return_bottom_sheet.dart';
import 'package:mobile/views/widgets/return/create_return2/return_search_bar.dart';
import 'package:mobile/views/widgets/return/create_return2/return_app_bar.dart';
import 'package:mobile/views/widgets/return/create_return2/transaction_card.dart';
import 'package:mobile/views/widgets/return/create_return2/empty_state_widget.dart';
import '../../models/create_return.dart';
import '../../repositories/create_return_repository.dart';

class CreateReturnPage extends StatefulWidget {
  final int resellerId;

  const CreateReturnPage({Key? key, required this.resellerId})
    : super(key: key);

  @override
  State<CreateReturnPage> createState() => _CreateReturnPageState();
}

class _CreateReturnPageState extends State<CreateReturnPage> {
  final CreateReturnRepository _returnRepository = CreateReturnRepository();
  final TextEditingController _searchController = TextEditingController();

  CompletedTransactionResponse? _transactionData;
  List<CompletedTransaction> _filteredTransactions = [];
  List<ReturnCartItem> _returnItems = [];
  TransactionDetailForReturn? _selectedTransactionDetail;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompletedTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _returnRepository.dispose();
    super.dispose();
  }

  // ========== Data Loading Methods ==========

  /// Load completed transactions from API
  Future<void> _loadCompletedTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactionData = await _returnRepository
          .fetchCompletedTransactions(resellerId: widget.resellerId);

      setState(() {
        _transactionData = transactionData;
        _filteredTransactions = transactionData.transactions;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _isLoading = false;
      });
      _showErrorSnackBar('Terjadi kesalahan yang tidak terduga');
    }
  }

  /// Refresh transactions
  Future<void> _refreshTransactions() async {
    await _loadCompletedTransactions();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  /// Load transaction detail for return
  Future<void> _loadTransactionDetail(CompletedTransaction transaction) async {
    try {
      final detail = await _returnRepository.fetchTransactionDetailForReturn(
        resellerId: widget.resellerId,
        transactionId: transaction.idTransaction,
      );

      setState(() {
        _selectedTransactionDetail = detail;
        _returnItems = detail.details
            .map(
              (item) => ReturnCartItem(product: item, quantity: 0, reason: ''),
            )
            .toList();
      });

      _showReturnBottomSheet(transaction);
    } on ApiException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Gagal memuat detail transaksi');
    }
  }

  // ========== Search Methods ==========

  /// Search transactions based on query
  void _searchTransactions(String query) {
    if (_transactionData == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredTransactions = _transactionData!.transactions;
      } else {
        _filteredTransactions = _returnRepository.searchTransactions(
          _transactionData!.transactions,
          query,
        );
      }
    });
  }

  // ========== Return Cart Management ==========

  /// Update return quantity for specific item
  void _updateReturnQuantity(int index, int newQuantity) {
    if (newQuantity < 0) return;

    final maxQuantity = _returnItems[index].product.quantity;
    if (newQuantity > maxQuantity) {
      _showErrorSnackBar('Tidak bisa melebihi jumlah pembelian');
      return;
    }

    setState(() {
      _returnItems[index].quantity = newQuantity;
    });
  }

  /// Update return reason for specific item
  void _updateReturnReason(int index, String reason) {
    setState(() {
      _returnItems[index].reason = reason;
    });
  }

  // ========== Calculations ==========

  /// Calculate total return price
  double get _totalReturnPrice {
    return _returnItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  /// Calculate total return items count
  int get _totalReturnItems {
    return _returnItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Calculate total return products count
  int get _totalReturnProducts {
    return _returnItems.where((item) => item.quantity > 0).length;
  }

  // ========== UI Feedback Methods ==========

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ========== Submit Return ==========

  /// Submit return transaction
  Future<void> _submitReturn(CompletedTransaction transaction) async {
    final itemsToReturn = _returnItems
        .where((item) => item.quantity > 0)
        .toList();

    // Validation
    if (itemsToReturn.isEmpty) {
      _showErrorSnackBar('Pilih minimal 1 produk untuk di-return');
      return;
    }

    for (var item in itemsToReturn) {
      if (item.reason.isEmpty) {
        _showErrorSnackBar(
          'Alasan return untuk ${item.product.productName} tidak boleh kosong',
        );
        return;
      }
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(transaction, itemsToReturn);
    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreateReturnRequest(details: itemsToReturn);
      final response = await _returnRepository.createReturnTransaction(
        resellerId: widget.resellerId,
        transactionId: transaction.idTransaction,
        request: request,
      );

      _showSuccessSnackBar(response.message);
      await _showSuccessDialog(response);
    } on ApiException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Gagal membuat return');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Show confirmation dialog before submitting
  Future<bool?> _showConfirmationDialog(
    CompletedTransaction transaction,
    List<ReturnCartItem> itemsToReturn,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.assignment_return, color: Color(0xFFFF6B6B)),
            SizedBox(width: 8),
            Text('Konfirmasi Return'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaksi #${transaction.idTransaction}'),
            SizedBox(height: 12),
            Text('Total produk: ${itemsToReturn.length} jenis'),
            Text('Total item: $_totalReturnItems pcs'),
            SizedBox(height: 8),
            Text(
              'Total: Rp ${_formatPrice(_totalReturnPrice)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin membuat return ini?',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Ya, Buat Return'),
          ),
        ],
      ),
    );
  }

  /// Show success dialog after submission
  Future<void> _showSuccessDialog(CreateReturnResponse response) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32),
            SizedBox(width: 8),
            Text('Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Return berhasil dibuat'),
            SizedBox(height: 8),
            Text(
              'ID Return: #${response.returnTransaction.idReturnTransaction}',
            ),
            Text('Status: ${response.returnTransaction.status}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Back to previous page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // ========== Bottom Sheet ==========

  void _showReturnBottomSheet(CompletedTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReturnBottomSheet(
        transaction: transaction,
        returnItems: _returnItems,
        isSubmitting: _isSubmitting,
        totalReturnPrice: _totalReturnPrice,
        totalReturnItems: _totalReturnItems,
        totalReturnProducts: _totalReturnProducts,
        onQuantityUpdate: _updateReturnQuantity,
        onReasonUpdate: _updateReturnReason,
        onSubmit: () => _submitReturn(transaction),
      ),
    );
  }

  // ========== Helper Methods ==========

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // ========== Build Methods ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            ReturnAppBar(
              isLoading: _isLoading,
              onBack: () => Navigator.pop(context),
              onRefresh: _refreshTransactions,
            ),

            // Search Bar
            ReturnSearchBar(
              controller: _searchController,
              onSearch: _searchTransactions,
            ),

            // Transactions List
            Expanded(child: _buildTransactionsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_isLoading) {
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
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        message: _errorMessage!,
        actionLabel: 'Coba Lagi',
        onAction: _loadCompletedTransactions,
      );
    }

    if (_filteredTransactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        message: 'Transaksi selesai tidak ditemukan',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      color: Color(0xFFFF6B6B),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return TransactionCard(
            transaction: transaction,
            onTap: () => _loadTransactionDetail(transaction),
          );
        },
      ),
    );
  }
}
