// lib/pages/create_stockout_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/views/widgets/stock_out/cresate_stock_out/cart_bottom_sheet.dart';
import 'package:mobile/views/widgets/stock_out/cresate_stock_out/category_filter.dart';
import 'package:mobile/views/widgets/stock_out/cresate_stock_out/stock_card.dart';
import '../../models/create_stockout.dart';
import '../../repositories/create_stockout_repository.dart';

class CreateStockOutPage extends StatefulWidget {
  final int resellerId;

  const CreateStockOutPage({Key? key, required this.resellerId})
    : super(key: key);

  @override
  State<CreateStockOutPage> createState() => _CreateStockOutPageState();
}

class _CreateStockOutPageState extends State<CreateStockOutPage> {
  // Dependencies
  final StockRepository _stockRepository = StockRepository();
  final TextEditingController _searchController = TextEditingController();

  // State variables
  List<StockItem> _allStocks = [];
  List<StockItem> _filteredStocks = [];
  List<StockOutCartItem> _cartItems = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stockRepository.dispose();
    super.dispose();
  }

  // ========== Data Loading Methods ==========

  /// Loads stocks from API
  Future<void> _loadStocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stockResponse = await _stockRepository.fetchStocks(
        widget.resellerId,
      );

      setState(() {
        _allStocks = stockResponse.details;
        _filteredStocks = stockResponse.details;
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

  /// Refreshes stock data
  Future<void> _refreshStocks() async {
    await _loadStocks();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  // ========== Search and Filter Methods ==========

  /// Searches and filters stocks based on query and category
  void _searchAndFilter(String query) {
    setState(() {
      var filtered = _allStocks;

      // Apply category filter
      if (_selectedCategory != 'Semua') {
        filtered = filtered
            .where((s) => s.categoryName == _selectedCategory)
            .toList();
      }

      // Apply search query
      if (query.isNotEmpty) {
        filtered = filtered.where((s) {
          return s.productName.toLowerCase().contains(query.toLowerCase()) ||
              s.categoryName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      _filteredStocks = filtered;
    });
  }

  /// Filters stocks by category
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchAndFilter(_searchController.text);
    });
  }

  /// Gets unique categories from all stocks
  List<String> get _categories {
    final categories = _allStocks.map((s) => s.categoryName).toSet().toList();
    categories.sort();
    return ['Semua', ...categories];
  }

  // ========== Cart Management Methods ==========

  /// Adds a stock item to cart
  void _addToCart(StockItem stock) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.stock.idProduct == stock.idProduct,
      );

      if (existingIndex >= 0) {
        if (_cartItems[existingIndex].quantity < stock.currentStock) {
          _cartItems[existingIndex].quantity++;
          _showSuccessSnackBar('Jumlah ${stock.productName} ditambahkan');
        } else {
          _showErrorSnackBar('Stok tidak mencukupi');
        }
      } else {
        _cartItems.add(StockOutCartItem(stock: stock, quantity: 1));
        _showSuccessSnackBar('${stock.productName} ditambahkan ke daftar');
      }
    });
  }

  /// Removes an item from cart
  void _removeFromCart(int index) {
    setState(() {
      final productName = _cartItems[index].stock.productName;
      _cartItems.removeAt(index);
      _showSuccessSnackBar('$productName dihapus dari daftar');
    });
  }

  /// Updates cart item quantity
  void _updateCartQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    final maxQuantity = _cartItems[index].stock.currentStock;
    if (newQuantity > maxQuantity) {
      _showErrorSnackBar('Stok tidak mencukupi');
      return;
    }

    setState(() {
      _cartItems[index].quantity = newQuantity;
    });
  }

  /// Calculates total items in cart
  int get _totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // ========== Submission Methods ==========

  /// Submits stock out request
  Future<void> _submitStockOut() async {
    if (_cartItems.isEmpty) {
      _showErrorSnackBar('Daftar stok keluar kosong');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreateStockOutRequest(details: _cartItems);
      final response = await _stockRepository.createStockOut(
        resellerId: widget.resellerId,
        request: request,
      );

      _showSuccessSnackBar(response.message);

      // Show success dialog and navigate back
      await _showSuccessDialog(response.idStockOut);
    } on ApiException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Gagal mencatat stok keluar');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Shows confirmation dialog before submitting
  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800)),
            SizedBox(width: 8),
            Text('Konfirmasi Stok Keluar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total produk: ${_cartItems.length} jenis'),
            Text('Total item: $_totalItems pcs'),
            SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin mengeluarkan stok ini?',
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
              backgroundColor: Color(0xFFFF9800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Ya, Keluarkan'),
          ),
        ],
      ),
    );
  }

  /// Shows success dialog after submission
  Future<void> _showSuccessDialog(int stockOutId) {
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
            Text('Stok keluar berhasil dicatat'),
            SizedBox(height: 8),
            Text('ID Stock Out: #$stockOutId'),
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

  // ========== UI Helper Methods ==========

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows cart bottom sheet
  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(
        cartItems: _cartItems,
        totalItems: _totalItems,
        isSubmitting: _isSubmitting,
        onUpdateQuantity: (index, quantity) {
          setState(() {
            _updateCartQuantity(index, quantity);
          });
        },
        onSubmit: () {
          Navigator.pop(context);
          _submitStockOut();
        },
      ),
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
            _buildAppBar(),
            _buildSearchBar(),
            if (!_isLoading && _allStocks.isNotEmpty)
              CategoryFilter(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: _filterByCategory,
              ),
            _buildStocksList(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds custom app bar
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFFFA726)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stok Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Catat barang yang keluar',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _isLoading ? null : _refreshStocks,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.refresh, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds search bar
  Widget _buildSearchBar() {
    return Padding(
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
          onChanged: _searchAndFilter,
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            hintStyle: TextStyle(color: Color(0xFF999999)),
            prefixIcon: Icon(Icons.search, color: Color(0xFFFF9800)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  /// Builds stocks list based on current state
  Widget _buildStocksList() {
    return Expanded(
      child: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _filteredStocks.isEmpty
          ? _buildEmptyState()
          : _buildStocksListView(),
    );
  }

  /// Builds loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat stok...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadStocks,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF9800),
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

  /// Builds empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF999999)),
          SizedBox(height: 16),
          Text(
            'Stok tidak ditemukan',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Builds stocks list view with refresh indicator
  Widget _buildStocksListView() {
    return RefreshIndicator(
      onRefresh: _refreshStocks,
      color: Color(0xFFFF9800),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filteredStocks.length,
        itemBuilder: (context, index) {
          final stock = _filteredStocks[index];
          final inCart = _cartItems.any(
            (item) => item.stock.idProduct == stock.idProduct,
          );
          return StockCard(
            stock: stock,
            inCart: inCart,
            onAddToCart: () => _addToCart(stock),
          );
        },
      ),
    );
  }

  /// Builds floating action button for cart
  Widget? _buildFloatingActionButton() {
    if (_cartItems.isEmpty) return null;

    return FloatingActionButton.extended(
      onPressed: _showCartBottomSheet,
      backgroundColor: Color(0xFFFF9800),
      icon: Stack(
        children: [
          Icon(Icons.assignment_turned_in),
          if (_cartItems.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${_cartItems.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: Text('Daftar ($_totalItems)'),
    );
  }
}
