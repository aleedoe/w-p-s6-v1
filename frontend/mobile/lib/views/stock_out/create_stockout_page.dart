// lib/pages/create_stockout_page.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_client.dart';
import '../../models/create_stockout.dart';
import '../../repositories/create_stockout_repository.dart';

class CreateStockOutPage extends StatefulWidget {
  final int resellerId;

  const CreateStockOutPage({Key? key, required this.resellerId}) : super(key: key);

  @override
  State<CreateStockOutPage> createState() => _CreateStockOutPageState();
}

class _CreateStockOutPageState extends State<CreateStockOutPage> {
  final StockRepository _stockRepository = StockRepository();
  final TextEditingController _searchController = TextEditingController();

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

  // Load stocks from API
  Future<void> _loadStocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stockResponse = await _stockRepository.fetchStocks(widget.resellerId);

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

  // Refresh stocks
  Future<void> _refreshStocks() async {
    await _loadStocks();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  // Search and filter stocks
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

  // Filter by category
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchAndFilter(_searchController.text);
    });
  }

  // Add to cart
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

  // Remove from cart
  void _removeFromCart(int index) {
    setState(() {
      final productName = _cartItems[index].stock.productName;
      _cartItems.removeAt(index);
      _showSuccessSnackBar('$productName dihapus dari daftar');
    });
  }

  // Update cart item quantity
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

  // Calculate total
  int get _totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Submit stock out
  Future<void> _submitStockOut() async {
    if (_cartItems.isEmpty) {
      _showErrorSnackBar('Daftar stok keluar kosong');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
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
              Text('Stok keluar berhasil dicatat'),
              SizedBox(height: 8),
              Text('ID Stock Out: #${response.idStockOut}'),
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
      _showErrorSnackBar('Gagal mencatat stok keluar');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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

  // Get unique categories
  List<String> get _categories {
    final categories = _allStocks.map((s) => s.categoryName).toSet().toList();
    categories.sort();
    return ['Semua', ...categories];
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
                  colors: [Color(0xFFFF9800), Color(0xFFFFA726)],
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
            ),

            // Category Filter
            if (!_isLoading && _allStocks.isNotEmpty)
              Container(
                height: 50,
                margin: EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () => _filterByCategory(category),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFFF9800) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Color(0xFF666666),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Stocks List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF9800),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat stok...',
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
                            onPressed: _loadStocks,
                            icon: Icon(Icons.refresh),
                            label: Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF9800),
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
                  : _filteredStocks.isEmpty
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
                            'Stok tidak ditemukan',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
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
                          return _buildStockCard(stock, inCart);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                _showCartBottomSheet();
              },
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
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
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
            )
          : null,
    );
  }

  Widget _buildStockCard(StockItem stock, bool inCart) {
    final isOutOfStock = stock.currentStock <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2,
                color: Color(0xFFFF9800),
                size: 32,
              ),
            ),
            SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.productName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    stock.categoryName,
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rp ${_formatPrice(stock.price)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? Color(0xFFF44336).withOpacity(0.1)
                              : Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOutOfStock ? 'Habis' : 'Stok: ${stock.currentStock}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock
                                ? Color(0xFFF44336)
                                : Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add Button
            GestureDetector(
              onTap: isOutOfStock ? null : () => _addToCart(stock),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? Color(0xFF999999)
                      : inCart
                      ? Color(0xFF2196F3)
                      : Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isOutOfStock
                      ? []
                      : [
                          BoxShadow(
                            color:
                                (inCart ? Color(0xFF2196F3) : Color(0xFFFF9800))
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  inCart ? Icons.check : Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                          Icons.assignment_turned_in,
                          color: Color(0xFFFF9800),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Daftar Stok Keluar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_cartItems.length} Produk',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),

              // Cart Items
              Expanded(
                child: _cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Color(0xFF999999),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Daftar masih kosong',
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
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = _cartItems[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Product Icon
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF9800).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Color(0xFFFF9800),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),

                                // Product Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.stock.productName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Stok tersedia: ${cartItem.stock.currentStock}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity Controls
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _updateCartQuantity(
                                            index,
                                            cartItem.quantity - 1,
                                          );
                                        });
                                        setModalState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF44336),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                        '${cartItem.quantity}',
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
                                          _updateCartQuantity(
                                            index,
                                            cartItem.quantity + 1,
                                          );
                                        });
                                        setModalState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFF9800),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                          'Total Item',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          '$_totalItems pcs',
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
                          'Total Produk',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          '${_cartItems.length} jenis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
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
                                Navigator.pop(context);
                                _submitStockOut();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF9800),
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
                                  Icon(Icons.assignment_turned_in_outlined),
                                  SizedBox(width: 8),
                                  Text(
                                    'Catat Stok Keluar',
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

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }}