import 'package:flutter/material.dart';
import 'package:mobile/repositories/product_repository.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/utils/price_formatter.dart';
import 'package:mobile/views/widgets/order/create_order/cart_bottom_sheet.dart';
import 'package:mobile/views/widgets/order/create_order/order_app_bar.dart';
import 'package:mobile/views/widgets/order/create_order/product_card.dart';
import 'package:mobile/views/widgets/order/create_order/product_search_bar.dart';
import '../../models/product.dart';

class CreateOrderPage extends StatefulWidget {
  final int resellerId;

  const CreateOrderPage({Key? key, required this.resellerId}) : super(key: key);

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final ProductRepository _productRepository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<CartItem> _cartItems = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productRepository.dispose();
    super.dispose();
  }

  // Load products from API
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productRepository.fetchProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('Terjadi kesalahan yang tidak terduga');
    }
  }

  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
    _showErrorSnackBar(message);
  }

  // Refresh products
  Future<void> _refreshProducts() async {
    await _loadProducts();
    if (_errorMessage == null) {
      _showSuccessSnackBar('Data berhasil diperbarui');
    }
  }

  // Search and filter products
  void _searchAndFilter(String query) {
    setState(() {
      var filtered = _allProducts;

      // Apply search query
      if (query.isNotEmpty) {
        filtered = filtered.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      _filteredProducts = filtered;
    });
  }


  // Cart management methods
  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        if (_cartItems[existingIndex].quantity < product.quantity) {
          _cartItems[existingIndex].quantity++;
          _showSuccessSnackBar('Jumlah ${product.name} ditambahkan');
        } else {
          _showErrorSnackBar('Stok tidak mencukupi');
        }
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
        _showSuccessSnackBar('${product.name} ditambahkan ke keranjang');
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      final productName = _cartItems[index].product.name;
      _cartItems.removeAt(index);
      _showSuccessSnackBar('$productName dihapus dari keranjang');
    });
  }

  void _updateCartQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    final maxQuantity = _cartItems[index].product.quantity;
    if (newQuantity > maxQuantity) {
      _showErrorSnackBar('Stok tidak mencukupi');
      return;
    }

    setState(() {
      _cartItems[index].quantity = newQuantity;
    });
  }

  // Calculate totals
  double get _totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  int get _totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Snackbar helpers
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

  // Build product list
  Widget _buildProductList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return _buildProductGrid();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat produk...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
          SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: Icon(Icons.refresh),
            label: Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF999999)),
          SizedBox(height: 16),
          Text('Produk tidak ditemukan'),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      color: Color(0xFF4CAF50),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          final inCart = _cartItems.any(
            (item) => item.product.id == product.id,
          );

          return ProductCard(
            product: product,
            inCart: inCart,
            onAddToCart: () => _addToCart(product),
          );
        },
      ),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(
        cartItems: _cartItems,
        totalPrice: _totalPrice,
        totalItems: _totalItems,
        isSubmitting: _isSubmitting,
        onUpdateQuantity: _updateCartQuantity,
        onRemoveItem: _removeFromCart,
        onSubmitOrder: _submitOrder,
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_cartItems.isEmpty) {
      _showErrorSnackBar('Keranjang kosong');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('Konfirmasi Pesanan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total produk: ${_cartItems.length} jenis'),
            Text('Total item: $_totalItems pcs'),
            SizedBox(height: 8),
            Text(
              'Total: Rp ${PriceFormatter.format(_totalPrice)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin membuat pesanan ini?',
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
              backgroundColor: Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Ya, Buat Pesanan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreateTransactionRequest(details: _cartItems);
      final response = await _productRepository.createTransaction(
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
              Text('Pesanan berhasil dibuat'),
              SizedBox(height: 8),
              Text('ID Transaksi: #${response.transaction.idTransaction}'),
              Text('Status: ${response.transaction.status}'),
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
      _showErrorSnackBar('Gagal membuat pesanan');
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
            OrderAppBar(
              isLoading: _isLoading,
              onBackPressed: () => Navigator.pop(context),
              onRefreshPressed: _refreshProducts,
            ),

            // Search Bar
            ProductSearchBar(
              controller: _searchController,
              onChanged: _searchAndFilter,
            ),


            // Products List
            Expanded(child: _buildProductList()),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showCartBottomSheet,
              backgroundColor: Color(0xFF4CAF50),
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart),
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
                        child: Text(
                          '${_cartItems.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: Text('Keranjang ($_totalItems)'),
            )
          : null,
    );
  }
}
