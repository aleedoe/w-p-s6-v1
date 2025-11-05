// ============================================
// FILE 2: lib/controllers/stock_page_controller.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/models/stock_detail.dart';
import 'package:mobile/repositories/stock_repository.dart';
import 'package:mobile/services/api_client.dart';

/// Controller untuk mengelola logika state dan business logic halaman stok
class StockPageController extends ChangeNotifier {
  final StockRepository _stockRepository;
  final int? _resellerId;

  StockResponse? _stockData;
  List<StockDetail> _filteredProducts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  StockPageController({int? resellerId, StockRepository? stockRepository})
    : _resellerId = resellerId,
      _stockRepository = stockRepository ?? StockRepository();

  // Getters
  StockResponse? get stockData => _stockData;
  List<StockDetail> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Memuat data stok dari repository
  Future<void> loadStockData() async {
    _setLoading(true);
    _clearError();

    try {
      final stockData = await _stockRepository.fetchStock(
        resellerId: _resellerId,
      );
      _stockData = stockData;
      _filteredProducts = stockData.details;
      _searchQuery = '';
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Terjadi kesalahan yang tidak terduga');
    }

    _setLoading(false);
  }

  /// Memuat ulang data stok
  Future<void> refreshStockData() async {
    await loadStockData();
  }

  /// Mencari produk berdasarkan query
  void searchProducts(String query) {
    _searchQuery = query;

    if (_stockData == null) return;

    if (query.isEmpty) {
      _filteredProducts = _stockData!.details;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredProducts = _stockData!.details
          .where(
            (product) =>
                product.productName.toLowerCase().contains(lowerQuery) ||
                product.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }

    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _stockRepository.dispose();
    super.dispose();
  }
}
