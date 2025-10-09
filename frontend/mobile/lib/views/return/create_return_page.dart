// lib/views/return/create_return_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:intl/intl.dart';
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

  // Load completed transactions from API
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

  // Refresh transactions
  Future<void> _refreshTransactions() async {
    await _loadCompletedTransactions();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  // Load transaction detail for return
  Future<void> _loadTransactionDetail(CompletedTransaction transaction) async {
    try {
      final detail = await _returnRepository.fetchTransactionDetailForReturn(
        resellerId: widget.resellerId,
        transactionId: transaction.idTransaction,
      );

      setState(() {
        _selectedTransactionDetail = detail;
        // Initialize return items from transaction details
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

  // Search transactions
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

  // Add to return cart
  void _addToReturnCart(ReturnDetailItem product) {
    final index = _returnItems.indexWhere(
      (item) => item.product.idProduct == product.idProduct,
    );

    if (index >= 0) {
      if (_returnItems[index].quantity < product.quantity) {
        setState(() {
          _returnItems[index].quantity++;
        });
        _showSuccessSnackBar('Jumlah ${product.productName} ditambahkan');
      } else {
        _showErrorSnackBar('Tidak bisa melebihi jumlah pembelian');
      }
    }
  }

  // Remove from return cart
  void _removeFromReturnCart(int index) {
    setState(() {
      final productName = _returnItems[index].product.productName;
      _returnItems[index].quantity = 0;
      _returnItems[index].reason = '';
      _showSuccessSnackBar('$productName dihapus dari return');
    });
  }

  // Update return quantity
  void _updateReturnQuantity(int index, int newQuantity) {
    if (newQuantity < 0) {
      return;
    }

    final maxQuantity = _returnItems[index].product.quantity;
    if (newQuantity > maxQuantity) {
      _showErrorSnackBar('Tidak bisa melebihi jumlah pembelian');
      return;
    }

    setState(() {
      _returnItems[index].quantity = newQuantity;
    });
  }

  // Update return reason
  void _updateReturnReason(int index, String reason) {
    setState(() {
      _returnItems[index].reason = reason;
    });
  }

  // Calculate total
  double get _totalReturnPrice {
    return _returnItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  int get _totalReturnItems {
    return _returnItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get _totalReturnProducts {
    return _returnItems.where((item) => item.quantity > 0).length;
  }

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

  // Submit return
  Future<void> _submitReturn(CompletedTransaction transaction) async {
    // Validate return items
    final itemsToReturn = _returnItems
        .where((item) => item.quantity > 0)
        .toList();

    if (itemsToReturn.isEmpty) {
      _showErrorSnackBar('Pilih minimal 1 produk untuk di-return');
      return;
    }

    // Check if all items have reason
    for (var item in itemsToReturn) {
      if (item.reason.isEmpty) {
        _showErrorSnackBar(
          'Alasan return untuk ${item.product.productName} tidak boleh kosong',
        );
        return;
      }
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
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

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final itemsFiltered = _returnItems
          .where((item) => item.quantity > 0)
          .toList();
      final request = CreateReturnRequest(details: itemsFiltered);
      final response = await _returnRepository.createReturnTransaction(
        resellerId: widget.resellerId,
        transactionId: transaction.idTransaction,
        request: request,
      );

      _showSuccessSnackBar(response.message);

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Return Baru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Pilih transaksi untuk di-return',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _refreshTransactions,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.all(24),
              child: Container(
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
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchTransactions,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan ID transaksi...',
                    hintStyle: TextStyle(color: Color(0xFF999999)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFFFF6B6B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            // Transactions List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF6B6B),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat transaksi...',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Color(0xFFF44336),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadCompletedTransactions,
                            icon: Icon(Icons.refresh),
                            label: Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredTransactions.isEmpty
                  ? Center(
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
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshTransactions,
                      color: Color(0xFFFF6B6B),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          return _buildTransactionCard(transaction);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(CompletedTransaction transaction) {
    return GestureDetector(
      onTap: () => _loadTransactionDetail(transaction),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${transaction.idTransaction}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah Produk',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${transaction.totalProducts} item',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Harga',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rp ${_formatPrice(transaction.totalPrice)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: Color(0xFFEEEEEE)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _loadTransactionDetail(transaction),
                  icon: Icon(Icons.arrow_forward_ios, size: 14),
                  label: Text('Buat Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnBottomSheet(CompletedTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_return,
                          color: Color(0xFFFF6B6B),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Return Produk',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Transaksi #${transaction.idTransaction}',
                      style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),

              // Return Items List
              Expanded(
                child: _returnItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Color(0xFF999999),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada produk',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _returnItems.length,
                        itemBuilder: (context, index) {
                          final returnItem = _returnItems[index];
                          final isSelected = returnItem.quantity > 0;

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFFFF6B6B)
                                    : Color(0xFFEEEEEE),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Header
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFFFF6B6B,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2,
                                        color: Color(0xFFFF6B6B),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            returnItem.product.productName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Rp ${_formatPrice(returnItem.product.price)} × ${returnItem.product.quantity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Divider(color: Color(0xFFEEEEEE)),
                                SizedBox(height: 16),

                                // Quantity Controls
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Jumlah Return',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _updateReturnQuantity(
                                                index,
                                                returnItem.quantity - 1,
                                              );
                                            });
                                            setModalState(() {});
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF44336),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${returnItem.quantity}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _updateReturnQuantity(
                                                index,
                                                returnItem.quantity + 1,
                                              );
                                            });
                                            setModalState(() {});
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFF6B6B),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Reason Input
                                if (isSelected) ...[
                                  Text(
                                    'Alasan Return',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFEEEEEE),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _updateReturnReason(index, value);
                                        });
                                        setModalState(() {});
                                      },
                                      minLines: 2,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Masukkan alasan return produk ini...',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF999999),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Subtotal: Rp ${_formatPrice(returnItem.totalPrice)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF6B6B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Summary and Submit
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Summary Rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Produk Return',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          '$_totalReturnProducts jenis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Item Return',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          '$_totalReturnItems pcs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(color: Color(0xFFEEEEEE)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Return',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          'Rp ${_formatPrice(_totalReturnPrice)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                _submitReturn(transaction);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline),
                                  SizedBox(width: 8),
                                  Text(
                                    'Buat Return',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
